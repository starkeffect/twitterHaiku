import rita.*;
import java.util.*;

ArrayList<String> vocab;
int vocabLimit;
Set<String> dict;
float updateInterval;
Twitter twitter;
Query query;
float[] location;

void setup()
{
  size(800, 800);
  background(0);
  stroke(255);
  smooth(12);
  frameRate(12);
  
  // Set update interval in minutes
  updateInterval = 30;
  
  // Data Strcuture for storing valid vocabulary
  vocab = new ArrayList<String>();
  
  // Setting the maximum vocabulary size
  vocabLimit = 10000;
  
  // Constructing offline dictionary
  String[] dictWords = loadStrings("/usr/share/dict/web2");
  dict = new HashSet<String>(Arrays.asList(dictWords));
  
  // Reading app credentials from file
  String[] creds = loadStrings("credentials.txt");
  
  // Current location (need to automate this !!!)
  getLocation();
  
  // Configuring the credentials
  ConfigurationBuilder cb = new ConfigurationBuilder();
  cb.setOAuthConsumerKey(split(creds[0], ':')[1]);
  cb.setOAuthConsumerSecret(split(creds[1], ':')[1]);
  cb.setOAuthAccessToken(split(creds[2], ':')[1]);
  cb.setOAuthAccessTokenSecret(split(creds[3], ':')[1]);
  
  // Building the twitter object using TwitterFactory
  twitter = new TwitterFactory(cb.build()).getInstance();
  
  // Setting up query requirements
  query = new Query();
  query.setCount(100); // Limiting number of results
  query.setLang("en"); // Limiting results to English
  
  // Update vocabulary with the set of queries
  // Last argument is a flag: 0 - create, 1 - update
  updateVocab();
  
  // Building a Markov Chain from the initial state vocabulary
  markovChain mc = new markovChain(vocab);
  println("Markov Chain Initialized!");
  HashMap<String, ArrayList<augString>> markovHash = mc.buildMarkov();
  println("Markov Chain Built!");
  mc.writeMarkovToFile("markov.txt");
  // Getting a random next word
  String s = mc.getNext("i");
  println(s);
  
    
  String[] haiku = generateHaiku(vocab);
  
}

void draw()
{
  pushStyle();
  noStroke();
  fill(0, 30);
  rect(0, 0, width, height);
  popStyle();
  
  
  for(int i=0; i<20; i++)
  {
    textSize(random(15, 25));
    text(vocab.get(int(random(1, vocab.size()))), random(width), random(height));
  }
  
  /*if(minute() % updateInterval == 0) // If reached the update interval
  {
    println("Updating Now!!");
    // Update the vocabulary: launching on a new thread
    thread("updateVocab");
    println("Vocabulary Updated");
  }*/
}

float[] getLocation()
{
   location = new float[2]; // [latitude, longitude]
   // Accessing location data
   processing.data.JSONObject json;
   json = loadJSONObject("http://ipinfo.io/json");
   // Parsing location data
   String loc = json.getString("loc");
   location[0] = float(loc.split(",")[0]);
   location[1] = float(loc.split(",")[1]);
   
   return location;
}

ArrayList<String> findTrendingTopic()
{
  float latitude = location[0], longitude = location[1];
  ArrayList<String> trendingTopicNames = new ArrayList<String>();
  
  // Setting up the current location
  GeoLocation location = new GeoLocation(latitude, longitude);
  
  // Getting closest available trend locations
  TrendsResources trends = twitter.trends();
  try
  {
    ResponseList<Location> trendLocations = trends.getClosestTrends(location);
    // Finding top 10 trending topics for the current location
    Trends localTrends = trends.getPlaceTrends(trendLocations.get(0).getWoeid());
    Trend[] trendingTopics = localTrends.getTrends();
    // Extracting topic names
    for(Trend t: trendingTopics) trendingTopicNames.add(t.getName());
  }
  catch(TwitterException trLoc)
  {
    println("Couldn't process the location-based trend query: " + trLoc);
  }
  return trendingTopicNames;
}

void processQuery()
{
  // Processing the query
  try
  {
    QueryResult result = twitter.search(query);
    ArrayList tweets = (ArrayList)result.getTweets();
    for(int i=0; i<tweets.size(); i++)
    {
      Status t = (Status)tweets.get(i);
      String content = t.getText();
      content = content.toLowerCase();
      content = RiTa.stripPunctuation(content);
      RiString tweet = new RiString(content);
      
      // Splitting the tweet into words and identifying parts of speech
      String[] tokens = tweet.words();
      String[] pos = tweet.pos();
      
      // Looping over tokens for textual analysis
      for (int j = 0;  j < tokens.length; j++) 
      {
         //Put each word into the vocab ArrayList
         //vocab.add(tokens[j]);
         if(checkWord(tokens[j], pos[j]) == true) 
         {
           // Over the limit - need to remove a part of the older vocabulary
           if(vocab.size() > vocabLimit) reduceVocab(vocab.size() - vocabLimit, 10);
           vocab.add(tokens[j]); 
         }
      }
      vocab.add("-");
     }
   }
  catch(TwitterException twEx)
  {
    println("Couldn't process the search query: " + twEx);
  }
}

boolean checkWord(String word, String pos)
{
  // Check 1: Check if the word is a part of weblink
  if(word.startsWith("https")) return false;
  
  // Check 2: Check if the word is a number
  if(pos == "cd") return false;
  
  // Check 3: Check if the word is a valid noun
  if((pos == "nn" || pos == "nns") && !dict.contains(word)) return false;
 
  // If made it through all the checks above, then the string "word" is indeed a word.
  return true; 
}

void updateVocab()
{
  // Finding query strings corresponding to trending topics
  ArrayList<String> queryString = findTrendingTopic();
  
  for(String qstr: queryString)
  {
    query.setQuery(qstr);
    processQuery();
  }
}

void reduceVocab(int overflow, int factor)
{
  // overflow: number of words above the vocab limit
  // factor: the excess factor by which the overflow should be removed
  int removeLimit = overflow * factor;
  int removeCount = 0;
  
  // Remove words till the overflow limit 
  while(removeCount <= removeLimit)
  {
    vocab.remove(0);
    removeCount += 1;
  }
  
  // Find the nearest end of tweet ("-") and remove till that point
  while(vocab.get(0) != "-")
  {
    vocab.remove(0);
  }
  vocab.remove(0); // to remove the "-" itself
}
import rita.*;
import java.util.*;
import java.net.InetAddress;

ArrayList<String> vocab;
Set<String> dict;

void setup()
{
  size(800, 800);
  background(0);
  stroke(255);
  smooth(12);
  frameRate(12);
  
  // Data Strcuture for storing valid vocabulary
  vocab = new ArrayList<String>();
  
  // Constructing offline dictionary
  String[] dictWords = loadStrings("/usr/share/dict/web2");
  dict = new HashSet<String>(Arrays.asList(dictWords));
  
  // Reading app credentials from file
  String[] creds = loadStrings("credentials.txt");
  
  // Current location (need to automate this !!!)
  float[] location = getLocation();
  float latitude = 35.997563;
  float longitude = -78.922561;
  
  // Configuring the credentials
  ConfigurationBuilder cb = new ConfigurationBuilder();
  cb.setOAuthConsumerKey(split(creds[0], ':')[1]);
  cb.setOAuthConsumerSecret(split(creds[1], ':')[1]);
  cb.setOAuthAccessToken(split(creds[2], ':')[1]);
  cb.setOAuthAccessTokenSecret(split(creds[3], ':')[1]);
  
  // Building the twitter object using TwitterFactory
  Twitter twitter = new TwitterFactory(cb.build()).getInstance();
  
  // Setting up a search query
  ArrayList<String> queryString = findTrendingTopic(twitter, latitude, longitude);
  Query query = new Query(queryString.get(0));
  query.setCount(100); // Limiting number of results
  query.setLang("en");
  
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
       if(checkWord(tokens[j], pos[j]) == true) vocab.add(tokens[j]);
      }
    }
    String[] haiku = generateHaiku(vocab);
  }
  catch(TwitterException twEx)
  {
    println("Couldn't process the search query: " + twEx);
  }
}

void draw()
{
  pushStyle();
  noStroke();
  fill(0, 30);
  rect(0, 0, width, height);
  popStyle();
  
  for(int i=0; i<50; i++)
  {
    textSize(random(8, 15));
    text(vocab.get(int(random(vocab.size()))), random(width), random(height));
  }
  //noLoop();
}

ArrayList<String> findTrendingTopic(Twitter twitter, float latitude, float longitude)
{
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
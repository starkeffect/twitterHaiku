class markovChain
{
   // MC = Markov Chain
   // Data structure holding the actual MC mappings
   HashMap<String, ArrayList<augString>> mc;
   // Corpus using which the MC is generated
   ArrayList<String> corpus;  
   
   // Constructor
   markovChain(ArrayList<String> c)
   {
     mc = new HashMap<String, ArrayList<augString>>();
     corpus = c;
   }
   
   HashMap<String, ArrayList<augString>> buildMarkov()
   {
      // Iterating over all the words in the most recent corpus
      for(int i=0; i<corpus.size()-1; i++)
      {
        if(corpus.get(i) == "-") continue;
        
        // First occurence of the word; simply add it to the mc hashtable with frequency 1
        if(mc.get(corpus.get(i)) == null)
        {
          ArrayList<augString> value = new ArrayList<augString>();
          // Appending the object [word, frequency = 1] to the value object
          augString word = new augString(corpus.get(i+1), 1);
          value.add(word);
          // Putting value into the mc Hashtable
          mc.put(corpus.get(i), value);
        }
        
        // Word is already present; update the value in the hashmap
        else
        {
           // Get the currrent value
           ArrayList<augString> value = mc.get(corpus.get(i));
           // Add the connected word to the value
           int found = 0;
           for(int j=0; j<value.size(); j++)
           {
              if(value.get(j).word.equals(corpus.get(i+1)) ==  true)
              {
                 // If found in "value", update the frequency
                 //println("old word found!!");
                 //println(value.get(j).word + "  " + corpus.get(i+1));
                 value.get(j).freq += 1;
                 found = 1;
                 break;
              }
            }
           // If not found in value, add the connected word
           if(found == 0) value.add(new augString(corpus.get(i+1), 1));
           // Replacing the entry in the Markov Chain "mc"
           mc.put(corpus.get(i), value);
         }
      }
      // Returning the constructed Markov Chain
      return mc;
   }
   
   // mode 0: random; mode 1: most frequent
   String getNext(String word, int mode)
   {
     String nextWord;
     if(mc.get(word) == null) nextWord = "-"; // Entry not found in the Markov Chain
     else
     {
        ArrayList<augString> value = mc.get(word);
        augString next = new augString(" ", 0);
        
        if(mode == 0) nextWord = value.get(int(random(0, value.size() - 1))).word;
        else
        {
          // Finding the highest frequency (most probable) follower
          //for(augString s: value)
          //{
            //if(s.freq > next.freq && s.word.equals("-") == false) next = s;
          //}
          //nextWord = next.word;
          next = value.get(0);
          nextWord = next.word;
        }
     }
     return nextWord;
   }
   
   void sortMarkov()
   {
     for(Map.Entry entry : mc.entrySet())
     {
       String k = entry.getKey().toString();;
       ArrayList<augString> value = mc.get(entry.getKey());
       ArrayList<augString> sortedValue = new ArrayList<augString>();
       String[] words = new String[value.size()];
       float[] freqs = new float[value.size()];
       
       // Extracting the words and frequencies to sort
       for(int i=0; i<value.size(); i++)
       {
         words[i] = value.get(i).word;
         freqs[i] = value.get(i).freq;
       }
       
       // Sorting the words according to frequency (using selection sort for now)
       String tempstr; float tempfreq;
       for(int i=0; i<value.size() - 1; i++)
       {
         for(int j=i+1; j<value.size(); j++)
         {
           if(freqs[j] > freqs[i])
           {
             // Swap
             tempfreq = freqs[i];
             freqs[i] = freqs[j];
             freqs[j] = tempfreq;
             
             tempstr = words[i];
             words[i] = words[j];
             words[j] = tempstr;
           }
         }
       }
       
       // Putting the sorted value back into the Markov Chain
       for(int i=0; i<value.size(); i++)
       {
         sortedValue.add(new augString(words[i], freqs[i])); 
       }
       mc.put(k, sortedValue);
     }
   }
   
   void writeMarkovToFile(String fileName)
   {
     // Writes the Markov Chain for debugging purposes
     PrintWriter outStream = createWriter(fileName);
     
     // Looping over the mc HashMap
     for(Map.Entry entry : mc.entrySet())
     {
       outStream.print(entry.getKey() + "  >>  ");
       for(augString s: mc.get(entry.getKey()))
       {
         outStream.print("[ " + s.word + ", " + s.freq + " ]" + "   ");
       }
       outStream.print("\n\n");
     }
     outStream.flush();
     outStream.close();
   }
   
   void writeMarkovtoJSON(String fileName)
   {
    int i;
    
    // Creating the JSON object to hold the Markov Chain
    processing.data.JSONObject mrkv = new processing.data.JSONObject();
    
    // Looping over the mc HashMap
    for(Map.Entry entry : mc.entrySet())
    {
      processing.data.JSONArray values = new processing.data.JSONArray();
      i = 0;
      for(augString s: mc.get(entry.getKey()))
      {
        processing.data.JSONObject wfpair = new processing.data.JSONObject();
        wfpair.setFloat(s.word, s.freq);
        values.setJSONObject(i++, wfpair);
      }
      mrkv.setJSONArray(entry.getKey().toString(), values);
    }
    
    // Writing JSON to file
    saveJSONObject(mrkv, fileName);
   }
}
 
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
   
   String getNext(String word)
   {
     String nextWord;
     if(mc.get(word) == null) nextWord = "-"; // Entry not found in the Markov Chain
     else
     {
        ArrayList<augString> value = mc.get(word);
        augString next = new augString(" ", 0);
        // Finding the highest frequency (most probable) follower
        for(augString s: value)
        {
          if(s.freq > next.freq && s.word.equals("-") == false) next = s;
        }
        nextWord = next.word;
     }
     return nextWord;
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
}
 
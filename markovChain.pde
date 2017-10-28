class markovChain
{
   // MC = Markov Chain
   // Data structure holding the actual MC mappings
   HashMap<String, ArrayList<augString>> mc;
   // Corpus using which the MC is generated
   ArrayList<String> corpus;
   // Order of the MC
   int order;
   
   
   // Constructor
   markovChain(ArrayList<String> c, int n)
   {
     mc = new HashMap<String, ArrayList<augString>>();
     corpus = c;
     order  = n;
   }
   
   HashMap<String, ArrayList<augString>> buildMarkov()
   {
      for(int i=order; i<corpus.size(); i++)
      {
        // Iterating over all the words in the most recent corpus
        if(mc.get(corpus.get(i)) == null)
        {
          // First occurence of the word
          ArrayList<augString> value = new ArrayList<augString>();
          // Appending the object [word, frequency = 1] to the value object
          for(int j=1; j<=order; j++)
          {
            augString word = new augString(corpus.get(i-j), 1);
            value.add(word);
          }
          // Putting value into the mc Hashtable
          mc.put(corpus.get(i), value);
        }
        else
        {
           // If word is already present, update the value in the hashmap
           ArrayList<augString> value = mc.get(corpus.get(i));
           for(int j=1; j<=order; j++)
           {
             // Take all the connected words to that entry and update their frequency values
             int found = 0;
             for(augString s: value)
             {
               if(s.word == corpus.get(i-j))
               {
                 // If found in value, update the frequency
                 s.freq += 1;
                 found = 1;
                 break;
               }
             }
             // If not found in value, add the connected word
             if(found == 0) value.add(new augString(corpus.get(i-j), 1));
           }
           mc.put(corpus.get(i), value);
        }
      }
      // Returning the constructed Markov Chain
      return mc;
   }
   
   void writeMarkovToFile(String fileName)
   {
     // Writes the Markov Chain for debugging purposes
     PrintWriter outStream = createWriter(fileName);
     
     // Looping over the mc HashMap
     for(Map.Entry entry : mc.entrySet())
     {
       outStream.print(entry.getKey() + "  <<  ");
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
 
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
   
   void buildMarkov()
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
      }
   }
}
 
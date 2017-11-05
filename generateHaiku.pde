String[] generateHaiku(markovChain markov, String seed)
{
  // Check if the seed is present in the Markov Chain; if not, return a null pointer
  if(markov.mc.get(seed) == null) return null;
  
  // 3 lines of 5-7-5 syllables.
  int[] syllCount = {5, 7, 5};
  
  // Check the number of syllables in the seed
  int nSeed = RiTa.getSyllables(seed).split("/").length; 
  
  // The array containing the returned haiku
  String[] haiku = {"", "", ""};
  syllCount[0] -= nSeed;
  haiku[0] += seed + " ";
  
  // Generating syllable combinations for each line
  int count;
  String next;
  for(int i=0; i<syllCount.length; i++)
  {
    while(syllCount[i] > 0)
    {
      // Find the next word for a given number of syllables
      do
      {
        count = int(random(1, syllCount[i]));
        next = mc.getNext(seed, 1);
      } while(RiTa.getSyllables(next).split("/").length != count);
      
      haiku[i] += next + " ";
      syllCount[i] -= count;
      seed = next;
     }
     
     // The line ended; need to find a related seed for the next line
     
     seed = markov.getNext(seed, 0);
  }
  
  return haiku;
}
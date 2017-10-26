// An augmented String datatype that stores a "string" and a "float" together
class augString
{
  private String word;
  private float freq;
  
  augString(String w, float f)
  {
    word = w;
    freq = f;
  }
  
  String getStr()
  {
    return word;
  }
  
  float getFreq()
  {
    return freq;
  }
}
    
package com.kitten.util {
  
  public class MathUtil {

    /**
    * Get a random integer from a given interval.
    */
    public static function randInt(max:int, min:int = 0):int {
      return Math.floor(Math.random() * (max - min)) + min; 
    }

  }
  
}

package com.kitten.util {
  
  public class MathUtil {

    public static function randInt(max:int, min:int = 0):int {
      return Math.floor(Math.random() * (max - min)) + min; 
    }

  }
  
}
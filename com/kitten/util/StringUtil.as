package com.kitten.util {

  public class StringUtil {
    
    private static var _letters:String = 'abcdefghijklmnopqrstuvwxyz';
    private static var _digits:String  = '0123456789';
    private static var _signs:String   = ' _-(){}[]';
    
    public static var LETTERS:uint = 1;
    public static var DIGITS:uint  = 2;
    public static var SIGNS:uint   = 4;
    
    public static function getRandomSequence(length:uint = 8, variationSet:uint = 1/* = LETTERS */):String {
      var chars:String = '';
      
      if (variationSet & LETTERS) {
        chars = chars.concat(_letters);
      }
      
      if (variationSet & DIGITS) {
        chars = chars.concat(_digits);
      } 
      
      if (variationSet & SIGNS) {
        chars = chars.concat(_signs);
      }
      
      var charsLength:uint = chars.length;
      var output:String = '';
      for (var i:uint = 0; i < length; i++) {
        output = output.concat(chars.charAt(MathUtil.randInt(charsLength)));
      }
      
      return output;
    }

  }
  
}
package {
  
  import com.hurlant.crypto.Crypto;
  import com.hurlant.crypto.hash.HMAC;
  import com.hurlant.util.Hex;
  import com.kitten.network.Connection;
  import com.kitten.util.StringUtil;
  
  import flash.display.Sprite;
  import flash.utils.ByteArray;

  public class Kitten extends Sprite {
    
    private var c:Connection;
    
    public function Kitten() {
      /*
      Use cases
      
      // CREATION
      var c:Connection = new Connection();
      var c:Connection = new Connection('http://example.org/');
      
      // AUTHENTICATION
      c.setSessionAuthentication(); // default TRUE
      c.setSessionAuthentication(TRUE);
      c.setSessionAuthentication(FALSE);
      
      c.setAPIKeyAuthentication(); // Default TRUE
      c.setAPIKeyAuthentication(TRUE);
      c.setAPIKeyAuthentication(FALSE);
      
      c.setApiKey('KEY');
      
      // CALL METHOD
      c.call('system', 'connect');
      c.call('user', 'get', 1);
      */
     
      c = new Connection('http://l/drupal_graphmind/services/amfphp');
      c.isSessionAuthentication = true;
      c.setAPIKey('c50a5a0e65c8dc2bef247733bda3a8c6', 'localhost');
      c.connectToSession(res);
      

    }
    
    private function res(result:Object):void {
      trace('result');
      trace(result);
      c.call('foo.bar', res2, 'aaa', 'bbb');
    }
    
    private function res2(result:Object):void {
      trace('result 2');
      trace(result);
    }
    
  }
}

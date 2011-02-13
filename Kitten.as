package {
  
  import flash.display.Sprite;
  import flash.events.IOErrorEvent;
  import flash.events.NetStatusEvent;
  import flash.net.NetConnection;
  import flash.net.NetStream;
  import flash.net.ObjectEncoding;

  public class Kitten extends Sprite {
    
    private var nc:NetConnection;
    
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
      
//      var c:Connection = new Connection('http://l/drupal_graphmind/services/amfphp', foo);
//      c.call('system.connect');
      
      trace('NC');
      nc = new NetConnection();
      nc.client = this;
      nc.addEventListener(IOErrorEvent.IO_ERROR, ioError);
      nc.addEventListener(NetStatusEvent.NET_STATUS, NSnetStatus);
      nc.objectEncoding = ObjectEncoding.AMF3;
      nc.connect('http://l/drupal_graphmind/services/amfphp');
      
      //ns.objectEncoding = ObjectEncoding.AMF3;
    }
    
    private function ioError(event:IOErrorEvent):void {
      trace(event);
    }
    
    private function NSnetStatus(event:NetStatusEvent):void {
      trace(event);
      trace('NS');
      var ns:NetStream = new NetStream(nc);
      ns.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
      ns.addEventListener(IOErrorEvent.IO_ERROR, ioError);
      ns.send('system', 'connect');
    }
    
    private function netStatus(event:NetStatusEvent):void {
      trace(event);
    }
    
    private function foo(result:Object):void {
      trace('foo');
    }
    
  }
}

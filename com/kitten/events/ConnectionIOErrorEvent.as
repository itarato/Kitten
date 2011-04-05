package com.kitten.events {
  
  import com.kitten.network.Connection;
  
  import flash.events.IOErrorEvent;

  public class ConnectionIOErrorEvent extends ConnectionEvent {
  
    public static var IO_ERROR_EVENT:String = 'ioErrorEvent';
  
    public var ioErrorEvent:IOErrorEvent;
    
    public function ConnectionIOErrorEvent(type:String, connection:Connection, ioErrorEvent:IOErrorEvent) {
      this.ioErrorEvent = ioErrorEvent;
      super(type, connection);
    }
    
  }
  
}

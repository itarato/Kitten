package com.kitten.events {
  
  import com.kitten.network.Connection;
  
  import flash.events.NetStatusEvent;

  public class ConnectionNetStatusEvent extends ConnectionEvent {
    
    public static var NET_STATUS_EVENT:String = 'netStatusEvent';
    
    public var netStatusEvent:NetStatusEvent;
    
    public function ConnectionNetStatusEvent(type:String, connection:Connection, netStatusEvent:NetStatusEvent) {
      this.netStatusEvent = netStatusEvent;
      super(type, connection);
    }
    
  }
  
}

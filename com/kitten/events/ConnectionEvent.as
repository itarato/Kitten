package com.kitten.events {
  
  import com.kitten.network.Connection;
  
  import flash.events.Event;

  /**
  * Events relate to Connection.
  */
  public class ConnectionEvent extends Event {
  
    /**
    * Fired when the connection is ready and working.
    */
    public static var CONNECTION_IS_READY:String = 'connectionIsReady';
    
    /**
    * Fired when the initial connection try failed.
    */
    public static var CONNECTION_IS_FAILED:String = 'connectionIsFailed';
  
    /**
    * Connection object itself.
    */  
    public var connection:Connection;
    
    
    /**
    * Constructor.
    */
    public function ConnectionEvent(type:String, connection:Connection) {
      this.connection = connection;
      super(type);
    }
    
  }
  
}

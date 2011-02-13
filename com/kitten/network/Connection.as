package com.kitten.network {
  
  import flash.net.NetConnection;
  import flash.net.ObjectEncoding;
  import flash.net.Responder;
  
  
  public class Connection {
  
    private var _target:String;
    private var _isSessionAuthentication:Boolean;
    private var _isAPIKeyAuthentication:Boolean;
    private var _APIKey:String;
    private var _objectEncoding:uint;
    
    private var _resultCallback:Function;
    private var _statusCallback:Function;
    
    private var _netConnection:NetConnection;
    private var _responder:Responder;


    /**
     * Constructor.
     */     
    public function Connection(target:String = null, resultCallback:Function = null) {
      trace('Connection');
      
      this._netConnection = new NetConnection();
      this._netConnection.objectEncoding = ObjectEncoding.AMF3;
      
      if (target !== null) {
        this.target = target;
      }
      
      if (resultCallback !== null) {
        this.callback = resultCallback;
      }
    }
    
    
    /**********************************
     * Class methods.
     **********************************/
     
    public function call(command:String):void {
      this._netConnection.call(command, this._responder);
    }
    
    public function set callback(callback:Function):void {
      this._resultCallback = callback;
      
      this._responder = new Responder(callback, _defaultStatusHandler);
    }
    
    public function set statusCallback(statusCallback:Function):void {
      this._statusCallback = statusCallback;
    }
    
    private function _defaultStatusHandler(status:Object):void {
      trace('_defaultStatusHandler');
      
      if (this._statusCallback !== null) {
        this._statusCallback(status);
      }
    }
     
    
    /**********************************
     * Getters and setters.
     **********************************/
    
    public function set target(target:String):void {
      this._target = target;
    }
    
    public function get target():String {
      return this._target;
    }
    
    public function set isSessionAuthentication(isSessionAuthentication:Boolean):void {
      this._isSessionAuthentication = isSessionAuthentication;
    }
    
    public function get isSessionAuthentication():Boolean {
      return this._isSessionAuthentication;
    }
    
    public function set isAPIKeyAuthentication(isAPIKeyAuthentication:Boolean):void {
      this._isAPIKeyAuthentication = isAPIKeyAuthentication;
    }
    
    public function get isAPIKeyAuthentication():Boolean {
      return this._isAPIKeyAuthentication;
    }
    
    public function set APIKey(APIKey:String):void {
      this._APIKey = APIKey;
    }
    
    public function set objectEncoding(objectEncoding:uint):void {
      this._objectEncoding = objectEncoding;
    }

  }
  
}
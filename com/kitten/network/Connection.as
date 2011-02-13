package com.kitten.network {
  
  import com.hurlant.crypto.Crypto;
  import com.hurlant.crypto.hash.HMAC;
  import com.hurlant.util.Hex;
  import com.kitten.util.StringUtil;
  
  import flash.events.EventDispatcher;
  import flash.events.IOErrorEvent;
  import flash.events.NetStatusEvent;
  import flash.net.NetConnection;
  import flash.net.ObjectEncoding;
  import flash.net.Responder;
  import flash.utils.ByteArray;
  
  
  public class Connection extends EventDispatcher {
  
    private var _target:String;
    private var _isSessionAuthentication:Boolean = false;
    private var _isAPIKeyAuthentication:Boolean = false;
    private var _APIKey:String;
    private var _APIKeyDomain:String;
    private var _objectEncoding:uint;
    
    private var _resultCallback:Function;
    private var _statusCallback:Function;
    private var _defaultNetStatusHandler:Function;
    private var _defaultIOErrorHandler:Function;
    
    private var _netConnection:NetConnection;
    private var _responder:Responder;
    
    private var _sessID:String;
    private var _user:Object;
    
    private var _defaultEncryptionType:String = 'sha256';


    /**
     * Constructor.
     */     
    public function Connection(target:String = null) {
      this._netConnection = new NetConnection();
      this._netConnection.objectEncoding = ObjectEncoding.AMF3;
      
      this._netConnection.addEventListener(NetStatusEvent.NET_STATUS, _onNetStatus);
      this._netConnection.addEventListener(IOErrorEvent.IO_ERROR, _onIOError);
      
      if (target !== null) {
        this.target = target;
      }
    }
    
    
    /**********************************
     * Class methods.
     **********************************/
     
    public function call(command:String, callback:Function, ...args):void {
      this.callback = callback;
      var params:Array = [command, this._responder];
      
      // Authentication check
      if (this.isAPIKeyAuthentication) {
        params = this._performAPIKeyArguments(params);
      }
      
      if (this.isSessionAuthentication) {
        params = params.concat([this._sessID]);
      }
      
      params = params.concat(args);
      (this._netConnection.call as Function).apply(this._netConnection, params);
    }
    
    public function set callback(callback:Function):void {
      this._resultCallback = callback;
      
      this._responder = new Responder(callback, _defaultStatusHandler);
    }
    
    public function set statusCallback(statusCallback:Function):void {
      this._statusCallback = statusCallback;
    }
    
    public function connectToSession(callback:Function):void {
      this.isSessionAuthentication = true;
      
      var scope:Connection = this;
      this.call('system.connect', function(result:Object):void{
        scope.user = result.user as Object;
        scope.sessID = result.sessid as String; 
        callback(result);
      });
    }
    
    private function _performAPIKeyArguments(params:Array):Array {
      var command:String = params[0];
      var date:Date = new Date();
      var timeStamp:String = Math.round(date.time / 1000).toString();
      var nonce:String = StringUtil.getRandomSequence();
      var hashString:String = timeStamp + ';' + this._APIKeyDomain + ';' + nonce + ';' + command;
      var hash:HMAC = Crypto.getHMAC(this._defaultEncryptionType);
      var keyData:ByteArray = Hex.toArray(this._APIKey);
      var textData:ByteArray = Hex.toArray(hashString);
      var resultData:ByteArray = hash.compute(keyData, textData);
      var resultText:String = Hex.fromArray(resultData);
      
      return params.concat([resultText, this._APIKeyDomain, timeStamp, nonce]);
    }
    
    /**********************************
     * Net event handlers.
     **********************************/
    
    private function _defaultStatusHandler(status:Object):void {
      if (this._statusCallback !== null) {
        this._statusCallback(status);
      }
    }
    
    private function _onNetStatus(event:NetStatusEvent):void {
      if (this._defaultNetStatusHandler !== null) {
        this._defaultNetStatusHandler(event);
      }
    }
    
    private function _onIOError(event:IOErrorEvent):void {
      if (this._defaultIOErrorHandler !== null) {
        this._defaultIOErrorHandler(event);
      }
    }
   
     
    /**********************************
     * Getters and setters.
     **********************************/
    
    public function set target(target:String):void {
      this._target = target;
      
      this._netConnection.connect(this._target);
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
    
    public function setAPIKey(APIKey:String, APIKeyDomain:String):void {
      this._APIKey = APIKey;
      this._APIKeyDomain = APIKeyDomain;
      this.isAPIKeyAuthentication = true;
    }
    
    public function set objectEncoding(objectEncoding:uint):void {
      this._objectEncoding = objectEncoding;
    }

    public function set user(user:Object):void {
      this._user = user;
    }
    
    public function get user():Object {
      return this._user;
    }
    
    public function set sessID(sessID:String):void {
      this._sessID = sessID;
    }

  }
  
}
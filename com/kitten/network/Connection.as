/**
 * Connection handler.
 */
package com.kitten.network {
  
  import com.hurlant.crypto.hash.HMAC;
  import com.hurlant.crypto.hash.SHA256;
  import com.hurlant.util.Hex;
  import com.kitten.events.ConnectionEvent;
  import com.kitten.util.StringUtil;
  
  import flash.events.EventDispatcher;
  import flash.events.IOErrorEvent;
  import flash.events.NetStatusEvent;
  import flash.net.NetConnection;
  import flash.net.ObjectEncoding;
  import flash.net.Responder;
  import flash.utils.ByteArray;
  
  
  [Event(name="connectionIsReady",  type="com.kitten.events.ConnectionEvent")]
  [Event(name="connectionIsFailed", type="com.kitten.events.ConnectionEvent")]
  public class Connection extends EventDispatcher {
  
    /**
    * URL to the target.
    * In Drupal it's something like: http://host/services/amfphp
    */
    private var _target:String;
    
    /**
    * Is using session authentication.
    */
    private var _isSessionAuthentication:Boolean = false;
    
    /**
    * Is using api key authentication.
    */
    private var _isAPIKeyAuthentication:Boolean = false;
    
    /**
    * Private api key.
    */
    private var _APIKey:String;
    
    /**
    * Domain that was registered with the api key.
    */
    private var _APIKeyDomain:String;
    
    /**
    * Object encoding protocol.
    * Usually AMF3.
    */
    private var _objectEncoding:uint;
    
    /**
    * Default status callback.
    */
    private var _statusCallback:Function;
    
    /**
    * Default net status handler for the responder object.
    */
    private var _defaultNetStatusHandler:Function;
    
    /**
    * Default ioerror handler object for the responder object.
    */
    private var _defaultIOErrorHandler:Function;
    
    /**
    * Net connection object.
    */
    private var _netConnection:NetConnection;
    
    /**
    * Session ID string.
    */
    private var _sessID:String;
    
    /**
    * User object of the session.
    */
    private var _user:Object;
    
    /**
    * Flag that show if the connection is live.
    * If it's false, it doesn't mean it's not working.
    * If it's true, it's working.
    */
    private var _isConnected:Boolean = false;
    

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
     
    /**
    * Makes a call to the target URL.
    * Requires a callback for the result.
    */
    public function call(command:String, callback:Function, ...args):void {
      var responder:Responder = new Responder(callback, _defaultStatusHandler);
      var params:Array = [command, responder];
      
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
    
    
    /**
    * Connect to a site.
    * It's not a mandatory step, but is important to know if the connection is accessible.  
    */
    public function connect():void {
      var scope:Connection = this;
      this.call('system.connect', function(result:Object):void{
        scope.user = result.user as Object;
        scope.sessID = result.sessid as String;
        scope._isConnected = true;
        scope.dispatchEvent(new ConnectionEvent(ConnectionEvent.CONNECTION_IS_READY, scope));
      });
    }
    
    
    /**
    * Adds API key authentication params to the existing param set.
    */
    private function _performAPIKeyArguments(params:Array):Array {
      var command:String = params[0];
      var date:Date = new Date();
      var timeStamp:String = Math.round(date.time / 1000).toString();
      var nonce:String = StringUtil.getRandomSequence(10);
      var hashString:String = timeStamp + ';' + this._APIKeyDomain + ';' + nonce + ';' + command;
      var hmac:HMAC = new HMAC(new SHA256());
      var keyData:ByteArray = Hex.toArray(Hex.fromString(this._APIKey));
      var textData:ByteArray = Hex.toArray(Hex.fromString(hashString));
      var resultData:ByteArray = hmac.compute(keyData, textData);
      var resultText:String = Hex.fromArray(resultData);
      
      return params.concat([resultText, this._APIKeyDomain, timeStamp, nonce]);
    }
    
    /**********************************
     * Net event handlers.
     **********************************/
    
    /**
    * Acts on network status events (Responder).
    */
    private function _defaultStatusHandler(status:Object):void {
      this.dispatchEvent(new ConnectionEvent(ConnectionEvent.CONNECTION_IS_FAILED, this));
      if (this._statusCallback !== null) {
        this._statusCallback(status);
      }
    }
    
    
    /**
    * Acts on network status events (NetConnection).
    */
    private function _onNetStatus(event:NetStatusEvent):void {
      this.dispatchEvent(new ConnectionEvent(ConnectionEvent.CONNECTION_IS_FAILED, this));
      if (this._defaultNetStatusHandler !== null) {
        this._defaultNetStatusHandler(event);
      }
    }
    
    
    /**
    * Acts on ioerror events (NetConnection).
    */
    private function _onIOError(event:IOErrorEvent):void {
      this.dispatchEvent(new ConnectionEvent(ConnectionEvent.CONNECTION_IS_FAILED, this));
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
    
    public function get isConnected():Boolean {
      return this._isConnected;
    }

  }
  
}

/**
 * Connection handler.
 */
package com.kitten.network {
  
  import com.hurlant.crypto.hash.HMAC;
  import com.hurlant.crypto.hash.SHA256;
  import com.hurlant.util.Hex;
  import com.kitten.events.ConnectionEvent;
  import com.kitten.events.ConnectionIOErrorEvent;
  import com.kitten.events.ConnectionNetStatusEvent;
  import com.kitten.util.StringUtil;
  
  import flash.events.EventDispatcher;
  import flash.events.IOErrorEvent;
  import flash.events.NetStatusEvent;
  import flash.net.NetConnection;
  import flash.net.ObjectEncoding;
  import flash.net.Responder;
  import flash.utils.ByteArray;
  
  
  [Event(name="connectionIsReady", type="com.kitten.events.ConnectionEvent")]
  [Event(name="ioErrorEvent",      type="com.kitten.events.ConnectionIOErrorEvent")]
  [Event(name="netStatusEvent",    type="com.kitten.events.ConnectionNetStatusEvent")]
  public class Connection extends EventDispatcher {
  
    /**
    * Base path.
    */
    private var _basePath:String;
    
    /**
    * Endpoint path.
    */
    private var _endPoint:String;
    
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
    * User name.
    */
    private var _userName:String;
    
    /**
    * User password.
    */
    private var _userPassword:String;
    
    /**
    * Flag that show if the connection is live.
    * If it's false, it doesn't mean it's not working.
    * If it's true, it's working.
    */
    private var _isConnected:Boolean = false;
    

    /**
     * Constructor.
     */     
    public function Connection(basePath:String, endPoint:String) {
      this._netConnection = new NetConnection();
      this._netConnection.objectEncoding = ObjectEncoding.AMF3;
      
      this._netConnection.addEventListener(NetStatusEvent.NET_STATUS, _onNetStatus);
      this._netConnection.addEventListener(IOErrorEvent.IO_ERROR,     _onIOError);
      
      this.setTarget(basePath, endPoint);
    }
    
    
    /**********************************
     * Class methods.
     **********************************/
     
    /**
    * Makes a call to the target URL.
    * Requires a callback for the result.
    */
    public function call(command:String, callback:Function, errorCallback:Function = null, ...args):void {
      var responder:Responder = new Responder(callback, errorCallback);
      var params:Array = [command, responder];
      
      // Authentication check
      if (this.isAPIKeyAuthentication) {
        params = this._performAPIKeyArguments(params);
      }
      
      if (this.isSessionAuthentication && this._sessID) {
        params = params.concat([this._sessID]);
      }
      
      if (args && args.length > 0) {
        params = params.concat(args);
      }
      
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
      }, function(error_result:Object):void{
        trace('Error');
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


    /**
    * Do a user login with the stored credentials.
    */    
    public function loginToDrupal(callback:Function):void {
      this.call('user.login', callback, null, this._userName, this._userPassword);
    }
    
    
    /**********************************
     * Net event handlers.
     **********************************/
    
    /**
    * Acts on network status events (NetConnection).
    */
    private function _onNetStatus(event:NetStatusEvent):void {
      this.dispatchEvent(new ConnectionNetStatusEvent(ConnectionNetStatusEvent.NET_STATUS_EVENT, this, event));
    }
    
    
    /**
    * Acts on ioerror events (NetConnection).
    */
    private function _onIOError(event:IOErrorEvent):void {
      this.dispatchEvent(new ConnectionIOErrorEvent(ConnectionIOErrorEvent.IO_ERROR_EVENT, this, event));
    }
    
    
    /**********************************
     * Getters and setters.
     **********************************/
    
    public function setTarget(basePath:String, endPoint:String):void {
      if (!(basePath is String) || basePath.match(/^(http|www).{1,}$/gi).length <= 0) return;
      
      this._basePath = basePath;
      this._endPoint = endPoint;
      
      this._netConnection.connect(this._basePath + this._endPoint);
    }
    
    public function get basePath():String {
      return this._basePath;
    }
    
    public function get endPoint():String {
      return this._endPoint;
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
    
    public function set userName(userName:String):void {
      this._userName = userName;
    }
    
    public function set userPassword(userPassword:String):void {
      this._userPassword = userPassword;
    }
    
    
    /**********************************
    * Overrides.
    ***********************************/
    public override function toString():String {
      return this._basePath.toString().replace(/http:\/\//gi, '').replace(/www\./gi, '');
    }

  }
  
}

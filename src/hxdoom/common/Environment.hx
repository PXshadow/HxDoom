package hxdoom.common;

#if js
import js.Browser;
#end

/**
 * ...
 * @author Kaelan
 */
class Environment 
{
	////////////////////////////////////////////////////////////////////////////////////////////////////
	//Variables
	////////////////////////////////////////////////////////////////////////////////////////////////////
	
	//Integers and Floats
	public static var AUTOMAP_ZOOM(default, set) = 0.001;
	
	public static var PLAYER_FOV(default, set):Int = 90;
	public static var PLAYER_VIEW_HEIGHT:Int = 41;
	
	public static var SCREEN_DISTANCE_FROM_VIEWER:Int = 160;
	
	//Bools.
	public static var AUTOMAP_ROTATES_WITH_PLAYER:Bool = false;
	
	public static var CHEAT_CLIPPING:Bool = false;
	public static var CHEAT_INVULNERABILITY:Bool = false;
	
	public static var IS_IN_AUTOMAP:Bool = false;
	
	public static var NEEDS_TO_REBUILD_AUTOMAP:Bool = false;
	
	public static var PLAYER_MOVING_FORWARD:Bool = false;
	public static var PLAYER_MOVING_BACKWARD:Bool = false;
	public static var PLAYER_STRAFING_LEFT:Bool = false;
	public static var PLAYER_STRAFING_RIGHT:Bool = false;
	public static var PLAYER_TURNING_LEFT:Bool = false;
	public static var PLAYER_TURNING_RIGHT:Bool = false;
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	//Functions
	////////////////////////////////////////////////////////////////////////////////////////////////////
	public static function GlobalThrowError(_msg:String) {
		#if !js
		throw _msg + "\n" + platform() + "\n\nReport issues to: https://github.com/kevansevans/HxDoom";
		#else
		Browser.alert(_msg + "\n" + platform() + "\n\nReport issues to: https://github.com/kevansevans/HxDoom");
		throw _msg + "\n" + platform() + "\n\nReport issues to: https://github.com/kevansevans/HxDoom";
		#end
	}
	static function platform():String {
		#if sys
		return Sys.systemName();
		#elseif js
		return Browser.navigator.userAgent;
		#elseif (flash || air)
		return "Flash Player";
		#end
	}
	
	static function set_PLAYER_FOV(value:Int):Int 
	{
		PLAYER_FOV = value;
		if (PLAYER_FOV > 360) PLAYER_FOV = 360; 
		if (PLAYER_FOV < 0) PLAYER_FOV = 0; 
		return PLAYER_FOV;
	}
	
	static function set_AUTOMAP_ZOOM(value:Float):Float
	{
		AUTOMAP_ZOOM = value;
		if (AUTOMAP_ZOOM < 0.0001) AUTOMAP_ZOOM = 0.0001;
		if (AUTOMAP_ZOOM > 0.01) AUTOMAP_ZOOM = 0.01;
		return AUTOMAP_ZOOM;
	}
}
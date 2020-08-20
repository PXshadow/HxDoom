package hxdoom.lumps.map;

import hxdoom.Engine;
import hxdoom.lumps.LumpBase;

/**
 * ...
 * @author Kaelan
 */
class Segment extends LumpBase
{
	public static var CONSTRUCTOR:(Array<Any>) -> Segment = Segment.new;
	
	public static inline var BYTE_SIZE:Int = 12;
	
	public var angle:Int;
	public var lineID:Int;
	public var side:Int;
	public var offset:Int;
	
	public var start(get, null):Vertex;
	public var end(get, null):Vertex;
	public var sector(get, null):Sector;
	public var lineDef(get, null):LineDef;
	
	public function new(_args:Array<Any>) 
	{
		super();
		
		angle = 	_args[0];
		lineID = 	_args[1];
		side = 		_args[2];
		offset = 	_args[3];
	}
	
	function get_start():Vertex 
	{
		return Engine.LEVELS.currentMap.linedefs[lineID].start;
	}
	
	function get_end():Vertex 
	{
		return Engine.LEVELS.currentMap.linedefs[lineID].end;
	}
	
	function get_sector():Sector 
	{
		if (side == 0) {
			return lineDef.frontSideDef.sector;
		} else {
			return lineDef.backSideDef.sector;
		}
	}
	
	function get_lineDef():LineDef 
	{
		return Engine.LEVELS.currentMap.linedefs[lineID];
	}
	
	public function toString():String {
		return([
			'Angle: {' + angle + '}, ',
			'Direction: {' + (side == 0 ? '0: Front' : '1: back') + '}, ',
			'Offset: {' + offset + '}, ',
			'Sector: {' + sector + '}, '
		].join(""));
	}
}
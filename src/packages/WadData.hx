package packages;

import haxe.io.Bytes;
import packages.WadData.Directory;
import packages.WadData.Thing;
import packages.actors.Player;

import packages.actors.TypeID;


/**
 * ...
 * @author Kaelan
 * 
 * Reserve this class for parsing ORIGINAL map data, features desired in the future will require a UDMF approach.
 * 
 */
class WadData
{
	public static inline var VERTEX_LUMP_SIZE:Int = 4;
	public static inline var LINEDEF_LUMP_SIZE:Int = 14;
	public static inline var THING_LUMP_SIZE:Int = 10;
	public static inline var NODE_LUMP_SIZE:Int = 28;
	
	public static inline var SUBSECTORIDENTIFIER:Int = 0x8000;
	
	public static var COMMERCIAL:Bool = false;
	
	public var deconstructed:Bool = false;
	
	//raw data
	var b_dataArray:Array<Int>;				//JS Friendly way of storing byte data
	var directories:Array<Directory>;		//Stores location info of each lump
	public var maps:Array<Map>;				//Stores deconstructed map data
	public var activemap:Map;	//Active map
	public var mapindex:Array<Int>;			//Tracks location of each map found
	var iwad:Bool;							//Is an Iwad
	var name:String;						//name of said wad
	var dir_count:Int;						//how big is said wad
	var dir_offset:Int;						//Offset for proper reading

	public function new(_data:Bytes, _name:String, _iwad:Bool = false) 
	{
		b_dataArray = new Array();
		for (a in 0..._data.length) {
			b_dataArray.push(_data.get(a));
		}
		name = _name;
		iwad = _iwad;
		
		directories = new Array();
		mapindex = new Array();
		maps = new Array();
		
		baseIndexWadItems();
	}
	function baseIndexWadItems() {
		
		dir_count = readFourBytes(0x04);
		dir_offset = readFourBytes(0x08);
		
		for (a in 0...dir_count) {
			directories[a] = readDirectoryData(dir_offset + a * 16);
			if (directories.length > 10) {							// A map can literally not exist without being at least 10 entries made into the array
				if (   directories[a - 9].lumpName == 	"THINGS" 	// Actors, positions and what they are
					&& directories[a - 8].lumpName == 	"LINEDEFS"	// lines, describing behavior between two points
					&& directories[a - 7].lumpName == 	"SIDEDEFS"	// Describes which linedefs posses what textures
					&& directories[a - 6].lumpName == 	"VERTEXES"	// Each XY position of lines
					&& directories[a - 5].lumpName == 	"SEGS"		//
					&& directories[a - 4].lumpName == 	"SSECTORS"	//
					&& directories[a - 3].lumpName == 	"NODES"		//
					&& directories[a - 2].lumpName == 	"SECTORS"	// Closed linedefs
					&& directories[a - 1].lumpName == 	"REJECT"	//
					&& directories[a].lumpName == 		"BLOCKMAP"	//
				) {
					mapindex.push(a);
				}
			}
		}
	}
	public	function loadMap(_mapIndex:Int) {
		if (maps[_mapIndex] == null) {
			deconstructMap(_mapIndex);
			return;
		}
		activemap = maps[_mapIndex];
	}
	function deconstructMap(_mapIndex:Int) {
		var dirIndex = mapindex[_mapIndex];
		var map:Map = {
			
			name 		: name + ":" + directories[dirIndex - 10].lumpName,
			player		: new Array<Player>(),
			nodes 		: readNodeData(directories[dirIndex - 3]),
			vertexes 	: readVertextData(directories[dirIndex - 6]),
			linedefs 	: readLineDefData(directories[dirIndex - 8]),
			things 		: readThingData(directories[dirIndex - 9]),
			offset_x 	: 0,
			offset_y 	: 0
			
		};
		var mapx = Math.POSITIVE_INFINITY;
		var mapy = Math.POSITIVE_INFINITY;
		for (a in map.vertexes) {
			if (a.x < mapx) mapx = a.x;
			if (a.y < mapy) mapy = a.y;
		}
			
		map.offset_x = mapx * -1;
		map.offset_y = mapy * -1;
		
		for (a in map.things) {
		switch (a.type)
		{
			case TypeID.P_PLAYERONE | TypeID.P_PLAYERTWO | TypeID.P_PLAYERTHREE | TypeID.P_PLAYERFOUR:
				var player = new Player(a.type);
				player.xpos = a.xpos;
				player.ypos = a.ypos;
				player.angle = a.angle;
				map.player.push(player);
			}
		}
		maps[_mapIndex] = map;
		activemap = map;
	}
	//Get lump location info
	function readDirectoryData(_offset:Int):Directory {
		
		var dir:Directory = {
			lumpOffset : readFourBytes(_offset + 0x00),
			lumpSize : readFourBytes(_offset + 0x04),
			lumpName : stringFromBytesRange(_offset + 0x08, _offset + 0x10)
		};
		return dir;
	}
	
	//map data
	//vertexes
	function readVertextData(_dir:Directory):Array<Vertex> {
		var ver_array:Array<Vertex> = new Array();
		var num_verts:Int = Std.int(_dir.lumpSize / VERTEX_LUMP_SIZE);
		for (a in 0...num_verts) 
		{
			var ver:Vertex = {
				x : readTwoBytes(_dir.lumpOffset + a * VERTEX_LUMP_SIZE, true),
				y : readTwoBytes((_dir.lumpOffset + a * VERTEX_LUMP_SIZE) + 2, true),
			};
			ver_array.push(ver);
		}
		return ver_array;
	}
	//linedefs
	function readLineDefData(_dir:Directory):Array<LineDef> {
		var line_array:Array<LineDef> = new Array();
		var num_lines = Std.int(_dir.lumpSize / LINEDEF_LUMP_SIZE);
		for (a in 0...num_lines) {
			var line:LineDef = {
				start : readTwoBytes(_dir.lumpOffset + a * LINEDEF_LUMP_SIZE),
				end : readTwoBytes(_dir.lumpOffset + a * LINEDEF_LUMP_SIZE + 2),
				flags : readTwoBytes(_dir.lumpOffset + a * LINEDEF_LUMP_SIZE + 4),
				linetype : readTwoBytes(_dir.lumpOffset + a * LINEDEF_LUMP_SIZE + 6),
				sectortag : readTwoBytes(_dir.lumpOffset + a * LINEDEF_LUMP_SIZE + 8),
				frontsidedef : readTwoBytes(_dir.lumpOffset + a * LINEDEF_LUMP_SIZE + 10),
				backsidedef : readTwoBytes(_dir.lumpOffset + a * LINEDEF_LUMP_SIZE + 12),
			}
			line_array.push(line);
		}
		return line_array;
	}
	//things
	function readThingData(_dir:Directory):Array<Thing>
	{
		var thing_array:Array<Thing> = new Array();
		var num_things = Std.int(_dir.lumpSize / THING_LUMP_SIZE);
		for (a in 0...num_things) {
			var thing:Thing = {
				xpos : readTwoBytes(_dir.lumpOffset + a * THING_LUMP_SIZE, true),
				ypos : readTwoBytes(_dir.lumpOffset + a * THING_LUMP_SIZE + 2, true),
				angle : readTwoBytes(_dir.lumpOffset + a * THING_LUMP_SIZE + 4),
				type : readTwoBytes(_dir.lumpOffset + a * THING_LUMP_SIZE + 6),
				flags : readTwoBytes(_dir.lumpOffset + a * THING_LUMP_SIZE + 8)
			}
			switch (thing.type) {
				case 	TypeID.M_ARCHVILE | TypeID.M_FORMERCOMMANDO | TypeID.M_REVENANT | TypeID.M_MANCUBUS |
						TypeID.M_ARACHNOTRON | TypeID.M_HELLKNIGHT | TypeID.M_PAINELEMENTAL | TypeID.M_WOLFSS | 
						TypeID.M_BOSSBRAIN | TypeID.M_BOSSSHOOTER 
						:
							if (!COMMERCIAL) {} //do nothing, these are the shareware excluded monsters
							else thing_array.push(thing);
				default :
					thing_array.push(thing);
			}
			
		}
		return(thing_array);
	}
	//nodes
	function readNodeData(_dir:Directory):Array<Node> {
		var node_array:Array<Node> = new Array();
		var num_nodes = Std.int(_dir.lumpSize / NODE_LUMP_SIZE);
		for (a in 0...num_nodes) {
			var node:Node = {
				xPartition : readTwoBytes(_dir.lumpOffset + a * NODE_LUMP_SIZE, true),
				yPartition : readTwoBytes(_dir.lumpOffset + a * NODE_LUMP_SIZE + 2, true),
				changeXPartition : readTwoBytes(_dir.lumpOffset + a * NODE_LUMP_SIZE + 4, true),
				changeYPartition : readTwoBytes(_dir.lumpOffset + a * NODE_LUMP_SIZE + 6, true),
				
				frontBoxTop : readTwoBytes(_dir.lumpOffset + a * NODE_LUMP_SIZE + 8, true),
				frontBoxBottom : readTwoBytes(_dir.lumpOffset + a * NODE_LUMP_SIZE + 10, true),
				frontBoxLeft : readTwoBytes(_dir.lumpOffset + a * NODE_LUMP_SIZE + 12, true),
				frontBoxRight : readTwoBytes(_dir.lumpOffset + a * NODE_LUMP_SIZE + 14, true),
				
				backBoxTop : readTwoBytes(_dir.lumpOffset + a * NODE_LUMP_SIZE + 16, true),
				backBoxBottom : readTwoBytes(_dir.lumpOffset + a * NODE_LUMP_SIZE + 18, true),
				backBoxLeft : readTwoBytes(_dir.lumpOffset + a * NODE_LUMP_SIZE + 20, true),
				backBoxRight : readTwoBytes(_dir.lumpOffset + a * NODE_LUMP_SIZE + 22, true),
				
				frontChildID : readTwoBytes(_dir.lumpOffset + a * NODE_LUMP_SIZE + 24),
				backChildID : readTwoBytes(_dir.lumpOffset + a * NODE_LUMP_SIZE + 26),
			}
			node_array.push(node);
		}
		return(node_array);
	}
	//data conversions
	function readTwoBytes(_offset:Int, _signed:Bool = false):Int //16 bits
	{
		var val = (b_dataArray[_offset + 1] << 8) | b_dataArray[_offset];
		return(_signed == true && val > 32768 ? val - 65536 : val);
	}
	function readFourBytes(_offset:Int):Int {
		return((b_dataArray[_offset + 3] << 24) | (b_dataArray[_offset + 2] << 16) | (b_dataArray[_offset + 1] << 8) | b_dataArray[_offset]);
	}
	function stringFromBytesRange(_start:Int, _end:Int):String {
		var str:String = "";
		for (a in _start..._end) {
			if (b_dataArray[a] != 0 && Math.isNaN(b_dataArray[a]) == false) str += String.fromCharCode(b_dataArray[a]);
		}
		return str;
	}
	public function isPointOnBackSide(_x:Int, _y:Int, _nodeID:Int):Bool
	{
		var dx = _x - activemap.nodes[node].xPartition;
		var dy = _y - activemap.nodes[node].yPartition;
		
		return (((dx *  activemap.nodes[node].changeYPartition) - (dy * activemap.nodes[node].changeXPartition)) <= 0);
	}
	
	public function getPlayerNode():Node {
		var node:Int = activemap.nodes.length - 1;
		while (true) {
			if (activemap.nodes[node].backChildID & SUBSECTORIDENTIFIER > 0 || activemap.nodes[node].frontChildID & SUBSECTORIDENTIFIER > 0 ) {
				return activemap.nodes[node];
			}
			var isOnBack:Bool = isPointOnBackSide(activemap.things[0].xpos, activemap.things[0].ypos, node);
			if (isOnBack) {
				node = activemap.nodes[node].backChildID;
			} else {
				node = activemap.nodes[node].frontChildID;
			}
		}
	}
}
typedef Directory = {
	var lumpOffset:Int;
	var lumpSize:Int;
	var lumpName:String;
}
typedef Map = {
	var name:String;
	var player:Array<Player>;
	var vertexes:Array<Vertex>;
	var linedefs:Array<LineDef>;
	var nodes:Array<Null<Node>>; //needs to be null as null array access is needed.
	var things:Array<Thing>;
	var offset_x:Float;
	var offset_y:Float;
}
typedef Vertex = {
	var x:Int;
	var y:Int;
}
typedef LineDef = {
	var start:Int;
	var end:Int;
	var flags:Int;
	var linetype:Int;
	var sectortag:Int;
	var frontsidedef:Int;
	var backsidedef:Int;
}
typedef Node = {
	var xPartition:Int;
	var yPartition:Int;
	var changeXPartition:Int;
	var changeYPartition:Int;
	
	var frontBoxTop:Int;
	var frontBoxBottom:Int;
	var frontBoxLeft:Int;
	var frontBoxRight:Int;
	
	var backBoxTop:Int;
	var backBoxBottom:Int;
	var backBoxLeft:Int;
	var backBoxRight:Int;
	
	var frontChildID:Int;
	var backChildID:Int;
}
typedef Thing = {
	var xpos:Int;
	var ypos:Int;
	var angle:Int;
	var type:Int;
	var flags:Int;
}
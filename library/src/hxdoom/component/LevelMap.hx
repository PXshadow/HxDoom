package hxdoom.component;

import haxe.ds.Vector;

import hxdoom.actors.Actor;
import hxdoom.actors.Player;

import hxdoom.enums.game.SharedID;

import hxdoom.lumps.map.*;

import hxdoom.component.Camera;
import hxdoom.component.CameraPoint;
import hxdoom.utils.geom.Angle;
/**
 * ...
 * @author Kaelan
 */
class LevelMap //DOES NOT EXTEND LUMPBASE
{
	public var name:String;
	
	public var things:Array<Thing>;
	public var actors:Array<Actor>;
	public var vertexes:Array<Vertex>;
	public var linedefs:Array<LineDef>;
	public var nodes:Array<Node>;
	public var subsectors:Array<SubSector>;
	public var segments:Array<Segment>;
	public var sidedefs:Array<SideDef>;
	public var sectors:Array<Sector>;
	
	public var offset_x:Float;
	public var offset_y:Float;
	
	public var actors_players:Array<Player>;
	
	public var camera:Camera;
	public var focus:CameraPoint;
	
	public function new() 
	{
		things = new Array();
		actors = new Array();
		vertexes = new Array();
		linedefs = new Array();
		nodes = new Array();
		subsectors = new Array();
		segments = new Array();
		sidedefs = new Array();
		sectors = new Array();
	}
	
	public function build() {
		parseThings();
		setOffset();
		
		camera = new Camera(actors_players[0]);
		focus = new CameraPoint();
	}
	
	public function parseThings() {
		actors_players = new Array();
		for (thing in things) {
			actors.push(Actor.fromThing(thing));
			switch (thing.type) {
				case SharedID.PLAYER_1 | SharedID.PLAYER_2 | SharedID.PLAYER_3 | SharedID.PLAYER_4:
					actors_players.push(Player.fromThing(thing));
			}
		}
	}
	
	
	public function getActorSubsector(_actor:Actor):SubSector {
		var node:Int = nodes.length - 1;
		while (true) {
			if (node & Node.SUBSECTORIDENTIFIER > 0) {
				return subsectors[node & (~Node.SUBSECTORIDENTIFIER)];
			}
			var isOnBack:Bool = isPointOnBackSide(_actor.xpos, _actor.ypos, node);
			if (isOnBack) {
				node = nodes[node].backChildID;
			} else {
				node = nodes[node].frontChildID;
			}
		}
	}
	
	public function setOffset() {
		var mapx = Math.POSITIVE_INFINITY;
		var mapy = Math.POSITIVE_INFINITY;
		for (a in vertexes) {
			if (a.xpos < mapx) mapx = a.xpos;
			if (a.ypos < mapy) mapy = a.ypos;
		}
			
		offset_x = mapx - (actors_players[0].xpos + mapx);
		offset_y = mapy - (actors_players[0].ypos + mapy);
	}
	
	public function isPointOnBackSide(_x:Float, _y:Float, _nodeID:Int):Bool
	{
		var dx = _x - nodes[_nodeID].xPartition;
		var dy = _y - nodes[_nodeID].yPartition;
		
		return (((dx *  nodes[_nodeID].changeYPartition) - (dy * nodes[_nodeID].changeXPartition)) <= 0);
	}
	
	public function copy():LevelMap {
		var _bsp:LevelMap = new LevelMap();
		
		_bsp.linedefs = linedefs.copy();
		_bsp.name = name;
		_bsp.nodes = nodes.copy();
		_bsp.offset_x = offset_x;
		_bsp.offset_y = offset_y;
		_bsp.sectors = sectors.copy();
		_bsp.segments = segments.copy();
		_bsp.sidedefs = sidedefs.copy();
		_bsp.subsectors = subsectors.copy();
		_bsp.things = things.copy();
		_bsp.vertexes = vertexes.copy();
		_bsp.parseThings();
		
		return _bsp;
	}
	
}
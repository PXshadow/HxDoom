package hxdoom.wad.maplumps;

/**
 * ...
 * @author Kaelan
 */
class Node 
{
	public var xPartition:Int;
	public var yPartition:Int;
	public var changeXParition:Int;
	public var changeYParition:Int;
	
	public var frontBoxTop:Int;
	public var frontBoxBottom:Int;
	public var frontBoxLeft:Int;
	public var frontBoxRight:Int;
	
	public var backBoxTop:Int;
	public var backBoxBottom:Int;
	public var backBoxLeft:Int;
	public var backBoxRight:Int;
	
	public var frontChildID:Int;
	public var backChildID:Int;
	
	public function new(_x:Int, _y:Int, _cx:Int, _cy:Int, _ft:Int, _fb:Int, _fl:Int, _fr:Int, _bt:Int, _bb:Int, _bl:Int, _br:Int, _fci:Int, _bci:Int) 
	{
		xPartition = _x;
		yPartition = _y;
		changeXParition = _cx;
		changeYParition = _cy;
		
		frontBoxTop = _ft;
		frontBoxBottom = _fb;
		frontBoxLeft = _fl;
		frontBoxRight = _fr;
		
		backBoxTop = _bt; 		//Sam, be careful with your order. You'll be travelling through the heart of BT territory
		backBoxBottom = _bb;	//Sam, your BB is nothing more than a tool. Don't get attached to it.
		backBoxLeft = _bl;		//I was so naive when I made this comment, go play Death Stranding
		backBoxRight = _br;
		
		frontChildID = _fci;
		backChildID = _bci;
	}
	
}
package render.gl.programs;

import lime.graphics.WebGLRenderContext;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.utils.Float32Array;
import mme.math.glmatrix.Mat4Tools;

import hxdoom.Engine;
import hxdoom.com.Environment;

/**
 * ...
 * @author Kaelan
 */
class GLMapGeometry 
{
	var gl:WebGLRenderContext;
	var program:GLProgram;
	
	var vertex_shader:GLShader;
	var fragment_shader:GLShader;
	
	var map_lineverts:Array<Float>;
	
	public function new(_gl:WebGLRenderContext)
	{
		gl = _gl;
		program = gl.createProgram();
		map_lineverts = new Array();
		
		vertex_shader = gl.createShader(gl.VERTEX_SHADER);
		fragment_shader = gl.createShader(gl.FRAGMENT_SHADER);
				
		gl.shaderSource(vertex_shader, GLMapGeometry.vertex_source);
		gl.shaderSource(fragment_shader, GLMapGeometry.fragment_source);
		
		gl.compileShader(vertex_shader);
		if (!gl.getShaderParameter(vertex_shader, gl.COMPILE_STATUS)) {
			throw ("Map Vertex Shadder error: \n" + gl.getShaderInfoLog(vertex_shader));
		}
		
		gl.compileShader(fragment_shader);
		if (!gl.getShaderParameter(fragment_shader, gl.COMPILE_STATUS)) {
			throw ("Map Fragment Shader error: \n" + gl.getShaderInfoLog(fragment_shader));
		}
		
		program = gl.createProgram();
			
		gl.attachShader(program, vertex_shader);
		gl.attachShader(program, fragment_shader);
			
		gl.linkProgram(program);
	}
	
	public function render(_winWidth:Int, _winHeight:Int) {
		
		var loadedLineBuffer = gl.createBuffer();
		gl.bindBuffer(gl.ARRAY_BUFFER, loadedLineBuffer);
		gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(map_lineverts), gl.STATIC_DRAW);
		
		var posAttributeLocation = gl.getAttribLocation(program, "V3_POSITION");
		var colorAttributeLocation = gl.getAttribLocation(program, "V4_COLOR");
		
		gl.vertexAttribPointer(
			posAttributeLocation,
			3,
			gl.FLOAT,
			false,
			7 * Float32Array.BYTES_PER_ELEMENT,
			0);
		gl.vertexAttribPointer(
			colorAttributeLocation,
			4,
			gl.FLOAT,
			false,
			7 * Float32Array.BYTES_PER_ELEMENT,
			3 * Float32Array.BYTES_PER_ELEMENT);
		gl.enableVertexAttribArray(posAttributeLocation);
		gl.enableVertexAttribArray(colorAttributeLocation);
		
		gl.useProgram(program);
		
		var worldArray = new Float32Array(16);
		var viewArray = new Float32Array(16);
		var projArray = new Float32Array(16);
		
		var p_subsector = Engine.ACTIVEMAP.getPlayerSector();
		var p_sectorfloor = p_subsector.sector.floorHeight + Environment.PLAYER_VIEW_HEIGHT;
		
		Mat4Tools.identity(worldArray);
		Mat4Tools.lookAt(	[Engine.ACTIVEMAP.actors_players[0].xpos, Engine.ACTIVEMAP.actors_players[0].ypos, p_sectorfloor], 
							[Engine.ACTIVEMAP.actors_players[0].xpos_look, Engine.ACTIVEMAP.actors_players[0].ypos_look, p_sectorfloor + Engine.ACTIVEMAP.actors_players[0].zpos_look], 
							[0, 0, 1], viewArray);
		Mat4Tools.perspective(45 * (Math.PI / 180), _winWidth / _winHeight, 0.1, 10000, projArray);
		
		gl.uniformMatrix4fv(gl.getUniformLocation(program, "M4_World"), false, worldArray);
		gl.uniformMatrix4fv(gl.getUniformLocation(program, "M4_View"), false, viewArray);
		gl.uniformMatrix4fv(gl.getUniformLocation(program, "M4_Proj"), false, projArray);
		
		gl.drawArrays(gl.TRIANGLES, 0, Std.int(map_lineverts.length / 7));
	}
	
	public function buildMapArray() {
		
		var loadedsegs = Engine.ACTIVEMAP.segments;
		var sectors = Engine.ACTIVEMAP.sectors;
		var numSegs = ((loadedsegs.length -1) * 42);
		map_lineverts.resize(numSegs);
		var itemCount:Int = 0;
		
		for (segs in 0...loadedsegs.length) {
			
			if (loadedsegs[segs].lineDef.solid) {
			
				map_lineverts[itemCount] 		= loadedsegs[segs].start.xpos;
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.ypos;
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].frontSector.floorHeight;
				
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
				map_lineverts[itemCount += 1] 	= 1.0;
				
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.xpos;
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.ypos;
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].frontSector.floorHeight;
				
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
				map_lineverts[itemCount += 1] 	= 1.0;
				
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.xpos;
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.ypos;
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].frontSector.ceilingHeight;
				
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
				map_lineverts[itemCount += 1] 	= 1.0;
				
				////////////////////////////////////////////////////////////////////////////////////////////////////
				
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.xpos;
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.ypos;
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].frontSector.ceilingHeight;
				
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
				map_lineverts[itemCount += 1] 	= 1.0;
				
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.xpos;
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.ypos;
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].frontSector.ceilingHeight;
				
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
				map_lineverts[itemCount += 1] 	= 1.0;
				
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.xpos;
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.ypos;
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].frontSector.floorHeight;
				
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
				map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
				map_lineverts[itemCount += 1] 	= 1.0;
				
				++itemCount;
			}
			else {
				
				if (loadedsegs[segs].lineDef.frontSideDef.lower_texture != "-") {
					
					map_lineverts[itemCount] 		= loadedsegs[segs].start.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].frontSector.floorHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 1.0;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].frontSector.floorHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 1.0;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].backSector.floorHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 1.0;
					
					////////////////////////////////////////////////////////////////////////////////////////////////////
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].backSector.floorHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 1.0;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].backSector.floorHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 1.0;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].frontSector.floorHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 1.0;
					
					++itemCount;
				}
				
				if (loadedsegs[segs].lineDef.frontSideDef.middle_texture != "-") {
					
					map_lineverts[itemCount] 		= loadedsegs[segs].start.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].backSector.floorHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 0.2;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].backSector.floorHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 0.2;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].backSector.ceilingHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 0.2;
					
					////////////////////////////////////////////////////////////////////////////////////////////////////
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].backSector.ceilingHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 0.2;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].backSector.ceilingHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 0.2;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].backSector.floorHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 0.2;
					
					++itemCount;
				}
				
				if (loadedsegs[segs].lineDef.frontSideDef.upper_texture != "-") {
					
					map_lineverts[itemCount] 		= loadedsegs[segs].start.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].backSector.ceilingHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 1.0;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].backSector.ceilingHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 1.0;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].frontSector.ceilingHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 1.0;
					
					////////////////////////////////////////////////////////////////////////////////////////////////////
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].frontSector.ceilingHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 1.0;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].frontSector.ceilingHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 1.0;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].backSector.ceilingHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 1.0;
					
					++itemCount;
				}
				
				if (loadedsegs[segs].lineDef.backSideDef.lower_texture != "-") {
					
					map_lineverts[itemCount] 		= loadedsegs[segs].start.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].backSector.floorHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 1.0;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].backSector.floorHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 1.0;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].frontSector.floorHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 1.0;
					
					////////////////////////////////////////////////////////////////////////////////////////////////////
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].frontSector.floorHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 1.0;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].frontSector.floorHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 1.0;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].backSector.floorHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 1.0;
					
					++itemCount;
				}
				
				if (loadedsegs[segs].lineDef.backSideDef.middle_texture != "-") {
					
					map_lineverts[itemCount] 		= loadedsegs[segs].start.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].backSector.floorHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 0.2;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].backSector.floorHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 0.2;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].backSector.ceilingHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 0.2;
					
					////////////////////////////////////////////////////////////////////////////////////////////////////
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].backSector.ceilingHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 0.2;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].backSector.ceilingHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 0.2;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].backSector.floorHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 0.2;
					
					++itemCount;
				}
				
				if (loadedsegs[segs].lineDef.backSideDef.upper_texture != "-") {
					
					map_lineverts[itemCount] 		= loadedsegs[segs].start.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].frontSector.ceilingHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 1.0;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].frontSector.ceilingHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 1.0;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].backSector.ceilingHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 1.0;
					
					////////////////////////////////////////////////////////////////////////////////////////////////////
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].backSector.ceilingHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 1.0;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].start.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].backSector.ceilingHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 1.0;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.xpos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].end.ypos;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].frontSector.ceilingHeight;
					
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].r_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].g_color;
					map_lineverts[itemCount += 1] 	= loadedsegs[segs].b_color;
					map_lineverts[itemCount += 1] 	= 1.0;
					
					++itemCount;
				}
			}
		}
		
		Environment.NEEDS_TO_REBUILD_AUTOMAP = false;
	}
	
	public static var vertex_source:String = [
	#if !desktop
	'precision mediump float;',
	#end
	'attribute vec3 V3_POSITION;',
	'attribute vec4 V4_COLOR;',
	'varying vec4 F_COLOR;',
	'uniform mat4 M4_World;',
	'uniform mat4 M4_View;',
	'uniform mat4 M4_Proj;',
	'',
	'void main()',
	'{',
	'	F_COLOR = V4_COLOR;',
	'	gl_Position = M4_Proj * M4_View * M4_World * vec4(V3_POSITION, 1.0);',
	'}'
	].join('\n');
	
	public static var fragment_source:String = [
	#if !desktop
	'precision mediump float;',
	#end
	'varying vec4 F_COLOR;',
	'',
	'void main()',
	'{',
	' 	gl_FragColor = vec4(F_COLOR);',
	'}'
	].join('\n');
	
}
package;

#if sys
import sys.FileSystem;
import sys.io.File;
import haxe.io.Bytes;
#end
import lime.utils.Bytes;
import lime.utils.Assets;
import lime.app.Application;
import lime.graphics.RenderContext;

import hxdoom.Engine;
import render.Scene;


class Main extends Application 
{
	var wadsLoaded:Bool = false;
	var renderScene:Scene;
	
	var hxdoom:Engine;
	
	public function new () {
		
		super ();
		
		hxdoom = new Engine();
		
		/*
		 * We're going to assume an iwad picker of some sorts has been made already
		 */ 
		#if sys
		hxdoom.setBaseIwad(File.getBytes("./IWADS/DOOM1.WAD"), "DOOM1.WAD");
		#elseif js
		var waddata = Assets.loadBytes("IWADS/DOOM1.WAD");
		waddata.onComplete(function(data:Bytes):Bytes {
			hxdoom.setBaseIwad(data, "DOOM1.WAD");
			hxdoom.loadMap(0);
			wadsLoaded = true;
			return data;
		});
		#end
		
		#if !js
		hxdoom.loadMap(0);
		
		wadsLoaded = true;
		#end
	}
	public static function main () {
		
		var app = new Main ();
		return app.exec ();
		
	}
	public override function render (context:RenderContext):Void {
		
		if (!wadsLoaded) return;
		
		switch (context.type) {
			
			case OPENGL, OPENGLES, WEBGL:
				
				if (renderScene == null) {
					renderScene = new Scene(context);
				}
				
			default:
				
				throw "Render context not supported by choice";
		}
	}
	
	override public function update(deltaTime:Int):Void 
	{
		super.update(deltaTime);
		
		if (renderScene != null) {
			renderScene.render();
		}
	}
}
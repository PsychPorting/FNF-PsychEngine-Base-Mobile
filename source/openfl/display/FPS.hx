package openfl.display;

import haxe.Timer;
import openfl.Lib;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.FlxG;
import flixel.math.FlxMath;
#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end

enum GLInfo
{	
	RENDERER;	
	SHADING_LANGUAGE_VERSION;
}
	
class FPS extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		#if mobile
		defaultTextFormat = new TextFormat('_sans', Std.int(14 * Math.min(Lib.current.stage.stageWidth / FlxG.width, Lib.current.stage.stageHeight / FlxG.height)), color);
		#else
		defaultTextFormat = new TextFormat('_sans', 14, color);
		#end
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";

		cacheCount = 0;
		currentTime = 0;
		times = [];

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end

		#if mobile
		addEventListener(Event.RESIZE, function(e:Event)
		{
			final daSize:Int = Std.int(14 * Math.min(Lib.current.stage.stageWidth / FlxG.width, Lib.current.stage.stageHeight / FlxG.height));
			if (defaultTextFormat.size != daSize)
				defaultTextFormat.size = daSize;
		});
		#end
	}

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);
		if (currentFPS > ClientPrefs.data.framerate) currentFPS = ClientPrefs.data.framerate;

		if (currentCount != cacheCount /*&& visible*/)
		{
			var memoryMegas:Float = 0;
			var memoryTotal:Float = 0;

			text = "FPS: " + currentFPS;
			
			#if openfl
			memoryMegas = Math.abs(FlxMath.roundDecimal(System.totalMemory / 1000000, 1));
			text += "\nMemory: " + memoryMegas + " MB";

		        if(ClientPrefs.data.MEMP)
			{
                        text += "\nMemory Peak: " + memoryTotal + " MB";
			}

                        if(ClientPrefs.data.GLRender)
			{
 			text += "\nGL Render: " + '${getGLInfo(RENDERER)}'; 
			text += "\nGLShading Version: " + '${getGLInfo(SHADING_LANGUAGE_VERSION)}';
			}
			#end
				
			#if lime
			text += "\nOS: " + '${lime.system.System.platformLabel}';
			#end

			textColor = 0xFFFFFFFF;
			if (#if mobile memoryMegas > 1000 #else memoryMegas > 3000 #end || currentFPS <= ClientPrefs.data.framerate / 2)
			{
				textColor = 0xFFFF0000;
			}

			#if (gl_stats && !disable_cffi && (!html5 || !canvas))
			text += "\ntotalDC: " + Context3DStats.totalDrawCalls();
			text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
			text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
			#end

			text += "\n";
		}

		cacheCount = currentCount;
	}
	
	private function getGLInfo(info:GLInfo):String	{		
		@:privateAccess		
			var gl:Dynamic = Lib.current.stage.context3D.gl;
		switch (info)		
		{			
			case RENDERER:				
				return Std.string(gl.getParameter(gl.RENDERER));			
			case SHADING_LANGUAGE_VERSION:				
				return Std.string(gl.getParameter(gl.SHADING_LANGUAGE_VERSION));		
		}
		return '';	
	}

}

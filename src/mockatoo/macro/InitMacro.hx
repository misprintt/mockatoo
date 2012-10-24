package mockatoo.macro;

#if macro
import sys.io.File;
import sys.FileSystem;

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

class InitMacro
{
	public static var TEMP_DIR:String = ".temp/mockatoo/";
	static var initialized = false;

	public static function init()
	{
		if (initialized) return;

		initialized = true;

		Compiler.define("no-inline");
		
		createTempDirectory();

		Console.addPrinter(new FilePrinter(TEMP_DIR + "mockatoo.log"));

		Console.start();
		Console.removePrinter(Console.defaultPrinter);
	}

	static function createTempDirectory()
	{
		var temp = TEMP_DIR.split("/");

		var path = "";
		
		while(temp.length > 0)
		{	
			var part = temp.shift();
			if(part == "" && temp.length == 0) break;

			path += part + "/";

			if(!FileSystem.exists(path)) FileSystem.createDirectory(path);
		}
	}
}

class FilePrinter extends mconsole.FilePrinter
{
	public function new(path:String)
	{
		if(FileSystem.exists(path))
			FileSystem.deleteFile(path);
		super(path);
	}

	/**
	Fiters out any logs outside of current package.
	*/
	override public function print(level: mconsole.LogLevel, params:Array<Dynamic>, indent:Int, pos:haxe.PosInfos):Void
	{
		if(StringTools.startsWith(pos.className, "mockatoo"))
			super.print(level, params, indent, pos);
	}
}

#end
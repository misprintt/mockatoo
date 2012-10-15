package mockatoo;

import msys.File;
import msys.Directory;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

class Mockatoo
{
	@:macro static public function mock<T>(e:ExprOf<Class<T>>, ?constructorArgs:ExprOf<Array<Dynamic>>):ExprOf<T>
	{
		init();
		return MockCreator.createMock(e,constructorArgs);
	}

	#if macro

	public static var TEMP_DIR:String = ".temp/mockatoo/";
	static var initialized = false;

	static function init()
	{
		if (initialized) return;

		initialized = true;
		
		Directory.create(TEMP_DIR);

		Console.addPrinter(new FilePrinter(TEMP_DIR + "mockatoo.log"));

		Console.start();
		Console.removePrinter(Console.defaultPrinter);
	}

	#end
}

#if macro


class FilePrinter extends mconsole.FilePrinter
{
	var currentClass:String;
	var currentMethod:String; 

	public function new(path:String)
	{
		File.remove(path);
		super(path);
	}
}

#end
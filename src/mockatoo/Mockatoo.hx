package mockatoo;

#if macro

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

import sys.io.File;
import sys.FileSystem;

#end

import mockatoo.macro.MockCreator;

enum VerificationFilter
{
	times(value:Int);
	atLeastOnce;
	atLeast(value:Int);
	never;
}

class Mockatoo
{	
	/**
	 * Creates mock object of given class or interface.
	 * 
	 * @param classToMock class or interface to mock
	 * @return mock object
	 */
	@:macro static public function mock<T>(classToMock:ExprOf<Class<T>>, ?paramTypes:ExprOf<Array<Class<T>>>):ExprOf<T>
	{
		init();
		return MockCreator.createMock(classToMock, paramTypes);
	}

	/**
	 * Verifies certain behavior happened at least once / exact number of times / never. E.g:
	 * <pre class="code"><code class="haxe">
	 *   verify(mock, times(5)).someMethod("was called five times");
	 *
	 *   verify(mock, atLeast(2)).someMethod("was called at least two times");
	 *
	 *   //you can use flexible argument matchers, e.g:
	 *   verify(mock, atLeastOnce()).someMethod(<b>anyString()</b>);
	 * </code></pre>
	 *
	 * <b>times(1) is the default</b> and can be omitted
	 * <p>
	 * Arguments passed are compared using <code>equals()</code> method.
	 * Read about {@link ArgumentCaptor} or {@link ArgumentMatcher} to find out other ways of matching / asserting arguments passed.
	 * <p>
	 *
	 * @param mock to be verified
	 * @param mode times(x), atLeastOnce() or never()
	 *
	 * @return mock object itself
	 */
	static public function verify(mock:Mock, ?filter:VerificationFilter):Dynamic
	{
		Console.assert(mock != null, "Cannot verify [null] mock");

		if(filter == null) filter = VerificationFilter.times(1);

		return mock.mockDelegate.verify(filter);
	}
	//verify(mock).foo("bar");

	#if macro

	public static var TEMP_DIR:String = ".temp/mockatoo/";
	static var initialized = false;

	static function init()
	{
		if (initialized) return;

		initialized = true;

		Compiler.define("--no-inline");
		Compiler.define("-no-inline");
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

	#end
}

#if macro

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
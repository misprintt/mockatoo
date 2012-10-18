package mockatoo;

#if macro
import msys.File;
import msys.Directory;

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
#end

import mockatoo.internal.MockCreator;

class Mockatoo
{	

	/**
	 * Creates mock object of given class or interface.
	 * 
	 * @param classToMock class or interface to mock
	 * @return mock object
	 */
	@:macro static public function mock<T>(classToMock:ExprOf<Class<T>>):ExprOf<T>
	{
		init();
		return MockCreator.createMock(classToMock);
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
	static public function verify(mock:Mock)
	{
		Console.assert(mock != null, "Cannot verify [null] mock");
	}

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
		
		Directory.create(TEMP_DIR);

		Console.addPrinter(new FilePrinter(TEMP_DIR + "mockatoo.log"));

		Console.start();
		Console.removePrinter(Console.defaultPrinter);
	}


	// /**
	// Include for compilation all classes defined in the given package excluding the ones referenced in the ignore list.
	// **/
	// public static function removeInlines( ?pack : String = "", ?rec = true, ?ignore : Array<String>, ?classPaths : Array<String> )
	// {
	// 	if(null == classPaths)
	// 		classPaths = Context.getClassPath();
	// 	// normalize class path
	// 	for( i in 0...classPaths.length ) {
	// 		var cp = StringTools.replace(classPaths[i], "\\", "/");
	// 		if(StringTools.endsWith(cp, "/"))
	// 			cp = cp.substr(0, -1);
	// 		classPaths[i] = cp;
	// 	}
	// 	var prefix = pack == '' ? '' : pack + '.';
	// 	for( cp in classPaths ) {
	// 		var path = pack == '' ? cp : cp + "/" + pack.split(".").join("/");
	// 		if( !sys.FileSystem.exists(path) || !sys.FileSystem.isDirectory(path) )
	// 			continue;
	// 		for( file in sys.FileSystem.readDirectory(path) ) {
	// 			if( StringTools.endsWith(file, ".hx") ) {
	// 				var cl = prefix + file.substr(0, file.length - 3);
	// 				Compiler.addMetadata(":build(mockatoo.Mockatoo.removeInlinesFrom")
	// 				Context.getModule(cl);
	// 			} else if( rec && sys.FileSystem.isDirectory(path + "/" + file) && !skip(prefix + file) )
	// 				include(prefix + file, true, ignore, classPaths);
	// 		}
	// 	}
	// }

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
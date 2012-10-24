package mockatoo;

#if macro

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

import sys.io.File;
import sys.FileSystem;

using tink.macro.tools.Printer;
using tink.macro.tools.ExprTools;
#end

import mockatoo.macro.MockCreator;

/**
 Mockatoo library enables mocks creation, verification and stubbing.
*/
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
	static public function verify(mock:Mock, ?mode:VerificationMode):Dynamic
	{
		Console.assert(mock != null, "Cannot verify [null] mock");
		return mock.mockDelegate.verify(mode);
	}
	//verify(mock).foo("bar");

	/**
     * Enables stubbing methods. Use it when you want the mock to return particular value when particular method is called. 
     * <p>
     * Simply put: "<b>When</b> the x method is called <b>then</b> return y".
     * <p>
     * Examples:
     * 
     * <pre class="code"><code class="java">
     * <b>when</b>(mock.someMethod()).<b>thenReturn</b>(10);
     *
     * //you can use flexible argument matchers, e.g:
     * when(mock.someMethod(<b>anyString()</b>)).thenReturn(10);
     *
     * //setting exception to be thrown:
     * when(mock.someMethod("some arg")).thenThrow(new RuntimeException());
     *
     * //you can set different behavior for consecutive method calls.
     * //Last stubbing (e.g: thenReturn("foo")) determines the behavior of further consecutive calls.
     * when(mock.someMethod("some arg"))
     *  .thenThrow(new RuntimeException())
     *  .thenReturn("foo");
     *  
     * //Alternative, shorter version for consecutive stubbing:
     * when(mock.someMethod("some arg"))
     *  .thenReturn("one", "two");
     * //is the same as:
     * when(mock.someMethod("some arg"))
     *  .thenReturn("one")
     *  .thenReturn("two");
     *
     * //shorter version for consecutive method calls throwing exceptions:
     * when(mock.someMethod("some arg"))
     *  .thenThrow(new RuntimeException(), new NullPointerException();
     *   
     * </code></pre>
     */
	@:macro static public function when(expr:ExprOf<Dynamic>):ExprOf<Dynamic>
	{

		var str = expr.print();
		trace(str);
		trace(expr);

		//converts instance.one(1)
		//into instance.mockDelegate.when("one", [1])

		switch(expr.expr)
		{
			case ECall(e, params):

				var ident = e.toString();

				var parts = ident.split(".");
				var methodName = EConst(CString(parts.pop())).at();

				var args = params.toArray();

				ident = parts.join(".") + ".mockDelegate.stub";

				var actualExpr = ident.resolve().call([methodName, args]);
				trace(actualExpr.toString());
				return actualExpr;

			default: throw "Invalid arg [" + expr.print() + "]";
		}
		return expr;
	}


	#if macro

	public static var TEMP_DIR:String = ".temp/mockatoo/";
	static var initialized = false;

	static function init()
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
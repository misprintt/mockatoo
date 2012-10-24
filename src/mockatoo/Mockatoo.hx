package mockatoo;

#if macro
import haxe.macro.Expr;
#end

import mockatoo.macro.InitMacro;
import mockatoo.macro.MockMaker;
import mockatoo.macro.WhenMacro;


/**
Mockatoo library enables mocks creation, verification and stubbing.
*/
class Mockatoo
{	
	/**
	Creates mock object of given class or interface.
	
	@param classToMock class or interface to mock
	@return new instance of generated Mock class
	*/
	@:macro static public function mock<T>(classToMock:ExprOf<Class<T>>, ?paramTypes:ExprOf<Array<Class<T>>>):ExprOf<T>
	{
		InitMacro.init();
		var mock = new MockMaker(classToMock, paramTypes);
		return mock.toExpr();
	}

	/**
	Verifies certain behavior happened at least once / exact number of times / never. E.g:
	<pre class="code"><code class="haxe">
	  verify(mock, times(5)).someMethod("was called five times");
	
	  verify(mock, atLeast(2)).someMethod("was called at least two times");
	
	  //you can use flexible argument matchers, e.g:
	  verify(mock, atLeastOnce().someMethod(<b>anyString()</b>);
	</code></pre>
	
	<b>times(1) is the default</b> and can be omitted
	<p>
	Arguments passed are compared using <code>equals()</code> method.
	Read about {@link ArgumentCaptor} or {@link ArgumentMatcher} to find out other ways of matching / asserting arguments passed.
	<p>
	
	@param mock to be verified
	@param mode times(x), atLeastOnce() or never()
	
	@return dynamic Verification for current mock's API 
	 */
	static public function verify(mock:Mock, ?mode:VerificationMode):mockatoo.internal.Verification
	{
		Console.assert(mock != null, "Cannot verify [null] mock");
		return mock.mockProxy.verify(mode);
	}

	/**
    Enables stubbing methods. Use it when you want the mock to return particular value when particular method is called. 
    <p>
    Simply put: "<b>When</b> the x method is called <b>then</b> return y".
    <p>
    Examples:
	
    <pre class="code"><code class="haxe">
    <b>when</b>(mock.someMethod()).<b>thenReturn</b>(10);
	
    //you can use flexible argument matchers, e.g:
    when(mock.someMethod(<b>anyString()</b>)).thenReturn(10);
	
    //setting exception to be thrown:
    when(mock.someMethod("some arg")).thenThrow(new RuntimeException());
	
    //you can set different behavior for consecutive method calls.
    //Last stubbing (e.g: thenReturn("foo")) determines the behavior of further consecutive calls.
    when(mock.someMethod("some arg"))
     .thenThrow(new RuntimeException())
     .thenReturn("foo");
	
    //Alternative, shorter version for consecutive stubbing:
    when(mock.someMethod("some arg"))
     .thenReturn("one", "two");
    //is the same as:
    when(mock.someMethod("some arg"))
     .thenReturn("one")
     .thenReturn("two");
	
    //shorter version for consecutive method calls throwing exceptions:
    when(mock.someMethod("some arg"))
     .thenThrow(new RuntimeException(), new NullPointerException();
      
    </code></pre>

    @param reference to the mock's method signature to stub
    @return dynamic Stubber for matching method
    */
	@:macro static public function when(expr:ExprOf<Dynamic>):ExprOf<mockatoo.internal.Stubber>
	{
		return WhenMacro.create(expr);
	}
}

/**
 * Allows flexible verification or stubbing of arguments based on type
 *
 * <pre class="code"><code class="haxe">
 * verify(mock).someMethod(anyString);
 * verify(mock).someMethod(anyInt);
 * verify(mock).someMethod(anyFloat);
 * verify(mock).someMethod(anyBool);
 * verify(mock).someMethod(anyIterator); //array, hash, iterable, iterator, etc
 * verify(mock).someMethod(anyObject); //anonymous data structure
 * verify(mock).someMethod(anyEnum);
 *
 * verify(mock).someMethod(enumOf(SomEnum)); //an enum value of a specific enum type
 * verify(mock).someMethod(instanceOf(SomeClass));
 *
 * verify(mock).someMethod(isNull);
 * verify(mock).someMethod(isNotNull); // any non null value
 * verify(mock).someMethod(any); // wildcard for any value
 *
 * verify(mock).someMethod(customMatch(someFunction)); //custom function to verify value

 */
enum Matcher
{
	anyString;
	anyInt;
	anyFloat;
	anyBool;
	anyIterator;
	anyObject;
	anyEnum;
	enumOf(e:Enum<Dynamic>);
	instanceOf(c:Class<Dynamic>);
	isNotNull;
    isNull;
	any;
	customMatcher(f:Dynamic -> Bool);
}



/**
 * Allows verifying that certain behavior happened at least once / exact number
 * of times / never. E.g:
 * 
 * <pre class="code"><code class="haxe">
 * verify(mock, times(5)).someMethod(&quot;was called five times&quot;);
 * 
 * verify(mock, never()).someMethod(&quot;was never called&quot;);
 * 
 * verify(mock, atLeastOnce()).someMethod(&quot;was called at least once&quot;);
 * 
 * verify(mock, atLeast(2)).someMethod(&quot;was called at least twice&quot;);
 * 
 * verify(mock, atMost(3)).someMethod(&quot;was called at most 3 times&quot;);
 * 
 * </code></pre>
 * 
 * <b>times(1) is the default</b> and can be omitted
 */
enum VerificationMode
{
	times(value:Int);
	atLeastOnce;
	atLeast(value:Int);
	never;
	atMost(value:Int);
}

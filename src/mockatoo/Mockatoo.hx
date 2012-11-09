package mockatoo;

#if macro
import haxe.macro.Expr;
#end

import mockatoo.macro.InitMacro;
import mockatoo.macro.MockMaker;
import mockatoo.macro.VerifyMacro;
import mockatoo.macro.StubbingMacro;


/**
Mockatoo library enables mocks creation, verification and stubbing.
*/
class Mockatoo
{	
	/**
	Creates mock object of given class or interface.
	
	@param typeToMock class or interface to mock
	@return new instance of generated Mock class
	*/
	@:macro static public function mock<T>(typeToMock:ExprOf<Class<T>>, ?paramTypes:ExprOf<Array<Class<T>>>):ExprOf<T>
	{
		InitMacro.init();
		var mock = new MockMaker(typeToMock, paramTypes);
		return mock.toExpr();
	}

	/**
	Creates a partial-mock object of given class that calls through to original
	method if no stubbing defined. Note: behaves same as mock for Interfaces.

	@param typeToMock class
	@return new instance of generated Mock class
	*/
	@:macro static public function spy<T>(typeToMock:ExprOf<Class<T>>, ?paramTypes:ExprOf<Array<Class<T>>>):ExprOf<T>
	{
		InitMacro.init();
		var mock = new MockMaker(typeToMock, paramTypes, true);
		return mock.toExpr();
	}

	/**
	Verifies certain behavior happened at least once / exact number of times / never. E.g:
	<pre class="code"><code class="haxe">
	  verify(mock.someMethod("was called five times"), 5);

	  //or the same call using a VerificationMode:
	  verify(mock.someMethod("was called five times"), times(5));
	
	  verify(mock.someMethod("was called at least two times"), atLeast(2));
	
	  //you can use flexible argument matchers, e.g:
	  verify(mock.someMethod(<b>anyString</b>), atLeastOnce);

	</code></pre>
	
	<b>times(1) is the default</b> and can be omitted
	<p>
	Arguments passed are compared using equality (==) with additional checks for enums with paramater values. 
	<p>
	
	@param mock expression to be verified
	@param mode 5, times(x), atLeastOnce, atLeast(x) or never
	
	@return dynamic Verification for current mock's API 
	 */

	@:macro static public function verify(expr:ExprOf<Dynamic>, ?mode:ExprOf<VerificationMode>):ExprOf<mockatoo.internal.Verification>
	{
		return VerifyMacro.create(expr,mode);
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
    when(mock.someMethod(<b>anyString</b>)).thenReturn(10);
	
    //setting exception to be thrown:
    when(mock.someMethod("some arg")).thenThrow(new SomeException());
	
    //you can set different behavior for consecutive method calls.
    //Last stubbing (e.g: thenReturn("foo")) determines the behavior of further consecutive calls.
    when(mock.someMethod("some arg"))
     .thenThrow(new SomeException())
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
     .thenThrow(new SomeException(), new SomeOtherException();
      
    </code></pre>

      @param reference to the mock's method signature to stub
    @return dynamic Stubber for matching method
    */
	@:macro static public function when(expr:ExprOf<Dynamic>):ExprOf<mockatoo.internal.Stubber>
	{
		return StubbingMacro.createWhen(expr);
	}


	/**
	Shorthand for stubbing a when().thenReturn
	<pre class="code"><code class="haxe">
    Mockatoo.returns(mock.someMethod("foo"), "someValue");

    //or with using
    mock.someMethod("foo").returns("someValue");

    //both of these are the equivalent of
    Mockatoo.when(mock.someMethod("foo")).thenReturn("someValue");
    </code></pre>
	*/
	@:macro static public function returns(expr:ExprOf<Dynamic>, value:Expr):ExprOf<mockatoo.internal.Stubber>
	{
		return StubbingMacro.returns(expr, value);
	}


	/**
	Shorthand for stubbing a when().thenThrow
	<pre class="code"><code class="haxe">
    Mockatoo.throws(mock.someMethod("foo"), "some exception");

    //or with using
    mock.someMethod("foo").throws("some exception");

    //both of these are the equivalent of
    Mockatoo.when(mock.someMethod("foo")).thenThrow("some exception");
    </code></pre>
	*/
	@:macro static public function throws(expr:ExprOf<Dynamic>, value:Expr):ExprOf<mockatoo.internal.Stubber>
	{
		return StubbingMacro.throws(expr, value);
	}

	/**
	Shorthand for stubbing a when().thenCall 
	<pre class="code"><code class="haxe">
    Mockatoo.calls(mock.someMethod("foo"), someFunction);

    //or with using
    mock.someMethod("foo").calls(someFunction);

    //both of these are the equivalent of
    Mockatoo.when(mock.someMethod("foo")).thenCall(someFunction);
    </code></pre>
	*/
	@:macro static public function calls(expr:ExprOf<Dynamic>, value:Expr):ExprOf<mockatoo.internal.Stubber>
	{
		return StubbingMacro.calls(expr, value);
	}


	/**
	Shorthand for stubbing a when().thenCallRealMethod
	<pre class="code"><code class="haxe">
    Mockatoo.callsRealMethod(mock.someMethod("foo"));

    //or with using
    mock.someMethod("foo").callsRealMethod();

    //both of these are the equivalent of
    Mockatoo.when(mock.someMethod("foo")).thenCallRealMethod();
    </code></pre>
	*/
	@:macro static public function callsRealMethod(expr:ExprOf<Dynamic>):ExprOf<mockatoo.internal.Stubber>
	{
		return StubbingMacro.callsRealMethod(expr);
	}

	/**
	Shorthand for stubbing a when().thenStub()
	<pre class="code"><code class="haxe">
    Mockatoo.stub(mock.someMethod("foo"));

    //or with using
    mock.someMethod("foo").stub();

    //both of these are the equivalent of
    Mockatoo.when(mock.someMethod("foo")).thenStub();
    </code></pre>
	*/
	@:macro static public function stub(expr:ExprOf<Dynamic>):ExprOf<mockatoo.internal.Stubber>
	{
		return StubbingMacro.stubs(expr);
	}


	/**
	Resets a mock object. This removes any existing stubbings or verifications on
	the methods of the instance
	*/
	static public function reset(mock:Dynamic)
	{
		Console.assert(mock != null, "Cannot verify [null] mock");
		Console.assert(Std.is(mock, Mock), "Object is not an instance of mock");
		return mock.mockProxy.reset();
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
 * verify(mock, never.someMethod(&quot;was never called&quot;);
 * 
 * verify(mock, atLeastOnce.someMethod(&quot;was called at least once&quot;);
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

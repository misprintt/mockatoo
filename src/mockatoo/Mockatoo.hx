package mockatoo;

import haxe.macro.Expr;
import haxe.macro.Context;
import mockatoo.macro.InitMacro;
import mockatoo.macro.MockMaker;
import mockatoo.macro.VerifyMacro;
import mockatoo.macro.StubbingMacro;

using mockatoo.macro.Tools;
/**
	Mockatoo library enables mocks creation, verification and stubbing.
**/
class Mockatoo
{	
	/**
		Creates mock object of given class or interface.
		
		@param typeToMock class or interface to mock
		@return new instance of generated Mock class
	**/
	macro static public function mock<T>(typeToMock:ExprOf<Class<T>>, ?paramTypes:ExprOf<Array<Class<T>>>):ExprOf<T>
	{
		InitMacro.init();
		var mock = new MockMaker(typeToMock.typed(), paramTypes);
		return mock.toExpr();
	}

	/**
		Creates a partial-mock object of given class that calls through to original
		method if no stubbing defined. Note: behaves same as mock for Interfaces.

		@param typeToMock class
		@return new instance of generated Mock class
	**/
	macro static public function spy<T>(typeToMock:ExprOf<Class<T>>, ?paramTypes:ExprOf<Array<Class<T>>>):ExprOf<T>
	{
		InitMacro.init();
		var mock = new MockMaker(typeToMock.typed(), paramTypes, true);
		return mock.toExpr();
	}

	/**
		Verifies certain behavior happened at least once / exact number of times / never. E.g:
		
		````
	  	verify(mock.someMethod("was called five times"), 5);

		//or the same call using a VerificationMode:
		verify(mock.someMethod("was called five times"), times(5));
		
		verify(mock.someMethod("was called at least two times"), atLeast(2));
		
		//you can use flexible argument matchers, e.g:
		verify(mock.someMethod(<b>anyString</b>), atLeastOnce);
		````

		times(1) is the default and can be omitted
		
		Arguments passed are compared using equality (==) with additional checks for enums with paramater values. 
		
		@param mock expression to be verified
		@param mode 5, times(x), atLeastOnce, atLeast(x) or never
		
		@return dynamic Verification for current mock's API 
	**/	
	macro static public function verify(expr:ExprOf<Dynamic>, ?mode:ExprOf<VerificationMode>):ExprOf<mockatoo.internal.Verification>
	{
		return VerifyMacro.create(expr.typed(),mode);
	}

	/**
		Verifies that no other methods have been invoked since last `verify`

		````
	  	mock.verifyZeroInteractions();
		````

		@throws VerificationException if a method has been called
	**/
	static public function verifyZeroInteractions(mock:Mock, ?pos:haxe.PosInfos)
	{
		mock.mockProxy.verifyZeroInteractions(pos);
	}

	/**
	    Enables stubbing methods. Use it when you want the mock to return particular value when particular method is called. 
	    
	    Simply put: "<b>When</b> the x method is called <b>then</b> return y".
	   
	    Examples:
		
		````
	    when(mock.someMethod()).thenReturn(10);
		
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
	      
	    ````

	    @param reference to the mock's method signature to stub
	    @return dynamic Stubber for matching method
	**/
	macro static public function when(expr:ExprOf<Dynamic>):ExprOf<mockatoo.internal.Stubber>
	{
		return StubbingMacro.createWhen(expr.typed());
	}

	/**
		Shorthand for stubbing a when().thenReturn
		````
	    Mockatoo.returns(mock.someMethod("foo"), "someValue");

	    //or with using
	    mock.someMethod("foo").returns("someValue");

	    //both of these are the equivalent of
	    Mockatoo.when(mock.someMethod("foo")).thenReturn("someValue");
	    ````
	**/
	macro static public function returns(expr:ExprOf<Dynamic>, value:Expr):ExprOf<mockatoo.internal.Stubber>
	{
		return StubbingMacro.returns(expr.typed(), value);
	}

	/**
		Shorthand for stubbing a when().thenThrow
		````
	    Mockatoo.throws(mock.someMethod("foo"), "some exception");

	    //or with using
	    mock.someMethod("foo").throws("some exception");

	    //both of these are the equivalent of
	    Mockatoo.when(mock.someMethod("foo")).thenThrow("some exception");
	  	````
	**/
	macro static public function throws(expr:ExprOf<Dynamic>, value:Expr):ExprOf<mockatoo.internal.Stubber>
	{
		return StubbingMacro.throws(expr.typed(), value);
	}

	/**
		Shorthand for stubbing a when().thenCall 
		````
	    Mockatoo.calls(mock.someMethod("foo"), someFunction);

	    //or with using
	    mock.someMethod("foo").calls(someFunction);

	    //both of these are the equivalent of
	    Mockatoo.when(mock.someMethod("foo")).thenCall(someFunction);
	    ````
	**/
	macro static public function calls(expr:ExprOf<Dynamic>, value:Expr):ExprOf<mockatoo.internal.Stubber>
	{
		return StubbingMacro.calls(expr.typed(), value);
	}

	/**
		Shorthand for stubbing a when().thenCallRealMethod
		````
	    Mockatoo.callsRealMethod(mock.someMethod("foo"));

	    //or with using
	    mock.someMethod("foo").callsRealMethod();

	    //both of these are the equivalent of
	    Mockatoo.when(mock.someMethod("foo")).thenCallRealMethod();
		````
	**/
	macro static public function callsRealMethod(expr:ExprOf<Dynamic>):ExprOf<mockatoo.internal.Stubber>
	{
		return StubbingMacro.callsRealMethod(expr.typed());
	}

	/**
		Shorthand for stubbing a when().thenStub()
		````
	    Mockatoo.stub(mock.someMethod("foo"));

	    //or with using
	    mock.someMethod("foo").stub();

	    //both of these are the equivalent of
	    Mockatoo.when(mock.someMethod("foo")).thenStub();
	    ````
	**/
	macro static public function stub(expr:ExprOf<Dynamic>):ExprOf<mockatoo.internal.Stubber>
	{
		return StubbingMacro.stubs(expr.typed());
	}

	/**
		Resets a mock object, removing any existing stubbings or verifications
		on the methods of the instance
	**/
	static public function reset(mock:Dynamic)
	{
		Console.assert(mock != null, "Cannot verify [null] mock");
		Console.assert(Std.is(mock, Mock), "Object is not an instance of mock");
		return mock.mockProxy.reset();
	}
}

/**
	Provides compatibility in haxe3 for "using" Mockatoo on methods that return Void.
	This is not needed when calling static Mockatoo functions directly 
**/
class MockatooVoid
{	
	/**
		Verifies certain behavior happened on a method that returns Void at least once / exact number of times / never
		@see Mockatoo.verify
	**/
	macro static public function verify(expr:ExprOf<Void>, ?mode:ExprOf<VerificationMode>):ExprOf<mockatoo.internal.Verification>
	{
		return VerifyMacro.create(expr.typed(),mode);
	}

	/**
	    Enables stubbing methods that return Void
	   	@see Mockatoo.when
   **/
	macro static public function when(expr:ExprOf<Void>):ExprOf<mockatoo.internal.Stubber>
	{
		return StubbingMacro.createWhen(expr.typed());
	}

	/**
		Shorthand for stubbing a when().thenReturn on a method that returns Void
		@see Mockatoo.returns
	**/
	macro static public function returns(expr:ExprOf<Void>, value:Expr):ExprOf<mockatoo.internal.Stubber>
	{
		return StubbingMacro.returns(expr.typed(), value);
	}

	/**
		Shorthand for stubbing a when().thenThrow on a method that returns Void
		@see Mockatoo.throws
	**/
	macro static public function throws(expr:ExprOf<Void>, value:Expr):ExprOf<mockatoo.internal.Stubber>
	{
		return StubbingMacro.throws(expr.typed(), value);
	}

	/**
		Shorthand for stubbing a when().thenCall on a method that returns Void
		@see Mockatoo.calls
	**/
	macro static public function calls(expr:ExprOf<Void>, value:Expr):ExprOf<mockatoo.internal.Stubber>
	{
		return StubbingMacro.calls(expr.typed(), value);
	}

	/**
		Shorthand for stubbing a when().thenCallRealMethod on a method that returns Void
		@see Mockatoo.callsRealMethod
	**/
	macro static public function callsRealMethod(expr:ExprOf<Void>):ExprOf<mockatoo.internal.Stubber>
	{
		return StubbingMacro.callsRealMethod(expr.typed());
	}

	/**
		Shorthand for stubbing a when().thenStub() on a method that returns Void
		@see Mockatoo.stub
	**/
	macro static public function stub(expr:ExprOf<Void>):ExprOf<mockatoo.internal.Stubber>
	{
		return StubbingMacro.stubs(expr.typed());
	}
}

/**
	Allows flexible verification or stubbing of arguments based on type. 

	````
	//if using 'using', you may need to cast the matcher to avoid a false compilation error
	mock.someMethod(cast anyString).verify();

	//if not using 'using'
	verify(mock).someMethod(anyString);
	````
**/
enum Matcher
{
	anyString;
	anyInt;
	anyFloat;
	anyBool;
	anyIterator; //array, map, iterable, iterator, etc
	anyObject;  //anonymous data structure
	anyEnum;
	enumOf(e:Enum<Dynamic>);  //an enum value of a specific enum type
	instanceOf(c:Class<Dynamic>);
	isNotNull; // any non null value
	any;  // wildcard for any value
	customMatcher(f:Dynamic -> Bool); //custom function to verify value
}

/**
	Allows verifying that certain behavior happened at least once / exact number
	of times / never. E.g:
	
	````
	
	// if using 'using'
	mock.someMethod("was called five times").verify(times(5));
	
	// if not using 'using'
	verify(mock, times(5)).someMethod("was called five times");
	
	// other examples
	verify(mock, never.someMethod("was never called");
	verify(mock, atLeastOnce.someMethod("was called at least once");
	verify(mock, atLeast(2)).someMethod("was called at least twice");
	verify(mock, atMost(3)).someMethod("was called at most 3 times");
	
	````
	
	<b>times(1) is the default</b> and can be omitted
**/
enum VerificationMode
{
	times(value:Int);
	atLeastOnce;
	atLeast(value:Int);
	never;
	atMost(value:Int);
}

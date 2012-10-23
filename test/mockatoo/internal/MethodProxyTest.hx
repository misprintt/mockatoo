package mockatoo.internal;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mockatoo.internal.MethodProxy;
import mockatoo.exception.VerificationException;
import mockatoo.exception.StubbingException;
import mockatoo.Mockatoo;
import mockatoo.VerificationMode;
import mockatoo.Matcher;
/**
* Auto generated MassiveUnit Test Class  for mockatoo.internal.MethodProxy 
*/
class MethodProxyTest 
{
	var instance:MethodProxy; 
	
	public function new() 
	{
		
	}
	
	@BeforeClass
	public function beforeClass():Void
	{
	}
	
	@AfterClass
	public function afterClass():Void
	{
	}
	
	@Before
	public function setup():Void
	{

	}
	
	@After
	public function tearDown():Void
	{
	}

	@Test
	public function should_call_and_return():Void
	{
		instance = createInstance();
		var result = instance.callAndReturn([], false);

		Assert.areEqual(false, result);
	}

	@Test
	public function should_verify_no_args():Void
	{
		var args:Array<Dynamic> = [];
		instance = createInstance();

		try
		{
			instance.verify(times(1), args);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.call(args);
		instance.verify(times(1), args);
	}

	@Test
	public function should_verify_with_args():Void
	{
		var args:Array<Dynamic> = ["foo", "bar"];
		instance = createInstance();

		try
		{
			instance.verify(times(1), args);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.call(args);
		instance.verify(times(1), args);
	}

	@Test
	public function should_verify_multiple_times():Void
	{
		var args:Array<Dynamic> = ["foo"];
		instance = createInstance();

		try
		{
			instance.verify(times(2), args);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.call(args);
			instance.verify(times(2), args);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.call(args);
		instance.verify(times(2), args);
	}

	@Test
	public function should_verify_zero_times():Void
	{
		var args:Array<Dynamic> = ["foo"];
		instance = createInstance();

		instance.verify(times(0), args);

		try
		{
			instance.call(args);
			instance.verify(times(0), args);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

	}

	@Test
	public function should_verify_never():Void
	{
		var args:Array<Dynamic> = ["foo"];
		instance = createInstance();

		instance.verify(never, args);

		try
		{
			instance.call(args);
			instance.verify(never, args);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

	}

	@Test
	public function should_verify_atLeastOnce():Void
	{
		var args:Array<Dynamic> = ["foo"];
		instance = createInstance();

		try
		{
			instance.verify(atLeastOnce, args);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.call(args);
		instance.verify(atLeastOnce, args);

		instance.call(args);
		instance.verify(atLeastOnce, args);
	}

	@Test
	public function should_verify_atLeast_one():Void
	{
		var args:Array<Dynamic> = ["foo"];
		instance = createInstance();

		try
		{
			instance.verify(atLeast(1), args);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.call(args);
		instance.verify(atLeast(1), args);

		instance.call(args);
		instance.verify(atLeast(1), args);
	}

	@Test
	public function should_verify_atLeast_multiple():Void
	{
		var args:Array<Dynamic> = ["foo"];
		instance = createInstance();

		try
		{
			instance.verify(atLeast(2), args);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.call(args);
			instance.verify(atLeast(2), args);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.call(args);
		instance.verify(atLeast(2), args);
	}

	@Test
	public function should_verify_atMost_one():Void
	{
		var args:Array<Dynamic> = ["foo"];
		instance = createInstance();

		instance.verify(atMost(1), args);

		instance.call(args);
		instance.verify(atMost(1), args);

		try
		{
			instance.call(args);
			instance.verify(atMost(1), args);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}
	}


	@Test
	public function should_not_verify_with_different_number_of_args():Void
	{
		var args:Array<Dynamic> = ["foo", "bar"];
		instance = createInstance();


		instance.call(["foo"]);

		try
		{
			instance.verify(times(1), args);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

	}

	@Test
	public function should_not_verify_with_different_arg_values():Void
	{
		instance = createInstance();


		instance.call(["foo"]);

		try
		{
			instance.verify(times(1), ["bar"]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.call(["bar"]);
		instance.verify(times(1), ["bar"]);
		

	}


	@Test
	public function should_verify_null():Void
	{
		instance = createInstance();

		try
		{
			instance.call(["1"]);
			instance.verify(times(1), [null]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.call([null]);
		instance.verify(times(1), [null]);
	}

	@Test
	public function should_verify_enum():Void
	{
		instance = createInstance();

		instance.call([SomeEnum.foo]);

		try
		{
			instance.verify(times(1), [SomeEnum.bar]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.verify(times(1), [SomeOtherEnum.foo]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.verify(times(1), [SomeEnum.foo]);
	}

	// ------------------------------------------------------------------------- MATCHES

	@Test
	public function should_verify_anyString():Void
	{
		instance = createInstance();

		try
		{
			instance.call([false]);
			instance.verify(times(1), [anyString]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.call([null]);
			instance.verify(times(1), [anyString]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.call(["foo"]);
		instance.verify(times(1), [anyString]);
	}

	@Test
	public function should_verify_anyInt():Void
	{
		instance = createInstance();

		try
		{
			instance.call([1.1]);
			instance.verify(times(1), [anyInt]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.call([null]);
			instance.verify(times(1), [anyInt]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.call([1]);
		instance.verify(times(1), [anyInt]);
	}

	@Test
	public function should_verify_anyFloat():Void
	{
		instance = createInstance();

		try
		{
			instance.call([null]);
			instance.verify(times(1), [anyFloat]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}


		instance.call([1.1]);
		instance.verify(times(1), [anyFloat]);

		instance.call([1]);
		instance.verify(times(2), [anyFloat]); //int is valid flaot
	}

	@Test
	public function should_verify_anyBool():Void
	{
		instance = createInstance();

		try
		{
			instance.call([1]);
			instance.verify(times(1), [anyBool]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.call([null]);
			instance.verify(times(1), [anyBool]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.call([true]);
		instance.verify(times(1), [anyBool]);

		instance.call([false]);
		instance.verify(times(2), [anyBool]);
	}

	@Test
	public function should_verify_anyObject():Void
	{
		instance = createInstance();

		try
		{
			instance.call([1]);
			instance.verify(times(1), [anyObject]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.call([null]);
			instance.verify(times(1), [anyObject]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.call(["foo"]);
			instance.verify(times(1), [anyObject]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.call([{foo:true}]);
		instance.verify(times(1), [anyObject]);

		instance.call([new Hash<String>()]);
		instance.verify(times(1), [anyObject]); //doesnt count instances - only annonomous objects
	}

	@Test
	public function should_verify_anyEnumValue():Void
	{
		instance = createInstance();

		try
		{
			instance.call([1]);
			instance.verify(times(1), [anyEnum]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.call([null]);
			instance.verify(times(1), [anyEnum]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}


		instance.call([SomeEnum.foo]);
		instance.verify(times(1), [anyEnum]);

		instance.call([SomeOtherEnum.bar]);
		instance.verify(times(2), [anyEnum]); 
	}

	@Test
	public function should_verify_anyEnumValue_of_specific_enum_type():Void
	{
		instance = createInstance();

		try
		{
			instance.call([SomeOtherEnum.foo]);
			instance.verify(times(1), [enumOf(SomeEnum)]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}


		instance.call([SomeEnum.foo]);
		instance.verify(times(1), [enumOf(SomeEnum)]);

		instance.call([SomeEnum.bar]);
		instance.verify(times(2), [enumOf(SomeEnum)]); 
	}


	@Test
	public function should_verify_anyInstanceOf():Void
	{
		instance = createInstance();

		try
		{
			instance.call([1]);
			instance.verify(times(1), [instanceOf(SomeClass)]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.call([null]);
			instance.verify(times(1), [instanceOf(SomeClass)]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.call([new Hash<String>()]);
			instance.verify(times(1), [instanceOf(SomeClass)]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.call([new SomeClass()]);
		instance.verify(times(1), [instanceOf(SomeClass)]);

		instance.call([new SomeSubClass()]);
		instance.verify(times(2), [instanceOf(SomeClass)]); 

		instance.verify(times(1), [instanceOf(SomeSubClass)]); 
	}



	@Test
	public function should_verify_isNotNull():Void
	{
		instance = createInstance();

		try
		{
			instance.call([null]);
			instance.verify(times(1), [isNotNull]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.call([1]);
		instance.verify(times(1), [isNotNull]);

		instance.call(["foo"]);
		instance.verify(times(2), [isNotNull]);

		instance.call([new SomeClass()]);
		instance.verify(times(3), [isNotNull]);

		instance.call([SomeEnum.foo]);
		instance.verify(times(4), [isNotNull]);
	}

	@Test
	public function should_verify_isNull():Void
	{
		instance = createInstance();

		try
		{
			instance.call([1]);
			instance.verify(times(1), [isNull]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.call([null]);
		instance.verify(times(1), [isNull]);

	}

	@Test
	public function should_verify_any():Void
	{
		instance = createInstance();

		instance.call([1]);
		instance.verify(times(1), [any]);

		instance.call([null]);
		instance.verify(times(2), [any]);
	}

	@Test
	public function should_verify_custom():Void
	{
		instance = createInstance();

		var f = function(value:Dynamic):Bool
		{
			return Std.is(value, String) && value.charAt(0) == "f";
		}

		try
		{
			instance.call(["bar"]);
			instance.verify(times(1), [customMatcher(f)]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}


		instance.call(["foo"]);
		instance.verify(times(1), [customMatcher(f)]);
	}


	@Test
	public function should_verify_iterator():Void
	{
		instance = createInstance();

		try
		{
			instance.call([1]);
			instance.verify(times(1), [anyIterator]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.call([null]);
			instance.verify(times(1), [anyIterator]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}
		
		var hash = new Hash<String>();
		instance.call([hash]);
		instance.verify(times(1), [anyIterator]);

		var array = new Array<Int>();
		instance.call([array]);
		instance.verify(times(2), [anyIterator]);

		var intHash = new IntHash<Int>();
		instance.call([intHash]);
		instance.verify(times(3), [anyIterator]);

		var list = new List<String>();
		instance.call([list]);
		instance.verify(times(4), [anyIterator]);

		var someIterable = new SomeIterable("foo");
		instance.call([someIterable]);
		instance.verify(times(5), [anyIterator]);

		var someIterator = new SomeIterator("foo");
		instance.call([someIterator]);
		instance.verify(times(6), [anyIterator]);
	}

	@Test
	public function should_verify_multiple_matches():Void
	{
		instance = createInstance();
		instance.call([1, "foo", null, new Array<Bool>()]);
		instance.verify(times(1), [anyInt, anyString, null , anyIterator]);
	}


	// ------------------------------------------------------------------------- Stubbing


	@Test
	public function should_return_value_for_stub():Void
	{
		instance = createInstance(["Int"], "Int");

		instance.addReturnFor([1], [1]);

		var result = instance.callAndReturn([0], 0);

		Assert.areEqual(0, result);

		result = instance.callAndReturn([1], 0);

		Assert.areEqual(1, result);
	}

	@Test
	public function should_throw_value_for_stub():Void
	{
		instance = createInstance(["Int"], "Int");

		instance.addThrowFor([1], ["exception"]);

		var result = instance.callAndReturn([0], 0);

		Assert.areEqual(0, result);

		try
		{
			result = instance.callAndReturn([1], 0);
		}
		catch(e:String)
		{
			Assert.areEqual("exception", e);
		}
	}

	@Test
	public function should_callback_answer_for_stub():Void
	{
		instance = createInstance(["Int"], "Int");

		var wasCalled:Bool = false;
		var f = function(args:Array<Dynamic>)
		{
			wasCalled = true;
			return 1;
		}

		instance.addCallbackFor([1], [f]);

		var result = instance.callAndReturn([0], 0);

		Assert.areEqual(0, result);


		result = instance.callAndReturn([1], 0);

		Assert.areEqual(1, result);
		Assert.isTrue(wasCalled);
	}

	//
	@Test
	public function should_stub_method_with_void_return():Void
	{
		instance = createInstance();

		try
		{
			instance.addReturnFor([], [1]);
			Assert.fail("Expected StubbingException");
		}
		catch(e:StubbingException){}
		

		instance.addThrowFor([], ["exception"]);

		try
		{
			instance.call([]);
			Assert.fail("Expected exception");
		}
		catch(e:String)
		{
			Assert.areEqual("exception", e);
		}

		var wasCalled:Bool = false;
		var f = function(args:Array<Dynamic>)
		{
			wasCalled = true;
		}

		instance.addCallbackFor([], [f]);
		instance.call([]);
		Assert.isTrue(wasCalled);

	}

	@Test
	public function should_throw_exception_if_callback_is_not_function():Void
	{
		instance = createInstance();

		try
		{
			instance.addCallbackFor([], ["notAFunction"]);
			Assert.fail("Expected StubbingException");
		}
		catch(e:StubbingException){}

	}




	@Test
	public function should_add_to_existing_stub():Void
	{
		instance = createInstance(["Int"], "Int");

		var wasCalled:Bool = false;
		var f = function(args:Array<Dynamic>)
		{
			wasCalled = true;
			return 100;
		}

		instance.addReturnFor([1], [1]);
		instance.addReturnFor([1], [2]);
		instance.addThrowFor([1], ["exception"]);
		instance.addCallbackFor([1], [f]);

		var result = instance.callAndReturn([1], 0);

		Assert.areEqual(1, result);

		result = instance.callAndReturn([1], 0);

		Assert.areEqual(2, result);

		try
		{
			instance.call([1]);
			Assert.fail("Expected exception");
		}
		catch(e:String)
		{
			Assert.areEqual("exception", e);
		}

		result = instance.callAndReturn([1], 0);

		Assert.areEqual(100, result);
		Assert.isTrue(wasCalled);
	}

	@Test
	public function should_only_return_matching_stubs():Void
	{
		instance = createInstance(["Int"], "Int");

		instance.addReturnFor([1], [1]);
		instance.addReturnFor([1, 2, 3], [2]);

		var result = instance.callAndReturn([1,2,3], 0);

		Assert.areEqual(2, result);
	}


	// ------------------------------------------------------------------------- Internal

	function createInstance(?args:Array<String>,?ret):MethodProxy
	{
		if(args == null) args = [];
		return new MethodProxy("ClassName", "fieldName", args, ret);
	}
}

private enum SomeEnum
{
	foo;
	bar;
}

private enum SomeOtherEnum
{
	foo;
	bar;
}

private class SomeClass
{
	public function new()
	{

	}
}

private class SomeSubClass extends SomeClass
{
	public function new()
	{
		super();
	}
}

private class SomeIterator
{
	var some:SomeIterable;

	public function new( str_: String ) {
		some = new SomeIterable(str_);
	}
	public function iterator ():Iterator<Int>
	{ 
		return some;            
	}
}

private class SomeIterable
{
	public var length: Int;
	private var count: Int;
	private var str: String;
	public function new( str_: String ) {
		count = 0;
		length = str_.length;
		str = str_;   
	}
	public function hasNext(): Bool {
			 return count < length;
	}
	public function next(): Int { 
			 return str.charCodeAt( count++ ); 
	}
}
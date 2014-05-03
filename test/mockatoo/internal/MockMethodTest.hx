package mockatoo.internal;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mockatoo.internal.MockOutcome;
import mockatoo.internal.MockMethod;
import mockatoo.exception.VerificationException;
import mockatoo.exception.StubbingException;
import mockatoo.Mockatoo;
import util.Asserts;
import haxe.ds.IntMap;
import haxe.ds.StringMap;

class MockMethodTest 
{
	var instance:MockMethod; 
	
	public function new() 
	{
		
	}

	@Test
	public function should_call_and_return():Void
	{
		instance = createInstance();
		var result = instance.getOutcomeFor([]);
		Asserts.assertEnumTypeEq(none, result);
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

		instance.getOutcomeFor(args);
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

		instance.getOutcomeFor(args);
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
			instance.getOutcomeFor(args);
			instance.verify(times(2), args);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.getOutcomeFor(args);
		instance.getOutcomeFor(args);
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
			instance.getOutcomeFor(args);
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
			instance.getOutcomeFor(args);
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

		instance.getOutcomeFor(args);
		instance.verify(atLeastOnce, args);

		instance.getOutcomeFor(args);
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

		instance.getOutcomeFor(args);
		instance.verify(atLeast(1), args);

		instance.getOutcomeFor(args);
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
			instance.getOutcomeFor(args);
			instance.verify(atLeast(2), args);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.getOutcomeFor(args);
		instance.getOutcomeFor(args);
		instance.verify(atLeast(1), args);
	}

	@Test
	public function should_verify_atMost_one():Void
	{
		var args:Array<Dynamic> = ["foo"];
		instance = createInstance();

		instance.verify(atMost(1), args);

		instance.getOutcomeFor(args);
		instance.verify(atMost(1), args);

		try
		{
			instance.getOutcomeFor(args);
			instance.getOutcomeFor(args);
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

		instance.getOutcomeFor(["foo"]);

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

		instance.getOutcomeFor(["foo"]);

		try
		{
			instance.verify(times(1), ["bar"]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.getOutcomeFor(["bar"]);
		instance.verify(times(1), ["bar"]);
		

	}

	@Test
	public function should_verify_null():Void
	{
		instance = createInstance();

		try
		{
			instance.getOutcomeFor(["1"]);
			instance.verify(times(1), [null]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.getOutcomeFor([null]);
		instance.verify(times(1), [null]);
	}

	@Test
	public function should_verify_enum():Void
	{
		instance = createInstance();

		instance.getOutcomeFor([SomeEnum.foo]);

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
			instance.getOutcomeFor([false]);
			instance.verify(times(1), [anyString]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.getOutcomeFor([null]);
			instance.verify(times(1), [anyString]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.getOutcomeFor(["foo"]);
		instance.verify(times(1), [anyString]);
	}

	@Test
	public function should_verify_anyInt():Void
	{
		instance = createInstance();

		try
		{
			instance.getOutcomeFor([1.1]);
			instance.verify(times(1), [anyInt]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.getOutcomeFor([null]);
			instance.verify(times(1), [anyInt]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.getOutcomeFor([1]);
		instance.verify(times(1), [anyInt]);
	}

	@Test
	public function should_verify_anyFloat():Void
	{
		instance = createInstance();

		try
		{
			instance.getOutcomeFor([null]);
			instance.verify(times(1), [anyFloat]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.getOutcomeFor([1.1]);
		instance.verify(times(1), [anyFloat]);

		instance.getOutcomeFor([1]);
		instance.verify(times(1), [anyFloat]); //int is valid flaot
	}

	@Test
	public function should_verify_anyBool():Void
	{
		instance = createInstance();

		try
		{
			instance.getOutcomeFor([1]);
			instance.verify(times(1), [anyBool]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.getOutcomeFor([null]);
			instance.verify(times(1), [anyBool]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.getOutcomeFor([true]);
		instance.verify(times(1), [anyBool]);

		instance.getOutcomeFor([false]);
		instance.getOutcomeFor([false]);
		instance.verify(times(2), [anyBool]);
	}

	@Test
	public function should_verify_anyObject():Void
	{
		instance = createInstance();

		try
		{
			instance.getOutcomeFor([1]);
			instance.verify(times(1), [anyObject]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.getOutcomeFor([null]);
			instance.verify(times(1), [anyObject]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.getOutcomeFor(["foo"]);
			instance.verify(times(1), [anyObject]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.getOutcomeFor([{foo:true}]);
		instance.verify(times(1), [anyObject]);

		instance.getOutcomeFor([new StringMap<String>()]);
		instance.verify(never, [anyObject]); //doesnt count instances - only annonomous objects
	}

	@Test
	public function should_verify_anyEnumValue():Void
	{
		instance = createInstance();

		try
		{
			instance.getOutcomeFor([1]);
			instance.verify(times(1), [anyEnum]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.getOutcomeFor([null]);
			instance.verify(times(1), [anyEnum]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.getOutcomeFor([SomeEnum.foo]);
		instance.verify(times(1), [anyEnum]);

		instance.getOutcomeFor([SomeOtherEnum.bar]);
		instance.verify(times(1), [anyEnum]); 
	}

	@Test
	public function should_verify_anyEnumValue_of_specific_enum_type():Void
	{
		instance = createInstance();

		try
		{
			instance.getOutcomeFor([SomeOtherEnum.foo]);
			instance.verify(times(1), [enumOf(SomeEnum)]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.getOutcomeFor([SomeEnum.foo]);
		instance.verify(times(1), [enumOf(SomeEnum)]);

		instance.getOutcomeFor([SomeEnum.bar]);
		instance.verify(times(1), [enumOf(SomeEnum)]); 
	}

	@Test
	public function should_verify_anyInstanceOf():Void
	{
		instance = createInstance();

		try
		{
			instance.getOutcomeFor([1]);
			instance.verify(times(1), [instanceOf(SomeClass)]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.getOutcomeFor([null]);
			instance.verify(times(1), [instanceOf(SomeClass)]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.getOutcomeFor([new StringMap<String>()]);
			instance.verify(times(1), [instanceOf(SomeClass)]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.getOutcomeFor([new SomeClass()]);
		instance.verify(times(1), [instanceOf(SomeClass)]);

		instance.getOutcomeFor([new SomeSubClass()]);
		instance.verify(times(1), [instanceOf(SomeClass)]); 

		instance.getOutcomeFor([new SomeSubClass()]);
		instance.verify(times(1), [instanceOf(SomeSubClass)]); 
	}

	@Test
	public function should_verify_isNotNull():Void
	{
		instance = createInstance();

		try
		{
			instance.getOutcomeFor([null]);
			instance.verify(times(1), [isNotNull]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.getOutcomeFor([1]);
		instance.verify(times(1), [isNotNull]);

		instance.getOutcomeFor(["foo"]);
		instance.verify(times(1), [isNotNull]);

		instance.getOutcomeFor([new SomeClass()]);
		instance.verify(times(1), [isNotNull]);

		instance.getOutcomeFor([SomeEnum.foo]);
		instance.verify(times(1), [isNotNull]);
	}

	@Test
	public function should_verify_any():Void
	{
		instance = createInstance();

		instance.getOutcomeFor([1]);
		instance.verify(times(1), [any]);

		instance.getOutcomeFor([null]);
		instance.verify(times(1), [any]);
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
			instance.getOutcomeFor(["bar"]);
			instance.verify(times(1), [customMatcher(f)]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.getOutcomeFor(["foo"]);
		instance.verify(times(1), [customMatcher(f)]);
	}

	@Test
	public function should_verify_iterator():Void
	{
		instance = createInstance();

		try
		{
			instance.getOutcomeFor([1]);
			instance.verify(times(1), [anyIterator]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.getOutcomeFor([null]);
			instance.verify(times(1), [anyIterator]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}
		
		var map = new StringMap<String>();
		instance.getOutcomeFor([map]);
		instance.verify(times(1), [anyIterator]);

		var array = new Array<Int>();
		instance.getOutcomeFor([array]);
		instance.verify(times(1), [anyIterator]);

		
		var intMap = new IntMap<Int>();

		instance.getOutcomeFor([intMap]);
		instance.verify(times(1), [anyIterator]);
		var list = new List<String>();
		instance.getOutcomeFor([list]);
		instance.verify(times(1), [anyIterator]);

		var someIterable = new SomeIterable("foo");
		instance.getOutcomeFor([someIterable]);
		instance.verify(times(1), [anyIterator]);

		var someIterator = new SomeIterator("foo");
		instance.getOutcomeFor([someIterator]);
		instance.verify(times(1), [anyIterator]);
	}

	@Test
	public function should_verify_multiple_matches():Void
	{
		instance = createInstance();
		instance.getOutcomeFor([1, "foo", null, new Array<Bool>()]);
		instance.verify(times(1), [anyInt, anyString, null , anyIterator]);
	}

	// ------------------------------------------------------------------------- Stubbing

	@Test
	public function should_return_value_for_stub():Void
	{
		instance = createInstance(["Int"], "Int");

		instance.addReturnFor([1], [1]);

		var result = instance.getOutcomeFor([0]);

		Asserts.assertEnumTypeEq(none, result);

		result = instance.getOutcomeFor([1]);

		Asserts.assertEnumTypeEq(returns(1), result);
	}

	@Test
	public function should_throw_value_for_stub():Void
	{
		instance = createInstance(["Int"], "Int");

		instance.addThrowFor([1], ["exception"]);

		var result = instance.getOutcomeFor([0]);

		Asserts.assertEnumTypeEq(none, result);

		result = instance.getOutcomeFor([1]);
		Asserts.assertEnumTypeEq(throws("exception"), result);
	}

	@Test
	public function should_callback_answer_for_stub():Void
	{
		instance = createInstance(["Int"], "Int");

		var f = function(args:Array<Dynamic>){return 0;}

		instance.addCallbackFor([1], [f]);

		var result = instance.getOutcomeFor([0]);
		Asserts.assertEnumTypeEq(none, result);

		result = instance.getOutcomeFor([1]);
		Asserts.assertEnumTypeEq(calls(f), result);
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
		

		var f = function(args:Array<Dynamic>)
		{
			return;
		}

		instance.addThrowFor([], ["exception"]);
		instance.addCallbackFor([], [f]);

		var result = instance.getOutcomeFor([]);
		Asserts.assertEnumTypeEq(throws("exception"), result);

		result = instance.getOutcomeFor([]);
		Asserts.assertEnumTypeEq(calls(f), result);
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

		var f = function(args:Array<Dynamic>)
		{
			return 100;
		}

		instance.addReturnFor([1], [1]);
		instance.addReturnFor([1], [2]);
		instance.addThrowFor([1], ["exception"]);
		instance.addCallbackFor([1], [f]);
		instance.addDefaultStubFor([1]);
		instance.addCallRealMethodFor([1]);

		var result = instance.getOutcomeFor([1]);
		Asserts.assertEnumTypeEq(returns(1), result);

		result = instance.getOutcomeFor([1]);

		Asserts.assertEnumTypeEq(returns(2), result);

		result = instance.getOutcomeFor([1]);
		Asserts.assertEnumTypeEq(throws("exception"), result);

		result = instance.getOutcomeFor([1]);
		Asserts.assertEnumTypeEq(calls(f), result);

		result = instance.getOutcomeFor([1]);
		Asserts.assertEnumTypeEq(stubs, result);

		result = instance.getOutcomeFor([1]);
		Asserts.assertEnumTypeEq(callsRealMethod, result);
	}

	@Test
	public function should_only_return_matching_stubs():Void
	{
		instance = createInstance(["Int"], "Int");

		instance.addReturnFor([1], [1]);
		instance.addReturnFor([1, 2, 3], [2]);

		var result = instance.getOutcomeFor([1,2,3]);

		Asserts.assertEnumTypeEq(returns(2), result);
	}

	@Test
	public function should_return_value_for_stub_matcher():Void
	{
		instance = createInstance(["Int"], "Int");

		instance.addReturnFor([anyInt], [666]);

		var result = instance.getOutcomeFor([0]);

		Asserts.assertEnumTypeEq(returns(666), result);
	}

	@Test
	public function should_addCallRealMethodFor():Void
	{
		instance = createInstance(["Int"], "Int");

		instance.addCallRealMethodFor([1]);

		var result = instance.getOutcomeFor([0]);

		Asserts.assertEnumTypeEq(none, result);

		result = instance.getOutcomeFor([1]);

		Asserts.assertEnumTypeEq(callsRealMethod, result);
	}

	@Test
	public function should_addDefaultStubFor():Void
	{
		instance = createInstance(["Int"], "Int");

		instance.addDefaultStubFor([1]);

		var result = instance.getOutcomeFor([0]);

		Asserts.assertEnumTypeEq(none, result);

		result = instance.getOutcomeFor([1]);

		Asserts.assertEnumTypeEq(stubs, result);
	}

	@Test
	public function shouldResultIn100PercentCoverage()
	{
		instance = createInstance(["Int"], "Int");

		instance.addDefaultStubFor([1]);
		Assert.isNull(untyped instance.getStubbingForArgs([2], true));
	}

	// ------------------------------------------------------------------------- Internal

	function createInstance(?args:Array<String>,?ret):MockMethod
	{
		if (args == null) args = [];
		return new MockMethod("ClassName", "fieldName", args, ret);
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
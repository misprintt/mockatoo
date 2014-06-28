package mockatoo;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mockatoo.exception.VerificationException;
import mockatoo.Mockatoo;
import mockatoo.Mock;
import test.TestClasses;
import util.Asserts;

import mockatoo.Mockatoo.*;
using mockatoo.Mockatoo;

class MockatooStubbingTest 
{
	public function new() 
	{
		
	}

	// ------------------------------------------------------------------------- when

	@Test
	public function should_when()
	{
		var instance = Mockatoo.mock(VariableArgumentsClass);

		var f = function(args:Array<Dynamic>)
		{
			return args[0];
		}
		var stub = Mockatoo.when(instance.one(1)).thenReturn(10).thenCall(f).thenThrow("exception");

		var result = instance.one(1);
		Assert.areEqual(10, result);

		result = instance.one(1);
		Assert.areEqual(1, result);

		try
		{
			instance.one(1);
			Assert.fail("Expected custom exception");
		}
		catch(e:String)
		{
			Assert.areEqual("exception", e);
		}
	}

	@Test
	public function should_cast_to_mock_when()
	{
		var instance:VariableArgumentsClass = Mockatoo.mock(VariableArgumentsClass);

		var stub = Mockatoo.when(instance.one(1));

		Assert.isNotNull(stub);
	}

	// ------------------------------------------------------------------------- advanced stubbing macros

	@Test
	public function should_generate_returns()
	{

		var instance = Mockatoo.mock(StubSomeClass);

		Mockatoo.returns(instance.toString(), "foo");
		instance.toString().returns("bar");
		
		var result = instance.toString();

		Assert.areEqual("foo", result);

		result = instance.toString();

		Assert.areEqual("bar", result);
	}

	@Test
	public function should_generate_return_using_matcher()
	{
		var instance = Mockatoo.mock(StubSomeClass);

		instance.parse(cast anyString).returns("foo");

		var result = instance.parse("a");

		Assert.areEqual("foo", result);

		Mockatoo.reset(instance);
		instance.parse(cast anyString).returns("bar");

		result = instance.parse("b");

		Assert.areEqual("bar", result);
	}

	@Test
	public function should_generate_throws()
	{
		var instance = Mockatoo.mock(StubSomeClass);

		Mockatoo.throws(instance.toString(), "foo");
		instance.toString().throws("bar");
		
		try
		{
			instance.toString();
			Assert.fail("expected exception 'foo'");
		}
		catch(e:String)
		{
			Assert.areEqual("foo", e);
		}

		try
		{
			instance.toString();
			Assert.fail("expected exception 'bar'");
		}
		catch(e:String)
		{
			Assert.areEqual("bar", e);
		}
	}

	@Test
	public function should_generate_calls()
	{
		var instance = Mockatoo.mock(StubSomeClass);

		var f = function(args)
		{
			return "foo";
		}

		var f2 = function(args)
		{
			return "bar";
		}

		Mockatoo.calls(instance.toString(), f);
		instance.toString().calls(f2);

		var result = instance.toString();

		Assert.areEqual("foo", result);

		result = instance.toString();

		Assert.areEqual("bar", result);
	}

	@Test
	public function should_generate_callsRealMethod()
	{
		var instance = Mockatoo.mock(StubSomeClass);

		instance.toString().callsRealMethod();
		
		var result = instance.toString();
		Assert.areEqual("", result);
	}

	@Test
	public function should_generate_stub()
	{
		var instance = Mockatoo.spy(StubSomeClass);
		
		var result = instance.toString();
		Assert.areEqual("", result);

		instance.toString().stub();

		result = instance.toString();
		Assert.isNull(result);
	}

	@Test
	public function should_inject_any_matcher_for_unspecified_method_args()
	{
		var instance = Mockatoo.mock(VariableArgumentsClass);

		Mockatoo.returns(instance.two(), 100);//should have two arguments
		
		var result = instance.two(1,2);

		Assert.areEqual(100, result);
	}

	var mock:StubSomeClass;

	@Test
	public function should_generate_returns_for_instance_mock()
	{
		mock = Mockatoo.mock(StubSomeClass);
		mock.toString().returns("bar");
		
		var result = mock.toString();
		Assert.areEqual("bar", result);
	}

	@Test
	public function should_generate_returns_for_this_instance_mock()
	{
		var mock:StubSomeClass = null;
		this.mock = Mockatoo.mock(StubSomeClass);
		this.mock.toString().returns("bar");
		
		var result = this.mock.toString();
		Assert.areEqual("bar", result);
	}
}

class StubSomeClass
{
	public function new()
	{

	}

	public function test(value:String)
	{

	}

	public function toString():String
	{
		return "";
	}

	public function parse(value:String):String
	{
		return value;
	}
}


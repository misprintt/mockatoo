package mockatoo;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mockatoo.exception.VerificationException;
import mockatoo.Mockatoo;
import mockatoo.Mock;
import test.TestClasses;
import util.Asserts;

using mockatoo.Mockatoo;

class MockatooStubbingTest 
{
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
		var instance = StubSomeClass.mock();

		Mockatoo.returns(instance.toString(), "foo");
		instance.toString().returns("bar");
		
		var result = instance.toString();

		Assert.areEqual("foo", result);

		result = instance.toString();

		Assert.areEqual("bar", result);
	}

	@Test
	public function should_generate_throws()
	{
		var instance = StubSomeClass.mock();

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
		var instance = StubSomeClass.mock();

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
		var instance = StubSomeClass.mock();

		instance.toString().callsRealMethod();
		
		var result = instance.toString();
		Assert.areEqual("", result);
	}

	@Test
	public function should_generate_stub()
	{
		var instance = StubSomeClass.spy();
		
		var result = instance.toString();
		Assert.areEqual("", result);

		instance.toString().stub();

		result = instance.toString();
		Assert.isNull(result);
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
}


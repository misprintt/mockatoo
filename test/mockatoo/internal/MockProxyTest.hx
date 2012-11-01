package mockatoo.internal;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mockatoo.internal.MockProxy;
import mockatoo.internal.MockOutcome;
import mockatoo.Mockatoo;
import mockatoo.exception.VerificationException;
import mockatoo.exception.StubbingException;
import util.Asserts;
/**
* Auto generated MassiveUnit Test Class  for mockatoo.internal.MockProxy 
*/
class MockProxyTest 
{
	var instance:MockProxy; 
	
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
	public function should_verify():Void
	{
		var mock = mockatoo.Mockatoo.mock(ClassToMock);
		instance = new MockProxy(mock);

		var verification = instance.verify();

		instance.getOutcomeFor("none", []);
		verification.none();

		instance.getOutcomeFor("one", [1]);
		verification.one(1);

		instance.getOutcomeFor("two", [1,2]);
		verification.two(1, anyInt);


		instance.getOutcomeFor("three", [1,2,3]);
		verification.three(1, anyInt, isNotNull);
	}

	@Test
	public function should_return_none():Void
	{
		var mock = mockatoo.Mockatoo.mock(ClassToMock);
		instance = new MockProxy(mock);

		var verification = instance.verify();

		var result = instance.getOutcomeFor("two", [1,2]);

		Asserts.assertEnumTypeEq(none, result);
	}


	@Test
	public function should_use_verification_mode():Void
	{
		var mock = mockatoo.Mockatoo.mock(ClassToMock);
		instance = new MockProxy(mock);

		var verification = instance.verify(never);

		instance.getOutcomeFor("none", []);

		try
		{
			verification.none();
		}
		catch(e:VerificationException)
		{

		}

	}

	// ------------------------------------------------------------------------- stubbing


	@Test
	public function should_throw_exception_if_cannot_stub_return_value():Void
	{
		var mock = mockatoo.Mockatoo.mock(ClassToMock);
		instance = new MockProxy(mock);

		var stub = instance.stub("none", []);

		try
		{
			stub.thenReturn("foo");
			Assert.fail("Expected StubbingException");
		}
		catch(e:StubbingException) {}
	}

	@Test
	public function should_return_stubbed_value():Void
	{
		var mock = mockatoo.Mockatoo.mock(ClassToMock);
		instance = new MockProxy(mock);

		var stub = instance.stub("two", [1,2]);

		stub.thenReturn(4);

		var result = instance.getOutcomeFor("two", [1,2]);
		Asserts.assertEnumTypeEq(returns(4), result);
	}

	@Test
	public function should_always_return_last_stub():Void
	{
		var mock = mockatoo.Mockatoo.mock(ClassToMock);
		instance = new MockProxy(mock);

		var stub = instance.stub("two", [1,2]);

		stub.thenReturn(4);

		var result = instance.getOutcomeFor("two", [1,2]);

		Asserts.assertEnumTypeEq(returns(4), result);

		result = instance.getOutcomeFor("two", [1,2]);

		Asserts.assertEnumTypeEq(returns(4), result);
	}


	@Test
	public function should_chain_stubs():Void
	{
		var mock = mockatoo.Mockatoo.mock(ClassToMock);
		instance = new MockProxy(mock);

		var stub = instance.stub("two", [1,2]);

		var exception = new CustomException(); 

		stub.thenReturn(4).thenThrow(exception);

		var result = instance.getOutcomeFor("two", [1,2]);

		Asserts.assertEnumTypeEq(returns(4), result);

		result = instance.getOutcomeFor("two", [1,2]);

		Asserts.assertEnumTypeEq(throws(exception), result);
	}

	@Test
	public function should_call_stubbed_callback():Void
	{
		var mock = mockatoo.Mockatoo.mock(ClassToMock);
		instance = new MockProxy(mock);


		var f = function(args:Array<Dynamic>) {}

		instance.stub("two", [1,2]).thenCall(f);

		var result = instance.getOutcomeFor("two", [1,2]);

		Asserts.assertEnumTypeEq(calls(f), result);
	}

	// ------------------------------------------------------------------------- reset


	@Test
	public function should_reset_stubbing():Void
	{
		var mock = mockatoo.Mockatoo.mock(ClassToMock);
		instance = new MockProxy(mock);
		
		instance.stub("two", [1,2]).thenReturn(4);

		var result = instance.getOutcomeFor("two", [1,2]);

		Asserts.assertEnumTypeEq(returns(4), result);

		instance.reset();

		result = instance.getOutcomeFor("two", [1,2]);

		Asserts.assertEnumTypeEq(none, result);
	}

	@Test
	public function should_reset_verifications():Void
	{
		var mock = mockatoo.Mockatoo.mock(ClassToMock);
		
		instance = new MockProxy(mock);
		instance.getOutcomeFor("two", [1,2]);
		instance.reset();

		try
		{
			instance.verify().two(1, 2);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}
	}
}

class CustomException
{
	public function new()
	{

	}
}

class ClassToMock
{
	public function new()
	{

	}

	public function none()
	{

	}

	public function one(arg1:Int)
	{

	}

	public function two(arg1:Int, arg2:Int):Int
	{
		return -1;
	}

	public function three(arg1:Int, arg2:Int, arg3:Int):Int
	{
		return -1;	
	}
}
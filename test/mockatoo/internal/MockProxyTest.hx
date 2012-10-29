package mockatoo.internal;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mockatoo.internal.MockProxy;
import mockatoo.Mockatoo;
import mockatoo.exception.VerificationException;
import mockatoo.exception.StubbingException;
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

		instance.callMethod("none", []);
		verification.none();

		instance.callMethod("one", [1]);
		verification.one(1);

		instance.callMethodAndReturn("two", [1,2], 1);
		verification.two(1, anyInt);


		instance.callMethodAndReturn("three", [1,2,3], 1);
		verification.three(1, anyInt, isNotNull);
	}

	@Test
	public function should_return_default_value():Void
	{
		var mock = mockatoo.Mockatoo.mock(ClassToMock);
		instance = new MockProxy(mock);

		var verification = instance.verify();

		var result = instance.callMethodAndReturn("two", [1,2], 1);

		Assert.areEqual(1, result);
	}


	@Test
	public function should_use_verification_mode():Void
	{
		var mock = mockatoo.Mockatoo.mock(ClassToMock);
		instance = new MockProxy(mock);

		var verification = instance.verify(never);

		instance.callMethod("none", []);

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
	public function should_throw_stubbed_execption():Void
	{
		var mock = mockatoo.Mockatoo.mock(ClassToMock);
		instance = new MockProxy(mock);

		var stub = instance.stub("none", []);

		stub.thenThrow(new CustomException());

		try
		{
			instance.callMethod("none", []);
			Assert.fail("Expected CustomException");
		}
		catch(e:CustomException){}

		Assert.isTrue(true);
	}

	@Test
	public function should_return_stubbed_value():Void
	{
		var mock = mockatoo.Mockatoo.mock(ClassToMock);
		instance = new MockProxy(mock);

		var stub = instance.stub("two", [1,2]);

		stub.thenReturn(4);

		var result = instance.callMethodAndReturn("two", [1,2], 0);

		Assert.areEqual(4, result);
	}

	@Test
	public function should_always_return_last_stub():Void
	{
		var mock = mockatoo.Mockatoo.mock(ClassToMock);
		instance = new MockProxy(mock);

		var stub = instance.stub("two", [1,2]);

		stub.thenReturn(4);

		var result = instance.callMethodAndReturn("two", [1,2], 0);

		Assert.areEqual(4, result);

		result = instance.callMethodAndReturn("two", [1,2], 0);

		Assert.areEqual(4, result);
	}


	@Test
	public function should_chain_stubs():Void
	{
		var mock = mockatoo.Mockatoo.mock(ClassToMock);
		instance = new MockProxy(mock);

		var stub = instance.stub("two", [1,2]);

		stub.thenReturn(4).thenThrow(new CustomException());

		var result = instance.callMethodAndReturn("two", [1,2], 0);

		Assert.areEqual(4, result);

		try
		{
			instance.callMethodAndReturn("two", [1,2], 0);
			Assert.fail("Expected CustomException");
		}
		catch(e:CustomException){}
	}

	@Test
	public function should_call_stubbed_callback():Void
	{
		var mock = mockatoo.Mockatoo.mock(ClassToMock);
		instance = new MockProxy(mock);


		var stub = instance.stub("two", [1,2]);

		var wasCalled:Bool = false;

		var f = function(args:Array<Dynamic>)
		{
			wasCalled = true;
		}

		stub.thenCall(f);

		instance.callMethodAndReturn("two", [1,2], 0);

		Assert.isTrue(wasCalled);
	}

	// ------------------------------------------------------------------------- reset


	@Test
	public function should_reset_stubbing():Void
	{
		var mock = mockatoo.Mockatoo.mock(ClassToMock);
		instance = new MockProxy(mock);
		
		instance.stub("two", [1,2]).thenReturn(4);

		var result = instance.callMethodAndReturn("two", [1,2], 0);

		Assert.areEqual(4, result);

		instance.reset();

		result = instance.callMethodAndReturn("two", [1,2], 0);
		Assert.areEqual(0, result);
	}

	@Test
	public function should_reset_verifications():Void
	{
		var mock = mockatoo.Mockatoo.mock(ClassToMock);
		
		instance = new MockProxy(mock);
		instance.callMethodAndReturn("two", [1,2], 0);
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
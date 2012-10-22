package mockatoo.internal;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mockatoo.internal.MethodProxy;
import mockatoo.exception.VerificationException;
import mockatoo.Mockatoo;

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
	public function should_match_argCount():Void
	{
		instance = createInstance();
		Assert.areEqual(0, instance.argCount);
	}

	@Test
	public function should_increment_count():Void
	{
		instance = createInstance();
		
		instance.call([]);
		Assert.areEqual(1, instance.count);
		
		instance.call([]);
		Assert.areEqual(2, instance.count);
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



	// @Test
	// public function should_verify_interface():Void
	// {
	// 	var mock = Mockatoo.mock(SimpleInterface);
	// 	mock.test();

	// 	var verified = instance.verify(mock).test();
	// 	Assert.isTrue(verified);
	// }

	// @Test
	// public function should_fail_verification():Void
	// {
	// 	var mock = Mockatoo.mock(SimpleClass);

	// 	try
	// 	{
	// 		instance.verify(mock).test();
	// 		Assert.fail("Expected VerificationException");
	// 	}
	// 	catch(e:VerificationException)
	// 	{
	// 		Assert.isTrue(true);
	// 	}
		
	// }

	// @Test
	// public function should_verify_once():Void
	// {
	// 	var mock = Mockatoo.mock(SimpleClass);
	// 	mock.test();
	// 	instance.verify(mock, times(1)).test();
	// }

	// @Test
	// public function should_verify_twice():Void
	// {
	// 	var mock = Mockatoo.mock(SimpleClass);
	// 	mock.test();

	// 	try
	// 	{
	// 		instance.verify(mock, times(2)).test();
	// 		Assert.fail("Expected VerificationException");
	// 	}
	// 	catch(e:VerificationException){}

	// 	mock.test();
	// 	instance.verify(mock, times(2)).test();
	// }


	// @Test
	// public function should_verify_never():Void
	// {
	// 	var mock = Mockatoo.mock(SimpleClass);
	// 	instance.verify(mock, never).test();

	// 	try
	// 	{
	// 		mock.test();
	// 		instance.verify(mock, never).test();
	// 		Assert.fail("Expected VerificationException");
	// 	}
	// 	catch(e:VerificationException){}
	// }


	// @Test
	// public function should_verify_atLeastOnce():Void
	// {
	// 	var mock = Mockatoo.mock(SimpleClass);

	// 	try
	// 	{
	// 		instance.verify(mock, atLeastOnce).test();
	// 		Assert.fail("Expected VerificationException");
	// 	}
	// 	catch(e:VerificationException){}

	// 	mock.test();
	// 	instance.verify(mock, atLeastOnce).test();

	// 	mock.test();
	// 	instance.verify(mock, atLeastOnce).test();
	// }

	// @Test
	// public function should_verify_atLeast_one():Void
	// {
	// 	var mock = Mockatoo.mock(SimpleClass);

	// 	try
	// 	{
	// 		instance.verify(mock, atLeast(1)).test();
	// 		Assert.fail("Expected VerificationException");
	// 	}
	// 	catch(e:VerificationException){}

	// 	mock.test();
	// 	instance.verify(mock, atLeast(1)).test();

	// 	mock.test();
	// 	instance.verify(mock, atLeast(1)).test();
	// }

	// @Test
	// public function should_verify_atLeast_two():Void
	// {
	// 	var mock = Mockatoo.mock(SimpleClass);

	// 	try
	// 	{
	// 		instance.verify(mock, atLeast(2)).test();
	// 		Assert.fail("Expected VerificationException");
	// 	}
	// 	catch(e:VerificationException){}

	// 	try
	// 	{
	// 		mock.test();
	// 		instance.verify(mock, atLeast(2)).test();
	// 		Assert.fail("Expected VerificationException");
	// 	}
	// 	catch(e:VerificationException){}

	// 	mock.test();
	// 	instance.verify(mock, atLeast(2)).test();
	// }

	// ------------------ variable arguments

	// @Test
	// public function should_verify_with_one_arg():Void
	// {
	// 	var mock = Mockatoo.mock(VariableArgumentsClass);
	// 	mock.one(1);
	// 	instance.verify(mock).one(1);
	// }

	// @Test
	// public function should_verify_with_two_arg():Void
	// {
	// 	var mock = Mockatoo.mock(VariableArgumentsClass);
	// 	mock.two(1,2);
	// 	instance.verify(mock).two(1,2);
	// }

	// @Test
	// public function should_verify_with_two_optional_arg():Void
	// {
	// 	var mock = Mockatoo.mock(VariableArgumentsClass);
	// 	mock.twoOptional(1,2);
	// 	instance.verify(mock).twoOptional(1,2);
	// }

	// ------------------------


	function createInstance(?args:Array<String>,?ret):MethodProxy
	{
		if(args == null) args = [];
		return new MethodProxy("ClassName", "fieldName", args, ret);
	}
}
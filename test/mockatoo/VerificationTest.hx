package mockatoo;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mockatoo.Mockatoo;
import mockatoo.Mock;
import test.TestClasses;
import mockatoo.exception.VerificationException;
/**
* Auto generated MassiveUnit Test Class  for mockatoo.Mockatoo 
*/
class VerificationTest
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

	@Test
	public function should_verify_class():Void
	{
		var mock = Mockatoo.mock(SimpleClass);
		mock.test();
		
		var verified = Mockatoo.verify(mock).test();
		Assert.isTrue(verified);
	}

	@Test
	public function should_verify_interface():Void
	{
		var mock = Mockatoo.mock(SimpleInterface);
		mock.test();

		var verified = Mockatoo.verify(mock).test();
		Assert.isTrue(verified);
	}

	@Test
	public function should_fail_verification():Void
	{
		var mock = Mockatoo.mock(SimpleClass);

		try
		{
			Mockatoo.verify(mock).test();
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException)
		{
			Assert.isTrue(true);
		}
		
	}

	@Test
	public function should_verify_once():Void
	{
		var mock = Mockatoo.mock(SimpleClass);
		mock.test();
		Mockatoo.verify(mock, times(1)).test();
	}

	@Test
	public function should_verify_twice():Void
	{
		var mock = Mockatoo.mock(SimpleClass);
		mock.test();

		try
		{
			Mockatoo.verify(mock, times(2)).test();
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException){}

		mock.test();
		Mockatoo.verify(mock, times(2)).test();
	}


	@Test
	public function should_verify_never():Void
	{
		var mock = Mockatoo.mock(SimpleClass);
		Mockatoo.verify(mock, never).test();

		try
		{
			mock.test();
			Mockatoo.verify(mock, never).test();
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException){}
	}


	@Test
	public function should_verify_atLeastOnce():Void
	{
		var mock = Mockatoo.mock(SimpleClass);

		try
		{
			Mockatoo.verify(mock, atLeastOnce).test();
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException){}

		mock.test();
		Mockatoo.verify(mock, atLeastOnce).test();

		mock.test();
		Mockatoo.verify(mock, atLeastOnce).test();
	}

	@Test
	public function should_verify_atLeast_one():Void
	{
		var mock = Mockatoo.mock(SimpleClass);

		try
		{
			Mockatoo.verify(mock, atLeast(1)).test();
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException){}

		mock.test();
		Mockatoo.verify(mock, atLeast(1)).test();

		mock.test();
		Mockatoo.verify(mock, atLeast(1)).test();
	}

	@Test
	public function should_verify_atLeast_two():Void
	{
		var mock = Mockatoo.mock(SimpleClass);

		try
		{
			Mockatoo.verify(mock, atLeast(2)).test();
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException){}

		try
		{
			mock.test();
			Mockatoo.verify(mock, atLeast(2)).test();
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException){}

		mock.test();
		Mockatoo.verify(mock, atLeast(2)).test();
	}

	// ------------------ variable arguments

	@Test
	public function should_verify_with_one_arg():Void
	{
		var mock = Mockatoo.mock(VariableArgumentsClass);
		mock.one(1);
		Mockatoo.verify(mock).one(1);
	}

	@Test
	public function should_verify_with_two_arg():Void
	{
		var mock = Mockatoo.mock(VariableArgumentsClass);
		mock.two(1,2);
		Mockatoo.verify(mock).two(1,2);
	}

	@Test
	public function should_verify_with_two_optional_arg():Void
	{
		var mock = Mockatoo.mock(VariableArgumentsClass);
		mock.twoOptional(1,2);
		Mockatoo.verify(mock).twoOptional(1,2);
	}

}

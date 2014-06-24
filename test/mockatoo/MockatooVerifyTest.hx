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

class MockatooVerifyTest 
{
	public function new() 
	{
		
	}

	// ------------------------------------------------------------------------- verification
	
	@Test
	public function should_verify_mock_instance()
	{
		var instance = Mockatoo.mock(VerifySomeClass);
		
		instance.test("foo");
		Mockatoo.verify(instance).test("foo");

		instance.test("foo");
		instance.verify().test("foo");

		instance.test("foo");
		instance.verify(times(1)).test("foo");

		instance.test("foo");
		instance.verify(1).test("foo");
	}

	var mock:VerifySomeClass;

	@Test
	public function should_verify_mock_instance_as_field()
	{
		mock = Mockatoo.mock(VerifySomeClass);
		
		mock.test("foo");

		Mockatoo.verify(this.mock).test("foo");

		mock.test("foo");
		this.mock.verify().test("foo");

		mock.test("foo");
		this.mock.verify(times(1)).test("foo");

		mock.test("foo");
		this.mock.verify(1).test("foo");

		mock.test("foo");
		mock.test("foo").verify();
	}

	@Test
	public function should_verify_mock_via_using()
	{
		mock = Mockatoo.mock(VerifySomeClass);
		mock.test("foo");
		mock.test("foo").verify();
	}

	@Test
	public function should_verify_this_mock_via_using()
	{
		var mock:VerifySomeClass = null;

		this.mock = Mockatoo.mock(VerifySomeClass);
		this.mock.test("foo");
		this.mock.test("foo").verify();
	}

	@Test
	public function should_verify_full_mock_expression()
	{
		var instance = Mockatoo.mock(VerifySomeClass);

		var count = 0;

		var f = function(a)
		{
			count ++;
		}
		
		Mockatoo.calls(instance.test("foo"),f);

		instance.test("foo");

		Mockatoo.verify(instance.test("foo"));

		instance.test("foo");
		Mockatoo.verify(instance.test("foo"), times(1));

		instance.test("foo");
		Mockatoo.verify(instance.test("foo"), 1);

		Assert.areEqual(3, count);
	}

	
	@Test
	public function should_throw_exception_if_verify_null_mock()
	{
		var mock:Mock = null;
		try
		{
			Mockatoo.verify(mock);	
			Assert.fail("Expected exception for non mock class");
		}
		catch(e:VerificationException)
		{
			Assert.isTrue(true);
		}
	}

	@Test
	public function should_throw_exception_if_verify_non_mock()
	{
		var instance:SimpleClass = new SimpleClass();
		try
		{
			Mockatoo.verify(instance);	
			Assert.fail("Expected exception for non mock class");
		}
		catch(e:VerificationException)
		{
			Assert.isTrue(true);
		}

	}

	@Test
	public function should_set_default_mode()
	{
		var instance = Mockatoo.mock(SimpleClass);

		var verification = Mockatoo.verify(instance);

		Asserts.assertEnumTypeEq(times(1), verification.mode);
		
	}

	@Test
	public function should_use_custom_mode()
	{
		var instance = Mockatoo.mock(SimpleClass);

		var verification = Mockatoo.verify(instance, never);

		Asserts.assertEnumTypeEq(never, verification.mode);
		
	}

	@Test
	public function should_verify_no_more_interactions()
	{
		var instance = Mockatoo.mock(VerifySomeClass);
			
		instance.verifyZeroInteractions();
		instance.test("foo");

		try
		{
			instance.verifyZeroInteractions();
			Assert.fail("Expected exception for existing invocation");
		}
		catch(e:VerificationException)
		{
			Assert.isTrue(true);
		}
	}

	//NOTE: THESE ARE MEANT TO CAUSE COMPILER ERRORS
	// @Test
	// public function should_cause_compilation_error_if_verify_non_existent_field()
	// {
	// 	var instance = Mockatoo.mock(VerifySomeClass);

	// 	Mockatoo.when(instance.notAnActualMethod());
	// 	Mockatoo.verify(instance.notAnActualMethod());
	// }

}

class VerifySomeClass
{
	public function new()
	{

	}

	public function test(value:String)
	{

	}
}

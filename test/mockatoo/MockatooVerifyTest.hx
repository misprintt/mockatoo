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

/**
* Auto generated MassiveUnit Test Class  for mockatoo.Mockatoo 
*/
class MockatooVerifyTest 
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

	// ------------------------------------------------------------------------- verification

	
	@Test
	public function should_verify_mock_instance()
	{
		var instance = VerifySomeClass.mock();
		
		instance.test("foo");

		Mockatoo.verify(instance).test("foo");

		instance.verify().test("foo");
		instance.verify(times(1)).test("foo");
		instance.verify(1).test("foo");
	}

	var mock:VerifySomeClass;

	@Test
	public function should_verify_mock_instance_as_field()
	{
		mock = VerifySomeClass.mock();
		
		mock.test("foo");

		Mockatoo.verify(this.mock).test("foo");

		this.mock.verify().test("foo");
		this.mock.verify(times(1)).test("foo");
		this.mock.verify(1).test("foo");
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
		Mockatoo.verify(instance.test("foo"), times(1));
		Mockatoo.verify(instance.test("foo"), 1);

		#if !haxe3
		//Note Haxe3 doesn't like using + macro for expression that returns void;
		Mockatoo.verify(instance.test("foo"));
		instance.test("foo").verify(times(1));
		instance.test("foo").verify(1);
		#end
		Assert.areEqual(1, count);
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
			trace(e);
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
			trace(e);
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

	//NOTE: THESE ARE MEANT TO CAUSE COMPILER ERRORS
	// @Test
	// public function should_cause_compilation_error_if_verify_non_existent_field()
	// {
	// 	var instance = VerifySomeClass.mock();

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

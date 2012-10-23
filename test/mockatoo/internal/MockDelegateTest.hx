package mockatoo.internal;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mockatoo.internal.MockDelegate;
import mockatoo.Matches;
import mockatoo.VerificationMode;
import mockatoo.exception.VerificationException;
/**
* Auto generated MassiveUnit Test Class  for mockatoo.internal.MockDelegate 
*/
class MockDelegateTest 
{
	var instance:MockDelegate; 
	
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
		instance = new MockDelegate(mock);

		var verification = instance.verify();

		instance.callMethod("none", []);
		verification.none();

		instance.callMethod("one", [1]);
		verification.one(1);

		instance.callMethodAndReturn("two", [1,2], 1);
		verification.two(1, AnyInt);


		instance.callMethodAndReturn("three", [1,2,3], 1);
		verification.three(1, AnyInt, NotNull);
	}

	@Test
	public function should_return_default_value():Void
	{
		var mock = mockatoo.Mockatoo.mock(ClassToMock);
		instance = new MockDelegate(mock);

		var verification = instance.verify();

		var result = instance.callMethodAndReturn("two", [1,2], 1);

		Assert.areEqual(1, result);
	}


	@Test
	public function should_use_verification_mode():Void
	{
		var mock = mockatoo.Mockatoo.mock(ClassToMock);
		instance = new MockDelegate(mock);

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
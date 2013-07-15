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

	// ------------------------------------------------------------------------- stubbing methods


	@Test
	public function should_throw_exception_if_cannot_stub_return_value():Void
	{
		var mock = mockatoo.Mockatoo.mock(ClassToMock);
		instance = new MockProxy(mock);

		var stub = instance.stubMethod("none", []);

		try
		{
			stub.thenReturn("foo");
			Assert.fail("Expected StubbingException");
		}
		catch(e:StubbingException) {}
	}

	@Test
	public function should_return_returns_outcome():Void
	{
		var mock = mockatoo.Mockatoo.mock(ClassToMock);
		instance = new MockProxy(mock);

		var stub = instance.stubMethod("two", [1,2]);

		stub.thenReturn(4);

		var result = instance.getOutcomeFor("two", [1,2]);
		Asserts.assertEnumTypeEq(returns(4), result);
	}

	@Test
	public function should_always_return_last_stubMethod():Void
	{
		var mock = mockatoo.Mockatoo.mock(ClassToMock);
		instance = new MockProxy(mock);

		var stub = instance.stubMethod("two", [1,2]);

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

		var stub = instance.stubMethod("two", [1,2]);

		var exception = new CustomException(); 

		stub.thenReturn(4).thenThrow(exception);

		var result = instance.getOutcomeFor("two", [1,2]);

		Asserts.assertEnumTypeEq(returns(4), result);

		result = instance.getOutcomeFor("two", [1,2]);

		Asserts.assertEnumTypeEq(throws(exception), result);
	}

	@Test
	public function should_return_calls_outcome():Void
	{
		var mock = mockatoo.Mockatoo.mock(ClassToMock);
		instance = new MockProxy(mock);


		var f = function(args:Array<Dynamic>) {}

		instance.stubMethod("two", [1,2]).thenCall(f);

		var result = instance.getOutcomeFor("two", [1,2]);

		Asserts.assertEnumTypeEq(calls(f), result);
	}

	@Test
	public function should_return_stubs_outcome():Void
	{
		var mock = mockatoo.Mockatoo.mock(ClassToMock);
		instance = new MockProxy(mock);



		instance.stubMethod("two", [1,2]).thenStub();

		var result = instance.getOutcomeFor("two", [1,2]);

			Asserts.assertEnumTypeEq(stubs, result);
	}

	@Test
	public function should_return_callsRealMethod_outcome():Void
	{
		var mock = mockatoo.Mockatoo.mock(ClassToMock);
		instance = new MockProxy(mock);

		instance.stubMethod("two", [1,2]).thenCallRealMethod();

		var result = instance.getOutcomeFor("two", [1,2]);

		Asserts.assertEnumTypeEq(callsRealMethod, result);
	}

	// ------------------------------------------------------------------------- reset


	@Test
	public function should_reset_stubbing():Void
	{
		var mock = mockatoo.Mockatoo.mock(ClassToMock);
		instance = new MockProxy(mock);
		
		instance.stubMethod("two", [1,2]).thenReturn(4);

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


	// ------------------------------------------------------------------------- stubbing properties


	@Test
	public function should_stub_property():Void
	{
		var mock:ClassWithPropertiesToMock = mockatoo.Mockatoo.mock(ClassWithPropertiesToMock);
		instance = new MockProxy(cast mock);
		untyped mock.mockProxy = instance; 

		instance.stubProperty("prop").thenReturn("foo");
		Assert.areEqual("foo", mock.prop);

		instance.stubProperty("propDefault").thenReturn("foo");
		Assert.areEqual("foo", mock.propDefault);

		instance.stubProperty("propNull").thenReturn("foo");
		Assert.areEqual("foo", mock.propNull);

		instance.stubProperty("propSet").thenReturn("foo");
		Assert.areEqual("foo", mock.propSet);

		instance.stubProperty("propGet").thenReturn("foo");
		Assert.areEqual("foo",mock.propGet);

		instance.stubProperty("propGetSet").thenReturn("foo");
		Assert.areEqual("foo", mock.propGetSet);
	}

	@Test
	public function should_stub_property_with_throw():Void
	{
		var mock:ClassWithPropertiesToMock = mockatoo.Mockatoo.mock(ClassWithPropertiesToMock);
		instance = new MockProxy(cast mock);
		untyped mock.mockProxy = instance; 


		try
		{
			instance.stubProperty("prop").thenThrow("foo");
			Assert.fail("Expected StubbingException");
		}
		catch(e:StubbingException) {}

		
		instance.stubProperty("propSet").thenThrow("foo");

		try
		{
			mock.propSet = "1";
			Assert.fail("Expected exception");
		}
		catch(e:String) {}

		Assert.isNull(mock.propSet);

		instance.stubProperty("propGet").thenThrow("foo");

		try
		{
			var result = mock.propGet;
			Assert.fail("Expected exception");
		}
		catch(e:String) {}


		instance.stubProperty("propGetSet").thenThrow("foo");

		try
		{
			mock.propGetSet = "1";
			Assert.fail("Expected exception");
		}
		catch(e:String) {}

		try
		{
			var result = mock.propGetSet;
			Assert.fail("Expected exception");
		}
		catch(e:String) {}

	}

	@Test
	public function should_stub_property_with_callback():Void
	{
		var mock:ClassWithPropertiesToMock = mockatoo.Mockatoo.mock(ClassWithPropertiesToMock);
		instance = new MockProxy(cast mock);
		untyped mock.mockProxy = instance; 

		var f = function(value:String)
		{
			return "foo";
		}

		try
		{
			instance.stubProperty("prop").thenCall(f);
			Assert.fail("Expected StubbingException");
		}
		catch(e:StubbingException) {}

		try
		{
			instance.stubProperty("propSet").thenCall(f);
			Assert.fail("Expected StubbingException");
		}
		catch(e:StubbingException) {}
		
		instance.stubProperty("propGet").thenCall(f);
		Assert.areEqual("foo",  mock.propGet);

		instance.stubProperty("propGetSet").thenCall(f);
		Assert.areEqual("foo", mock.propGetSet);
	}


	@Test
	public function should_stub_property_with_realMethod():Void
	{
		var mock:ClassWithPropertiesToMock = mockatoo.Mockatoo.mock(ClassWithPropertiesToMock);
		instance = new MockProxy(cast mock);
		untyped mock.mockProxy = instance; 

		try
		{
			instance.stubProperty("prop").thenCallRealMethod();
			Assert.fail("Expected StubbingException");
		}
		catch(e:StubbingException) {}

		instance.stubProperty("propSet").thenCallRealMethod();
		mock.propSet = "foo";
		Assert.areEqual("foo", mock.propSet);
		
		instance.stubProperty("propGet").thenCallRealMethod();
		Assert.areEqual(null,  mock.propGet);

		instance.stubProperty("propGetSet").thenCallRealMethod();
		mock.propGetSet = "foo";
		Assert.areEqual("foo", mock.propGetSet);
	}

	@Test
	public function should_stub_property_with_stub():Void
	{
		var mock:ClassWithPropertiesToMock = mockatoo.Mockatoo.mock(ClassWithPropertiesToMock);
		instance = new MockProxy(cast mock);
		untyped mock.mockProxy = instance; 

		try
		{
			instance.stubProperty("prop").thenStub();
			Assert.fail("Expected StubbingException");
		}
		catch(e:StubbingException) {}

		instance.stubProperty("propSet").thenStub();
		mock.propSet = "foo";
		Assert.areEqual(null, mock.propSet);
		
		instance.stubProperty("propGet").thenStub();
		Assert.areEqual(null,  mock.propGet);

		instance.stubProperty("propGetSet").thenStub();
		mock.propGetSet = "foo";
		Assert.areEqual(null, mock.propGetSet);
	}

}

class CustomException
{
	public function new()
	{

	}
}

class ClassWithPropertiesToMock
{
	public var prop:String;

	public var propDefault(default, default):String;
	public var propNull(default, null):String;

	#if haxe3
	@:isVar public var propSet(default, set):String;
	@:isVar public var propGet(get, null):String;
	@:isVar public var propGetSet(get, set):String;
	#else
	public var propSet(default, set_propSet):String;
	public var propGet(get_propGet, null):String;
	public var propGetSet(get_propGetSet, set_propGetSet):String;
	#end

	function set_propSet(value:String):String{propSet = value; return value;}

	function get_propGet():String{return propGet;}

	function get_propGetSet():String{return propGetSet;}
	function set_propGetSet(value:String):String{propGetSet = value; return value;}

	public function new()
	{
		prop = "";
		propDefault = "";
		propNull = "";
		propSet = "";
		propGet = "";
		propGetSet = "";
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
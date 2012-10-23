package mockatoo.internal;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mockatoo.internal.MethodProxy;
import mockatoo.exception.VerificationException;
import mockatoo.Mockatoo;
import mockatoo.VerificationMode;
import mockatoo.Matches;
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

	@Test
	public function should_verify_atMost_one():Void
	{
		var args:Array<Dynamic> = ["foo"];
		instance = createInstance();

		instance.verify(atMost(1), args);

		instance.call(args);
		instance.verify(atMost(1), args);

		try
		{
			instance.call(args);
			instance.verify(atMost(1), args);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}
	}


	@Test
	public function should_not_verify_with_different_number_of_args():Void
	{
		var args:Array<Dynamic> = ["foo", "bar"];
		instance = createInstance();


		instance.call(["foo"]);

		try
		{
			instance.verify(times(1), args);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

	}

	@Test
	public function should_not_verify_with_different_arg_values():Void
	{
		instance = createInstance();


		instance.call(["foo"]);

		try
		{
			instance.verify(times(1), ["bar"]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.call(["bar"]);
		instance.verify(times(1), ["bar"]);
		

	}


	@Test
	public function should_verify_null():Void
	{
		instance = createInstance();

		try
		{
			instance.call(["1"]);
			instance.verify(times(1), [null]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.call([null]);
		instance.verify(times(1), [null]);
	}

	@Test
	public function should_verify_enum():Void
	{
		instance = createInstance();

		instance.call([SomeEnum.foo]);

		try
		{
			instance.verify(times(1), [SomeEnum.bar]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.verify(times(1), [SomeOtherEnum.foo]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.verify(times(1), [SomeEnum.foo]);
	}

	// ------------------------------------------------------------------------- MATCHES

	@Test
	public function should_verify_anyString():Void
	{
		instance = createInstance();

		try
		{
			instance.call([false]);
			instance.verify(times(1), [AnyString]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.call([null]);
			instance.verify(times(1), [AnyString]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.call(["foo"]);
		instance.verify(times(1), [AnyString]);
	}

	@Test
	public function should_verify_anyInt():Void
	{
		instance = createInstance();

		try
		{
			instance.call([1.1]);
			instance.verify(times(1), [AnyInt]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.call([null]);
			instance.verify(times(1), [AnyInt]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.call([1]);
		instance.verify(times(1), [AnyInt]);
	}

	@Test
	public function should_verify_anyFloat():Void
	{
		instance = createInstance();

		try
		{
			instance.call([null]);
			instance.verify(times(1), [AnyFloat]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}


		instance.call([1.1]);
		instance.verify(times(1), [AnyFloat]);

		instance.call([1]);
		instance.verify(times(2), [AnyFloat]); //int is valid flaot
	}

	@Test
	public function should_verify_anyBool():Void
	{
		instance = createInstance();

		try
		{
			instance.call([1]);
			instance.verify(times(1), [AnyBool]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.call([null]);
			instance.verify(times(1), [AnyBool]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.call([true]);
		instance.verify(times(1), [AnyBool]);

		instance.call([false]);
		instance.verify(times(2), [AnyBool]);
	}

	@Test
	public function should_verify_anyObject():Void
	{
		instance = createInstance();

		try
		{
			instance.call([1]);
			instance.verify(times(1), [AnyObject]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.call([null]);
			instance.verify(times(1), [AnyObject]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.call(["foo"]);
			instance.verify(times(1), [AnyObject]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.call([{foo:true}]);
		instance.verify(times(1), [AnyObject]);

		instance.call([new Hash<String>()]);
		instance.verify(times(1), [AnyObject]); //doesnt count instances - only annonomous objects
	}

	@Test
	public function should_verify_anyEnumValue():Void
	{
		instance = createInstance();

		try
		{
			instance.call([1]);
			instance.verify(times(1), [AnyEnumValue()]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.call([null]);
			instance.verify(times(1), [AnyEnumValue()]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}


		instance.call([SomeEnum.foo]);
		instance.verify(times(1), [AnyEnumValue()]);

		instance.call([SomeOtherEnum.bar]);
		instance.verify(times(2), [AnyEnumValue()]); 
	}

	@Test
	public function should_verify_anyEnumValue_of_specific_enum_type():Void
	{
		instance = createInstance();

		try
		{
			instance.call([SomeOtherEnum.foo]);
			instance.verify(times(1), [AnyEnumValue(SomeEnum)]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}


		instance.call([SomeEnum.foo]);
		instance.verify(times(1), [AnyEnumValue(SomeEnum)]);

		instance.call([SomeEnum.bar]);
		instance.verify(times(2), [AnyEnumValue(SomeEnum)]); 
	}


	@Test
	public function should_verify_anyInstanceOf():Void
	{
		instance = createInstance();

		try
		{
			instance.call([1]);
			instance.verify(times(1), [AnyInstanceOf(SomeClass)]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.call([null]);
			instance.verify(times(1), [AnyInstanceOf(SomeClass)]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.call([new Hash<String>()]);
			instance.verify(times(1), [AnyInstanceOf(SomeClass)]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.call([new SomeClass()]);
		instance.verify(times(1), [AnyInstanceOf(SomeClass)]);

		instance.call([new SomeSubClass()]);
		instance.verify(times(2), [AnyInstanceOf(SomeClass)]); 

		instance.verify(times(1), [AnyInstanceOf(SomeSubClass)]); 
	}



	@Test
	public function should_verify_notNull():Void
	{
		instance = createInstance();

		try
		{
			instance.call([null]);
			instance.verify(times(1), [NotNull]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		instance.call([1]);
		instance.verify(times(1), [NotNull]);

		instance.call(["foo"]);
		instance.verify(times(2), [NotNull]);

		instance.call([new SomeClass()]);
		instance.verify(times(3), [NotNull]);

		instance.call([SomeEnum.foo]);
		instance.verify(times(4), [NotNull]);
	}



	@Test
	public function should_verify_iterator():Void
	{
		instance = createInstance();

		try
		{
			instance.call([1]);
			instance.verify(times(1), [AnyIterator]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}

		try
		{
			instance.call([null]);
			instance.verify(times(1), [AnyIterator]);
			Assert.fail("Expected VerificationException");
		}
		catch(e:VerificationException) {}
		
		var hash = new Hash<String>();
		instance.call([hash]);
		instance.verify(times(1), [AnyIterator]);

		var array = new Array<Int>();
		instance.call([array]);
		instance.verify(times(2), [AnyIterator]);

		var intHash = new IntHash<Int>();
		instance.call([intHash]);
		instance.verify(times(3), [AnyIterator]);

		var list = new List<String>();
		instance.call([list]);
		instance.verify(times(4), [AnyIterator]);

		var someIterable = new SomeIterable("foo");
		instance.call([someIterable]);
		instance.verify(times(5), [AnyIterator]);

		var someIterator = new SomeIterator("foo");
		instance.call([someIterator]);
		instance.verify(times(6), [AnyIterator]);
	}

	@Test
	public function should_verify_multiple_matches():Void
	{
		instance = createInstance();
		instance.call([1, "foo", null, new Array<Bool>()]);
		instance.verify(times(1), [AnyInt, AnyString, null , AnyIterator]);
	}

	// ------------------------------------------------------------------------- Internal

	function createInstance(?args:Array<String>,?ret):MethodProxy
	{
		if(args == null) args = [];
		return new MethodProxy("ClassName", "fieldName", args, ret);
	}
}

private enum SomeEnum
{
	foo;
	bar;
}

private enum SomeOtherEnum
{
	foo;
	bar;
}

private class SomeClass
{
	public function new()
	{

	}
}

private class SomeSubClass extends SomeClass
{
	public function new()
	{
		super();
	}
}

private class SomeIterator
{
	var some:SomeIterable;

	public function new( str_: String ) {
		some = new SomeIterable(str_);
	}
	public function iterator ():Iterator<Int>
	{ 
		return some;            
	}
}

private class SomeIterable
{
	public var length: Int;
	private var count: Int;
	private var str: String;
	public function new( str_: String ) {
		count = 0;
		length = str_.length;
		str = str_;   
	}
	public function hasNext(): Bool {
			 return count < length;
	}
	public function next(): Int { 
			 return str.charCodeAt( count++ ); 
	}
}
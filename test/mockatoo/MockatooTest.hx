package mockatoo;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mockatoo.Mockatoo;
import mockatoo.Mock;

/**
* Auto generated MassiveUnit Test Class  for mockatoo.Mockatoo 
*/
class MockatooTest 
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
	public function should_mock_class():Void
	{
		var mock = Mockatoo.mock(SomeClass);

		Assert.isTrue(Std.is(mock, SomeClass));
		Assert.isTrue(Std.is(mock, Mock));


		trace(Type.getClassName(Type.getClass(mock)));

		#if (flash || cpp || java || cs)
			Assert.isFalse(mock.getBool());
			Assert.areEqual(0, mock.getInt());
		#else
			Assert.isNull(mock.getBool());
			Assert.isNull(mock.getInt());
		#end

		Assert.isNull(mock.getString());
	}

	@Test
	public function should_mock_http():Void
	{
		var mock = Mockatoo.mock(haxe.Http);

		Assert.isTrue(Std.is(mock, haxe.Http));
		Assert.isTrue(Std.is(mock, Mock));

		Assert.isNull(mock.request(false));
	}

	@Test
	public function should_mock_hash():Void
	{
		var mock = Mockatoo.mock(StringHash);

		Assert.isTrue(Std.is(mock, Hash));
		Assert.isTrue(Std.is(mock, StringHash));
		Assert.isTrue(Std.is(mock, Mock));
		
		#if (flash || cpp || java || cs)
			Assert.isFalse(mock.exists("foo"));
		#else
			Assert.isNull(mock.exists("foo"));
		#end

		Assert.isNull(mock.get("foo"));
	}
}


typedef StringHash = Hash<String>;


class SomeClass
{
	public function new()
	{

	}

	public function getString():String
	{
		return "string";
	}


	public function getBool():Bool
	{
		return true;
	}


	public function getInt():Int
	{
		return 1;
	}
}
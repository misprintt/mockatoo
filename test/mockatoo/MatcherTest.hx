package mockatoo;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mockatoo.exception.VerificationException;
import mockatoo.exception.StubbingException;
import mockatoo.Mockatoo;
import mockatoo.Mock;
import test.TestClasses;
import util.Asserts;

import haxe.ds.StringMap;

using mockatoo.Mockatoo;

class MatcherTest
{

	// ------------------------------------------------------------------------- matchers

	
	@Test
	public function should_match_anyString()
	{
		var mock = Mockatoo.spy(SomeMatcherClass);

		Assert.isFalse(mock.fromString("foo"));

		mock.fromString(cast anyString).returns(true);

		Assert.isTrue(mock.fromString("foo"));
	}
	
	@Test
	public function should_match_anyInt()
	{
		var mock = Mockatoo.spy(SomeMatcherClass);

		Assert.isFalse(mock.fromInt(2));

		mock.fromInt(cast anyInt).returns(true);

		Assert.isTrue(mock.fromInt(2));
	}

	@Test
	public function should_match_anyFloat()
	{
		var mock = Mockatoo.spy(SomeMatcherClass);

		Assert.isFalse(mock.fromFloat(0.0));

		mock.fromFloat(cast anyFloat).returns(true);

		Assert.isTrue(mock.fromFloat(0.0));
	}

	@Test
	public function should_match_anyBool()
	{
		var mock = Mockatoo.spy(SomeMatcherClass);

		Assert.isFalse(mock.fromBool(true));

		mock.fromBool(cast anyBool).returns(true);

		Assert.isTrue(mock.fromBool(true));
	}

	@Test
	public function should_match_anyIterator()
	{
		var mock = Mockatoo.spy(SomeMatcherClass);

		var a:Array<Int> = [1,2,3];

		Assert.isFalse(mock.fromArray(a));

		mock.fromArray(cast anyIterator).returns(true);

		Assert.isTrue(mock.fromArray(a));
	}


	@Test
	public function should_match_anyObject()
	{
		var mock = Mockatoo.spy(SomeMatcherClass);

		var o:Dynamic = {foo:"bar"};

		Assert.isFalse(mock.fromDynamic(o));

		mock.fromDynamic(cast anyObject).returns(true);

		Assert.isTrue(mock.fromDynamic(o));
	}

	@Test
	public function should_match_anyEnum()
	{
		var mock = Mockatoo.spy(SomeMatcherClass);


		Assert.isFalse(mock.fromEnum(SomeEnumType.foo));

		mock.fromEnum(cast anyEnum).returns(true);

		Assert.isTrue(mock.fromEnum(SomeEnumType.foo));
	}


	@Test
	public function should_match_enumOf()
	{
		var mock = Mockatoo.spy(SomeMatcherClass);

		Assert.isFalse(mock.fromEnum(SomeEnumType.foo));

		mock.fromEnum(cast enumOf(SomeEnumType)).returns(true);

		Assert.isTrue(mock.fromEnum(SomeEnumType.foo));
	}

	@Test
	public function should_match_instanceOf()
	{
		var mock = Mockatoo.spy(SomeMatcherClass);

		var c = new SomeClass();

		Assert.isFalse(mock.fromInstance(c));

		mock.fromInstance(cast instanceOf(SomeClass)).returns(true);

		Assert.isTrue(mock.fromInstance(c));


		mock.fromDynamic(cast instanceOf(SomeClass)).returns(true);

		Assert.isTrue(mock.fromDynamic(c));
		Assert.isFalse(mock.fromDynamic({value:1}));
	}

	@Test
	public function should_match_instanceOf_specific_type()
	{
		var mock = Mockatoo.spy(SomeMatcherClass);

		var c = new SomeClass();
		var o = {value:1};

		Assert.isFalse(mock.fromDynamic(c));
		Assert.isFalse(mock.fromDynamic(o));

		mock.fromDynamic(cast instanceOf(SomeClass)).returns(true);

		Assert.isTrue(mock.fromDynamic(c));
		Assert.isFalse(mock.fromDynamic(o));
	}




	@Test
	public function should_match_isNotNull()
	{
		var mock = Mockatoo.spy(SomeMatcherClass);

		Assert.isFalse(mock.fromString(null));
		Assert.isFalse(mock.fromString("foo"));

		mock.fromString(cast isNotNull).returns(true);

		Assert.isFalse(mock.fromString(null));
		Assert.isTrue(mock.fromString("foo"));
	}

	@Test
	public function should_match_any()
	{
		var mock = Mockatoo.spy(SomeMatcherClass);

		Assert.isFalse(mock.fromString(null));

		mock.fromString(cast any).returns(true);

		Assert.isTrue(mock.fromString(null));
	}

	@Test
	public function should_match_customMatcher()
	{
		var mock = Mockatoo.spy(SomeMatcherClass);

		var matcher = function(value:Int):Bool
		{
			return value > 10;
		}

		Assert.isFalse(mock.fromInt(1));
		Assert.isFalse(mock.fromInt(100));

		mock.fromInt(cast customMatcher(matcher)).returns(true);

		Assert.isFalse(mock.fromInt(1));
		Assert.isTrue(mock.fromInt(100));
	}
}
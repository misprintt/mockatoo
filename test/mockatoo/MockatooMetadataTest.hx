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

import mockatoo.Mockatoo.*;
using mockatoo.Mockatoo;


class MockatooMetadataTest implements mockatoo.MockTest
{
	@:mock var mock:SimpleClass;
	@:spy var spy:SimpleClass;

	public function new() 
	{
		
	}
	
	// ------------------------------------------------------------------------- mocking

	@Test
	public function should_generate_mock():Void
	{
		Assert.isNotNull(mock);
		Assert.isTrue(Std.is(mock, SimpleClass));
		Assert.isTrue(Std.is(mock, Mock));
	}

	@Test
	public function should_generate_spy():Void
	{
		Assert.isNotNull(spy);
		Assert.isTrue(Std.is(spy, SimpleClass));
		Assert.isTrue(Std.is(spy, Mock));
	}

}
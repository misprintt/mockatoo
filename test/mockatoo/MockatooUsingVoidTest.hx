package mockatoo;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mockatoo.exception.VerificationException;
import mockatoo.Mockatoo;
import mockatoo.Mock;
import test.TestClasses;
import util.Asserts;

#if haxe3
import mockatoo.Mockatoo.*;
#end

using mockatoo.Mockatoo;

class MockatooUsingVoidTest 
{
	public function new() 
	{
		
	}

	@Test
	public function should_throw()
	{
		var instance = Mockatoo.mock(SimpleClass);
		
		instance.test().when().thenThrow("foo");

		Mockatoo.when(instance.test()).thenThrow("foo");

		

	}

}


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

#if haxe3
import mockatoo.Mockatoo.*;
#else
#end

using mockatoo.Mockatoo;

/**
* Tests for Mockatoo API on methods that return void
*/
class MockatooVoidTest 
{
	public function new() 
	{
		
	}

	@Test
	public function should_verify()
	{
		var mock = mock(VariableArgumentsReturnsVoidClass);
		mock.none();

		mock.none().verify();
	}

}
package mockatoo;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mockatoo.exception.VerificationException;
import mockatoo.Mockatoo;
import mockatoo.Mock;
import test.TestClasses;
import util.Asserts;
import mockatoo.Mockatoo.*;

using mockatoo.Mockatoo;

class MockatooUsingTest 
{
	public function new() 
	{
		
	}

	@Test
	public function should_generate_returns()
	{
		var instance:VariableArgumentsClass = null;
		instance = mock(VariableArgumentsClass);
		instance.one(null).returns(2);
	}

}


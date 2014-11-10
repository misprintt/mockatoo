package mockatoo.macro;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mockatoo.internal.MockProxy;
import mockatoo.internal.MockOutcome;
import mockatoo.Mockatoo;
import mockatoo.exception.VerificationException;
import mockatoo.exception.StubbingException;
import util.Asserts;

using mockatoo.macro.Tools;
import mockatoo.Mockatoo.*;
using mockatoo.Mockatoo;

class MockMakerTest 
{ 	

	public function new() 
	{

	}
	
	@Test
	public function should_not_mock_abstract()
	{
		Assert.isNotNull(macro_mock_error(AbstractInt));
	}

	macro function macro_mock_error<T>(typeToMock:ExprOf<Class<T>>, ?paramTypes:ExprOf<Array<Class<T>>>):ExprOf<String>
	{
		InitMacro.init();

		var s:String = null;
		try
		{
			var mock = new MockMaker(typeToMock.typed(), paramTypes);
		}
		catch(e:mockatoo.exception.MockatooException)
		{
			s = e.message;
		}

		return macro $v{s};
	}
}	
	
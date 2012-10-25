import mockatoo.Mockatoo;
import mockatoo.exception.VerificationException;
import mockatoo.exception.StubbingException;
/**
Simple example showing mocking for interfaces, classes and typedef alisas.
Each mock overrides/implements the methods and returns stub values 
*/
class Main
{
	public static function main()
	{
		basicMocking();
		stubbing();
		verifying();
	}
	
	static function basicMocking()
	{
		//crate a mock;
		var mock = Mockatoo.mock(math.Calculator);

		//invoke a method and trace stubbed result
		var result = mock.round(1.1);

		#if (flash || cpp || java || cs)
			assertEqual(0, result); //outputs 0 on static ones (flash, cpp, etc)
		#else
			assertEqual(null, result); //outputs null on dynamic platforms (js, neko, etc) and 
		#end

		//verify 'round' was called with arguments 1.1;
		Mockatoo.verify(mock).round(1.1); //all good


		//attempt to verify with arguments that were not used
		try
		{
			Mockatoo.verify(mock).round(3.14);
		}
		catch(e:Dynamic)
		{
			var expected = Type.getClassName(VerificationException);
			var actual = Type.getClassName(Type.getClass(e));
			assertEqual(expected, actual);
		}
	}

	static function stubbing()
	{
		//crate a mock;
		var mock = Mockatoo.mock(math.Calculator);

		//stub some responses
		Mockatoo.when(mock.round(1.1)).thenReturn(11);

		//stub an exception response
		Mockatoo.when(mock.round(0)).thenThrow("exception");

		//stub a custom response for any other values
		Mockatoo.when(mock.round(anyFloat)).thenReturn(99);

		var result = mock.round(1.1);
		assertEqual(11, result);

		result = mock.round(2.2);
		assertEqual(99, result);
		
		try
		{
			mock.round(0);
		}
		catch(e:String)
		{
			assertEqual("exception", e);
		}
	}

	static function verifying()
	{
		//create a mock;
		var mock = Mockatoo.mock(math.Calculator);

		Mockatoo.verify(mock, never).round(1.0);// never called

		mock.round(1.0);
		mock.round(1.2);
		mock.round(1.2);

		Mockatoo.verify(mock, times(1)).round(1.0);// matches first call
		Mockatoo.verify(mock, atLeast(2)).round(1.2);// matches second and third call
		Mockatoo.verify(mock, times(3)).round(anyFloat);// matches all calls
	}

	////

	/**
	Prints the result of the assertion and the value 
	*/
	static function assertEqual(expected:Dynamic, actual:Dynamic, ?pos:haxe.PosInfos)
	{
		var result = (actual == expected);

		trace(result + " : " + Std.string(actual) + ", (line " + pos.lineNumber + ")", pos);
	}

	
}

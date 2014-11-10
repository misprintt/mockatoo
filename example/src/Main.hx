package ;

import mockatoo.exception.VerificationException;

import mockatoo.Mockatoo.*;
using mockatoo.Mockatoo;

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
		spying();
	}
	
	static function basicMocking()
	{
		//creat a mock;
		var mock = mock(math.Calculator);

		//invoke a method and trace stubbed result
		var result = mock.round(1.1);

		#if (flash || cpp || java || cs)
			assertEqual(0, result); //outputs 0 on static ones (flash, cpp, etc)
		#else
			assertEqual(null, result); //outputs null on dynamic platforms (js, neko, etc) and 
		#end

		//verify 'round' was called with arguments 1.1;
		mock.round(1.1).verify(); //all good

		//attempt to verify with arguments that were not used
		try
		{
			mock.round(3.14).verify();
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
		var mock = mock(math.Calculator);

		//stub some responses
		mock.round(1.1).returns(11);

		//stub an exception response
		mock.round(0).throws("exception");

		//stub a custom response for any other values
		mock.round(cast anyFloat).returns(99);

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
		var mock = mock(math.Calculator);

		mock.round(1.0).verify(never);// never called

		mock.round(1.0);
		mock.round(1.2);
		mock.round(1.2);

		mock.round(1.0).verify(1);// matches first call
		mock.round(1.2).verify(atLeast(2));// matches second and third call

		mock.round(1.0);
		mock.round(1.2);
		mock.round(1.2);
		mock.round(cast anyFloat).verify(3);// matches all calls
	}

	static function spying()
	{
		//crate a spy mock;
		var mock = math.Calculator.spy();

		//invoke the real method
		var result = mock.round(1.1);
		assertEqual(1, result);

		//stub some responses
		mock.round(1.1).returns(11);

		//invoke again to return stub value
		result = mock.round(1.1);
		assertEqual(11, result);

		//verify method was called twice
		mock.round(1.1).verify(2);
	}

	/**
		Prints the result of the assertion and the value 
	*/
	static function assertEqual(expected:Dynamic, actual:Dynamic, ?pos:haxe.PosInfos)
	{
		var result = (actual == expected);

		trace(result + " : " + Std.string(actual) + ", (line " + pos.lineNumber + ")", pos);
	}	
}

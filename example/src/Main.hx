import mockatoo.Mockatoo;

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

	}

	
	static function basicMocking()
	{
		//crate a mock;
		var mock = Mockatoo.mock(math.Calculator);

		//invoke a method and trace stubbed result
		var result = mock.add(1, 1);
		trace(result); //outputs null on dynamic platforms (js, neko, etc) and 0 on static ones (flash, cpp, etc)

		//verify 'add' was called with arguments 1,1;
		Mockatoo.verify(mock).add(1, 1); //all good


		//attempt to verify with arguments that were not used
		try
		{
			Mockatoo.verify(mock).add(1, 2);
		}
		catch(e:Dynamic)
		{
			trace("VerificationException");//verification error;
		}

	}

	static function stubbing()
	{
		//crate a mock;
		var mock = Mockatoo.mock(math.Calculator);

		//stub some responses
		Mockatoo.when(mock.add(1, 1)).thenReturn(11);

		//stub an exception response
		Mockatoo.when(mock.add(0, 0)).thenThrow("exception");


		var result = mock.add(1,1);
		trace(result);// 11;

		result = mock.add(1,2);
		trace(result);// default value (i.e. null or 0);
		
		try
		{
			mock.add(0, 0);
		}
		catch(e:String)
		{
			trace(e);//verification error;
		}
	}

	
}

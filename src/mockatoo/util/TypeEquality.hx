package mockatoo.util;

/**
	Utilities for checking type equality. Special rules for enums with paramaters.
*/
class TypeEquality
{
	/**
		Measures equality, including enumTypeEQ - see below
	*/
	public static function equals(expected:Dynamic, actual:Dynamic):Bool
	{
		switch (Type.typeof(expected))
		{
			case TEnum(_):
			{
				return equalsEnum(cast expected, cast actual);
			}
			default:

				#if cpp
				switch (Type.typeof(actual))
				{
					case TEnum(e): return false;
					default: return expected == actual;
				}
				#end
				return expected == actual;
		}
		return false;
	}

	/**
		Compares enum equality, ignoring any non enum parameters, so that:
		
		````
		Fail(IO("One thing happened")) == Fail(IO("Another thing happened"))
		````

		Also allows for wildcard matching by passing through <code>null</code> for
		any params, so that:
		
		````
		Fail(IO(null)) matches Fail(IO("Another thing happened"))
		````
		
		@param a the enum value to filter on
		@param b the enum value being checked
	*/
	static public function equalsEnum(a:EnumValue, b:EnumValue)
	{
		//if (a == b) return true;
		if (Type.getEnum(a) != Type.getEnum(b)) return false;
		if (Type.enumIndex(a) != Type.enumIndex(b)) return false;

		var aParams = Type.enumParameters(a);
		if (aParams.length == 0) return true;
		var bParams = Type.enumParameters(b);

		for (i in 0...aParams.length)
		{
			var aParam = aParams[i];
			var bParam = bParams[i];

			if (aParam == null) continue;
			if (!equals(aParam, bParam)) return false;
		}

		return true;
	}
}
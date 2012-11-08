package util;

import massive.munit.Assert;
import haxe.PosInfos;
import Type;
class Asserts
{
	/**
	 * Recursively compares two dynamic structures (i.e. typedefs) to determine if they are identical
	 * For example: {foo:"bar"} == {foo:"bar"}
	*/
	static public function assertStructureEquality(expected:Dynamic, actual:Dynamic, ?scope:String="obj", ?info:PosInfos)
	{
		if(expected == actual) return;

		for(field in Reflect.fields(expected))
		{
			var fieldScope:String = scope + (scope != "" ?  "." : "") + field;

			if(Reflect.hasField(actual, field))
			{
				var expectedValue = Reflect.field(expected, field);
				var actualValue = Reflect.field(actual, field);

				if(Type.typeof(expectedValue) == TObject)
					assertStructureEquality(expectedValue, actualValue, scope + ".field", info);
				else if(expectedValue != actualValue)
				{
					Assert.fail("Value [" + Std.string(actualValue) + "] was not equal to expected value [" + Std.string(expectedValue) + "] for field [" + fieldScope + "]", info);
				}
			}
			else
			{
				Assert.fail("Structure does not contain field [" + fieldScope +"]", info);
			}
		}
	}


	/**
	 * Compares enum equality, ignoring any non enum parameters, so that:
	 *	Fail(IO("One thing happened")) == Fail(IO("One thing happened"))
	 * 
	 * Also allows for wildcard matching by passing through <code>null</code> for
	 * any params, so that:
	 *  Fail(IO(null)) matches Fail(IO("Another thing happened"))
	 *
	 * @param expected the enum value to filter on
	 * @param actual the enum value being checked
	*/
	static public function assertEnumTypeEq(expected:EnumValue, actual:EnumValue, ?info:PosInfos)
	{
		if (expected == actual) return;

		var expectedType = Type.getEnum(expected);
		var actualType = Type.getEnum(actual);

		if(expectedType != actualType)
			Assert.fail("Enum type [" + actualType +"] was not equal to expected type [" + expectedType + "]", info);
	
		var expectedIndex = Type.enumIndex(expected);
		var actualIndex = Type.enumIndex(actual);

		if(expectedIndex != actualIndex)
			Assert.fail("Enum value [" + Type.getEnumConstructs(expectedType)[actualIndex] +"] was not equal to expected value [" + Type.getEnumConstructs(expectedType)[expectedIndex] + "]", info);


		var expectedParams = Type.enumParameters(expected);
		if (expectedParams.length == 0) return;
		var actualParams = Type.enumParameters(actual);

		for (i in 0...expectedParams.length)
		{
			var expectedParam = expectedParams[i];
			var actualParam = actualParams[i];

			if (expectedParam == null) continue;
			assertEnumParamTypeEq(expectedParam, actualParam, info);
		}
	}

	/**
	 * Compares object equality with special rules for enum values:
	 * 
	 * @param expected value
	 * @param actual value
	*/

	public static function assertEnumParamTypeEq(expected:Dynamic, actual:Dynamic, ?info:PosInfos)
	{
		

		switch(Type.typeof(expected))
		{
			case TEnum(e):
			{
				assertEnumTypeEq(cast expected, cast actual, info);
			}
			default:
			{
				if(expected != actual)
				{
					Assert.fail("Enum param [" + expected +"] was not equal to expected value [" + actual + "]", info);
				}
			}
		}
	}

}
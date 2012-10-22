package mockatoo.internal;
import mockatoo.exception.VerificationException;
import mockatoo.VerificationMode;
using mockatoo.util.TypeEquality;

class MethodProxy
{
	public var fieldName(default, null):String;

	/**
	Number of arguments 
	*/
	public var argCount(default, null):Int;

	public var count(default, null):Int;

	var argumentTypes:Array<String>;

	var returnType:Null<String>;

	var className:String;

	var invocations:Array<Dynamic>;

	public function new(className:String, fieldName:String, arguments:Array<String>, ?returns:String)
	{
		this.fieldName = fieldName;
		this.className = className;

		argumentTypes = arguments;
		returnType = returns;

		argCount = argumentTypes.length;
		count = 0;

		invocations = [];
	}

	public function call(args:Array<Dynamic>)
	{
		invocations.push(args);
		//specific, any value, null
		count ++;
	}

	public function callAndReturn<T>(args:Array<Dynamic>, defaultReturn:T):T
	{
		invocations.push(args);
		count ++;
		return defaultReturn;
	}

	public function verify(mode:VerificationMode, ?args:Array<Dynamic>):Bool
	{
		var matches:Int = 0;

		for(invocation in invocations)
		{
			if(invocation.length != args.length) 
				continue;

			var matchingArgs = 0;
			for(i in 0...args.length)
			{
				if(compareArgs(args[i], invocation[i])) 
					matchingArgs ++;
			}

			if(matchingArgs == args.length)
				matches ++;
		}
		
		var range:Range = null;
		//trace(fieldName + ":" + Std.string(mode) + ": " + Std.string(args) + ", " + count);
		switch(mode)
		{
			case times(value):
				range = {min:value, max:value};
			case atLeastOnce:
				range = {min:1, max:null};
			case never:
				range = {min:0, max:0};
			case atLeast(value):
				range = {min:value, max:null};
			case atMost(value):
				range = {min:null, max:value};
			case between(value1, value2):
				range = {min:value1, max:value2};
		}

		var execptionMessage:String = className + "." + fieldName + " was invoked " + toTimes(matches) + ", expected ";

		if(range.max == null)
		{
			if(matches >= range.min) return true;
			else throw new VerificationException(execptionMessage + "at least " + toTimes(range.min));
		}
		else if(range.min == null)
		{
			 if(matches <= range.max) return true;
			 else throw new VerificationException(execptionMessage + "less than " + toTimes(range.max));
		}
		else if(range.min == range.max)
		{
			if(matches == range.min) return true;
			else throw new VerificationException(execptionMessage + toTimes(range.min));
		}
		else
		{
			if(matches >= range.min && matches <= range.max) return true;
			else throw new VerificationException(execptionMessage + "between " + toTimes(range.min) + " and " + toTimes(range.max));
		}
		
		return false;
	}

	function toTimes(value:Int):String
	{
		return value == 1 ? "[1] time" : "[" + value + "] times";
	}

	function compareArgs(expected:Dynamic, actual:Dynamic):Bool
	{
		return expected.equals(actual);
	}

}

private typedef Range =
{
	min:Null<Int>,
	max:Null<Int>
}
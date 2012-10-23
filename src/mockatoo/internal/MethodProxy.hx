package mockatoo.internal;
import mockatoo.exception.VerificationException;
import mockatoo.VerificationMode;
import mockatoo.Matcher;

using mockatoo.util.TypeEquality;

/**
 * Represents a single method in a Mock class, storing all calls, verifications
 * and stubs for that method.
 * Created by <code>MockDelegate</code>
 */
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
			{
				continue;
			}

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
		}

		var execptionMessage:String = className + "." + fieldName + "(" + args.join(",") + ") was invoked " + toTimes(matches) + ", expected ";

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
		else
		{
			if(matches == range.min) return true;
			else throw new VerificationException(execptionMessage + toTimes(range.min));
		}
		
		return false;
	}

	function toTimes(value:Int):String
	{
		return value == 1 ? "[1] time" : "[" + value + "] times";
	}

	/**
	Compares to values to determine if they match.
	Supports fuzzy matching using <code>mockatoo.Matcher</code>
	*/
	function compareArgs(expected:Dynamic, actual:Dynamic):Bool
	{
		var type = Type.typeof(expected);
		switch(type)
		{
			case TUnknown:
			case TObject:
			case TNull:
				return actual == null;
			case TInt:
			case TFunction:
			case TFloat:
			case TEnum(e): //Enum<Dynamic>
				if(e == Matcher)
				{
					switch(expected)
					{
						case anyString: return Std.is(actual, String);
						case anyInt:  return Std.is(actual, Int);
						case anyFloat: return Std.is(actual, Float);
						case anyBool: return Std.is(actual, Bool);
						case anyIterator: return isIterable(actual);
						case anyObject: return isObject(actual);
						case anyEnum: return isEnumValueOf(actual, null);
						case enumOf(en): return isEnumValueOf(actual, en);
						case instanceOf(c): return Std.is(actual, c);
						case isNotNull: return actual != null;
						case isNull: return actual == null;
						case any: return true;
						case customMatcher(f): return f(actual);
					}
				}
			case TClass(c): //Class<Dynamic>
			case TBool:
		}
		return expected.equals(actual);
	}

	function isEnumValueOf(value:Dynamic, ?ofType:Enum<Dynamic>):Bool
	{
		switch(Type.typeof(value))
		{
			case TEnum(e): //Enum<Dynamic>
				if(ofType == null)
					return true;
				return e == ofType;
			default: return false;
		}
	}

	function isObject(value:Dynamic):Bool
	{
		switch(Type.typeof(value))
		{
			case TObject: return true;
			default: return false;
		}
	}

	function isIterable(value:Dynamic):Bool
	{
		if(value == null) return false;
		
		if(Std.is(value, Array) || Std.is(value, Hash) || Std.is(value, IntHash)) return true;

		//Iterable
		var iterator = Reflect.field(value, "iterator");
		
		if(Reflect.isFunction(iterator)) return true;

		//Iterator

		var next = Reflect.field(value, "next");
		var hasNext = Reflect.field(value, "hasNext");

		return Reflect.isFunction(next) && Reflect.isFunction(hasNext);

	}
}

private typedef Range =
{
	min:Null<Int>,
	max:Null<Int>
}
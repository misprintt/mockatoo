package mockatoo.internal;
import mockatoo.exception.VerificationException;
import mockatoo.exception.StubbingException;
import mockatoo.Mockatoo;

using mockatoo.util.TypeEquality;

/**
 * Represents a single method in a Mock class, storing all calls, verifications
 * and stubs for that method.
 * Created by <code>MockDelegate</code>
 */
class MethodProxy
{
	public var fieldName(default, null):String;

	var argumentTypes:Array<String>;

	public var returnType(default, null):Null<String>;

	var className:String;

	var invocations:Array<Array<Dynamic>>;
	var stubbings:Array<Stub>;

	public function new(className:String, fieldName:String, arguments:Array<String>, ?returns:String)
	{
		this.fieldName = fieldName;
		this.className = className;

		argumentTypes = arguments;
		returnType = returns;

		invocations = [];
		stubbings = [];
	}
	
	public function call(args:Array<Dynamic>)
	{
		invocations.push(args);

		var stub = getStubForArgs(args);

		if(stub != null && stub.values.length > 0)
		{
			switch(stub.values.shift())
			{
				case returns(value): //return value;
				case throws(value): throw value;
				case calls(value): value(args);
			}
		}
		//specific, any value, null
	}

	public function callAndReturn<T>(args:Array<Dynamic>, defaultReturn:T):T
	{
		invocations.push(args);

		var stub = getStubForArgs(args);

		if(stub != null && stub.values.length > 0)
		{
			switch(stub.values.shift())
			{
				case returns(value): return value;
				case throws(value): throw value;
				case calls(value): return value(args);
			}

		}
		else
			return defaultReturn;
	}

	public function addReturnFor<T>(args:Array<Dynamic>, values:Array<T>)
	{
		if(returnType == null) throw new StubbingException("Method [" + fieldName + "] has no return type and cannot stub custom return values.");

		var stub = getStubForArgs(args);

		if(stub == null)
		{
			stub = {args:args, values:[]};
			stubbings.push(stub);
		}

		for(value in values)
		{
			stub.values.push( returns(value) );
		}
	}


	public function addThrowFor(args:Array<Dynamic>, values:Array<Dynamic>)
	{
		var stub = getStubForArgs(args);

		if(stub == null)
		{
			stub = {args:args, values:[]};
			stubbings.push(stub);
		}

		for(value in values)
		{
			stub.values.push(throws(value));
		}
	}

	public function addCallbackFor(args:Array<Dynamic>, values:Array<Dynamic>)
	{
		var stub = getStubForArgs(args);

		if(stub == null)
		{
			stub = {args:args, values:[]};
			stubbings.push(stub);
		}

		for(value in values)
		{
			if(!Reflect.isFunction(value))
				 throw new StubbingException("Value [" + value + "] is not a function.");

			stub.values.push( calls(value) );
		}
	}

	function getStubForArgs(args:Array<Dynamic>):Stub
	{
		for(stub in stubbings)
		{
			if(stub.args.length != args.length) continue;

			var matchingArgs = 0;

			for(i in 0...args.length)
			{
				if(compareArgs(args[i], stub.args[i])) 
					matchingArgs ++;
			}

			if(matchingArgs == args.length)
			{
				return stub;
			}
		}
		return null;
	}

	public function verify(mode:VerificationMode, ?args:Array<Dynamic>):Bool
	{
		var matchingInvocations = getMatchingArgs(invocations, args);

		var matches:Int = matchingInvocations.length;
		
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

	function getMatchingArgs(argArrays:Array<Array<Dynamic>>, args:Array<Dynamic>):Array<Array<Dynamic>>
	{
		var matches:Array<Array<Dynamic>> = [];

		for(targetArgs in argArrays)
		{
			if(targetArgs.length != args.length) 
			{
				continue;
			}

			var matchingArgs = 0;
			for(i in 0...args.length)
			{
				if(compareArgs(args[i], targetArgs[i])) 
					matchingArgs ++;
			}

			if(matchingArgs == args.length)
				matches.push(targetArgs);
		}

		return matches;
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


typedef Stub = 
{
	args:Array<Dynamic>,
	values:Array<StubValue>
}

enum StubValue
{
	returns(value:Dynamic);
	throws(value:Dynamic);
	calls(value:Dynamic);
}

typedef Range =
{
	min:Null<Int>,
	max:Null<Int>
}
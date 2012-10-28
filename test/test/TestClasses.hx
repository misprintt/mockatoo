package test;

/**
Contains classes for testing mocking scenarios
*/
// -----------------------------------------------------------------------------

interface SimpleInterface
{
	function test():Void;
}

class SimpleClass
{
	public function new()
	{
		throw "not mocked";
	}

	public function test()
	{
		throw "not mocked";
	}
}

class VariableArgumentsClass
{
	public function new()
	{

	}

	public function none()
	{

	}

	public function one(arg:Int):Int
	{
		return arg;
	}

	public function two(arg1:Int, arg2:Int):Int
	{
		return arg1 + arg2;
	}

	public function three(arg1:Int, arg2:Int, arg3:Int):Int
	{
		return arg1 + arg2 + arg3;
	}

	public function oneOptional(?arg1:Int):Int
	{
		return arg1;
	}

	public function twoOptional(arg1:Int, ?arg2:Int):Int
	{
		return arg1;
	}
}

interface IntefaceWithFields
{
	var bool:Bool;
	var int:Int;
	var float:Float;
	var string:String;
	var object:Dynamic;

	function toBool():Bool;
	function toInt():Int;
	function toFloat():Float;
	function toString():String;
	function toDynamic():Dynamic;
	function toVoid():Void;
	
	function toBoolWithArgs(arg:Bool):Bool;
	function toIntWithArgs(arg:Int):Int;
	function toFloatWithArgs(arg:Float):Float;
	function toStringWithArgs(arg:String):String;
	function toDynamicWithArgs(arg:Dynamic):Dynamic;
	function toVoidWithArgs(arg:Int):Void;

	function withMultipleArgs(arg1:Int, arg2:Bool):Void;
	function withOptionalArgs(?arg1:Int, ?arg2:Bool):Void;
}

class ClassWithFields implements IntefaceWithFields
{
	public function new(){}

	public var bool:Bool;
	public var int:Int;
	public var float:Float;
	public var string:String;
	public var object:Dynamic;

	public function toBool():Bool {throw "not mocked"; return true;}

	public function toInt():Int {throw "not mocked"; return 1;}
	public function toFloat():Float {throw "not mocked"; return 1.0;}
	public function toString():String {throw "not mocked"; return "string";}
	public function toDynamic():Dynamic {throw "not mocked"; return {name:"foo"};}
	public function toVoid():Void {throw "not mocked";}

	public function toBoolWithArgs(arg:Bool):Bool {throw "not mocked"; return true;}
	public function toIntWithArgs(arg:Int):Int {throw "not mocked";return 1;}
	public function toFloatWithArgs(arg:Float):Float {throw "not mocked";return 1.0;}
	public function toStringWithArgs(arg:String):String {throw "not mocked";return "string";}
	public function toDynamicWithArgs(arg:Dynamic):Dynamic {throw "not mocked";return {name:"foo"};}
	public function toVoidWithArgs(arg:Int):Void {throw "not mocked";}

	public function withMultipleArgs(arg1:Int, arg2:Bool):Void {throw "not mocked";}
	public function withOptionalArgs(?arg1:Int, ?arg2:Bool):Void {throw "not mocked";}
}


class ClassWithConstructorAgs
{
	public function new(bool:Bool, int:Int)
	{
		throw "not mocked";
	}
}

class ClassWithInlinedMethod
{
	public function new()
	{
		throw "not mocked";
	}

	inline public function isInlined():Bool
	{
		throw "not mocked";
		return true;
	}
}

@:final
class ClassThatIsFinal
{
	public function new()
	{
		throw "not mocked";
	}
}


// ----------------------------------------------------------------------------- Typed paramaters


interface TypedInterface<T>
{
	function toTypeWithArg(value:T):T;
}

interface StringTypedInterface implements TypedInterface<String>
{

}

interface ImplementsTypedInterface<TFoo, TBar> implements TypedInterface<TBar>
{

}

class TypedClass<T>
{
	public function new()
	{

	}

	public function toTypeWithArg(value:T):T
	{
		return value;
	}
}

class StringTypedClass extends TypedClass<String>
{
	public function new()
	{
		super();
	}	
}

class ExtendsTypedClass<TFoo, TBar> extends TypedClass<TBar>
{
	public function new(foo:TFoo, bar:TBar)
	{
		super();
	}	
}


class ExtendsTypedExtensionClass extends ExtendsTypedClass<String, String>
{
	public function new(foo:String, bar:String)
	{
		super(foo,bar);
	}	
}

class ClassWithPrivateReference
{
	public function new()
	{

	}


	public function test(arg:PrivateClass):PrivateClass
	{
		return arg;
	}
}

private class PrivateClass
{
	public function new()
	{
		
	}
}


// ----------------------------------------------------------------------------- Typedef Aliases


typedef TypedefToSimpleInterface = SimpleInterface;
typedef TypedefToSimpleClass = SimpleClass;
typedef TypedefToStringTypedInterface = TypedInterface<String>;
typedef TypedefToStringTypedClass = TypedClass<String>;

typedef TypedefToImplementsTypedInterface = ImplementsTypedInterface<String, String>;
typedef TypedefToExtendsTypedClass = ExtendsTypedClass<String, String>;



// ----------------------------------------------------------------------------- Typedef Structures


typedef TypedefStructure = 
{
	var title:String;
	var func:Void->String;
	var type:SomeEnumType;
	
	@:optional var optionalTitle:String;
	@:optional var optionalFunc:Void -> String;
}


enum SomeEnumType
{
	foo;
	bar;
}

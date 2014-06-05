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

class VariableArgumentsReturnsVoidClass
{
	public function new()
	{

	}

	public function none()
	{

	}

	public function one(arg:Int)
	{
	}

	public function two(arg1:Int, arg2:Int)
	{
		
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

interface StringTypedInterface extends TypedInterface<String> {}
interface ImplementsTypedInterface<TFoo, TBar> extends TypedInterface<TBar> {}

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

class TypedIterableClass<T>
{
	var source:Array<T>;
	public function new()
	{
		source = [];
	}

	public function iterator():Iterator<Null<T>>
	{
		return source.iterator();
	}
}

class IntIterableClass extends TypedIterableClass<Int>
{
	public function new()
	{
		super();
	}
}


class TypedMethod
{
	public function new()
	{
		
	}
	public function test<T>(t:T)
	{
	}
}
// ---------------------- others

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

class ClassWithOptionalArg
{
	public function new()
	{

	}

	public function foo(value:Bool=false):String
	{
		return "";
	}

	public function foo2(?value:Bool=false):String
	{
		return "";
	}
}

class ClassWithTypedConstraint<T:TypedConstraintFoo>
{
	public function new()
	{

	}
	public function test():String
	{
		return "";
	}
}

class ClassWithMultipleTypedConstraints<T:(TypedConstraintFoo,TypedConstraintBar)>
{
	public function new()
	{

	}

	public function test():String
	{
		return "";
	}
}

class TypedConstraintFoo
{
	public function new()
	{
		
	}

	public function foo()
	{

	}
}

interface TypedConstraintBar
{
	function bar():Void;
}

class TypedConstraintFooBar extends TypedConstraintFoo implements TypedConstraintBar
{
	public function new()
	{
		super();
	}

	public function fooBar()
	{
		
	}

	public function bar()
	{
		
	}
}

class BaseTypedParam<T>
{
	public function new()
	{

	}
}

class ConcreteTypedParam<T> extends BaseTypedParam<T>
{
	public function new()
	{
		super();
	}
}

typedef AnyConcreteTypedParam = ConcreteTypedParam<Dynamic>;

// ----------------------------------------------------------------------------- Properties

class ClassWithProperties
{
	public var property:String;

	public var readOnly(default, null):String;
	
	public var setter(default, set_setter):String;
	
	public var never(default, never):String;

	public var func:Void->String;

	function set_setter(value:String)
	{
		setter = value;
		return value;
	}

	@:isVar public var getterSetter(get_getterSetter, set_getterSetter):String;
	
	function get_getterSetter():String
	{
		return getterSetter;
	}

	function set_getterSetter(value:String)
	{
		getterSetter = value;
		return value;
	}

	public function new()
	{
		
	}

}

interface InterfaceWithProperties
{
	public var getterSetter(get_getterSetter, set_getterSetter):String;
    public var getter(default, null):String;
    public var setter(default, set_setter):String;
}
 
interface InterfaceWithTypedProperties<T>
{
    public var getterSetter(get_getterSetter, set_getterSetter):T;
    public var getter(default, null):T;
    public var setter(default, set_setter):T;
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

class SomeClass
{
	public function new(){}
}

interface Issue17Interface
{
	var setter(null, set): Void->Void;
	var getter(get, null): Void->Void;
	var getterSetter(default, default): Void->Void;
	var nulledGetterSetter(get, set): Null<Void->Void>;
}

class Issue17Class implements Issue17Interface
{
	public function new()
	{
		value = function(){};
	}
	var value:Null<Void->Void>;

	public var setter(null, set): Void->Void;

	function set_setter(v:Void->Void):Void->Void
	{
		value = v;
		return value;
	}

	public var getter(get, null): Void->Void;

	function get_getter():Void->Void
	{
		return value;
	}

	public var getterSetter(default, default): Void->Void;

	public var nulledGetterSetter(get, set): Null<Void->Void>;

	function set_nulledGetterSetter(v:Void->Void):Void->Void
	{
		value = v;
		return value;
	}

	function get_nulledGetterSetter():Void->Void
	{
		return value;
	}
}

// ----------------------------------------------------------------------------- Matchers

interface SomeMatcherInterface
{
	function fromString(?value:String):Bool;
	function fromInt(value:Int):Bool;
	function fromFloat(value:Float):Bool;
	function fromBool(value:Bool):Bool;
	function fromArray(value:Array<Int>):Bool;
	function fromDynamic(value:Dynamic):Bool;
	function fromEnum(value:SomeEnumType):Bool;
	function fromInstance(value:SomeClass):Bool;
}

class SomeMatcherClass implements SomeMatcherInterface
{
	public function new(){}

	public function fromString(?value:String):Bool{return false;}
	public function fromInt(value:Int):Bool{return false;}
	public function fromFloat(value:Float):Bool{return false;}
	public function fromBool(value:Bool):Bool{return false;}
	public function fromArray(value:Array<Int>):Bool{return false;}
	public function fromDynamic(value:Dynamic):Bool{return false;}
	public function fromEnum(value:SomeEnumType):Bool{return false;}
	public function fromInstance(value:SomeClass):Bool{return false;}
}

interface Something {
    public function returnSomething(something:String, ?other:Null<Int> = 0):String;
}

interface Issue18
{
	var myVal(null, set): Dynamic;
}

class Issue23
{
	public function new()
	{

	}
	public function test<T>(t:T)
	{
	}
}

class ClassWithoutTypedArgs
{
	public function new()
	{

	}

	public function untypedArg(arg)
	{

	}

	public function untypedReturn()
	{
		return {};
	}
}
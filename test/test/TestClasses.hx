package test;

/**
Contains classes for testing mocking scenarios
*/
// -----------------------------------------------------------------------------

interface SimpleInterface {}

class SimpleClass
{
	public function new()
	{
		throw "not mocked";
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
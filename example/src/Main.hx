import mockatoo.Mockatoo;
import mockatoo.Mock;

/**
Simple example showing mocking for interfaces, classes and typedef alisas.
Each mock overrides/implements the methods and returns stub values 
*/
class Main
{
	public static function main()
	{
		mconsole.Console.start();

		// mock an interface
		var mock1 = Mockatoo.mock(Collection);
		trace(Std.is(mock1, Collection));
		mock1.add("first");
		trace(mock1.get(0));//null
		mock1.clear();
	
		// mock a class
		var mock2 = Mockatoo.mock(StringCollection);
		trace(Std.is(mock2, StringCollection));
		mock2.add("first");
		trace(mock2.get(0));//null
		mock2.clear();

		// mock an interface with type paramaters
		var mock3 = Mockatoo.mock(Collection, [Int]);
		trace(Std.is(mock3, Collection));
		mock3.add(1);
		trace(mock3.get(0));//null
		mock3.clear();

		//mock a typedef alias
		var mock4 =  Mockatoo.mock(BoolCollection);
		trace(Std.is(mock4, Collection));
		mock4.add(true);
		trace(mock4.get(0));//null
		mock4.clear();
	}
}

interface Collection<T>
{
	function add(value:T):Void;
	function clear():Void;
	function get(index:Int):T;
}

class StringCollection implements Collection<String>
{
	var values:Array<String>;

	public function new()
	{
		values = [];
	}

	public function add(value:String):Void
	{
		values.push(value);
	}

	public function clear():Void
	{
		values = [];
	}

	public function get(index:Int):String
	{
		if(index < 0 || index > values.length-1) throw "Range exception";
		return values[index];
	}
}

typedef BoolCollection = Collection<Bool>;



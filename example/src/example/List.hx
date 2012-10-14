package example;

interface List<T>
{
	function add(value:T):Void;

	function clear():Void;

	function get(index:Int):T;
}

class SimpleList<T> implements List<T>
{
	var values:Array<T>;

	public function new()
	{
		values = [];
	}

	public function add(value:T):Void
	{
		values.push(value);
	}

	public function clear():Void
	{
		values = [];
	}

	public function get(index:Int):T
	{
		if(index < 0 || index > values.length-1) throw "Range exception";

		return values[index];
	}


}

class SimpleListWithConstructorArg<T> extends SimpleList<T>
{
	public function new(values:Array<T>)
	{
		super();
		this.values = values;
	}
}


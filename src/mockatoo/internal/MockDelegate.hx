package mockatoo.internal;

class MockDelegate
{
	public var target:Mock;

	public function new(target:Mock)
	{
		this.target = target;
	}

	public function call(method:String, args:Array<Dynamic>)
	{
		//trace(method);
	}

	public function callWithReturn<T>(method:String, args:Array<Dynamic>, returnValue:T):T
	{
		//trace(method);
		return returnValue;
	}
}
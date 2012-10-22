package mockatoo.internal;

class MockDelegate
{
	public var target:Mock;

	public function new(target:Mock)
	{
		this.target = target;
	}
}
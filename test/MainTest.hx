import massive.munit.Assert;

class MainTest 
{
	public function new(){}

	@Test
	public function main_returns_true():Void
	{
		Assert.isTrue(Main.main());
	}
}

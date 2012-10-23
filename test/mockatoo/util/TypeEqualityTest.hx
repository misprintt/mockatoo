package mockatoo.util;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mockatoo.util.TypeEquality;
using mockatoo.util.TypeEquality;
/**
* Auto generated MassiveUnit Test Class  for mockatoo.util.TypeEquality 
*/
class TypeEqualityTest 
{
	public function new() 
	{
		
	}
	
	@BeforeClass
	public function beforeClass():Void
	{
	}
	
	@AfterClass
	public function afterClass():Void
	{
	}
	
	@Before
	public function setup():Void
	{
	}
	
	@After
	public function tearDown():Void
	{
	}
	
	
	@Test
	public function should_equal_same_type():Void
	{
		Assert.isTrue(1.equals(1));
		Assert.isTrue("foo".equals("foo"));
		Assert.isFalse("foo".equals("bar"));
	}

	@Test
	public function should_equal_same_enum_type():Void
	{
		Assert.isTrue(a.equals(a));
		Assert.isFalse(a.equals(b));

		Assert.isTrue(a.equalsEnum(a));
		Assert.isFalse(a.equals(b));

		Assert.isTrue(c(1).equalsEnum(c(1)));
		Assert.isFalse(c(1).equalsEnum(c(2)));
	}

	@Test
	public function should_not_equal_different_enum():Void
	{
		Assert.isFalse(false.equals(a));
	}

	@Test
	public function should_match_on_wildcar():Void
	{
		Assert.isTrue(c(null).equals(c(1)));
		Assert.isTrue(d(null).equals(d("foo")));
	}
}

private enum TestEnum
{
	a;
	b;
	c(value:Dynamic);
	d(value:String);
}
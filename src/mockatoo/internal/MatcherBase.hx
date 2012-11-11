package mockatoo.internal;

import mockatoo.Mockatoo;

class MatcherBase
{
	public function new()
	{

	}


	public function anyString()
	{
		return Matcher.anyString;
	}

	public function anyInt()
	{
		return Matcher.anyInt;
	}
	
	public function anyFloat()
	{
		return Matcher.anyFloat;
	}
	
	public function anyBool()
	{
		return Matcher.anyBool;
	}
	
	public function anyIterator()
	{
		return Matcher.anyIterator;
	}
	
	public function anyObject()
	{
		return Matcher.anyObject;
	}

	public function anyEnum()
	{
		return Matcher.anyEnum;
	}

	public function enumOf(e:Enum<Dynamic>)
	{
		return Matcher.enumOf(e);
	}	

	public function instanceOf(c:Class<Dynamic>)
	{
		return Matcher.instanceOf(c);
	}

	public function isNotNull()
	{
		return Matcher.isNotNull;
	}
	
	public function isNull()
	{
		return Matcher.isNull;
	}

	public function any()
	{
		return Matcher.any;
	}	
	
	public function customMatcher(f:Dynamic -> Bool)
	{
		return Matcher.customMatcher(f);
	}
}

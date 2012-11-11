package mockatoo.exception;

import haxe.PosInfos;

#if munit
class MockatooException extends massive.munit.AssertionException
{
	public function new(?message:String="", ?info:PosInfos)
	{
		super(message, info);
		type = here().className;
	}

	function here(?pos:PosInfos):PosInfos
	{
		return pos;
	}
}

#else
class MockatooException
{
	var message:String;
	var info:PosInfos;
	var type:String;

	public function new(?message:String="", ?info:PosInfos)
	{
		this.message = message;
		this.info = info;
		type = here().className;
	}

	public function toString()
	{
		return type + " - " + message + " - At " + info.className + "#" + info.methodName + "::" + info.lineNumber + " [" + info.fileName + "]";
	}

	function here(?pos:PosInfos):PosInfos
	{
		return pos;
	}
}
#end

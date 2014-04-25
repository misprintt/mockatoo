package mockatoo.exception;

import haxe.PosInfos;

/**
	To be raised when stubbing is invalid.
	@see massive.munit.AssertionException
*/
class StubbingException extends MockatooException
{
	public function new(?message:String="", ?info:PosInfos)
	{
		super(message, info);
		type = here().className;
	}
}

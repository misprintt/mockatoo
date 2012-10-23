package mockatoo.exception;

import haxe.PosInfos;

/**
To be raised when stubbing is invalid.
@see mcore.exception.Exception
*/
class StubbingException extends massive.munit.AssertionException
{
	public function new(?message:String="", ?info:PosInfos)
	{
		super(message, info);
	}
}

package mockatoo.exception;

import haxe.PosInfos;

/**
To be raised when a verification failed.

@see mcore.exception.Exception
*/
class VerificationException extends massive.munit.AssertionException
{
	public function new(?message:String="", ?info:PosInfos)
	{
		super(message, info);
	}
}

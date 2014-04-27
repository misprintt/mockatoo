package mockatoo.exception;

import haxe.PosInfos;

/**
	To be raised when a verification failed.
	@see massive.munit.AssertionException
*/
class VerificationException extends MockatooException
{
	public function new(?message:String="", ?info:PosInfos)
	{
		super(message, info);
		type = here().className;
	}
}

package mockatoo.internal;

import mockatoo.Mockatoo;

/**
 * Dynamic class that is created for verification.
 * Each dynamic method calls to a specific MethodProxy.
 */
class MockVerification implements Dynamic<Dynamic>
{
	public var mode:VerificationMode;

	public function new(mode:VerificationMode)
	{
		this.mode = mode;	
	}
}

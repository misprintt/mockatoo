package mockatoo.internal;

import mockatoo.VerificationMode;

class MockVerification implements Dynamic<Dynamic>
{
	public var mode:VerificationMode;

	public function new(mode:VerificationMode)
	{
		this.mode = mode;	
	}
}

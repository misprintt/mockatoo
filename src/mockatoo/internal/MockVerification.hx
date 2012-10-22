package mockatoo.internal;

import mockatoo.VerificationMode;

class MockVerification implements Dynamic<Bool>
{
	public var mode:VerificationMode;

	public function new(mode:VerificationMode)
	{
		this.mode = mode;	
	}
}

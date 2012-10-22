package mockatoo.internal;

import mockatoo.Mockatoo;

class MockVerification implements Dynamic<Bool>
{
	public var filter:VerificationFilter;

	public function new(filter:VerificationFilter)
	{
		this.filter = filter;	
	}
}

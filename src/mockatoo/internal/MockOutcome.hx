package mockatoo.internal;

enum MockOutcome
{
	returns(value:Dynamic);
	throws(value:Dynamic);
	calls(value:Dynamic);
	stubs;//default stub value
	callsRealMethod;
	none;
}

package mockatoo.internal;

enum MockOutcome
{
	returns(value:Dynamic);
	throws(value:Dynamic);
	calls(value:Dynamic);
	none;
}
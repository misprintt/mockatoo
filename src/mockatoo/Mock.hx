package mockatoo;

import mockatoo.internal.MockProxy;

/**
Indicates a class is a generated Mock
*/
@:keepSub
interface Mock
{
	var mockProxy:MockProxy;
}
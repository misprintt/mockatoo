package mockatoo;

import mockatoo.internal.MockDelegate;


/**
Indicates a class is a generated Mock
*/
interface Mock
{
	var mockDelegate:MockDelegate;
}
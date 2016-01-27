package mockatoo.internal;

/**
 * Generic typedef for any matcher class that have a matches function. 
 * This way you can use any 3rdparty framework like hamcrest to match against complex conditions.
 * @author grosmar
 */

typedef MatcherClass =
{
	function matches(item:Dynamic):Bool;
}
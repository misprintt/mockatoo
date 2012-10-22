package mockatoo;

/**
 * Allows verifying that certain behavior happened at least once / exact number
 * of times / never. E.g:
 * 
 * <pre class="code"><code class="java">
 * verify(mock, times(5)).someMethod(&quot;was called five times&quot;);
 * 
 * verify(mock, never()).someMethod(&quot;was never called&quot;);
 * 
 * verify(mock, atLeastOnce()).someMethod(&quot;was called at least once&quot;);
 * 
 * verify(mock, atLeast(2)).someMethod(&quot;was called at least twice&quot;);
 * 
 * verify(mock, atMost(3)).someMethod(&quot;was called at most 3 times&quot;);
 * 
 * </code></pre>
 * 
 * <b>times(1) is the default</b> and can be omitted
 */
enum VerificationMode
{
	times(value:Int);
	atLeastOnce;
	atLeast(value:Int);
	never;
	atMost(value:Int);
	between(value1:Int, value2:Int);
}
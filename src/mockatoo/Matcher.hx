package mockatoo;

/**
 * Allow flexible verification or stubbing of arguments.
 */
enum Matcher
{
	/**
     * Any <code>String</code> 
    */
	anyString;

	/**
     * Any <code>Int</code> 
    */
	anyInt;

	/**
     * Any <code>Float</code> or <code>Int</code> 
    */
	anyFloat;

	/**
     * Any <code>Bool</code>
    */
	anyBool;

	/**
     * Any <code>Iterator</code> or <code>Iterable</code> including <code>Array</code> 
     * <code>Hash</code>, etc
    */
	anyIterator;

	/**
     * Any anonymous data structure like <code>{foo:"bar"}</code>. Does not
     * match on class instances
    */
	anyObject;

	/**
     * Any <code>EnumValue</code>
    */
	anyEnum;

	/**
     * Any <code>EnumValue</code> of Enum <code>e</code> 
    */
	enumOf(e:Enum<Dynamic>);

	/**
     * Any instance of class <code>c</code> 
    */
	instanceOf(c:Class<Dynamic>);

	/**
     * Any value that is not <code>null</code>
    */
	isNotNull;

	/**
     * Value that is <code>null</code>
    */
	isNull;

	/**
     * Any value (including <code>null</code>)
    */
	any;

	/**
     * A custom function that verifies match of argument
    */
	customMatcher(f:Dynamic -> Bool);
}

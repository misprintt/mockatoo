package mockatoo;

enum Matches
{
	AnyString;
	AnyInt;
	AnyFloat;
	AnyBool;
	AnyObject; //anonymose data structures only (not class instances)
	AnyEnumValue(?e:Enum<Dynamic>);
	AnyInstanceOf(c:Class<Dynamic>);
	AnyIterator;
	NotNull;
}

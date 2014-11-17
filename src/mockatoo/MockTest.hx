package mockatoo;

/**
	Interface for automatically generating mock instances via metadata


	````
	@:mock var mock:SomeClass;
	@:spy var spy:SomeClass;
	````

	Current supports munit test framework
**/
@:autoBuild(mockatoo.macro.MockTestMacro.build())
interface MockTest
{

}
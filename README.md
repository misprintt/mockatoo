## Overview

Mockatoo is a Haxe mocking library that uses macros to generated mock
implementations of classes and interfaces for testing. Tested against Haxe 2.10 across most platforms (AVM2, JavaScript, Neko, C++, etc)

Mockatoo is inspired by **Mockito**'s public API <http://docs.mockito.googlecode.com/hg/latest/org/mockito/Mockito.html>


#### Mockatoo is in very early developement and is subject to change.

* See [releases](#release) for details on the current stable release.
* See [roadmap](#roadmap) for more details on planned features.


## Installation

Install the latest directly from github:

	haxelib git mockatoo https://github.com/massiveinteractive/mockatoo.git src/lib

Or point to your local fork:

	haxelib dev mockatoo /ABSOLUTE_PATH_TO_REPO/src/lib

## Usage[usage]

Import Mockatoo;

	import mockatoo.Mockatoo;

### Creating a mock instance

Mocks can be generated from both classes and interfaces:

	var mockedClass = Mockatoo.mock(SomeClass);
	var mockedInterface = Mockatoo.mock(SomeInterface);

A Mock class type will be generated that extends the Class (or Interface), stubbing all methods, and generate the code to instanciate the instance:

	var mockedClass = new SomeClassMocked();
	var mockedInterface = new SomeInterfaceMocked();


If a class requires Type paramaters then you need to create a typedef alias.

	typedef FooBar = Foo<Bar>;

	...

	var mockFoo =  Mockatoo.mock(FooBar);

Both these generates the equivalent expressions:

	var mockFoo = new Foo<Bar>();


> Note: Typedef aliases are required for Type paramaters in order to circumvent limitation of compiler with generics. You cannot compile `Foo.doSomething(Array<String>)`


## Release Notes[release]

### Release 0.1

Basic class and interface mocking (generates empty stub methods)

* Generate a mock class for any Class or Interface
* Generates sub class for Class targets
* Generates implementation for Interface targets
* Generate a mock class for classes with typed parameters  (and typedef aliases)
* Generate mocks for classes with super classes (mocks all non-overridden functions from super classes)
* Return correct 'null' types for methods with return types  (including default Int, Bool and Float types for static platforms) 


## Roadmap[roadmap]

This is the active roadmap.

### Release 0.2

**Typed paramaters without typedef**

Remove the need to use a typedef to generate a mock for a class or interface with
Type paramaters.

	//You can mock both concrete classes and interfaces
	var mockedList:List<String> = Mockatoo.mock(List, [String]);


**Basic Verification**

Verify if a method has been executed with the specified arguments:

	//using mock object
	mockedList.add("one");
	collection.clear();

	//verification
	verify(mockedList).add("one");
	verify(mockedList).clear();


### Release 0.3

**Basic Stubbing**

Define the stub response when calling specific methods/arguments

	//stubbing
	when(mockedList.get(0)).thenReturn("first");
	when(mockedList.get(1)).thenThrow(new RuntimeException());


### Release 0.4

**Spying**

Partial mock that defers to concrete implementation if not stubbed

	var hash:IntHash<String> = Mockatoo.spy(IntHash, [String]);

	when(hash.get(0)).thenReturn("mocked");

	hash.set(0, "a");
	hash.set(1, "b");

	trace(hash.get(0)); // traces 'mocked'
	trace(hash.get(1)); // traces 'b'


	




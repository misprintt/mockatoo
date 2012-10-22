## Overview

Mockatoo is a Haxe mocking library that uses macros to generated mock
implementations of classes and interfaces for testing. Tested against Haxe 2.10 across most platforms (AVM2, JavaScript, Neko, C++, etc)

Mockatoo is inspired by **Mockito**'s public API <http://docs.mockito.googlecode.com/hg/latest/org/mockito/Mockito.html>



> Disambiguation: The **Mockatoo** belongs to the bird family *Cacatuidae* and look suspiciously like a taxidermied [Cockatoo](http://en.wikipedia.org/wiki/Cockatoo) with fake plumage. They are mostly found nesting within testing habitats and may turn violent if mistaken for a *MockingBird* :)


#### Mockatoo is in very early developement and is subject to change.

* See [releases](#releases) for details on the current stable release.
* See [roadmap](#roadmap) for more details on planned features.


## Installation

Install the latest directly from github:

	haxelib git mockatoo https://github.com/misprintt/mockatoo.git src

Or point to your local fork:

	haxelib dev mockatoo /ABSOLUTE_PATH_TO_REPO/src

## Usage

Import Mockatoo;

	import mockatoo.Mockatoo;

### Creating a mock instance

Mocks can be generated from any Class, Interface or Typedef alias (not typedef structure)

	var mockedClass = Mockatoo.mock(SomeClass);
	var mockedInterface = Mockatoo.mock(SomeInterface);

A Mock class type will be generated that extends the Class (or Interface), stubbing all methods, and generate the code to instanciate the instance:

	var mockedClass = new SomeClassMocked();
	var mockedInterface = new SomeInterfaceMocked();


If a class requires Type paramaters then you can either use a typedef alias.

	typedef FooBar = Foo<Bar>;

	...

	var mockFoo =  Mockatoo.mock(FooBar);

Or pass through the types as a second paramater

	var mockFoo = Mockatoo.mock(Foo, [Bar]);

Both these generates the equivalent expressions:

	var mockFoo = new FooMocked<Bar>();


> Note: These usages are required in order to circumvent limitation of compiler with generics. You cannot compile `Foo.doSomething(Array<String>)`


### Verification

Verification refers to validation of of if, and how often a method has been
called (invoked) with particular argument values.

To verify that a method has been invoked:

	Mockatoo.verify(mock).foo();
	Mockatoo.verify(mock).foo("bar");
	Mockatoo.verify(mock).foo("foo");

To verify the number of times a method was invoked

	import mockatoo.VerificationMode;

	... 

	Mockatoo.verify(mock, times(2)).foo();
	Mockatoo.verify(mock, atLeast(2)).foo();
	Mockatoo.verify(mock, atLeastOnce).foo();
	Mockatoo.verify(mock, never).foo();
	Mockatoo.verify(mock, between(2,3)).foo();

> Note: Default mode is times(1);

## Limitations

* inlined methods will not be mocked (prints a compiler warning)
* @:final methods throw runtime errors in flash (AVM2) 

## Releases

### Release 0.2

Verification

* Added verification of methods being invoked
* Added Verification mode (validate number of invocations)

### Release 0.1

Basic class and interface mocking (generates empty stub methods)

* Generate a mock class for any Class, Interface or Typedef alias
* Generates sub class for Class targets
* Generates implementation for Interface targets (including super classes)
* Generate a mock class for classes with typed parameters  (and typedef aliases)
* Generate mocks for classes with super classes (mocks all non-overridden functions from super classes)
* Return correct 'null' types for methods with return types  (including default Int, Bool and Float types for static platforms) 


## Roadmap

This is the active roadmap.

### Release 0.2

**Basic Verification**

Verify if a method has been executed with the specified arguments:

	//verification
	verify(mockedList).foo("one");
	verify(mockedList, atLeast(2)).bar();


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



### Other proposed features

**Mockable Typedef stuctures**


	typedef SomeType = 
	{
		name:String,
		doSomething:Void->Void
	}

	var mock:Sometype = Mockatoo.mock(SomeType);





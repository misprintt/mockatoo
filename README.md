## Overview

Mockatoo is a Haxe library for mocks creation, verification and stubbing.

Uses Haxe macros to generated mock implementations of classes and interfaces for testing.
Tested against Haxe 2.10 across most platforms (AVM2, JavaScript, Neko, C++, etc)

Mockatoo is inspired by **Mockito**'s public API <http://docs.mockito.googlecode.com/hg/latest/org/mockito/Mockito.html>


> Disambiguation: The **Mockatoo** belongs to the bird family *Cacatuidae* and look suspiciously like a taxidermied [Cockatoo](http://en.wikipedia.org/wiki/Cockatoo) with fake plumage. They are mostly found nesting within testing habitats and like  to repeat what you say (like a parrot). A Mockatoo may turn violent if mistaken for a *MockingBird* :)


#### Mockatoo is in developement and is subject to change.

* See [Features](#features) for overview of key features
* See [Usage](#usage) for more detailed examples and usecases
* See [Known Limitations](#knownlimitations) for edge cases not supported in Haxe 2.10.
* See [milestones](#milestones) for details on the current stable release.
* See [roadmap](#roadmap) for more details on planned features.


## Installation

Install the latest directly from github:

	haxelib git mockatoo https://github.com/misprintt/mockatoo.git src

Or point to your local fork:

	haxelib dev mockatoo /ABSOLUTE_PATH_TO_REPO/src


## Features

Mock any class or interface (or typedef alias), including types with generics

	var mockedClass = Mockatoo.mock(SomeClass);
	var mockedInterface = Mockatoo.mock(SomeInterface);
	var mockedClassWithGenerics = Mockatoo.mock(Foo, [Bar]);

Verify a method has been called with specific paramaters

	Mockatoo.verify(mock).foo();
	Mockatoo.verify(mock).someMethod("foo", "bar");

Define a stub response when a method is invoked

	Mockatoo.when(mock.foo("bar")).thenReturn("hello");
	Mockatoo.when(mock.someMethod("foo", "bar").thenThrow(new Exception(""));

Custom argument matchers and wildcards

	Mockatoo.when(mock.foo(anyString)).thenReturn("hello");
	Mockatoo.when(mock.foo(isNull)).thenReturn("world");

Verifying exact number of invocations

	Mockatoo.verify(mock, times(2)).foo();
	Mockatoo.verify(mock, atLeast(2)).foo();
	Mockatoo.verify(mock, atLeastOnce).foo();
	Mockatoo.verify(mock, never).foo();


## Usage

* [Create a Mock](#createamock)
* [Verifying Behaviour](#verifyingbehaviour)
* [Basic Stubbing](#basicstubbing)
* [Argument Matchers](#argumentmatchers)
* [Verifying exact number of invocations / at least once / never](#verifyingexactnumberofinvocations)
* [Advanced Stubbing with consecutive calls or callbacks](#advancedstubbing)
* [Known limitations](#limitations)


Import Mockatoo;

	import mockatoo.Mockatoo;

### Create a Mock

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


### Verifying Behaviour

Verification refers to validation of of if, and how often a method has been
called (invoked) with particular argument values.

To verify that a method *foo* has been invoked:

	Mockatoo.verify(mock).foo();
	Mockatoo.verify(mock).foo("bar");
	Mockatoo.verify(mock).foo("foo");
	Mockatoo.verify(mock).foo("foo", true);

Once created, mock will remember all interactions. Then you can selectively verify whatever interaction you are interested in.

### Basic Stubbing

Mockatoo allows the behaviour of methods to be stubbed

	Mockatoo.when(mock.foo("bar")).thenReturn("hello");

You can also specify an execption

	Mockatoo.when(mock.foo("not bar")).thenThrow(new SomeApplicationException("not a bar"));


### Argument Matchers

Mockatoo verifies argument values in natural syntax: by using an <code>equals()</code> method. Sometimes, when extra flexibility is required then you might use argument matchers:  

Matching against a type:

	Mockatoo.verify(mock).foo(anyString);
	Mockatoo.verify(mock).foo(anyInt);
	Mockatoo.verify(mock).foo(anyFloat);
	Mockatoo.verify(mock).foo(anyBool);
	Mockatoo.verify(mock).foo(anyObject); 	//anonymous data structures only (not class instances)
	Mockatoo.verify(mock).foo(anyIterator); // any Iterator or Iterable (e.g. Array, Hash, etc)
	Mockatoo.verify(mock).foo(anyEnum); 	// any enum value of any enum;

Matching against a specific class or enum:

	Mockatoo.verify(mock).foo(enumOf(Color)); 		 	// any enum value of Enum Colour
	Mockatoo.verify(mock).foo(instanceOf(SomeClass)); 	// any instance of SomeClass (or it's subclasses)


Wildcard matches

	Mockatoo.verify(mock).foo(any);	 		//any value (including null)
	Mockatoo.verify(mock).foo(isNotNull);	// any non null value
	Mockatoo.verify(mock).foo(isNull);		// same as verifying 'null')


Custom matching function

	var f = function(value:Dynamic):Bool
	{
		...
	}

	Mockatoo.verify(mock).foo(customMatcher(f));


### Verifying exact number of invocations

Verifications use natural language to specify the minimum and maximum times a method was invoked with specific arguments

	Mockatoo.verify(mock, times(2)).foo();
	Mockatoo.verify(mock, atLeast(2)).foo();
	Mockatoo.verify(mock, atLeastOnce).foo();
	Mockatoo.verify(mock, never).foo();

> Note: Default mode is times(1);

### Advanced stubbing

Stubbing is chainable, so you can stub with different behavior for consecutive method calls.

This can be achieved by providing multiple return (or thrown) values:

	Mockatoo.when(mock.someMethod()).thenReturn("a", "b");
	Mockatoo.when(mock.someMethod()).theThrow("one", "two");

Combinations can also be chained together

	Mockatoo.when(mock.someMethod()).thenReturn("one", "two").thenThrow("empty");


The last stubbing (e.g: thenThrow("empty")) determines the behavior for any further consecutive calls.

**Custom Callback Stub**

You can also set a custom callback when a method is invoked

	var f = function(args:Array<Dynamic>)
	{
		if(Std.is(args[0], String) return args[0].charAt(0) == "b";
	}

	Mockatoo.when(mock.foo("bar")).thenCall(f);


## Known Limitations

### Mocking inlined methods

In Haxe 2.10 inlined methods cannot be mocked. Mockatoo will print a compiler warning and skip affected fields.

	inline public function someMethod()
	{
		..///
	}

In Haxe 2.11 (svn) this has been resolved (<http://code.google.com/p/haxe/issues/detail?id=1231>) and requires the `--no-inline` compiler flag

### Mocking @:final methods

Mockatoo supports overriding @:final methods, however it throws run time exceptions on the Flash target (AVM2).

See <http://code.google.com/p/haxe/issues/detail?id=1246> for more details.

	@:final public function someMethod()
	{
		..///
	}

### Mocking methods which reference private types


Some classes may expect arguments, or return values typed to a private Class, Enum or Typedef. For example, mocking `haxe.Http` will fail to compile on the neko target due to a reference to `private typedef AbstractSocket`

	Mockatoo.mock(haxe.Http);


This is due to an edge case in tink_macros (1.2.0) that has now been fixed on tinkerbell master (see <https://github.com/back2dos/tinkerbell/pull/37> for more details)

## Milestones

### M2 - Completed

Verification

* Added verification of methods being invoked
* Added Verification mode (validate number of invocations)
* Added verification of fuzzy matches (AnyString, AnyBool, NotNull, etc)

Stubbing

* Added basic stubbing - `thenReturn`, `thenThrow`
* Added chaining of stubs - `thenReturn(1).thenThrow("empty")`
* Added callback stub - `thenCall(function)`

### M1  - Completed

Basic class and interface mocking (generates empty stub methods)

* Generate a mock class for any Class, Interface or Typedef alias
* Generates sub class for Class targets
* Generates implementation for Interface targets (including super classes)
* Generate a mock class for classes with typed parameters  (and typedef aliases)
* Generate mocks for classes with super classes (mocks all non-overridden functions from super classes)
* Return correct 'null' types for methods with return types  (including default Int, Bool and Float types for static platforms) 

## Roadmap

This is the active roadmap.

### M3

**Partial Mocks (Spying)**

Partial mock that defers to concrete implementation if not stubbed

	var hash:IntHash<String> = Mockatoo.spy(IntHash, [String]);

	when(hash.get(0)).thenReturn("mocked");

	hash.set(0, "a");
	hash.set(1, "b");

	trace(hash.get(0)); // traces 'mocked'
	trace(hash.get(1)); // traces 'b'


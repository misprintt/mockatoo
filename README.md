## Overview

Mockatoo is a Haxe library for mocks creation, verification and stubbing.

Uses Haxe macros to generated mock implementations of classes and interfaces for testing.
Tested against Haxe 2.10 across most platforms (AVM2, JavaScript, Neko, C++, etc)

Mockatoo is inspired by **Mockito**'s public API <http://docs.mockito.googlecode.com/hg/latest/org/mockito/Mockito.html>


> Disambiguation: The **Mockatoo** belongs to the bird family *Cacatuidae* and look suspiciously like a taxidermied [Cockatoo](http://en.wikipedia.org/wiki/Cockatoo) with fake plumage. They are mostly found nesting within testing habitats and like  to repeat what you say (like a parrot). A Mockatoo may turn violent if mistaken for a *MockingBird* :)


## Table of Contents

* [Installation Guide](#installation)
* [Overview of Features](#features)
* [Detailed Usage Guide and Examples](#usage-guide) 
* [Known Limitations](#known-limitations) and edge cases with Haxe 2.10.
* [Credits](#credits)


## Installation

Install current stable release from haxelib

	haxelib install mockatoo

Install the latest directly from github:

	haxelib git mockatoo https://github.com/misprintt/mockatoo.git src

Or point to your local fork:

	haxelib dev mockatoo /ABSOLUTE_PATH_TO_REPO/src


## Features

Mock any class or interface, including typedef aliases and types with generics (type paramaters)

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

Verify exact number of invocations

	Mockatoo.verify(mock, times(2)).foo();
	Mockatoo.verify(mock, atLeast(2)).foo();
	Mockatoo.verify(mock, atLeastOnce).foo();
	Mockatoo.verify(mock, never).foo();

Spy on real objects and partial mocking (Since 1.1.0)

	var spy = Mockatoo.spy(SomeClass);
	spy.foo(); // calls real method;
	Mockatoo.when(spy.foo()).thenReturn("hello");
	spy.foo(); //calls stub;


Mock properties that are read or write only (Since 1.2.0)

	Mockatoo.when(mock.someProperty).thenReturn("hello");
	Mockatoo.when(mock.someSetter).thenThrow("exception");
	Mockatoo.when(mock.someGetter).thenThrow("exception");
	Mockatoo.when(mock.someGetter).thenCall(function(){return "foo"});

## Usage Guide

* [Create a Mock](#create-a-mock)
* [Verifying Behaviour](#verifying-behaviour)
* [Basic Stubbing](#basic-stubbing)
* [Argument Matchers](#argument-matchers)
* [Verifying exact number of invocations / at least once / never](#verifying-exact-number-of-invocations)
* [Spying on real objects](#spying-on-real-objects)
* [Advanced Stubbing with consecutive calls or callbacks](#advanced-stubbing)
* [Mocking Properties that are Read or Write only](#mocking-properties-that-are-read-or-write-only)
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


You can also 'mock' a typedef structure, however the
generated object is not technically a mock, so does not support verification or stubbing.

	typedef SomeTypeDef = {name:String}
	...
	var mockedTypDef = Mockatoo.mock(SomeTypeDef);


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


### Spying on real objects

You can create spies of real objects. When you use the spy then the real methods
are called (unless a method was stubbed).

This is referred to as 'partial mocking'.

Real spies should be used carefully and occasionally, for example when dealing with legacy code.

	var mock = Mockatoo.spy(SomeClass);
	mock.someMethod();//calls real method

	Mockatoo.when(mock.someMethod()).thenReturn("one");
	mock.someMethod();//returns stub value;

	Mockatoo.verify(mock, times(2)).someMethod(); //both calls recorded


If you just want to stub a single method using the default mock values then

	Mockatoo.when(mock.someMethod()).thenMock();
	mock.someMethod();//returns default mock value (usually null)


There are several limitations to spying:

* The real constructor cannot be accessed directly, and will always be called with
the default values for each argument type - e.g:

			super(null,null,null);

* Interfaces cannot be spied (Mockatoo will ignore these and used normal mocking instead)


**Custom Callback Stub**

You can also set a custom callback when a method is invoked

	var f = function(args:Array<Dynamic>)
	{
		if(Std.is(args[0], String) return args[0].charAt(0) == "b";
	}

	Mockatoo.when(mock.foo("bar")).thenCall(f);


### Mocking Properties that are read or write only

A property that is read/write only, or calls out to getter/setter functions
can be stubbed to a specific return value:

	Mockatoo.when(mock.someReadOnlyProperty).thenReturn("foo");


If a property has a getter function, stubbing a return value will automatically
stub the underlying getter method - the equivalent of:

	Mockatoo.when(mock.get_someReadOnlyProperty()).thenReturn("foo"); 

Getters can also be stubbed to a custom callback:

	Mockatoo.when(mock.someGetter).thenCall(f); 

Both Getters and Setters can also be stubbed with an exception:

	Mockatoo.when(mock.someGetter).thenThrow("foo");
	Mockatoo.when(mock.someSetter).thenThrow("foo");

	var result = mock.someGetter;//throws exception
	mock.someSetter = "a";//throws exception


>Note: If a property has both a getter and setter, both getting and setting the
property with trigger the exception


There are some limitations to property stubbing:

* stubbed properties cannot be chained (thenReturn("foo", "bar", "etc"))
* only getters support stubbed callbacks (`thenCall(f)`)
* only getter and setters support stubbed exceptions (`thenThrow(xxx)`)


### Resetting a mock

You can reset a mock to remove any custom stubs and/or verifications

	Mockatoo.reset(mock);
	

## Known Limitations

### Mocking inlined methods

In Haxe 2.10 inlined methods cannot be mocked. Mockatoo will print a compiler warning and skip affected fields.

	inline public function someMethod()
	{
		..///
	}

In Haxe 2.11 (svn) this has been resolved (<http://code.google.com/p/haxe/issues/detail?id=1231>) and requires the `--no-inline` compiler flag

### Mocking @:final classes and methods

Mockatoo supports overriding @:final classes and methods in targets other than flash.

	@:final public function someMethod()
	{
		..///
	}

Mocking a @:final class in flash will throw a compiler error.

Mocking a @:final method in flash will generate a compiler warning and leave the
real method untouched.

See <http://code.google.com/p/haxe/issues/detail?id=1246> for more details.


### Mocking methods which reference private types


Some classes may expect arguments, or return values typed to a private Class, Enum or Typedef. For example, mocking `haxe.Http` will fail to compile on the neko target due to a reference to `private typedef AbstractSocket`

	Mockatoo.mock(haxe.Http);

This is due to an edge case with tink_macros that is fixed in tink_macros 1.2.1;

## Credits

Mockatoo is heavily inspired by **Mockito**'s public API <http://docs.mockito.googlecode.com/hg/latest/org/mockito/Mockito.html>

Mockatoo uses [tink_macros](https://github.com/back2dos/tinkerbell) for a lot of the low level macro manipulations.
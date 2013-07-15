
## Overview

Mockatoo is a Haxe library for mocks creation, verification and stubbing.

Uses Haxe macros to generated mock implementations of classes and interfaces for testing.


Mockatoo is inspired by **Mockito**'s public API <http://docs.mockito.googlecode.com/hg/latest/org/mockito/Mockito.html>


> Disambiguation: The **Mockatoo** belongs to the bird family *Cacatuidae* and look suspiciously like a taxidermied [Cockatoo](http://en.wikipedia.org/wiki/Cockatoo) with fake plumage. They are mostly found nesting within testing habitats and like  to repeat what you say (like a parrot). A Mockatoo may turn violent if mistaken for a *MockingBird* :)

### Installation

Mockatoo supports Haxe 3 across most platforms (AVM2, JavaScript, Neko, C++, etc)

Install current official release from haxelib (2.x)

	haxelib install mockatoo

Install the latest directly from github:

	haxelib git mockatoo https://github.com/misprintt/mockatoo.git src

Or point to your local fork:

	haxelib dev mockatoo /ABSOLUTE_PATH_TO_REPO/src

> For Legacy Haxe 2.10 refer to the haxe2 branch

## Features

Import and use the 'using' mixin

	import mockatoo.Mockatoo.*;
	using mockatoo.Mockatoo;

Mock any class or interface, including typedef aliases and types with generics (type paramaters)

	var mockedClass = mock(SomeClass);
	var mockedInterface = mock(SomeInterface);
	var mockedClassWithTypeParams = mock(Foo,[Bar]); //e.g. Foo<Bar>

Verify a method has been called with specific paramaters (cleaner syntax since 1.3.0)

	mock.someMethod().verify();
	mock.someMethod("foo", "bar").verify();

Define a stub response when a method is invoked

	mock.foo("bar").returns("hello");
	mock.someMethod("foo", "bar").throws(new Exception("error"));

Custom argument matchers and wildcards

	mock.foo(anyString).returns("hello");
	mock.foo(anyString).verify();

Verify exact number of invocations 

	mock.foo().verify(2);//raw integers supported since 1.3.0
	mock.foo().verify(times(2));
	mock.foo().verify(atLeast(2));
	mock.foo().verify(atLeastOnce);
	mock.foo().verify(never);

Spying on real objects

	var spy = spy(SomeClass);//creates instance where all methods are real (not stubbed)
	spy.foo(); // calls real method;
	
	spy.foo().stub();
	spy.foo(); //calls default stub;
	
	spy.foo().returns("hello");
	spy.foo(); //calls custom stub;


Partial Mocking

	var mock = mock(SomeClass);
	mock.foo().callsRealMethod();
	mock.foo();//calls out to real method


Mock properties that are read or write only

	mock.someProperty.returns("hello");
	mock.someSetter.throws("exception");
	mock.someGetter.throws("exception");
	mock.someGetter.calls(function(){return "foo"});


Click here for detailed [documentation and examples](http://github.com/misprintt/mockatoo/wiki/Developer-Guide)


## Release Notes

### New in 2.1.0

- Haxe 3 support
- Changes to use static imports (see below)
- Changes to referencing Matchers (see below)


#### Static imports

Due to a limitations in Haxe 3.0 with `using` + `macro` on class references, developers should use static importing avoid explicit references to `Mockatoo.mock` and `Mockatoo.spy`.


In Haxe 2

	using mockatoo.Mockatoo;
	...
	var mock = SomeClass.mock();
	var spy SomeClass.spy();

In Haxe 3 the recommended approach is:

	import mockatoo.Mockatoo.*;
	using mockatoo.Mockatoo;
	...

	var mock = mock(SomeClass);
	var spy = spy(SomeClass);



#### Matchers

The matcher helper methods in the Mockatoo class have been removed - (e.g. `anyString()`, `anyInt()`, `enumOf(SomeEnum)`) as they are no longer required when using static imports.


In Haxe 2:

	mock.someMethod(Mockatoo.anyString()).returns("foo");

With Haxe 3 refer to the Matcher enum value directly

	mock.someMethod(cast anyString).returns("foo");


>Note: As of Mockatoo 2.1, matchers need to be explicitly cast (as in the example above) to circumvent compiler type errors.


### New in 2.0.0

- Haxe 3 RC1 support

### New in 1.3.2

Fixed issues preventing mocking of interface properties (getter/setters)

### New in 1.3.0

Mockatoo 1.3.0 provides a simplified, smarter, macro enhanced API when using Haxe's 
'using' mixin (and is still fully backwards compatible with existing API).

	using mockatoo.Mockatoo;
	...
	var mock = mock(SomeClass);
	var mock = mock(SomeInterface);
	var spy = spy(SomeClass); // partial mock that calls real methods unless stubbed

New macros have been added for simplified stubbing with 'using':

	mock.someMethod().returns("foo");
	mock.someMethod("foo").throws("some error");
	mock.someMethod("bar").calls(function(args){return "bar";});
	mock.someMethod().callsRealMethod();
	mock.someMethod().stub(); // resets to default stub value (i.e. null)

You can allso stub properties and getter setters (since 1.2.0)

	mock.someProperty.returns("some value");

Verifications now also support raw integer counts

	mock.someMethod().verify(1); //converted to verify(times(1))

Verfifying and stubbing mock fields are now validated at compile time to prevent
runtime exceptions caused by out of date field references.

	mock.someMethodThatDoesNotExist().verify(); //causes compilation error

The syntax for wildcard Matchers has been updated to be compiler-safe when using 'using'

	mock.someMethod(Mockatoo.anyString()).returns("foo");

## Credits

Mockatoo is heavily inspired by **Mockito**'s public API <http://docs.mockito.googlecode.com/hg/latest/org/mockito/Mockito.html>

Mockatoo uses [tink_macro](https://github.com/back2dos/tinkerbell) for a lot of the low level macro manipulations.
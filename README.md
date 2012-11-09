## Overview

Mockatoo is a Haxe library for mocks creation, verification and stubbing.

Uses Haxe macros to generated mock implementations of classes and interfaces for testing.
Tested against Haxe 2.10 across most platforms (AVM2, JavaScript, Neko, C++, etc)

Mockatoo is inspired by **Mockito**'s public API <http://docs.mockito.googlecode.com/hg/latest/org/mockito/Mockito.html>


> Disambiguation: The **Mockatoo** belongs to the bird family *Cacatuidae* and look suspiciously like a taxidermied [Cockatoo](http://en.wikipedia.org/wiki/Cockatoo) with fake plumage. They are mostly found nesting within testing habitats and like  to repeat what you say (like a parrot). A Mockatoo may turn violent if mistaken for a *MockingBird* :)


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

Verify a method has been called with specific paramaters (cleaner syntax since 1.3.0)

	Mockatoo.verify(mock.foo());
	Mockatoo.verify(mock.someMethod("foo", "bar"));

Define a stub response when a method is invoked

	Mockatoo.when(mock.foo("bar")).thenReturn("hello");
	Mockatoo.when(mock.someMethod("foo", "bar").thenThrow(new Exception(""));

Custom argument matchers and wildcards

	Mockatoo.when(mock.foo(anyString)).thenReturn("hello");
	Mockatoo.when(mock.foo(isNull)).thenReturn("world");

Verify exact number of invocations 

	Mockatoo.verify(mock.foo(), 2);//raw integers supported since 1.3.0
	Mockatoo.verify(mock.foo(), times(2));
	Mockatoo.verify(mock.foo(), atLeast(2));
	Mockatoo.verify(mock.foo(), atLeastOnce);
	Mockatoo.verify(mock.foo(), never);

Spying on real objects (Since 1.1.0)

	var spy = Mockatoo.spy(SomeClass);//creates instance where all methods are real (not stubbed)
	spy.foo(); // calls real method;
	Mockatoo.when(spy.foo()).thenStub();
	spy.foo(); //calls default stub;
	Mockatoo.when(spy.foo()).thenReturn("hello");
	spy.foo(); //calls custom stub;


Partial Mocking (Since 1.2.0)

	 var mock = Mockatoo.mock(SomeClass);
	 Mockatoo.when(mock.foo()).thenCallRealMethod();
	 mock.foo();//calls out to real method


Mock properties that are read or write only (Since 1.2.0)

	Mockatoo.when(mock.someProperty).thenReturn("hello");
	Mockatoo.when(mock.someSetter).thenThrow("exception");
	Mockatoo.when(mock.someGetter).thenThrow("exception");
	Mockatoo.when(mock.someGetter).thenCall(function(){return "foo"});


Improved syntax when using 'using' (i.e. mixins) (Since 1.3.0)

	using mockatoo.Mockatoo;

	...

	var mock = SomeClass.mock();
	mock.doSomething("a").verify(2); //verify called 3 times



Click here for detailed [documentation and examples](http://github.com/misprintt/mockatoo/wiki/Developer-Guide)

## Credits

Mockatoo is heavily inspired by **Mockito**'s public API <http://docs.mockito.googlecode.com/hg/latest/org/mockito/Mockito.html>

Mockatoo uses [tink_macros](https://github.com/back2dos/tinkerbell) for a lot of the low level macro manipulations.
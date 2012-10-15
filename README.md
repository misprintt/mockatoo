## Mockatoo


Mockatoo is a Haxe mocking library that uses macros to generated mock
implementations of classes and interfaces for testing.



To build the haxelib, execute:

	haxelib run mtask build haxelib



## Overview

	import mockatoo.Mockatoo;

	...

	var mockList = Mockatoo.mock(List);




## References

Inspired by <http://docs.mockito.googlecode.com/hg/latest/org/mockito/Mockito.html>


### Basic Behavior

Mocking an interface

	//Let's import Mockito statically so that the code looks clearer
	import mockito.Mockito.*;

	//mock creation from interface
	var collection:Collection<String> = mock(Collection<String>);

	//using mock object
	collection.add("one");
	collection.clear();

	//verification
	verify(collection).add("one");
	verify(collection).clear();

### Stubbing
	
	//You can mock concrete classes, not only interfaces
	var mockedList = mock(ArrayList<String>);

	//stubbing
	when(mockedList.get(0)).thenReturn("first");
	when(mockedList.get(1)).thenThrow(new RuntimeException());

	//following prints "first"
	System.out.println(mockedList.get(0));

	//following throws runtime exception
	System.out.println(mockedList.get(1));

	//following prints "null" because get(999) was not stubbed
	System.out.println(mockedList.get(999));
	 
	//Although it is possible to verify a stubbed invocation, usually it's just redundant
	//If your code cares what get(0) returns then something else breaks (often before even verify() gets executed).
	//If your code doesn't care what get(0) returns then it should not be stubbed. Not convinced? See here.
	verify(mockedList).get(0);
package mockatoo;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mockatoo.exception.VerificationException;
import mockatoo.exception.StubbingException;
import mockatoo.Mockatoo;
import mockatoo.Mock;
import test.TestClasses;
import util.Asserts;

#if haxe3
import haxe.ds.StringMap;
#else
private typedef StringMap<T> = Hash<T>
#end

using mockatoo.Mockatoo;

typedef AnyArray = Array<Dynamic>;
typedef Field = 
{
	name:String,
	args:Array<Dynamic>
}
/**
* Auto generated MassiveUnit Test Class  for mockatoo.Mockatoo 
*/
class MockatooTest 
{
	public function new() 
	{
		
	}
	
	@BeforeClass
	public function beforeClass():Void
	{
	}
	
	@AfterClass
	public function afterClass():Void
	{
	}
	
	@Before
	public function setup():Void
	{
	}
	
	@After
	public function tearDown():Void
	{
	}

	// ------------------------------------------------------------------------- mocking


	@Test
	public function should_mock_class():Void
	{
		var fields:Array<Field> = [];
		addField(fields, "test");

		var mock = Mockatoo.mock(SimpleClass);
		assertMock(mock, SimpleClass, fields);
	}

	@Test
	public function should_mock_interface():Void
	{
		var fields:Array<Field> = [];
		addField(fields, "test");

		var mock = Mockatoo.mock(SimpleInterface);
		assertMock(mock, SimpleInterface, fields);
	}

	@Test
	public function should_mock_class_with_fields():Void
	{
		var fields:Array<Field> = [];
		var args:Array<Dynamic> = [];

		addField(fields, "toBool", args);
		addField(fields, "toInt", args);
		addField(fields, "toFloat", args);
		addField(fields, "toString", args);
		addField(fields, "toDynamic", args);
		addField(fields, "toVoid", args);

		addField(fields, "toBoolWithArgs", toArgs(true));

		addField(fields, "toIntWithArgs", toArgs(1));

		addField(fields, "toFloatWithArgs", toArgs(1.0));
		
		addField(fields, "toStringWithArgs", toArgs("string"));

		addField(fields, "toDynamicWithArgs", toArgs({name:"foo"}));

		addField(fields, "toVoidWithArgs", toArgs(1));

		addField(fields, "withMultipleArgs", toArgs(1,true));
		addField(fields, "withOptionalArgs", toArgs(1.0));

		var mock = Mockatoo.mock(ClassWithFields);
		assertMock(mock, ClassWithFields, fields);
	}

	@Test
	public function should_mock_interface_with_fields():Void
	{
		var fields:Array<Field> = [];

		addField(fields, "toBool", null);
		addField(fields, "toInt", null);
		addField(fields, "toFloat", null);
		addField(fields, "toString", null);
		addField(fields, "toDynamic", null);
		addField(fields, "toVoid", null);

		addField(fields, "toBoolWithArgs", [true]);
		addField(fields, "toIntWithArgs", [1]);
		addField(fields, "toFloatWithArgs", [1.0]);
		addField(fields, "toStringWithArgs", ["string"]);
		addField(fields, "toDynamicWithArgs", [{name:"foo"}]);
		addField(fields, "toVoidWithArgs", [1]);

		addField(fields, "withMultipleArgs", [1, true]);
		addField(fields, "withOptionalArgs", [1.0]);

		var mock = Mockatoo.mock(IntefaceWithFields);
		assertMock(mock, IntefaceWithFields, fields);
	}

	@Test
	public function should_mock_class_with_constructor_args():Void
	{
		var fields:Array<Field> = [];

		var mock = Mockatoo.mock(ClassWithConstructorAgs);
		assertMock(mock, ClassWithConstructorAgs, fields);
	}


	// ------------------------------------------------------------------------- spying

	@Test
	public function should_call_super_for_spy()
	{
		var mock = Mockatoo.spy(VariableArgumentsClass);

		var result = mock.one(10);

		Assert.areEqual(10, result);
		Mockatoo.verify(mock, times(1)).one(10);

		Mockatoo.when(mock.one(10)).thenReturn(2);
		result = mock.one(10);

		Assert.areEqual(2, result);
		Mockatoo.verify(mock, times(2)).one(10);

		Mockatoo.reset(mock);

		result = mock.one(10);

		Assert.areEqual(10, result);
		Mockatoo.verify(mock, times(1)).one(10);
	}

	@Test
	public function should_return_default_mock_value_for_spy_when_thenStub()
	{
		var mock = Mockatoo.spy(VariableArgumentsClass);

		var result = mock.one(10);

		Assert.areEqual(10, result);
		Mockatoo.verify(mock, times(1)).one(10);

		Mockatoo.when(mock.one(10)).thenStub();
		result = mock.one(10);

		#if (flash||cpp||java||cs)
		Assert.areEqual(0, result);
		#else
		Assert.areEqual(null, result);
		#end

		Mockatoo.verify(mock, times(2)).one(10);
	}

	// ------------------------------------------------------------------------- generics & typdefs

	@Test
	public function should_mock_typedef_interface():Void
	{
		var fields:Array<Field> = [];
		addField(fields, "test");

		var mock = Mockatoo.mock(TypedefToSimpleInterface);
		assertMock(mock, TypedefToSimpleInterface, fields);

		Assert.isTrue(Std.is(mock, SimpleInterface));
	}

	@Test
	public function should_mock_typedef_class():Void
	{
		var fields:Array<Field> = [];
		addField(fields, "test");

		var mock = Mockatoo.mock(TypedefToSimpleClass);
		assertMock(mock, TypedefToSimpleClass, fields);

		Assert.isTrue(Std.is(mock, SimpleClass));
	}

	@Test
	public function should_mock_typedef_typedInterface():Void
	{
		var fields:Array<Field> = [];
		addField(fields, "toTypeWithArg", [""]);

		var mock = Mockatoo.mock(TypedefToStringTypedInterface);
		assertMock(mock, TypedefToStringTypedInterface, fields);

		Assert.isTrue(Std.is(mock, TypedInterface));
	}

	@Test
	public function should_mock_typedef_typedClass():Void
	{
		var fields:Array<Field> = [];
		addField(fields, "toTypeWithArg", [""]);

		var mock = Mockatoo.mock(TypedefToStringTypedClass);
		assertMock(mock, TypedefToStringTypedClass, fields);

		Assert.isTrue(Std.is(mock, TypedClass));
	}

	@Test
	public function should_mock_typedef_typedInterfaceImplementation():Void
	{
		var fields:Array<Field> = [];
		addField(fields, "toTypeWithArg", [""]);

		var mock = Mockatoo.mock(TypedefToImplementsTypedInterface);
		assertMock(mock, TypedefToImplementsTypedInterface, fields);

		Assert.isTrue(Std.is(mock, TypedInterface));
	}

	@Test
	public function should_mock_typedef_typedClassExtension():Void
	{
		var fields:Array<Field> = [];
		addField(fields, "toTypeWithArg", [""]);

		var mock = Mockatoo.mock(TypedefToExtendsTypedClass);
		assertMock(mock, TypedefToExtendsTypedClass, fields);

		Assert.isTrue(Std.is(mock, TypedClass));
	}



	@Test
	public function should_mock_untyped_interface():Void
	{
		var fields:Array<Field> = [];
		addField(fields, "toTypeWithArg", [""]);

		var mock = Mockatoo.mock(TypedInterface, [String]);
		assertMock(mock, TypedInterface, fields);

	}

	// ------------------------------------------------------------------------- edge cases

	#if haxe3
	@Test
	public function should_mock_class_with_inlined_methods():Void
	{
		var fields:Array<Field> = [];

		addField(fields, "isInlined");

		var mock = Mockatoo.mock(ClassWithInlinedMethod);
		assertMock(mock, ClassWithInlinedMethod, fields);
	}
	#else
	@Test @Ignore("Can only override inline methods in Haxe3")
	public function should_mock_class_with_inlined_methods():Void
	{
	}
	#end

	#if flash
	@Ignore("Cannot override final methods in AS3")
	@Test
	public function should_mock_class_marked_final():Void
	{
		
	}

	#else

	@Test
	public function should_mock_class_marked_final():Void
	{
		var fields:Array<Field> = [];

		var mock = Mockatoo.mock(ClassThatIsFinal);
		assertMock(mock, ClassThatIsFinal, fields);
	}

	#end

	#if haxe3
	@Test
	public function should_mock_class_with_private_type_references():Void
	{
		var fields:Array<Field> = [];
		addField(fields, "test", [null]);

		var mock = Mockatoo.mock(ClassWithPrivateReference);
		assertMock(mock, ClassWithPrivateReference, fields);
	}
	#else
	@Test  @Ignore("Requires Haxe 3 and corresponding tink_macros")
	public function should_mock_class_with_private_type_references():Void
	{
		
	}
	#end

	#if haxe3
	@Test
	public function should_mock_http():Void
	{
		var fields:Array<Field> = [];
		addField(fields, "request", [false]);
		var mock = Mockatoo.mock(haxe.Http);

		assertMock(mock, haxe.Http, fields);
	}
	#else
	@Test  @Ignore("Requires Haxe 3 and corresponding tink_macros")
	public function should_mock_http():Void
	{
		
	}
	#end


	@Test
	public function should_mock_classes_with_nested_typeParams()
	{
		var mock = Mockatoo.mock(IntIterableClass);
		Assert.isNull(mock.iterator());
	}

	@Test
	public function should_mock_classes_incomplete_optional_arg()
	{
		var mock = Mockatoo.mock(ClassWithOptionalArg);
		mock.foo(true);

		Assert.isTrue(true);
	}

	@Test
	public function should_mock_class_with_typed_constraints()
	{
		var mock = Mockatoo.mock(ClassWithTypedConstraint, [TypedConstraintFoo]);
		mock.test();
		Assert.isTrue(true);
	}


	@Test
	public function should_mock_class_with_multiple_typed_constraints()
	{
		var mock = ClassWithMultipleTypedConstraints.mock([TypedConstraintFooBar]);
		mock.test();
		Assert.isTrue(true);
	}

		@Test
	public function should_mock_class_with_typed_constraints_using_typdef_ref()
	{
		var mock = AnyConcreteTypedParam.mock();
		Assert.isTrue(true);
	}


	// ------------------------------------------------------------------------- typedef structures
	
	@Test
	public function should_mock_typdef_structure():Void
	{
		var fields:Array<Field> = [];
		addField(fields, "func", []);
		var mock = Mockatoo.mock(TypedefStructure);

		assertTypedefMockField(mock, "type", null);
		assertTypedefMockField(mock, "title", null);
		assertTypedefMockField(mock, "optionalTitle", null);
		assertTypedefMockField(mock, "func", null, true);
		assertTypedefMockField(mock, "optionalFunc", null, true);
	}

	function assertTypedefMockField(mock:Dynamic, fieldName:String, value:Dynamic, ?isFunc:Bool=false)
	{
		Assert.isTrue(Reflect.hasField(mock, fieldName));

		var field = Reflect.field(mock, fieldName);

		Assert.areEqual(isFunc, Reflect.isFunction(field));

		if(isFunc)
		{
			Assert.areEqual(value, field());
		}
		else
		{
			Assert.areEqual(value, field);
		}
	}

	// ------------------------------------------------------------------------- reset

	@Test
	public function should_reset_verifications()
	{
		var instance = Mockatoo.mock(SimpleClass);

		instance.test();
		Mockatoo.reset(instance);

		Mockatoo.verify(instance, never).test();
	}

	@Test
	public function should_reset_stubs()
	{
		var instance = Mockatoo.mock(SimpleClass);

		Mockatoo.when(instance.test()).thenThrow("exception");
		Mockatoo.reset(instance);

		instance.test();
		Assert.isTrue(true);//otherwise an expception would have been thrown
	}


	// ------------------------------------------------------------------------- matchers

	
	@Test
	public function should_return_anyString_matcher()
	{
		Asserts.assertEnumTypeEq(Matcher.anyString, cast Mockatoo.anyString());
	}
	
	@Test
	public function should_return_anyInt_matcher()
	{
		Asserts.assertEnumTypeEq(Matcher.anyInt, cast Mockatoo.anyInt());
	}
	
	
	@Test
	public function should_return_anyFloat_matcher()
	{
		Asserts.assertEnumTypeEq(Matcher.anyFloat, cast Mockatoo.anyFloat());
	}
	
	@Test
	public function should_return_anyBool_matcher()
	{
		Asserts.assertEnumTypeEq(Matcher.anyBool, cast Mockatoo.anyBool());
	}
	
	@Test
	public function should_return_anyIterator_matcher()
	{
		Asserts.assertEnumTypeEq(Matcher.anyIterator, cast Mockatoo.anyIterator());
	}
	
	@Test
	public function should_return_anyObject_matcher()
	{
		Asserts.assertEnumTypeEq(Matcher.anyObject, cast Mockatoo.anyObject());
	}
	
	@Test
	public function should_return_anyEnum_matcher()
	{
		Asserts.assertEnumTypeEq(Matcher.anyEnum, cast Mockatoo.anyEnum());
	}
	
	@Test
	public function should_return_enumOf_matcher()
	{
		Asserts.assertEnumTypeEq(Matcher.enumOf(Type.ValueType), cast Mockatoo.enumOf(Type.ValueType));
	}
	
	@Test
	public function should_return_instanceOf_matcher()
	{
		Asserts.assertEnumTypeEq(Matcher.instanceOf(StringMap), cast Mockatoo.instanceOf(StringMap));
	}
	
	@Test
	public function should_return_isNotNull_matcher()
	{
		Asserts.assertEnumTypeEq(Matcher.isNotNull, cast Mockatoo.isNotNull());
	}
	
	@Test
	public function should_return_any_matcher()
	{
		Asserts.assertEnumTypeEq(Matcher.any, cast Mockatoo.any());
	}
	
	@Test
	public function should_return_customMatcher()
	{
		var f = function(value:Dynamic):Bool { return true; }
		Asserts.assertEnumTypeEq(Matcher.customMatcher(f), cast Mockatoo.customMatcher(f));
	}

	// ------------------------------------------------------------------------- stub properties


	@Test
	public function should_stub_property()
	{
		var instance = Mockatoo.mock(ClassWithProperties);

		Mockatoo.when(instance.property).thenReturn("foo");

		Assert.areEqual("foo", instance.property);
		
		//using `using`
		instance.property.returns("bar");
		Assert.areEqual("bar", instance.property);

	}

	@Test
	public function should_not_stub_property_with_throw()
	{
		var instance = Mockatoo.mock(ClassWithProperties);

		try
		{
			Mockatoo.when(instance.property).thenThrow("foo");
			Assert.fail("Expected StubbingException");
		}
		catch(e:StubbingException){}

		try
		{
			instance.property.throws("bar");
			Assert.fail("Expected StubbingException");
		}
		catch(e:StubbingException){}

	}


	@Test
	public function should_not_stub_property_with_callback()
	{
		var instance = Mockatoo.mock(ClassWithProperties);

		var f = function(args:Array<Dynamic>)
		{
			return "foo";
		};

		try
		{
			Mockatoo.when(instance.property).thenCall(f);
			Assert.fail("Expected StubbingException");
		}
		catch(e:StubbingException){}
		
	}

	@Test
	public function should_stub_readOnly_property()
	{
		var instance = Mockatoo.mock(ClassWithProperties);

		Mockatoo.when(instance.readOnly).thenReturn("foo");

		Assert.areEqual("foo", instance.readOnly);
	}

	@Test
	public function should_stub_setter_property()
	{
		var instance = Mockatoo.mock(ClassWithProperties);

		Mockatoo.when(instance.setter).thenReturn("foo");

		Assert.areEqual("foo", instance.setter);
	}

	@Test
	public function should_stub_getterSetter_property()
	{
		var instance = Mockatoo.mock(ClassWithProperties);

		Mockatoo.when(instance.getterSetter).thenReturn("foo");

		Assert.areEqual("foo", instance.getterSetter);
	}

	@Test
	public function should_stub_setter_property_with_throw()
	{
		var instance = Mockatoo.mock(ClassWithProperties);

		Mockatoo.when(instance.setter).thenThrow("foo");

		try
		{
			instance.setter = "a";
			Assert.fail("Expected exception");
		}
		catch(e:String){
			Assert.areEqual("foo", e);
		}
	}

	@Test
	public function should_not_stub_setter_property_with_callback()
	{
		var instance = Mockatoo.mock(ClassWithProperties);

		var f = function(args:Array<Dynamic>)
		{
			return "foo";
		};

		try
		{
			Mockatoo.when(instance.property).thenCall(f);
			Assert.fail("Expected StubbingException");
		}
		catch(e:StubbingException){}
	}


	@Test
	public function should_stub_getter_property_with_throw()
	{
		var instance = Mockatoo.mock(ClassWithProperties);

		Mockatoo.when(instance.getterSetter).thenThrow("foo");

		try
		{
			var result = instance.getterSetter;
			Assert.fail("Expected exception");
		}
		catch(e:String){
			Assert.areEqual("foo", e);
		}
	}

	@Test
	public function should_stub_getter_property_with_callback()
	{
		var instance = Mockatoo.mock(ClassWithProperties);

		var f = function(args:Array<Dynamic>)
		{
			return "foo";
		};

		Mockatoo.when(instance.getterSetter).thenCall(f);

		var result = instance.getterSetter;

		Assert.areEqual("foo", instance.getterSetter);

	}

	@Test
	public function should_stub_hidden_property()
	{
		var instance = Mockatoo.mock(ClassWithProperties);

		Mockatoo.when(instance.never).thenReturn("foo");

		Assert.areEqual("foo", untyped instance.never);
	}

	@Test
	public function should_stub_varFunction_property()
	{
		var instance = Mockatoo.mock(ClassWithProperties);

		var f = function()
		{
			return "foo";
		};

		Mockatoo.when(instance.func).thenReturn(f);

		Assert.areEqual("foo", instance.func());
	}

	///

	@Test
	public function should_stub_interface_with_getterSetter()
	{
		var instance = Mockatoo.mock(InterfaceWithProperties);
 
		Mockatoo.when(instance.getterSetter).thenReturn("foo");
 
		Assert.areEqual("foo", instance.getterSetter);
	}
 
	@Test
	public function should_stub_interface_with_getter()
	{
		var instance = Mockatoo.mock(InterfaceWithProperties);
 
		Mockatoo.when(instance.getter).thenReturn("foo");
 
		Assert.areEqual("foo", instance.getter);
	}
 
 
	@Test
	public function should_stub_interface_with_setter()
	{
		var instance = Mockatoo.mock(InterfaceWithProperties);
 
		Mockatoo.when(instance.setter).thenThrow("foo");
 
		try
		{
			instance.setter = "a";
			Assert.fail("Expected exception");
		}
		catch(e:String){
			Assert.areEqual("foo", e);
		}
	}
 
 
	@Test
	public function should_stub_interface_with_typed_setter()
	{
		var instance = Mockatoo.mock(InterfaceWithTypedProperties);
 
		Mockatoo.when(instance.getter).thenReturn("foo");
		Mockatoo.when(instance.setter).thenThrow("bar");
 
		Assert.areEqual("foo", instance.getter);
 
		try
		{
			instance.setter = "a";
			Assert.fail("Expected exception");
		}
		catch(e:String){
			Assert.areEqual("bar", e);
		}
	}

	// ------------------------------------------------------------------------- utilities

	function assertMock(mock:Mock, cls:Class<Dynamic>, ?fields:Array<Field>, ?pos:haxe.PosInfos)
	{
		if(fields == null) fields = [];

		Assert.isTrue(Std.is(mock, cls), pos);
		Assert.isTrue(Std.is(mock, Mock), pos);

		var className = Type.getClassName(cls);


		for(field in fields)
		{
			try
			{
				Reflect.callMethod(mock, Reflect.field(mock, field.name), field.args);
			}
			catch(e:String)
			{
				if(e == "not mocked")
				{
					Assert.fail(className + "." + field.name + " is not mocked.", pos);
				}
			}
		}
	}

	function addField(fields:Array<Field>, name:String, ?args:Array<Dynamic>)
	{
		if(args == null)
			args = [];

		fields.push({name:name, args:args});
	}

	/**
	utility function for haxe3 to create dynamic arrays of arguments for a function
	*/
	function toArgs(?arg1:Dynamic, ?arg2:Dynamic, ?arg3:Dynamic):Array<Dynamic>
	{
		var args:Array<Dynamic> = new Array<Dynamic>();
		if(arg1 != null) args.push(arg1);
		if(arg2 != null) args.push(arg2);
		if(arg3 != null) args.push(arg3);
		return args;
	}

}

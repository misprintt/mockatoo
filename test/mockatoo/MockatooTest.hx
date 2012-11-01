package mockatoo;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mockatoo.exception.StubbingException;
import mockatoo.Mockatoo;
import mockatoo.Mock;
import test.TestClasses;
import util.Asserts;

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

	// ------------------------------------------------------------------------- verification

	@Test
	public function should_throw_exception_if_verify_non_mock()
	{
		try
		{
			Mockatoo.verify(null);	
			Assert.fail("Expected exception for non mock class");
		}
		catch(e:Dynamic)
		{
			Assert.isTrue(true);
		}
		
	}

	@Test
	public function should_set_default_mode()
	{
		var instance = Mockatoo.mock(SimpleClass);

		var verification = Mockatoo.verify(instance);

		Asserts.assertEnumTypeEq(times(1), verification.mode);
		
	}


	@Test
	public function should_use_custom_mode()
	{
		var instance = Mockatoo.mock(SimpleClass);

		var verification = Mockatoo.verify(instance, never);

		Asserts.assertEnumTypeEq(never, verification.mode);
		
	}

	// ------------------------------------------------------------------------- stubbing

	@Test
	public function should_when()
	{
		var instance = Mockatoo.mock(VariableArgumentsClass);

		var f = function(args:Array<Dynamic>)
		{
			return args[0];
		}
		var stub = Mockatoo.when(instance.one(1)).thenReturn(10).thenCall(f).thenThrow("exception");

		var result = instance.one(1);
		Assert.areEqual(10, result);

		result = instance.one(1);
		Assert.areEqual(1, result);

		try
		{
			instance.one(1);
			Assert.fail("Expected custom exception");
		}
		catch(e:String)
		{
			Assert.areEqual("exception", e);
		}
	}


	@Test
	public function should_cast_to_mock_when()
	{
		var instance:VariableArgumentsClass = Mockatoo.mock(VariableArgumentsClass);

		var stub = Mockatoo.when(instance.one(1));

		Assert.isNotNull(stub);
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

		addField(fields, "toBool");
		addField(fields, "toInt");
		addField(fields, "toFloat");
		addField(fields, "toString");
		addField(fields, "toDynamic");
		addField(fields, "toVoid");

		addField(fields, "toBoolWithArgs", [true]);
		addField(fields, "toIntWithArgs", [1]);
		addField(fields, "toFloatWithArgs", [1.0]);
		addField(fields, "toStringWithArgs", ["string"]);
		addField(fields, "toDynamicWithArgs", [{name:"foo"}]);
		addField(fields, "toVoidWithArgs", [1]);

		addField(fields, "withMultipleArgs", [1, true]);
		addField(fields, "withOptionalArgs", [1.0]);

		var mock = Mockatoo.mock(ClassWithFields);
		assertMock(mock, ClassWithFields, fields);
	}

	@Test
	public function should_mock_interface_with_fields():Void
	{
		var fields:Array<Field> = [];

		addField(fields, "toBool");
		addField(fields, "toInt");
		addField(fields, "toFloat");
		addField(fields, "toString");
		addField(fields, "toDynamic");
		addField(fields, "toVoid");

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
	public function should_return_default_mock_value_for_spy_when_thenMock()
	{
		var mock = Mockatoo.spy(VariableArgumentsClass);

		var result = mock.one(10);

		Assert.areEqual(10, result);
		Mockatoo.verify(mock, times(1)).one(10);

		Mockatoo.when(mock.one(10)).thenMock();
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

	@Test #if !haxe_211 @Ignore("Cannot override inline methods") #end
	public function should_mock_class_with_inlined_methods():Void
	{
		var fields:Array<Field> = [];

		addField(fields, "isInlined");

		var mock = Mockatoo.mock(ClassWithInlinedMethod);
		assertMock(mock, ClassWithInlinedMethod, fields);
	}

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

	#if haxe_211
	@Test
	public function should_mock_class_with_private_type_references():Void
	{
		var fields:Array<Field> = [];
		addField(fields, "test", [null]);

		var mock = Mockatoo.mock(ClassWithPrivateReference);
		assertMock(mock, ClassWithPrivateReference, fields);
	}
	#else
	@Test  @Ignore("Requires tink_macros fork https://github.com/back2dos/tinkerbell/pull/37")
	public function should_mock_class_with_private_type_references():Void
	{
		
	}
	#end

	#if haxe_211
	@Test
	public function should_mock_http():Void
	{
		var fields:Array<Field> = [];
		addField(fields, "request", [false]);
		var mock = Mockatoo.mock(haxe.Http);

		assertMock(mock, haxe.Http, fields);
	}
	#else
	@Test
	@Ignore("Requires tink_macros fork https://github.com/back2dos/tinkerbell/pull/37")
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



	// ------------------------------------------------------------------------- stub properties


	@Test
	public function should_stub_property()
	{
		var instance = Mockatoo.mock(ClassWithProperties);

		Mockatoo.when(instance.property).thenReturn("foo");

		Assert.areEqual("foo", instance.property);
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
		if(args == null) args = [];
		fields.push({name:name, args:args});
	}
}

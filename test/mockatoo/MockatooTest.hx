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
import haxe.ds.StringMap;

import mockatoo.Mockatoo.*;
using mockatoo.Mockatoo;


typedef AnyArray = Array<Dynamic>;
typedef Field = 
{
	name:String,
	args:Array<Dynamic>
}

class MockatooTest 
{
	public function new() 
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
		addField(fields, "toMap", args);
		addField(fields, "toVoid", args);

		addField(fields, "toBoolWithArgs", toArgs(true));

		addField(fields, "toIntWithArgs", toArgs(1));

		addField(fields, "toFloatWithArgs", toArgs(1.0));
		
		addField(fields, "toStringWithArgs", toArgs("string"));

		addField(fields, "toDynamicWithArgs", toArgs({name:"foo"}));
		addField(fields, "toMapWithArgs", toArgs(new Map<String,Bool>()));

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
		Mockatoo.verify(mock, times(1)).one(10);

		mock.one(10);
		mock.one(10);

		Mockatoo.verify(mock, times(2)).one(10);		

		mock.one(10);
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

		Mockatoo.verify(mock, times(1)).one(10);
	}

	// ------------------------------------------------------------------------- generics & typedefs

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
	@Test
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
	
	@Test
	public function should_mock_class_with_private_type_references():Void
	{
		var fields:Array<Field> = [];
		addField(fields, "test", [null]);

		var mock = Mockatoo.mock(ClassWithPrivateReference);
		assertMock(mock, ClassWithPrivateReference, fields);
	}

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
		var mock = Mockatoo.mock(ClassWithMultipleTypedConstraints,[TypedConstraintFooBar]);
		mock.test();
		Assert.isTrue(true);
	}

	@Test
	public function should_mock_class_with_typed_constraints_using_typedef_ref()
	{
		var mock = Mockatoo.mock(AnyConcreteTypedParam);
		Assert.isTrue(true);
	}

	// ------------------------------------------------------------------------- typedef structures
	
	@Test
	public function should_mock_typedef_structure():Void
	{
		var fields:Array<Field> = [];
		addField(fields, "func", []);
		var mock = Mockatoo.mock(TypedefStructure);

		assertTypedefMockField(mock, "type", null);
		assertTypedefMockField(mock, "title", null);
		assertTypedefMockField(mock, "optionalTitle", null, false, true);
		assertTypedefMockField(mock, "func", null, true);
		assertTypedefMockField(mock, "optionalFunc", null, true, true);
	}

	macro static function isStaticPlatform()
	{
		var value = mockatoo.macro.Tools.isStaticPlatform();

		return macro $v{value};
	}
	function assertTypedefMockField(mock:Dynamic, fieldName:String, value:Dynamic, ?isFunc:Bool=false, ?isOptional:Bool=false, ?pos:haxe.PosInfos)
	{
		Assert.isTrue(Reflect.hasField(mock, fieldName), pos);

		var field = Reflect.field(mock, fieldName);

		#if (haxe_ver >= 3.1)

		if(isStaticPlatform())
			isFunc = isFunc && !isOptional;

		#end
		
		Assert.areEqual(isFunc, Reflect.isFunction(field), pos);
		
		if (isFunc)
		{
			Assert.areEqual(value, field(), pos);
		}
		else
		{
			Assert.areEqual(value, field, pos);
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

	#if cpp @Ignore("Cannot stub 'never' field in cpp")#end
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

	/**
		Issue #17 - Compiler error when mocking interface with write-only properties (#17)
	*/
	@Test
	public function should_mock_interface_with_with_property_type_void_void():Void
	{
		var instance = Mockatoo.mock(Issue17Interface);

		var count = 0;
		var func = function()
		{
			count ++;
		}

		Mockatoo.when(instance.setter).thenReturn(func);
		Mockatoo.when(instance.getter).thenReturn(func);
		Mockatoo.when(instance.getterSetter).thenReturn(func);
		Mockatoo.when(instance.nulledGetterSetter).thenReturn(func);

		instance.getterSetter();
		Assert.areEqual(1, count);

		instance.getter();
		Assert.areEqual(2, count);

		instance.setter = func;

		instance.nulledGetterSetter();
		Assert.areEqual(3, count);
	}

	@Test
	public function should_mock_class_with_with_property_type_void_void():Void
	{
		var instance = Mockatoo.mock(Issue17Class);

		var count = 0;
		var func = function()
		{
			count ++;
		}

		Mockatoo.when(instance.setter).thenReturn(func);
		Mockatoo.when(instance.getter).thenReturn(func);
		Mockatoo.when(instance.getterSetter).thenReturn(func);
		Mockatoo.when(instance.nulledGetterSetter).thenReturn(func);

		instance.getterSetter();
		Assert.areEqual(1, count);

		instance.getter();
		Assert.areEqual(2, count);

		instance.setter = func;

		instance.nulledGetterSetter();
		Assert.areEqual(3, count);
	}

	@Test
	public function should_mock_Issue18()
	{
		var mock = Mockatoo.mock(Issue18);
		var o = {};
		mock.myVal = o;
		Mockatoo.verify(mock.set_myVal(o));

	}

	@Test
	public function should_mock_Issue23()
	{
		var real = new TypedMethod();
		real.test(1);
		Assert.isTrue(true);
		
		var mock = Mockatoo.mock(TypedMethod);
		mock.test(1);
		Mockatoo.verify(mock.test(1));
	}

	@Test
	public function should_support_untyped_method_args_and_returns()
	{
		var mock = Mockatoo.mock(ClassWithoutTypedArgs);

		mock.untypedArg("");
		mock.untypedReturn();

		Mockatoo.verify(mock.untypedArg(""));
		Mockatoo.verify(mock.untypedReturn());
	}

	@Test
	public function should_mock_static_method()
	{
		var mock = Mockatoo.mock(ClassWithStaticMethodReference);
		mock.callsStaticMethod();
		Mockatoo.verify(mock.callsStaticMethod());
	}

	// @Test
	// @Ignore("Triggers compilation error")
	// public function should_mock_abstract()
	// {
	// 	var mock = Mockatoo.mock(AbstractInt);
	// }

	@Test
	public function should_mock_class_with_abstract_property()
	{
		var instance = Mockatoo.mock(ClassWithAbstractProperties);
	
		Mockatoo.when(instance.test()).thenReturn(10);

		Assert.areEqual(10, instance.test());

		Mockatoo.when(instance.setter).thenReturn(1);

		Assert.areEqual(1, instance.setter);
	}

	// ------------------------------------------------------------------------- utilities

	function assertMock(mock:Mock, cls:Class<Dynamic>, ?fields:Array<Field>, ?pos:haxe.PosInfos)
	{
		if (fields == null) fields = [];

		Assert.isTrue(Std.is(mock, cls), pos);
		Assert.isTrue(Std.is(mock, Mock), pos);

		var className = Type.getClassName(cls);

		for (field in fields)
		{
			try
			{
				Reflect.callMethod(mock, Reflect.field(mock, field.name), field.args);
			}
			catch(e:String)
			{
				if (e == "not mocked")
				{
					Assert.fail(className + "." + field.name + " is not mocked.", pos);
				}
			}
		}
	}

	function addField(fields:Array<Field>, name:String, ?args:Array<Dynamic>)
	{
		if (args == null)
			args = [];

		fields.push({name:name, args:args});
	}

	/**
		utility function for haxe3 to create dynamic arrays of arguments for a function
	*/
	function toArgs(?arg1:Dynamic, ?arg2:Dynamic, ?arg3:Dynamic):Array<Dynamic>
	{
		var args:Array<Dynamic> = new Array<Dynamic>();
		if (arg1 != null) args.push(arg1);
		if (arg2 != null) args.push(arg2);
		if (arg3 != null) args.push(arg3);
		return args;
	}

}

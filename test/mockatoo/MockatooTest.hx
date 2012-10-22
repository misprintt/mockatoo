package mockatoo;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
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
	public function should_set_default_filter()
	{
		var instance = Mockatoo.mock(SimpleClass);

		var verification = Mockatoo.verify(instance);

		Asserts.assertEnumTypeEq(times(1), verification.filter);
		
	}

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

	@Test @Ignore("Cannot override inline methods")
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

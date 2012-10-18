package mockatoo;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mockatoo.Mockatoo;
import mockatoo.Mock;
import test.TestClasses;


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
	public function should_mock_class():Void
	{
		var mock = Mockatoo.mock(SimpleClass);
		assertMock(mock, SimpleClass);
	}

	@Test
	public function should_mock_interface():Void
	{
		var mock = Mockatoo.mock(SimpleInterface);
		assertMock(mock, SimpleInterface);
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

	function assertMock(mock:Mock, cls:Class<Dynamic>, ?fields:Array<Field>)
	{
		if(fields == null) fields = [];

		Assert.isTrue(Std.is(mock, cls));
		Assert.isTrue(Std.is(mock, Mock));

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
					Assert.fail(className + "." + field.name + " is not mocked.");
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

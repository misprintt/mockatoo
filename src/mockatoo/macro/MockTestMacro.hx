package mockatoo.macro;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Printer;
import mockatoo.Mock;

using StringTools;
using haxe.macro.Tools;
using mockatoo.macro.Tools;

/**
	Macro build to generate mock instance inside a test class
*/
class MockTestMacro
{
	static var befores:Array<Expr>;
	static var afters:Array<Expr>;

	static public function build()
	{
		befores = [];
		afters = [];

		var fields = Context.getBuildFields();

		for(field in fields)
		{
			if(field.meta == null || field.meta.length == 0) continue;

			switch(field.kind)
			{
				case FVar(t,e):
					for(meta in field.meta)
					{
						if(meta.name == ":mock")
							addMock(field, t, e);
						else if(meta.name == ":spy")
							addMock(field, t, e, true);
					}
					
				case _:
			}
		}

		if(befores.length > 0 || afters.length > 0)
		{
			if(Context.defined("munit"))
			{
				fields.push(addField("setupMockatoo", "Before", befores));
				fields.push(addField("teardownMockatoo", "After", afters));
			}
			else
				Context.warning("Unable to generate mocks: @:mock and @:spy require munit", Context.currentPos());
			
			return fields;	
		}
		
		return null;
	}

	/**
	Generates a function containing an array of `exprs`
	**/
	static function addField(name:String, meta:String, exprs:Array<Expr>)
	{

		var f:Function = 
		{
			args:[],
			ret: null,
			expr: macro $b{exprs},
			params:[]
		}

		var field:Field = 
		{
			name:name,
			meta:[{name:meta, params:[], pos:Context.currentPos()}],
			kind: FieldType.FFun(f),
			doc: null,
			access: [Access.APublic],
			pos:Context.currentPos()
		}

		return field;
	}

	/**
	Appends exprs for setting up / tearing down each mock or spy
	**/
	static function addMock(field:Field, t:ComplexType, ?e:Expr, ?isSpy:Bool=false)
	{
		var type = t.toString();
		var before:Expr = null;
		var after:Expr = null;

		if(isSpy)
		{
			before = macro $i{field.name} = Mockatoo.spy($i{type});
			after = macro $i{field.name} = null;
		}
		else
		{
			before = macro $i{field.name} = Mockatoo.mock($i{type});
			after = macro $i{field.name} = null;
		}

		befores.push(before);		
		afters.push(after);		
	}
	
}
#end


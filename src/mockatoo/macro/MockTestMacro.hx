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
	static var META_BEFORE = "Before";
	static var META_AFTER = "After";
	static var META_MOCK = ":mock";
	static var META_SPY = ":spy";
	static var FIELD_SETUP = "setup";
	static var FIELD_TEARDOWN = "tearDown";

	static var befores:Array<Expr>;
	static var afters:Array<Expr>;

	static var beforeField:Field;
	static var afterField:Field;

	static public function build()
	{
		befores = [];
		afters = [];
		beforeField = null;
		afterField = null;

		var fields = Context.getBuildFields();

		for (field in fields)
		{
			if (field.meta == null || field.meta.length == 0) continue;

			switch (field.kind)
			{
				case FVar(t,e):
					for (meta in field.meta)
					{
						if (meta.name == META_MOCK)
							addMock(field, t, e);
						else if (meta.name == META_SPY)
							addMock(field, t, e, true);
					}
				case FFun(f):
					//check for existing before/after functions
					for (meta in field.meta)
					{
						if (meta.name == META_BEFORE)
							beforeField = field;
						else if (meta.name == META_AFTER)
							afterField = field;
					}
				case _:
			}
		}

		if (befores.length == 0 || afters.length == 0) return null;

		if (!Context.defined("munit"))
			Context.warning("Unable to generate mocks - @:mock and @:spy require munit", Context.currentPos());

		if (beforeField == null)
		{
			beforeField = createField(FIELD_SETUP, META_BEFORE, befores);
			fields.push(beforeField);
		}
		else
			updateField(beforeField, befores);
		
		if (afterField == null)
		{
			afterField = createField(FIELD_TEARDOWN, META_AFTER, afters);
			fields.push(afterField);
		}
		else
			updateField(afterField, afters);
		
		return fields;	
	}


	/**
	Prepends generated expressions to the start of an existing function 
	**/
	static function updateField(field:Field, exprs:Array<Expr>)
	{
		var localExprs:Array<Expr> = [];
		var existingExpr:Expr = null;

		switch (field.kind)
		{
			case FFun(f):
				existingExpr = f.expr;
				switch (existingExpr.expr)
				{
					case EBlock(e):
						localExprs = exprs.concat(e);
						f.expr = EBlock(localExprs).at();
					case _:

						localExprs = exprs.concat([existingExpr]);
						f.expr = EBlock(localExprs).at();
				}
			case _:
		}
	}

	/**
	Generates a function containing an array of `exprs`
	**/
	static function createField(name:String, meta:String, exprs:Array<Expr>)
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

		if (isSpy)
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

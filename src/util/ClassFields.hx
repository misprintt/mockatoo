package util;

#if macro

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Type;
import haxe.PosInfos;
using tink.macro.tools.MacroTools;

class ClassFields
{
	static inline var PRETTY = true;

	public static function getClassFields(c:ClassType):Array<Field>
	{
		if(c.superClass != null)
				throw "not implemented";

		var fields:Array<Field> = [];

		for(classField in c.fields.get())
		{
			var field = getClassField(classField);
			
			fields.push(field);
		}

		if(c.constructor != null)
		{
			var field = getConstructorField(c);
			fields.unshift(field);
		}

		return fields;
	}


	public static function getClassField(field:ClassField):Field
	{
		var kind = getFieldType(field);

		var meta = field.meta.get();

		if(kind == null)
			throw "FieldType is null. Cannot create field [" + field + "]";

		return {
			name:field.name,
			pos:field.pos,
			kind:kind,
			access: field.isPublic ? [APublic] : [APrivate],
			meta:meta
		}
	}

	static function getConstructorField(c:ClassType):Field
	{
		var classField = c.constructor.get();

		classField.name = "new";

		var field = getClassField(classField);

		return field;
	}

	public static function getFieldType(field:ClassField):FieldType
	{
		var expr = getFieldExpr(field);

		switch(field.kind)
		{
			case FVar(read, write):
			{
				return FProp(getVarAccess(read), getVarAccess(write), field.type.toComplex(PRETTY), expr);
			}
			case FMethod(k):
			{
				switch(k)
				{
					case MethMacro: null;
					default: 
						switch(Context.follow(field.type))
						{
							case TFun(args, ret):

								return FFun(
								{
									args:convertTFunArgsToFunctionArgs(args),
									ret: ret.toComplex(PRETTY),
									expr:expr,
									params:[]
								});

							default: throw "not implemented for type [" + field.type + "]";
						}
				}
			}
		}

		return null;
	}

	static function convertTFunArgsToFunctionArgs(args : Array<{ t : Type, opt : Bool, name : String }>):Array<FunctionArg>
	{
		var converted:Array<FunctionArg> = [];

		for(arg in args)
		{
			var value = 
			{
				value : null, //Null<Expr>
				type : arg.t.toComplex(PRETTY), //<ComplexType>
				opt : arg.opt,
				name : arg.name
			}

			converted.push(value);
		}

		return converted;
	}

	static function getVarAccess(access:VarAccess):String
	{
		return switch (access)
		{
			case AccNormal, AccInline: "default";
			case AccNo: "null";
			case AccNever: "never";
			case AccCall(m): m;
			case AccResolve: throw "not implemented for VarAccess [" + access + "]";
			case AccRequire(r): throw "not implemented VarAccess [" + access + "]";
			
		}		
	}

	/**
	Converts a ClassField's TypedExpr to an Expr
	*/
	public static function getFieldExpr(classField:ClassField):Expr
	{
		var typedExpr = classField.expr();

		if(typedExpr == null) return null;

		var expr = Context.getTypedExpr(typedExpr);

		switch(classField.kind)
		{
			case FMethod(k):
			{
				switch(expr.expr)
				{
					case EFunction(name, f):
						return f.expr;
					default: throw "not implemented for ExprDef [" + expr.expr + "]";//return null;
				}
			}
			case FVar(read, write):
			{
				return expr;
			}
		}
	}
}

#end
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

	/**
	Recursively aggregates fields from class and super classes, ensuring that
	inherited/overriden fields take precidence.
	*/
	public static function getClassFields(c:ClassType, ?includeStatics:Bool=false, ?fieldHash:Hash<Field>):Array<Field>
	{
		if(fieldHash == null) fieldHash = new Hash();

		if(c.superClass != null)
		{
			var superFields = getClassFields(c.superClass.t.get(), includeStatics, fieldHash);

			for(field in superFields)
			{
				fieldHash.set(field.name, field);
			}
		}
		
		for(classField in c.fields.get())
		{
			var field = getClassField(classField);
			fieldHash.set(field.name, field);
		}

		if(includeStatics)
		{
			for(classField in c.statics.get())
			{
				var field = getClassField(classField, true);
				fieldHash.set(field.name, field);
			}
		}

		if(c.constructor != null)
		{
			var field = getConstructorField(c);
			fieldHash.set(field.name, field);
		}

		return Lambda.array(fieldHash);
	}


	public static function getClassField(field:ClassField, ?isStatic:Bool=false):Field
	{
		var kind = getFieldType(field);

		var meta = field.meta.get();

		if(kind == null)
			throw "FieldType is null. Cannot create field [" + field + "]";

		var access:Array<Access> = field.isPublic ? [APublic] : [APrivate];

		if(isStatic) access.push(AStatic);

		return {
			name:field.name,
			pos:field.pos,
			kind:kind,
			access: access,
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
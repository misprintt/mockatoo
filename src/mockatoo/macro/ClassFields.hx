package mockatoo.macro;

#if macro

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Type;
import haxe.PosInfos;
import haxe.macro.Printer;
import haxe.macro.TypeTools;
import haxe.ds.StringMap;

using haxe.macro.Tools;
using mockatoo.macro.Tools;

typedef TypeDeclaration = 
{
	name:String,
	type:Type
}

#if (haxe_ver < 3.1)
typedef TypeParameter = 
{
	name : String,
	t : Type
}
#end
/**
	Macro for recursively converting ClassFields to Field types
*/
class ClassFields
{
	@:extern static inline var PRETTY = true;

	/**
		Recursively aggregates fields from class and super classes, ensuring that
		inherited/overriden fields take precidence.
	*/
	public static function getClassFields(c:ClassType, ?includeStatics:Bool=false, ?paramTypes:Array<Type>, ?fieldMap:StringMap<Field>):Array<Field>
	{
		if (paramTypes == null) paramTypes = [];
		if (fieldMap == null) fieldMap = new StringMap();

		Console.log(c.name + ":" + paramTypes);

		var paramMap = getClassTypeDeclarationMap(c, paramTypes);
		
		// recurse through super classes (or interfaces if an interface)
		var superTypes:Array<{ t : Ref<ClassType>, params : Array<Type> }> = [];

		if (c.superClass != null)
			superTypes.push(c.superClass);
		else if (c.isInterface)
			superTypes = superTypes.concat(c.interfaces);

		for (type in superTypes)
		{
			var superParams = mapTypes( type.params, paramMap);

			Console.log("     superParams: " + superParams);
			var superFields = getClassFields(type.t.get(), includeStatics, superParams, fieldMap);

			for (field in superFields)
			{
				fieldMap.set(field.name, field);
			}
		}
		
		for (classField in c.fields.get())
		{
			try
			{
				var field = getClassField(classField, paramMap);
				fieldMap.set(field.name, field);
			}
			catch(e:Dynamic)
			{
				//probaby a macro function
			}
			
		}

		if (includeStatics)
		{
			for (classField in c.statics.get())
			{
				try
				{
					var field = getClassField(classField, paramMap, true);
					fieldMap.set(field.name, field);
				}
				catch(e:Dynamic)
				{
					//probaby amacro function
				}
			}
		}

		if (c.constructor != null)
		{
			var field = getConstructorField(c,paramMap);
			fieldMap.set(field.name, field);
		}

		return Lambda.array(fieldMap);
	}

	/**
		Replaces abstract types (T, TData, etc) with concrete ones
	*/
	static function getClassTypeDeclarationMap(classType:ClassType, paramDecls:Array<Type>):Array<TypeDeclaration>
	{
		var results:Array<TypeDeclaration> = [];

		for (i in 0...classType.params.length)
		{
			var param = classType.params[i];

			var decl =
			{
				name:param.name,
				type:paramDecls[i]
			}
			results.push(decl);
		}
		return results;
	}

	/**
		Replaces abstract types <T> with concrete Types
	*/
	static function mapTypes(types:Array<Type>, map:Array<TypeDeclaration>):Array<Type>
	{
		var results:Array<Type> = [];

		for (type in types)
		{
			type = mapType(type, map);
			results.push(type);
		}

		return results;
	}

	/**
		Recursively Replaces references to an abstract type <T> with a concrete Types
		defined in a map (recursively updates param types as well)
		(e.g. T, Array<T>, Interator<Null<T>>)
	*/
	static public function mapType(type:Type, map:Array<TypeDeclaration>):Type
	{
		var id = type.getId();

		if (id != null)
		{
			id = id.split(".").pop();
			for (m in map)
			{
				if (m.name == id && m.type != null)
					return m.type;
			}
		}

		switch (type)
		{
			case TInst(t, params):
				return TInst(t, mapTypes(params,map));
			case TEnum(t, params):
				return TEnum(t, mapTypes(params,map));
			case TType(t, params):
				return TType(t, mapTypes(params,map));
			default:
				return type;	
		}
	}

	public static function getClassField(field:ClassField, paramMap:Array<TypeDeclaration>, ?isStatic:Bool=false):Field
	{
		var kind = getFieldType(field,paramMap);

		var access = getFieldAccess(field);

		if (isStatic) access.push(AStatic);

		var meta = field.meta.get();

		if (kind == null)
			throw "FieldType is null. Cannot create field [" + field + "]";

		return {
			name:field.name,
			pos:field.pos,
			kind:kind,
			access: access,
			meta:meta
		}
	}

	static function getFieldAccess(field:ClassField)
	{
		var access:Array<Access> = field.isPublic ? [APublic] : [APrivate];

		switch (field.kind)
		{
			case FMethod(k):
				switch (k)
				{
					case MethInline: access.push(AInline);
					case MethDynamic: access.push(ADynamic);
					default: null;
				}
			default: null;
		}
		return access;
	}

	static function getConstructorField(c:ClassType, paramMap:Array<TypeDeclaration>):Field
	{
		var classField = c.constructor.get();

		classField.name = "new";

		var field = getClassField(classField,paramMap);

		return field;
	}

	/**
		Converts a Type to ComplexType and subsitutes Param types (e.g. <T>) with concrete ones
	*/
	static function convertType(type:Type, paramMap:Array<TypeDeclaration>):ComplexType
	{
		var type:Type = mapType(type, paramMap);
		switch (type)
		{
			case TDynamic(t):
				if (t == null)
					return TPath({pack:[], name:"StdTypes", sub:"Dynamic", params:[]});

				var param = TPType(t.toComplexType());
				
				return TPath({pack:[], name:"StdTypes", sub:"Dynamic", params:[param]});
			default:
				return haxe.macro.TypeTools.toComplexType(type);
		}
	}

	public static function getFieldType(field:ClassField, paramMap:Array<TypeDeclaration>):FieldType
	{
		var expr = getFieldExpr(field);

		switch (field.kind)
		{
			case FVar(read, write):
			{
				var readAccess = getVarAccess(read);
				var writeAccess = getVarAccess(write);

				if (readAccess == "property") readAccess = "get_" + field.name;
				if (writeAccess == "property") writeAccess = "set_" + field.name;

				return FProp(readAccess, writeAccess, convertType(field.type, paramMap), expr);
			}
			case FMethod(methodKind):
			{
				switch (methodKind)
				{
					case MethMacro: null;
					default:
						switch (Context.follow(field.type))
						{
							case TFun(args, ret):
								return FFun(
								{
									args:convertTFunArgsToFunctionArgs(args, paramMap),
									ret: convertType(ret, paramMap),
									expr:expr,
									params:convertParams(field.params,paramMap)
								});

							default: throw "not implemented for type [" + field.type + "]";
						}
				}
			}
		}
		return null;
	}

	static function convertParams(params:Array<TypeParameter>, paramMap:Array<TypeDeclaration>):Array<TypeParamDecl>
	{
		var results:Array<TypeParamDecl> = [];

		for(param in params)
		{
			var complexType = convertType(param.t, paramMap);
			var result = {
				name:param.name,
				constraints:[],
				params:[]
			}
			results.push(result);
		}
		return results;
	}

	static function convertTFunArgsToFunctionArgs(args : Array<{ t : Type, opt : Bool, name : String }>, paramMap:Array<TypeDeclaration>):Array<FunctionArg>
	{
		var converted:Array<FunctionArg> = [];

		for (arg in args)
		{
			var argType = convertType(arg.t, paramMap);

			var value:Null<Expr> = arg.opt ? arg.t.toComplexType().getDefaultValue() : null;

			if (arg.opt && Tools.isStaticPlatform())
			{
				//NOTE(Dom) - this is to prevent #9 - optional method args without a `?` cause compilation error
				arg.opt = verifyOptionalArgIsActuallyNullable(arg);
			}

			var value = 
			{
				value : value, //Null<Expr>
				type : argType, //<ComplexType>
				opt : arg.opt,
				name : arg.name
			}

			// Console.log(arg.name + ":" + arg + "\n   " + value);
			converted.push(value);
		}
		return converted;
	}

	static function verifyOptionalArgIsActuallyNullable(arg:{ t : Type, opt : Bool, name : String }):Bool
	{
		switch (arg.t)
		{
			case TType(t,_):
				if (t.get().name == "Null")
					return true;
			default: null;
		}

		return false;
	}

	static function getVarAccess(access:VarAccess):String
	{
		return switch (access)
		{
			case AccNormal, AccInline: "default";
			case AccNo: "null";
			case AccNever: "never";
			case AccResolve: throw "not implemented for VarAccess [" + access + "]";
			case AccCall: "property";
			case AccRequire(_,_): throw "not implemented VarAccess [" + access + "]";
		}		
	}

	/**
		Converts a ClassField's TypedExpr to an Expr
	*/
	public static function getFieldExpr(classField:ClassField):Expr
	{
		var typedExpr = classField.expr();

		if (typedExpr == null) return null;

		var expr = Context.getTypedExpr(typedExpr);

		switch (classField.kind)
		{
			case FMethod(_):
			{
				switch (expr.expr)
				{
					case EFunction(_, f):
						return f.expr;
					default: throw "not implemented for ExprDef [" + expr.expr + "]";//return null;
				}
			}
			case FVar(_,_):
			{
				return expr;
			}
		}
	}
}

#end

package mockatoo.macro.tool;

#if macro

import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Expr;

using haxe.macro.Tools;
using mockatoo.macro.Tools;

class ComplexTypes
{

	#if (haxe_ver < 3.1)
	/**
	Generates a ComplexType from a qualified path
	*/
	inline static public function toComplex(ident:String):ComplexType
	{
		return TPath(ident.toTypePath());
	}
	#end

	/**
		Returns the default 'null' value for a type.

		On static platforms (Flash, CPP, Java, C#), basic types have their own default values :

		every Int is by default initialized to 0
		every Float is by default initialized to NaN on Flash9+, and to 0.0 on CPP, Java and C#
		every Bool is by default initialized to false
	*/
	static public function getDefaultValue(type:ComplexType):Expr
	{
		if (type != null && Tools.isStaticPlatform())
		{
			switch (type)
			{
				case TPath(p):
				{
					if (p.pack.length != 0) return EConst(CIdent("null")).at();

					if (p.name == "StdTypes") p.name = p.sub;

					switch (p.name)
					{
						case "Bool":
							return EConst(CIdent("false")).at();
						case "Int":
							return EConst(CInt("0")).at();
						case "Float":
							if ( Context.defined("flash"))
								return "Math.NaN".toFieldExpr();
							else
								return EConst(CFloat("0.0")).at();
						default: null;
					}	
				}
				default: null;
			}
		}
		return EConst(CIdent("null")).at();
	}

	// ------------------------------------------------------------------------ 

	static var types = new Map<Int,Void->Type>();
	static var idCounter = 0;
	
	@:noUsing macro static public function getType(id:Int):Type
		return types.get(id)();
	
	static function register(type:Void->Type):Int {
		types.set(idCounter, type);
		return idCounter++;
	}
		
	/**
		Borrowed idea from tink_macros to create a complexType when haxe.macro.Tools returns null
	**/
	static public function toLazyComplexType(type:Type):ComplexType
	{
		var f = function() return type;
		var expr = macro mockatoo.macro.tool.ComplexTypes.getType;

		var id = register(f);

		var eId:Expr = macro $v{id};

		return TPath(
		{
			pack : ['haxe','macro'],
			name : 'MacroType',
			params : [TPExpr(expr.call([eId]))],
			sub : null,				
		});
	}
}

#end

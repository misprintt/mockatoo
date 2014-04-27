package mockatoo.macro.tool;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;

#if (haxe_ver >= 3.1)
using haxe.macro.MacroStringTools;
#else
using haxe.macro.Tools;
#end
using mockatoo.macro.Tools;

class Exprs
{
	static public function at(e:ExprDef, ?pos:Position):Expr
	{
		if (pos == null) pos = Context.currentPos();
		return {expr:e, pos:pos};
	}

	static public function typed(expr:Expr):Expr
	{
		#if (haxe_ver >= 3.1)
		try
		{
			var typeExpr = Context.typeExpr(expr);
			expr = Context.getTypedExpr(typeExpr);
		}
		catch(e:Dynamic)
		{
			//possibly a typedef structure (cannot)
		}
		#end
		return expr;
	}

	/**
		Converts a qualified path into a EField reference using `haxe.macro.MacroStringTools.toFieldExpr'

		@see haxe.macro.MacroStringTools.toFieldExpr
	*/
	inline static public function toFieldExpr(ident:String):Expr
	{	
		return ident.split(".").toFieldExpr();
	}

	/**
		Shorthand to create a reference to a EField
	**/
	static public inline function field(expr:Expr, field:String, ?pos:Position)
	{
		return EField(expr, field).at(pos);
	}

	/**
		Shorthand for creation an ECall
	**/
	static public inline function call(expr:Expr, ?params:Array<Expr>, ?pos:Position) 
	{
		return ECall(expr, params == null ? [] : params).at(pos);
	}
}

#end
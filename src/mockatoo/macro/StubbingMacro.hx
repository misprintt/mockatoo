package mockatoo.macro;

#if macro

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import mockatoo.exception.StubbingException;

using haxe.macro.Tools;
using mockatoo.macro.Tools;

/**
	Macro for remapping a mock's method invocation when using Mockatoo.when()
*/
class StubbingMacro
{
	public static function createWhen(expr:Expr):Expr
	{
		var str = expr.toString();
		Console.log(str);
		Console.log(expr);

		//converts instance.one(1)
		//into instance.mockProxy.when("one", [1])

		switch (expr.expr)
		{
			case ECall(e, params):

				var ident = e.toString();

				var parts = ident.split(".");
				var methodName = parts.pop();

				var args = EArrayDecl(params).at();

				ident = parts.join(".");

				var eId = ident.toFieldExpr();
				var eField = (ident + "." + methodName).toFieldExpr();

				var eIdent = ident.toFieldExpr();

				var whenExpr = macro cast($eIdent, mockatoo.Mock).mockProxy.stubMethod($v{methodName}, $args);

				var actualExpr = macro {if(false) $eField; $whenExpr;};

				return actualExpr;

			case EField(e, field):

				var ident = e.toString();
				var eIdent = ident.toFieldExpr();
				var whenExpr = macro cast ($eIdent, mockatoo.Mock).mockProxy.stubProperty($v{field});
				var actualExpr = macro {if(false) $expr; $whenExpr;};
				return actualExpr;

			default: throw "Invalid expression [" + expr.toString() + "]";
		}
		return expr;
	}

	static function isMatcher(expr:Expr):Bool
	{
		return switch (expr.expr)
		{
			case EConst(CIdent("anyString")): 		true;
			case EConst(CIdent("anyInt")): 			true;
			case EConst(CIdent("anyFloat")): 		true;
			case EConst(CIdent("anyBool")): 		true;
			case EConst(CIdent("anyIterator")): 	true;
			case EConst(CIdent("anyObject")): 		true;
			case EConst(CIdent("anyEnum")): 		true;
			case EConst(CIdent("enumOf")): 			true;
			case EConst(CIdent("instanceOf")): 		true;
			case EConst(CIdent("isNotNull")): 		true;
			case EConst(CIdent("any")): 			true;
			case EConst(CIdent("customMatcher")): 	true;
			case ECall(e, params): 					isMatcher(e);
			case _: 								false;

		}
	}

	public static function returns(expr:Expr, returnExpr:Expr):Expr
	{
		return createThen(expr, "thenReturn", returnExpr);
	}

	public static function throws(expr:Expr, throwExpr:Expr):Expr
	{
		return createThen(expr, "thenThrow", throwExpr);
	}

	public static function calls(expr:Expr, callExpr:Expr):Expr
	{
		return createThen(expr, "thenCall", callExpr);
	}

	public static function callsRealMethod(expr:Expr):Expr
	{
		return createThen(expr, "thenCallRealMethod", null);
	}

	public static function stubs(expr:Expr):Expr
	{
		return createThen(expr, "thenStub", null);
	}

	static function createThen(whenExpr:Expr, thenMethod:String, ?thenExpr:Expr=null):Expr
	{
		whenExpr = createWhen(whenExpr);

		var exprs = switch (whenExpr.expr)
		{
			case EBlock(e): e;
			default: [whenExpr];
		}

		var actualExpr = exprs.pop();

		var params = thenExpr != null ? [thenExpr] : [];
		actualExpr = actualExpr.field(thenMethod).call(params);
		exprs.push(actualExpr);

		var ret = EBlock(exprs).at();
		Console.log(ret.toString());

		return ret;
	}
}

#end

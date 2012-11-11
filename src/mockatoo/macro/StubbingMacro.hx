package mockatoo.macro;

#if macro

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import mockatoo.exception.StubbingException;

using tink.macro.tools.Printer;
using tink.macro.tools.ExprTools;
using tink.macro.tools.TypeTools;

/**
Macro for remapping a mock's method invocation when using Mockatoo.when()
*/
class StubbingMacro
{
	public static function createWhen(expr:Expr):Expr
	{
		var str = expr.print();
		Console.log(str);
		Console.log(expr);

		//converts instance.one(1)
		//into instance.mockProxy.when("one", [1])

		switch(expr.expr)
		{
			case ECall(e, params):

				var ident = e.toString();

				var parts = ident.split(".");
				var methodName = parts.pop();

				var args = params.toArray();

				ident = parts.join(".");

				var eCast = ECast(ident.resolve(), "mockatoo.Mock".asComplexType()).at();

				var eMethod = eCast.field("mockProxy").field("stubMethod");

				var whenExpr = eMethod.call([EConst(CString(methodName)).at(), args]);

				var eField = ident.resolve().field(methodName);
				var compilerCheck = EIf(EConst(CIdent("false")).at(), eField, null).at();

				var actualExpr = EBlock([compilerCheck, whenExpr]).at();
				// Console.log(actualExpr.toString());
				return actualExpr;

			case EField(e, field):

				var ident = e.toString();

				var eCast = ECast(ident.resolve(), "mockatoo.Mock".asComplexType()).at();

				var eMethod = eCast.field("mockProxy").field("stubProperty");

				var eFieldName = EConst(CString(field)).at();

				var whenExpr = eMethod.call([eFieldName]);

				var compilerCheck = EIf(EConst(CIdent("false")).at(), expr, null).at();

				var actualExpr = EBlock([compilerCheck, whenExpr]).at();
				// Console.log(actualExpr.toString());
				return actualExpr;

			default: throw "Invalid expression [" + expr.print() + "]";
		}
		return expr;
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

		var exprs = switch(whenExpr.expr)
		{
			case EBlock(e): e;
			default: [whenExpr];
		}

		var actualExpr = exprs.pop();

		var params = thenExpr != null ? [thenExpr] : [];
		actualExpr = actualExpr.field(thenMethod).call(params);
		exprs.push(actualExpr);

		var ret = EBlock(exprs).at();
		Console.log(Printer.print(ret));

		return ret;
	}
}

#end
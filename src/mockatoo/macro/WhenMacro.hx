package mockatoo.macro;

#if macro

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using tink.macro.tools.Printer;
using tink.macro.tools.ExprTools;
using tink.macro.tools.TypeTools;

/**
Macro for remapping a mock's method invocation when using Mockatoo.when()
*/
class WhenMacro
{
	public static function create(expr:Expr):Expr
	{
		var str = expr.print();
		trace(str);
		trace(expr);

		//converts instance.one(1)
		//into instance.mockProxy.when("one", [1])

		switch(expr.expr)
		{
			case ECall(e, params):

				var ident = e.toString();

				var parts = ident.split(".");
				var methodName = EConst(CString(parts.pop())).at();

				var args = params.toArray();

				ident = parts.join(".");

				var eCast = ECast(ident.resolve(), "mockatoo.Mock".asComplexType()).at();

				var eMethod = eCast.field("mockProxy").field("stubMethod");

				var actualExpr = eMethod.call([methodName, args]);
				trace(actualExpr.toString());
				return actualExpr;

			case EField(e, field):

				var ident = e.toString();

				var eCast = ECast(ident.resolve(), "mockatoo.Mock".asComplexType()).at();

				var eMethod = eCast.field("mockProxy").field("stubProperty");

				var eFieldName = EConst(CString(field)).at();

				var actualExpr = eMethod.call([eFieldName]);

				trace(actualExpr.toString());
				return actualExpr;

			default: throw "Invalid arg [" + expr.print() + "]";
		}
		return expr;
	}
}

#end
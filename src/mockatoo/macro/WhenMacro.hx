package mockatoo.macro;

#if macro

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using tink.macro.tools.Printer;
using tink.macro.tools.ExprTools;

class WhenMacro
{
	public static function create(expr:Expr):Expr
	{
		var str = expr.print();
		trace(str);
		trace(expr);

		//converts instance.one(1)
		//into instance.mockDelegate.when("one", [1])

		switch(expr.expr)
		{
			case ECall(e, params):

				var ident = e.toString();

				var parts = ident.split(".");
				var methodName = EConst(CString(parts.pop())).at();

				var args = params.toArray();

				ident = parts.join(".") + ".mockDelegate.stub";

				var actualExpr = ident.resolve().call([methodName, args]);
				trace(actualExpr.toString());
				return actualExpr;

			default: throw "Invalid arg [" + expr.print() + "]";
		}
		return expr;
	}
}

#end
package mockatoo.macro;

#if macro

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using tink.macro.tools.Printer;
using tink.macro.tools.ExprTools;
using tink.macro.tools.TypeTools;

import mockatoo.exception.VerificationException;

/**
Macro for remapping a mock's method invocation when using Mockatoo.when()
*/
class VerifyMacro
{

	public static function create(expr:Expr, mode:Expr):Expr
	{
		var str = expr.print();
		// Console.log(str);
		// Console.log(expr);

		mode = validateModeExpr(mode);

		//converts instance.one(1)
		//into instance.mockProxy.when("one", [1])

		switch(expr.expr)
		{
			case EConst(c):
				//this is to support the old style - e.g. `verify(mock).doSomething();
				var ident:String = switch(c)
				{
					case CIdent(v): v;
					default: throw "Invalid arg [" + expr.print() + "]";
				}

				var exprs = createVerifyExpressions(expr, mode);
				return EBlock(exprs).at();

			case EField(_,_):

				var exprs = createVerifyExpressions(expr, mode);
				return EBlock(exprs).at();

			case ECall(e, params):

				var actualExpr = convertCallExprToVerification(e.toString(), params, mode);
				//Console.log(actualExpr.toString());
				return actualExpr;

			case ECast(e, t):
				return create(e,mode);

			case _: throw "Invalid verify expression [" + expr.print() + "]";
		}
		return expr;
	}

	static function createVerifyExpressions(expr:Expr, mode:Expr):Array<Expr>
	{
		var eIsNotNull:Expr;
		var eIsAMock:Expr;

		if(haxe.macro.Compiler.getDefine("cpp") != null)
		{
			eIsNotNull = macro if($expr == null) throw new mockatoo.exception.VerificationException("Cannot verify [null] mock");
			eIsAMock = macro if(!Std.is($expr, mockatoo.Mock)) throw new mockatoo.exception.VerificationException("Object is not an instance of mock");
		}
		else
		{
			eIsNotNull = macro Console.assert($expr != null, new mockatoo.exception.VerificationException("Cannot verify [null] mock"));
			eIsAMock = macro Console.assert(Std.is($expr, mockatoo.Mock), new mockatoo.exception.VerificationException("Object is not an instance of mock"));
		}

		var verifyExpr = macro cast($expr, mockatoo.Mock).mockProxy.verify($mode);
		return [eIsNotNull, eIsAMock, verifyExpr];
	}

	static function convertCallExprToVerification(path:String, params:Array<Expr>,mode:Expr)
	{
		var parts = path.split(".");
		var methodName = parts.pop();
		var ident = parts.join(".");

		var eInstance = ident.resolve();
		var exprs = createVerifyExpressions(eInstance, mode);

		var verifyExpr = exprs.pop();
		var actualExpr = verifyExpr.field(methodName).call(params);

		var eField = eInstance.field(methodName);
		var compilerCheck = EIf(EConst(CIdent("false")).at(), eField, null).at();

		exprs.push(compilerCheck);
		exprs.push(actualExpr);

		return EBlock(exprs).at();
	}

	static function validateModeExpr(expr:Expr)
	{
		switch(expr.expr)
		{
			case EConst(c):
				switch(c)
				{
					case CInt(_): return "VerificationMode.times".resolve().call([expr]);
					default: return expr;
				}
			default: return expr;

		}
	}
}

#end
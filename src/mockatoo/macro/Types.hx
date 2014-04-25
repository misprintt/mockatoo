package mockatoo.macro;

#if macro

import haxe.macro.Type;
import haxe.macro.Expr;

using musings.Tools;

class Types
{
	static var types = new Map<Int,Void->Type>();
	static var idCounter = 0;
	
	@:noUsing macro static public function getType(id:Int):Type
		return types.get(id)();
	
	static function register(type:Void->Type):Int {
		types.set(idCounter, type);
		return idCounter++;
	}
	
	static public function toLazyComplexType(type:Type):ComplexType
	{
		var f = function() return type;
		var expr = macro mockatoo.macro.Types.getType;

		var id = register(f).toConstant().at();

		return TPath(
		{
			pack : ['haxe','macro'],
			name : 'MacroType',
			params : [TPExpr(expr.call([id]))],
			sub : null,				
		});
	}
}

#end

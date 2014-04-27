package mockatoo.macro.tool;

#if macro

import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Expr;

using haxe.macro.Tools;
using mockatoo.macro.Tools;

class Types
{
	static public function getId(type:Type):String
	{
		// return type.getId();
		return switch (type)
		{
			case TAbstract(t, _): t.toString();
			case TInst(t, _): t.toString();
			case TEnum(t, _): t.toString();
			case TType(t, _): t.toString();
			default: null;
		}
	}
}

#end

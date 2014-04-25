package mockatoo.macro.tool;

#if macro

import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Expr;

using haxe.macro.Tools;
using mockatoo.macro.Tools;

class TypePaths
{
	/**
		Returns a TypePath for the string [ident], and optional paramaters [params]
	*/
	static public function toTypePath(ident:String, ?params:Array<TypeParam>):TypePath
	{
		// return id.toTypePath(params);

		if (params == null) params = [];

		var parts:Array<String> = ident.split(".");
		var sub:String = null;
		var name:String = parts.pop();

		if (parts.length > 0)
		{
			var char = parts[parts.length-1].split("").shift();
			
			if (char == char.toUpperCase())
			{
				sub = name;
				name = parts.pop();
			}
		}

		if (sub == name)
			sub = null;

		return {
			sub:sub,
			pack:parts,
			name:name,
			params:params
		}
	}
}

#end

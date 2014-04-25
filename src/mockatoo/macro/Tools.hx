package mockatoo.macro;

#if macro

import haxe.macro.*;
using haxe.macro.Tools;

typedef TExprs = mockatoo.macro.tool.Exprs;
typedef TTypes = mockatoo.macro.tool.Types;
typedef TComplexTypes = mockatoo.macro.tool.ComplexTypes;
typedef TTypePaths = mockatoo.macro.tool.TypePaths;

class Tools
{
	/**
		Returns true if current target platform is static
		See <http://haxe.org/manual/basic_types#statically-typed-platforms>
	*/
	public static function isStaticPlatform():Bool
	{
		if (_isStaticPlatform == null)
		{
			_isStaticPlatform = false;
			var staticPlatforms = ["flash", "cpp", "java", "cs"];

			for (platform in staticPlatforms)
			{
				if (Context.defined(platform))
				{
					_isStaticPlatform = true;
					break;
				}
			}
		}
		return _isStaticPlatform;		
	}

	static var _isStaticPlatform:Null<Bool> = null;

}

#end
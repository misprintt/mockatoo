package mockatoo.macro;


#if macro
using haxe.macro.Context;


class Contexts
{

	static var _isStaticPlatform:Null<Bool> = null;

	/**
	Returns true if current target platform is static
	See <http://haxe.org/manual/basic_types#statically-typed-platforms>
	*/
	static public function isStaticPlatform():Bool
	{
		if(_isStaticPlatform == null)
		{
			_isStaticPlatform = false;
			var staticPlatforms = ["flash", "cpp", "java", "cs"];

			for(platform in staticPlatforms)
			{
				if(platform.defined())
				{
					_isStaticPlatform = true;
					break;
				}

			}
		}

		return _isStaticPlatform;
		
	}

}

#end
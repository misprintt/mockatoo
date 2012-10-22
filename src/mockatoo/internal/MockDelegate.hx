package mockatoo.internal;
import mockatoo.Mockatoo;

class MockDelegate
{
	public var target:Mock;

	var targetClass:Class<Mock>;
	var targetClassName:String;

	var hash:Hash<MethodProxy>;

	public function new(target:Mock)
	{
		this.target = target;
		targetClass = Type.getClass(target);
		hash = new Hash();

		parseMetadata();

	}

	/**
	Called by mocked clases when methods are executed. Do not call directly
	*/
	public function callMethod(method:String, args:Array<Dynamic>)
	{
		var proxy = hash.get(method);
		proxy.call(args);
	}

	/**
	Called by mocked clases when methods are executed. Do not call directly
	*/
	public function callMethodAndReturn<T>(method:String, args:Array<Dynamic>, returnValue:T):T
	{
		var proxy = hash.get(method);
		return proxy.callAndReturn(args, returnValue);
		//return returnValue;
	}

	public function verify(filter:VerificationFilter):MockVerification
	{
		var temp = new MockVerification();

		for(proxy in hash.iterator())
		{
			switch(proxy.argCount)
			{
				case 0:
					Reflect.setField(temp, proxy.fieldName,
						function()
						{
							return proxy.verify(filter);
						}
					);
				case 1:
					Reflect.setField(temp, proxy.fieldName,
						function(?arg)
						{
							return proxy.verify(filter, [arg]);
						}
					);
				case 2:
					Reflect.setField(temp, proxy.fieldName,
						function(?arg1,?arg2)
						{
							return proxy.verify(filter, [arg1,arg2]);
						}
					);
				case 3:
					Reflect.setField(temp, proxy.fieldName,
						function(?arg1,?arg2,?arg3)
						{
							return proxy.verify(filter, [arg1,arg2]);
						}
					);
			}
		}

		return temp;
	}

	function parseMetadata()
	{
		var m = haxe.rtti.Meta.getType(targetClass);
		//trace( + " Mock");

		targetClassName = cast m.mockatoo[0];

		var fieldMetas = haxe.rtti.Meta.getFields(targetClass);
		var fieldNames = Type.getInstanceFields(targetClass);

		for(fieldName in fieldNames)
		{	
			//trace(fieldName);

			#if flash
				if(Reflect.hasField(target, fieldName))
				{
					if(!Reflect.isFunction(Reflect.field(target, fieldName))) continue;
				}
			
			#else
				if(Reflect.hasField(target, fieldName)) continue; //only care about methods
			#end
			
			var fieldMeta = Reflect.field(fieldMetas, fieldName);

			if(fieldMeta != null && Reflect.hasField(fieldMeta, "mockatoo"))
			{
				var mockMeta = Reflect.field(fieldMeta, "mockatoo");
				//trace("   " + fieldName + ": " + Std.string(mockMeta));

				var args:Array<String> = cast mockMeta[0];
				var ret:String = cast(mockMeta.length > 1 ? mockMeta[1] : null);
				var proxy = new MethodProxy(targetClassName, fieldName, args, ret);

				hash.set(fieldName, proxy);

				//Reflect.setField(this, fieldName, proxy.verify);
			}
		}
	}
}

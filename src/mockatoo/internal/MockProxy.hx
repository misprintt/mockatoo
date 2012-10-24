package mockatoo.internal;
import mockatoo.Mockatoo;

/**
 * Responsible for run time mocking behaviour
 */
class MockProxy
{
	public var target:Mock;

	var targetClass:Class<Mock>;
	var targetClassName:String;

	var hash:Hash<MockMethod>;

	public function new(target:Mock)
	{
		this.target = target;
		targetClass = Type.getClass(target);
		hash = new Hash();

		var m = haxe.rtti.Meta.getType(targetClass);
		targetClassName = cast m.mockatoo[0];

		var fieldMeta = haxe.rtti.Meta.getFields(targetClass);
		parseMetadata(fieldMeta);
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

	public function verify(?mode:VerificationMode):Verification
	{
		if(mode == null) mode = VerificationMode.times(1);
		
		var temp = new Verification(mode);

		for(proxy in hash.iterator())
		{
			var f = Reflect.makeVarArgs(function(a:Array<Dynamic>)
			{
				return proxy.verify(mode, a);
			});

			Reflect.setField(temp, proxy.fieldName, f);
		}
		return temp;
	}

	public function stub(method:String, args:Array<Dynamic>):Stubber
	{
		var stub = new Stubber();

		var proxy = hash.get(method);

		var fReturn = Reflect.makeVarArgs(function(values:Array<Dynamic>)
		{
			proxy.addReturnFor(args, values);
			return stub;
		});

		var fThrow = Reflect.makeVarArgs(function(values:Array<Dynamic>)
		{
			proxy.addThrowFor(args, values);
			return stub;
		});

		var fCallback = Reflect.makeVarArgs(function(values:Array<Dynamic>)
		{
			proxy.addCallbackFor(args, values);
			return stub;
		});


		
		Reflect.setField(stub, "thenReturn", fReturn);
		Reflect.setField(stub, "thenThrow", fThrow);
		Reflect.setField(stub, "thenCall", fCallback);


		return stub;
	}

	/*
	public function thenReturn(value:T):Stubber
	{
		
	}

	public function thenThrow(value:Dynamic):Stubber
	{

	}

	*/

	function parseMetadata(fields:Dynamic<Dynamic<Array<Dynamic>>>)
	{
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
			
			var fieldMeta = Reflect.field(fields, fieldName);

			if(fieldMeta != null && Reflect.hasField(fieldMeta, "mockatoo"))
			{
				var mockMeta = Reflect.field(fieldMeta, "mockatoo");
				//trace("   " + fieldName + ": " + Std.string(mockMeta));

				var args:Array<String> = cast mockMeta[0];
				var ret:String = cast(mockMeta.length > 1 ? mockMeta[1] : null);
				var proxy = new MockMethod(targetClassName, fieldName, args, ret);

				hash.set(fieldName, proxy);

				//Reflect.setField(this, fieldName, proxy.verify);
			}
		}
	}
}

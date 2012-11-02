package mockatoo.internal;
import mockatoo.Mockatoo;
import mockatoo.exception.StubbingException;

/**
Responsible for run time mocking behaviour of a Mock instance.
*/
class MockProxy
{
	public var target:Mock;
	public var spy:Bool;
	var targetClass:Class<Mock>;
	var targetClassName:String;
	var methods:Hash<MockMethod>;
	var properties:Hash<MockProperty>;

	public function new(target:Mock, ?spy:Bool=false)
	{
		this.target = target;
		this.spy = spy;
		targetClass = Type.getClass(target);
		reset();
	}

	/**
	Called by mocked clases when methods are executed. 
	*/
	public function getOutcomeFor(method:String, args:Array<Dynamic>):MockOutcome
	{
		var proxy = methods.get(method);
		return proxy.getOutcomeFor(args);
	}

	/**
	Called by Mockatoo.verify to access verifications for a mock class.
	*/
	public function verify(?mode:VerificationMode):Verification
	{
		if(mode == null) mode = VerificationMode.times(1);
		
		var temp = new Verification(mode);

		for(proxy in methods.iterator())
		{
			var f = Reflect.makeVarArgs(function(a:Array<Dynamic>)
			{
				return proxy.verify(mode, a);
			});

			Reflect.setField(temp, proxy.fieldName, f);
		}
		return temp;
	}

	public function stubMethod(method:String, args:Array<Dynamic>):Stubber
	{
		var stub = new Stubber();

		var proxy = methods.get(method);

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

		var fCallReal = function()
		{
			proxy.addCallRealMethodFor(args);
			return stub;
		};

		var fStub = function()
			{
				proxy.addDefaultStubFor(args);
				return stub;
			};


		
		Reflect.setField(stub, "thenReturn", fReturn);
		Reflect.setField(stub, "thenThrow", fThrow);
		Reflect.setField(stub, "thenCall", fCallback);
		Reflect.setField(stub, "thenCallRealMethod", fCallReal);
		Reflect.setField(stub, "thenStub", fStub);

		return stub;
	}


	/**
	Determines how to stub a property based on it's read/write signature
	thenReturns maps to the getter (if available), otherwise Reflect.setField 
	thenThrow and thenCall maps to the setter (if available)
	*/
	public function stubProperty(property:String):Stubber
	{
		var stub = new Stubber();

		var prop:MockProperty = properties.exists(property) ? properties.get(property) : {name:property, get:"", set:""};
		var getMethod = prop.get != "" ? methods.get(prop.get) : null;
		var setMethod = prop.set != "" ? methods.get(prop.set) : null;
		
		var fReturn =  function(value:Dynamic)
		{
			Reflect.setField(target, property, value);
			return stub;
		};	

		var fThrow = function(value:Dynamic)
		{
			throw new StubbingException("Cannot use thenThrow on property field without getter or setter [" + property + "]");
			return stub;
		};

		var fCallback = function(value:Dynamic)
		{
			throw new StubbingException("Cannot use thenCall on property field without getter [" + property + "]");
			return stub;
		};

		var fCallReal = function()
		{
			throw new StubbingException("Cannot use thenCallRealMethod on property field without getter or setter [" + property + "]");
			return stub;
		};

		var fStub = function()
		{
			throw new StubbingException("Cannot use thenStub on property field without getter or setter [" + property + "]");
			return stub;
		};


		if(getMethod != null)
		{
			fReturn = function(value:Dynamic)
			{
				Reflect.setField(target, property, value);
				getMethod.addReturnFor([], [value]);
				return stub;
			};

			fCallback = function(value:Dynamic)
			{
				getMethod.addCallbackFor([], [value]);
				return stub;
			};
		}

		if(setMethod != null && getMethod != null)
		{
			fThrow =function(value:Dynamic)
			{
				setMethod.addThrowFor([Matcher.any], [value]);
				getMethod.addThrowFor([], [value]);
				return stub;
			};

			fCallReal = function():Stubber
			{
				getMethod.addCallRealMethodFor([]);
				setMethod.addCallRealMethodFor([Matcher.any]);
				return stub;
			};

			fStub = function()
			{
				getMethod.addDefaultStubFor([]);
				setMethod.addDefaultStubFor([Matcher.any]);
				return stub;
			};
		}
		else if(getMethod != null)
		{
			fThrow =function(value:Dynamic)
			{
				getMethod.addThrowFor([], [value]);
				return stub;
			};

			fCallReal = function()
			{
				getMethod.addCallRealMethodFor([]);
				return stub;
			};

			fStub = function()
			{
				getMethod.addDefaultStubFor([]);
				return stub;
			};
		}
		else if(setMethod != null)
		{
			fThrow = function(value:Dynamic)
			{
				setMethod.addThrowFor([Matcher.any], [value]);
				return stub;
			};

			fCallReal = function()
			{
				setMethod.addCallRealMethodFor([Matcher.any]);
				return stub;
			};

			fStub = function()
			{
				setMethod.addDefaultStubFor([Matcher.any]);
				return stub;
			};
		}

		Reflect.setField(stub, "thenReturn", fReturn);
		Reflect.setField(stub, "thenThrow", fThrow);
		Reflect.setField(stub, "thenCall", fCallback);
		Reflect.setField(stub, "thenCallRealMethod", fCallReal);
		Reflect.setField(stub, "thenStub", fStub);

		return stub;
	}

	/**
	Resets all stubs/verifications for the mock class
	*/
	public function reset()
	{
		methods = new Hash();
		properties = new Hash();

		var m = haxe.rtti.Meta.getType(targetClass);
		targetClassName = cast m.mockatoo[0];


		parsePropertyMetadata(m.mockatooProperties);

		var fieldMeta = haxe.rtti.Meta.getFields(targetClass);
		parseMethodMetadata(fieldMeta);
	}

	function parsePropertyMetadata(props:Array<MockProperty>)
	{
		if(props == null) return;

		//trace(props);

		for(prop in props)
		{
			properties.set(prop.name, prop);
		}
	}

	function parseMethodMetadata(fields:Dynamic<Dynamic<Array<Dynamic>>>)
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

				methods.set(fieldName, proxy);

				//Reflect.setField(this, fieldName, proxy.verify);
			}
		}
	}
}

typedef MockProperty =
{
	var name:String;
	var get:String;
	var set:String;
}

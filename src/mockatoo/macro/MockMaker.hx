package mockatoo.macro;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Printer;
import mockatoo.Mock;
import mockatoo.macro.ClassFields;
import mockatoo.internal.MockOutcome;
import haxe.ds.StringMap;

using haxe.macro.Tools;
using mockatoo.macro.Tools;

typedef PropertyMeta = 
{
	var get:String;
	var set:String;
	var name:String;
}

/**
	Macro class that generates a Mock implementation of a class or interface
*/
class MockMaker
{
	static var mockedClassMap:StringMap<String> = new StringMap();
	static var eNull:Expr = EConst(CIdent("null")).at();

	var expr:Expr;
	var pos:Position;
	var id:String;
	var type:Type;
	var actualType:Type;

	var isSpy:Bool;

	var classType:ClassType;
	var params:Array<Type>;

	var isInterface:Bool;

	var extendTypePath:TypePath;

	var typeDefinition:TypeDefinition;
	var typeDefinitionId:String;

	var hasConstructor = false;

	var generatedExpr:Expr;

	var propertyMetas:Array<PropertyMeta>;

	public function new(e:Expr, ?paramTypes:Expr, isSpy:Bool=false)
	{
		expr = e;

		id = e.toString();

		Console.log(id);

		this.isSpy = isSpy;

		pos = e.pos;
		type = Context.getType(id);
		Console.log(type);
		actualType = type.follow();
		
		Console.log(type);
		Console.log(actualType);

		params = [];

		if (paramTypes != null && isNotNull(paramTypes))
		{
			switch (paramTypes.expr)
			{
				case EArrayDecl(values):

					for (value in values)
					{
						var ident = value.toString();
						Console.log("  param: " + ident);
						params.push(Context.getType(ident));
					}

				default: throw "invalid param [" + paramTypes.toString() + "]";
			}
		}

		switch (actualType)
		{
			case TAnonymous(a):
				createMockFromStruct(a.get().fields);
			case TInst(_,_):
				id = actualType.getId().split(".").pop();
				createMockFromClass();
			default:
				throw new mockatoo.exception.MockatooException("Unsupported type [" + id + "]. Cannot mock");
		}
	}

	/**
		Returns the generated expr instanciating an instance of the mock
	*/
	public function toExpr():Expr
	{
		if (generatedExpr == null)
		{
			var typeParams:Array<TypeParam> = [];
			for (type in params)
			{	
				try
				{
					var complexType = type.toComplexType();
					if (complexType == null)
					{
						complexType = type.toLazyComplexType();
					}

					var typeParam = TPType(complexType);
					typeParams.push(typeParam);
				}
				catch(e:Dynamic)
				{
					Console.log(type);
				}
			}

			var eIsSpy = EConst(CIdent(Std.string(isSpy))).at();

			var typePath = typeDefinitionId.toTypePath(typeParams);
			generatedExpr = ENew(typePath, [eIsSpy]).at(pos);
		}

		Console.log(generatedExpr.toString());
		return generatedExpr;	
	}

	function toComplexType(type:Type):ComplexType
	{
		return type.toComplexType();
	}
	
	/**
		Generates a dynamic object matching a TypeDef structure
	*/
	function createMockFromStruct(fields:Array<ClassField>)
	{
		var args:Array<{ field : String, expr : Expr }> = [];

		var arg:{ field : String, expr : Expr };

		for (field in fields)
		{
			Console.log(field.name);
			arg = {field:field.name, expr:null};

		
			switch (field.type)
			{
				case TInst(_,_):
					arg.expr = toComplexType(field.type).getDefaultValue();
				case TType(_,_):
					arg.expr = toComplexType(field.type).getDefaultValue();
				case TEnum(_,_):
					arg.expr = toComplexType(field.type).getDefaultValue();					
				case TFun(functionArgs, ret):
					var e = toComplexType(field.type).getDefaultValue();
					var fargs:Array<FunctionArg> = [];

					for (a in functionArgs)
					{
						var arg = {
							name: a.name,
							opt: a.opt,
							type: toComplexType(a.t),
							value: null
						};
					
						fargs.push(arg);
					}

					var f:Function = {
						args: fargs,
						ret: toComplexType(ret),
						params: [],
						expr: EReturn(e).at(e.pos)
					}

					arg.expr = EFunction(null, f).at();
				case TAbstract(t, params):
					arg.expr = field.type.toComplexType().getDefaultValue();

				default: throw "Unsupported type [" + field.type + "] for field [" + field.name + "]";
			}

			args.push(arg);
		}
		generatedExpr = EObjectDecl(args).at(pos);
	}

	/**
		Creates a class definition for a mocked class or interface 
	*/
	function createMockFromClass()
	{
		Console.log("expr: " + expr);
		Console.log("id: " + id);
		Console.log("type: " + type);
		Console.log("actual: " + actualType);
		
		switch (actualType)
		{
			case TInst(t, typeParams):
				classType = t.get();

				if (params.length == 0)
					params = typeParams;

			default: throw "not implementend";
		}

		if (mockedClassMap.exists(id))
		{
			typeDefinitionId = mockedClassMap.get(id);
			Console.log("existing: " + id + ", " + typeDefinitionId);
			return;
		}

		isInterface = classType.isInterface;

		if (isInterface) isSpy = false;
		
		Console.log("params: " + params);
		Console.log("isSpy " +  isSpy);
		Console.log("class " +  classType.name);
		Console.log("   interface: " + isInterface);
		Console.log("   params: " + classType.params);
		Console.log("   pos: " + classType.pos);
		Console.log("   module: " + classType.module);

		typeDefinition = createTypeDefinition();
		typeDefinitionId = (typeDefinition.pack.length > 0 ? typeDefinition.pack.join(".")  + "." : "") + typeDefinition.name;

		debugPrintClass();

		Context.defineType(typeDefinition);

		mockedClassMap.set(id, typeDefinitionId);
	}

	function isNotNull(expr:Expr):Bool
	{
		switch (expr.expr)
		{
			case EConst(c):
				switch (c)
				{
					case CIdent(id):
						if (id == "null") return false;
					default: null;
				}
			default: null;
		}
		return true;
	}

	/**
		Returns a new type definition based on the target class or interface that
		mocks the contents of all function fields
	*/
	function createTypeDefinition():TypeDefinition
	{
		propertyMetas = [];
		var paramTypes:Array<TypeParamDecl> = [];

		Console.log("classType.params:" + classType.params);
		
		for (i in 0...classType.params.length)
		{
			var param = classType.params[i];

			var constraints:Array<ComplexType> = [];
			switch (param.t)
			{
				case TInst(t,_):
				{
					switch (t.get().kind)
					{
						case ClassKind.KTypeParameter(constrnts):
							for (const in constrnts)
							{
								var complexParam = haxe.macro.TypeTools.toComplexType(const);
								constraints.push(complexParam);
							}
						default:
					}
				}
				default: null;
			}

			paramTypes.push({name:param.name, constraints:constraints, params:[]});
		}

		var extendId = classType.module + "." + classType.name;

		Console.log("paramTypes:" + paramTypes);
		Console.log("super params:" + classType.params);

		var typeParams:Array<TypeParam> = [];
		for (p in classType.params)
		{
			typeParams.push(TPType(haxe.macro.TypeTools.toComplexType(p.t)));
		}

		Console.log(typeParams);

		typeParams = removeTypedConsraintsFromTypeParams(typeParams);

		Console.log(typeParams);

		extendTypePath = extendId.toTypePath(typeParams);

		Console.log(extendTypePath);

		var kind = createKind();

		var fields = createFields();

		if (isInterface || !hasConstructor)
			fields.unshift(createEmptyConstructor());

		var metas = updateMeta(classType.meta.get());

		if (Context.defined("flash"))
		{
			var skip = false;
			for (m in metas)
			{
				if (m.name == ":hack")
				{
					skip = true;
					break;
				}
			}

			if (skip)
			{
				Context.error("Cannot mock final class [" + id + "] on flash target.", Context.currentPos());
				return null;
			}
		}

		var eProps:Array<Expr> = [];

		for (prop in propertyMetas)
		{
			var args = [];
			for (field in Reflect.fields(prop))
				args.push( { field:field, expr: EConst(CString(Reflect.field(prop, field))).at() } );
			var eObject = EObjectDecl(args).at();
			eProps.push(eObject);
		}

		metas.push(
		{
			pos:Context.currentPos(),
			name:"mockatooProperties",
			params: eProps
		});

		metas.push({
			pos:Context.currentPos(),
			name:"mockatoo",
			params:[EConst(CString(id)).at()]
		});

		return {
			pos: classType.pos,
			params: paramTypes,
			pack: classType.pack,
			name: id + "Mocked",
			meta: metas,
			kind: kind,
			isExtern:false,
			fields:fields
		};
	}

	/**
		Hack to remove the constraints from super class type params to ensure type definition
		can compile.
	*/
	function removeTypedConsraintsFromTypeParams(types:Array<TypeParam>):Array<TypeParam>
	{
		var temp:Array<TypeParam> = [];

		for (type in types)
		{
			switch (type)
			{
				case TPType(t):
					switch (t)
					{
						case TPath(path):
							path.params = [];
							type = TPType(TPath(path));
						default:
					}
				default:
			}

			temp.push(type);
		}
		return temp;
	}
	
	function debugPrintClass()
	{
		var printer = new haxe.macro.Printer();
		var result = printer.printTypeDefinition(typeDefinition);
		Console.log(result);
	}

	function updateMeta(source:Metadata):Metadata
	{
		var metadata:Metadata = [];

		for (meta in source)
		{
			Console.log(meta.name + ":" + new Printer().printExprs(meta.params, ""));

			switch (meta.name)
			{
				case ":final":
					metadata.push({pos:Context.currentPos(), name:":hack", params:[]});
				case ":core_api", ":build":
					null;
				default:
					metadata.push(meta);
			}
		}
		
		return metadata;
	}

	/**
		Creates the typeDefinition kind that extends the target class
	*/
	function createKind()
	{
		var mockInterface = "mockatoo.Mock".toTypePath();

		var extension:TypePath = null;
		var interfaces:Array<TypePath> = null;

		if (isInterface)
		{
			interfaces = [extendTypePath, mockInterface];
		}
		else
		{
			Console.log(extendTypePath);
			extension = extendTypePath;
			interfaces = [mockInterface];
		}

		var kind:TypeDefKind = TDClass(

			extension,
			interfaces,
			false
			);

		return kind;
	}

	/**
		Returns mocked versions of all functions within the target class or interface.
		Also cleans up constructor to call super (if a class) and to not return Void.
	*/
	function createFields():Array<Field>
	{
		var fields:Array<Field> = [];//[createEmptyConstructor()];

		var superFields = ClassFields.getClassFields(classType);

		for (field in superFields)
		{
			createField(field, fields);
		}

		fields = appendMockInterfaceFields(fields);
		return fields;
	}

	/**
		Generates the mocked verison of a field.
		Generates additional getter/setter function fields for interface properties
	*/
	function createField(field:Field, fields:Array<Field>)
	{

		field.meta = updateMeta(field.meta);

		switch (field.kind)
		{
			case FFun(f):

				if (field.name == "new")
				{
					overrideConstructor(field, f);
				}
				else
				{
					overrideField(field, f);
				}

				if (field.access.remove(AInline))
				{
					#if no_inline
						fields.push(field);
					#else
						Context.warning("Cannot mock inline method [" + id + "." + field.name + "]. Please set '--no-inline' compiler flag.", Context.currentPos());
					#end

					return;
					
				}

				if (Context.defined("flash"))
				{
					var skip = false;
					for (m in field.meta)
					{
						if (m.name == ":hack")
						{
							skip = true;
							break;
						}
					}

					if (skip)
						Context.warning("Cannot mock final method [" + id + "." + field.name + "] on flash target.", Context.currentPos());
					else
						fields.push(field);
				}
				else
				{
					fields.push(field);
				}
					
			case FVar(_,_):
				if (isInterface) fields.push(field);
			case FProp(get, set, t,_):

				t = normaliseComplexType(t);

				var getMethod = toGetterSetter(get);
				var setMethod = toGetterSetter(set);

				if (getMethod != "" || setMethod != "")
					propertyMetas.push({name:field.name, set:setMethod, get:getMethod});

				if (isInterface) 
				{
					//force concrete property for getter setter
					addConcretePropertyMetadata(field);

					fields.push(field);
			 
					if (getMethod != "")
					{
						var getter = createGetterFunction(getMethod, t, field.pos);
						createField(getter, fields);
					}
					if (setMethod != "")
					{
						var setter = createSetterFunction(setMethod, t, field.pos);
						createField(setter, fields);
					}
				}

		}
	}

	function addConcretePropertyMetadata(field:Field)
	{
		var isVar = false;
		for (meta in field.meta)
		{
			if (meta.name == ":isVar")
			{
				isVar = true;
				break;
			}
		}

		if (!isVar)
		{
			field.meta.push({pos:field.pos, params:[], name:":isVar"});
		}
	}

	/**
		Generates a stub setter function when mocking a FProp on an interface
	*/
	function createSetterFunction(name:String, ret:ComplexType, pos:Position):Field
	{
		var arg = {
			value:null,
			type:ret,
			opt:false,
			name:"value"
		}
		var f = {
			ret: ret,
			params: [],
			expr: EReturn(EConst(CIdent("null")).at()).at(),
			args: [arg]
		}
		return {
			pos: pos,
			name: name,
			meta: [],
			kind: FFun(f),
			doc: null,
			access: [Access.APublic]
		}
	}

	/**
		Generates a stub getter function when mocking a FProp on an interface
	*/
	function createGetterFunction(name:String, ret:ComplexType, pos:Position ):Field
	{
		var f = {
			ret: ret,
			params: [],
			expr: EReturn(EConst(CIdent("null")).at()).at(),
			args: []
		}
		return {
			pos: pos,
			name: name,
			meta: [],
			kind: FFun(f),
			doc: null,
			access: [Access.APublic]
		}
	}

	function toGetterSetter(value:String):String
	{
		switch (value)
		{
			case "default", "null", "never": return "";
			case "dynamic": throw "Not implemented";
			default: return value;
		}
		return "";
	}

	/**
		Appends the fields required by the <code>mockatoo.Mock</code> interface
	*/
	function appendMockInterfaceFields(fields:Array<Field>):Array<Field>
	{
		var mockInterface = Context.getType("mockatoo.Mock");

		switch (mockInterface)
		{
			case TInst(t,_):
				var mockFields = ClassFields.getClassFields(t.get(), false);

				for (field in mockFields)
				{
					fields.push(field);
				}
			default:null;
		}

		return fields;
	}

	/**
		Override an existing constructor, ensuring super call occurs after return
	*/
	function overrideConstructor(field:Field, f:Function)
	{
		hasConstructor = true;

		f.ret = null; //remove Void return type from constructor.
		field.access.remove(APublic);
		field.access.remove(APrivate);
		field.access.push(APublic);

		var eMockConstructorExprs = createMockConstructorExprs();
		var eReturn = isSpy ? eNull : EReturn().at();
		var e = EConst(CIdent("super")).at();

		if (f.args.length == 0)
		{
			e = e.call();
		}
		else 
		{
			var args:Array<Expr> = [];

			for (arg in f.args)
			{
				Console.log(arg);
				var argExpr = arg.type.getDefaultValue();
				args.push(argExpr);
			}
			e = e.call(args);

			//remove super arg paramaters from constructor
			f.args = [];
		}

		var spyArg = {
			value: EConst(CIdent("false")).at(),
			type: TPath({sub:null,params:[],pack:[],name:"Bool"}),
			opt:true,
			name:"spy"
		}

		f.args.push(spyArg);

		//deliberately call return before call to super
		//to prevent target class constructor being executed
		var exprs:Array<Expr> = [eMockConstructorExprs,eReturn, e];
		f.expr = EBlock(exprs).at();
	}

	function createMockConstructorExprs()
	{
		return macro mockProxy = new mockatoo.internal.MockProxy(this,spy);
	}

	/**
		Override an existing field, normalising return types and generating default values
	*/
	function overrideField(field:Field, f:Function)
	{
		if (!isInterface)
			field.access.unshift(AOverride);

		var args:Array<Expr> = [];

		for (arg in f.args)
		{
			arg.type = normaliseComplexType(arg.type);
			args.push(macro cast $i{arg.name});
		}
		
		var eMockOutcome = createMockFieldExprs(field, args);
		var eCaseReturns = macro mockatoo.internal.MockOutcome.returns(v);
		var eCaseThrows = macro mockatoo.internal.MockOutcome.throws(v);
		var eCaseCalls = macro mockatoo.internal.MockOutcome.calls(v);
		var eCaseStubs = macro mockatoo.internal.MockOutcome.stubs;
		var eCaseReal = macro mockatoo.internal.MockOutcome.callsRealMethod;
		var eCaseNone = macro mockatoo.internal.MockOutcome.none;

		var eArgs = EArrayDecl(args).at(); //reference to args

		var eIsSpy = macro mockProxy.spy;

		var eSwitch:Expr = null;

		if (f.ret == null || isNotVoid(f.ret))
		{
			if(f.ret != null)
				f.ret = normaliseComplexType(f.ret);

			Console.log(field.name + ":" + Std.string(f.ret));
		
			var eDefaultReturnValue = f.ret.getDefaultValue(); //default return type (usually 'null')

			var eSuper =  ("super." + field.name).toFieldExpr().call(args);

			if (isInterface)
				eSuper = eDefaultReturnValue;

			var eIf:Expr = macro $eIsSpy ? $eSuper : $eDefaultReturnValue;

			eSwitch = macro switch ($eMockOutcome)
			{
				case $eCaseReturns: return v;
				case $eCaseThrows: throw v;
				case $eCaseCalls: 
					var args:Array<Dynamic> = $eArgs;
					return v(args);
				case $eCaseStubs: return $eDefaultReturnValue;
				case $eCaseReal: return $eSuper;
				case $eCaseNone: return $eIf;
			}
		}
		else if (isVoidVoid(f.ret))
		{	
			var eReturn = macro function(){};

			var eSuper =  ("super." + field.name).toFieldExpr().call(args);

			if (isInterface)
				eSuper = eReturn;

			var eIf:Expr = macro $eIsSpy ? $eSuper : $eReturn;

			eSwitch = macro switch ($eMockOutcome)
			{
				case $eCaseReturns: return v;
				case $eCaseThrows: throw v;
				case $eCaseCalls: 
					var args:Array<Dynamic> = $eArgs;
					return v(args);
				case $eCaseStubs: return $eReturn;
				case $eCaseReal: return $eSuper;
				default: return $eIf;
			}
		}
		else
		{
			var eSuper =  ("super." + field.name).toFieldExpr().call(args);

			if (isInterface)
				eSuper = eNull;

			var eIf:Expr = macro $eIsSpy ? $eSuper : $eNull;

			eSwitch= macro switch ($eMockOutcome)
			{
				case $eCaseThrows: throw v;
				case $eCaseCalls: 
					var args:Array<Dynamic> = $eArgs;
					v(args);
				case $eCaseStubs: $eNull;
				case $eCaseReal: $eSuper;
				default: $eIf;
			}
		}

		f.expr = createBlock([eSwitch]);

		field.kind = FFun(f);

		var meta = createMockFieldMeta(field, f);
		field.meta.push(meta);
		
		//validate optional args
		for (arg in f.args)
		{
			if (!arg.opt) continue;

			Console.log(arg.name + ":" + arg.type.toString());
		}
	}

	/*
		Returns true if complex type is Void ->Void
	*/
	function isVoidVoid(type:ComplexType):Bool
	{
		if (type != null)
		{
			switch (type)
			{
				case TFunction(args,ret): 
					if (args.length == 0 && !isNotVoid(ret))
					{
						return true;
					}
				case _:
					return false;
			}
		}
		return false;
	}
 
	function updateVoidVoid(type:ComplexType):ComplexType
	{
		if (!isVoidVoid(type)) return type;

		var tpath = TPath({
			sub:null,
			name:"Void",
			params: [],
			pack:[]
		});

		switch (type)
		{
			case TFunction(fargs,fret):
				fargs.push(tpath);

				return TFunction(fargs,fret);
			case _:
		}
		return type;
	}

	function createMockFieldExprs(field:Field, args:Array<Expr>):Expr
	{
		var eArgs = EArrayDecl(args).at(); //reference to args
		var eName = EConst(CString(field.name)).at(); //name of current method

		return macro mockProxy.getOutcomeFor(${eName}, ${eArgs});
	}
		
	function normaliseComplexType(complexType:ComplexType):ComplexType
	{
		if(complexType == null) return null;

		var typePath:TypePath = switch (complexType)
		{
			case TPath(p): p;
			case TAnonymous(fields):
				// need to ignore inferred struct in flash or it will cause error
				// 'overloads parent class with different or incomplete type'
				return null;
			default: null;
		}

		if (typePath == null) return complexType;

		if(typePath.params != null && typePath.params.length > 0)
		{
			for(i in 0...typePath.params.length)
			{
				var param = typePath.params[i];
				typePath.params[i] = switch(param)
				{
					case TPType(t): 
						switch(t)
						{
							case TAnonymous(fields): param;
							case _: TPType(normaliseComplexType(t));
						}
					case TPExpr(e): param;
				}
			}
		}

		if (typePath.name == "StdTypes")
		{
			typePath.name = typePath.sub;
			typePath.sub = null;
			complexType = TPath(typePath);
		}
		else if (typePath.sub != null)
		{
			var lazy = toPrivateComplexType(typePath);
			if (lazy != null)
				complexType = lazy;
		}
		return complexType;
	}

	function toPrivateComplexType(typePath:TypePath):ComplexType
	{
		var module = typePath.pack.concat([typePath.name]).join(".");
		
		for (type in Context.getModule(module))
		{
			var baseType:BaseType = switch (type)
			{
				case TInst(t,p): t.get();
				case TEnum(t,p): t.get();
				case TType(t,p): t.get();
				case _: null;
			}

			if (baseType != null && baseType.name == typePath.sub && baseType.isPrivate)
			{
				Console.log("! " + Std.string(type));
				return type.toLazyComplexType();
			}
		}
		
		return null;

	}

	/**
		Creates a @mock metadata value for the field that is used at runtime
		by MockProxy and MockMethod

		Inclues
			- arguments as qualified types (optional args prefixed with '?')
			- default argument values (usually null, may differ on static targets)'
			- return type (if applicable)

		For example: 
		
			@mock(["String", "?foo.Bar"], [null,null], returns.Something)
	*/
	function createMockFieldMeta(field:Field, f:Function)
	{
		var args:Array<Expr> = [];

		for (functionArg in f.args)
		{
			Console.log(functionArg);

			var value = functionArg.opt ? "?" : "";

			if (functionArg.type != null)
				value += functionArg.type.toString();
	
			args.push(macro $v{value});
		}

		var mockParams:Array<Expr> = [EArrayDecl(args).at()];

		if (f.ret != null && isNotVoid(f.ret))
		{
			var ident = f.ret.toString();
			mockParams.push(macro $v{ident});
		}
		else if (isVoidVoid(f.ret))
		{
			//is of type Void->Void
			var voidType = updateVoidVoid(f.ret);
			var ident = normaliseComplexType(voidType).toString();
			mockParams.push(macro $v{ident});
		}

		return {
			pos:Context.currentPos(),
			name:"mockatoo",
			params:mockParams
		};
	}

	function isNotVoid(type:ComplexType):Bool
	{
		var s = type.toString();

		return s != "Void" && s != "StdTypes.Void";
	}

	/**
		Returns an empty block expression.
	*/
	function createBlock(?args:Array<Expr>=null):Expr
	{
		if (args == null) args = [];
		var exprs = EBlock(args).at();
		return exprs;
	}

	/**
		Returns an empty constructor field.
	*/
	function createEmptyConstructor():Field
	{	
		var constructorExprs = createMockConstructorExprs();
		var exprs = EBlock([constructorExprs]).at();

		var arg = {
			value: EConst(CIdent("false")).at(),
			type: TPath({sub:null,params:[],pack:[],name:"Bool"}),
			opt:true,
			name:"spy"
		}

		var f:Function = {
			args: [arg],
			ret: null,
			params: [],
			expr: exprs
		}

		return 
		{
			pos:Context.currentPos(),
			name:"new",
			meta:[],
			kind:FFun(f),
			doc:null,
			access:[APublic]
		}
	}
}

#end

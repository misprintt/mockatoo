package mockatoo.macro;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import tink.macro.tools.MacroTools;
import tink.macro.tools.Printer;
import tink.macro.tools.ExprTools;
import tink.macro.tools.TypeTools;
import tink.macro.tools.FunctionTools;
import tink.core.types.Outcome;
import mockatoo.Mock;
import mockatoo.macro.ClassFields;
import mockatoo.internal.MockOutcome;

#if haxe3
import haxe.ds.StringMap;
#else
private typedef StringMap<T> = Hash<T>
typedef TypeParamDecl = {
	var name : String;
	@:optional var constraints : Array<ComplexType>;
	// @:optional var params : Array<TypeParamDecl>;
}
#end

using tink.macro.tools.Printer;
using tink.macro.tools.ExprTools;
using tink.macro.tools.TypeTools;
using tink.core.types.Outcome;

using mockatoo.macro.Types;
using haxe.macro.Tools;

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
		actualType = type.reduce();
		
		Console.log(type);
		Console.log(actualType);

		params = [];

		if(paramTypes != null && isNotNull(paramTypes))
		{
			switch(paramTypes.expr)
			{
				case EArrayDecl(values):

					for(value in values)
					{
						var ident = Printer.print(value);
						Console.log("  param: " + ident);
						params.push(Context.getType(ident));
					}

				default: throw "invalid param [" + Printer.print(paramTypes) + "]";
			}
		}

		switch(actualType)
		{
			case TAnonymous(a):
				createMockFromStruct(a.get().fields);
			case TInst(_,_):
				id = actualType.getID().split(".").pop();
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
		if(generatedExpr == null)
		{
			var typeParams = untyped TypeTools.paramsToComplex(params);
			var eIsSpy = EConst(CIdent(Std.string(isSpy))).at();
			generatedExpr = ExprTools.instantiate(typeDefinitionId, [eIsSpy], typeParams, pos);
		}

		Console.log(Printer.print(generatedExpr));
		return generatedExpr;	
	}

	function toComplexType(type:Type):ComplexType
	{
		#if haxe3
		return type.toComplexType();
		#else
		return type.toComplex(true);
		#end
	}
	/**
	Generates a dynamic object matching a TypeDef structure
	*/
	function createMockFromStruct(fields:Array<ClassField>)
	{
		var args:Array<{ field : String, expr : Expr }> = [];

		var arg:{ field : String, expr : Expr };

		for(field in fields)
		{
			Console.log(field.name);
			arg = {field:field.name, expr:null};

		
			switch(field.type)
			{
				case TInst(_,_):
					arg.expr = toComplexType(field.type).defaultValue();
				case TType(_,_):
					arg.expr = toComplexType(field.type).defaultValue();
				case TEnum(_,_):
					arg.expr = toComplexType(field.type).defaultValue();					
				case TFun(functionArgs, ret):
					var e = toComplexType(field.type).defaultValue();
					var fargs:Array<FunctionArg> = [];

					for(a in functionArgs)
					{

						fargs.push(FunctionTools.toArg(a.name, toComplexType(a.t) ,a.opt));
					}

					var f = FunctionTools.func(e, fargs, toComplexType(ret), [], true);
					arg.expr = EFunction(null, f).at();

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
		
		switch(actualType)
		{
			case TInst(t, typeParams):
				classType = t.get();

				if(params.length == 0)
					params = typeParams;

			default: throw "not implementend";
		}

		if(mockedClassMap.exists(id))
		{
			typeDefinitionId = mockedClassMap.get(id);
			Console.log("existing: " + id + ", " + typeDefinitionId);
			return;
		}

		isInterface = classType.isInterface;

		if(isInterface) isSpy = false;
		
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
		switch(expr.expr)
		{
			case EConst(c):
				switch(c)
				{
					case CIdent(id):
						if(id == "null") return false;
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
		
		for(i in 0...classType.params.length)
		{
			var param = classType.params[i];

			var constraints:Array<ComplexType> = [];
			switch(param.t)
			{
				case TInst(t,_):
				{
					switch(t.get().kind)
					{
						#if haxe3
						case ClassKind.KTypeParameter(constrnts):
							for(const in constrnts)
							{
								var complexParam = const.toComplex(true);
								constraints.push(complexParam);
							}
						#else
						case ClassKind.KTypeParameter:
							if( t.get().interfaces.length > 0 && params[i] != null)
								constraints.push(toComplexType(params[i]));//issue #12 - support typed constraints
						#end
						default:
					}
				}
				default: null;
			}

			#if haxe3
			paramTypes.push({name:param.name, constraints:constraints, params:[]});
			#else
			paramTypes.push({name:param.name, constraints:constraints});
			#end
			
		}

		var extendId = classType.module + "." + classType.name;

		Console.log("paramTypes:" + paramTypes);
		Console.log("super params:" + classType.params);

		var a:Array<Type> = [];
		for(p in classType.params)
		{
			a.push(p.t);
		}
		var typeParams:Array<TypeParam> = untyped TypeTools.paramsToComplex(a);

		Console.log(typeParams);

		typeParams = removeTypedConsraintsFromTypeParams(typeParams);

		Console.log(typeParams);

		extendTypePath = TypeTools.asTypePath(extendId, typeParams);

		Console.log(extendTypePath);

		var kind = createKind();

		var fields = createFields();

		if(isInterface || !hasConstructor)
			fields.unshift(createEmptyConstructor());

		var metas = updateMeta(classType.meta.get());

		if(Context.defined("flash"))
		{
			var skip = false;
			for(m in metas)
			{
				if(m.name == ":hack")
				{
					skip = true;
					break;
				}
			}

			if(skip)
			{
				Context.error("Cannot mock final class [" + id + "] on flash target.", Context.currentPos());
				return null;
			}
		}

		var eProps:Array<Expr> = [];

		for(prop in propertyMetas)
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
		}
	}

	/**
	Hack to remove the constraints from super class type params to ensure type definition
	can compile.
	*/
	function removeTypedConsraintsFromTypeParams(types:Array<TypeParam>):Array<TypeParam>
	{
		var temp:Array<TypeParam> = [];

		for(type in types)
		{
			switch(type)
			{
				case TPType(t):
					switch(t)
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
	
	#if haxe3
	function debugPrintClass()
	{
		var printer = new haxe.macro.Printer();
		var result = printer.printTypeDefinition(typeDefinition);
		Console.log(result);
	}

	#else
	function debugPrintClass()
	{
		var metas = typeDefinition.meta;
		var fields = typeDefinition.fields;
 
		var preview = "";
 
		for(meta in metas)
		{
			if(meta.name == "mockatoo")
			{
				preview += "@" + meta.name;
 
				if(meta.params.length > 0)
					preview += Printer.printExprList("",meta.params, ",");
 
				preview += "\n";
				break;
			}
		}

		preview += "class " + id + "Mocked " + (isInterface?"implements":"extends") + " " + id;
		preview += "\n{";

		for(field in fields)
		{
			for(meta in field.meta)
			{
				preview += "\n	@" + meta.name;

				if(meta.params.length > 0)
					preview += Printer.printExprList("",meta.params, ",");
			}

			preview += "\n	" + Printer.printField("	", field);
		}
		preview += "\n}";

		Console.log(preview);

	}
	#end


	function updateMeta(source:Metadata):Metadata
	{
		var metadata:Metadata = [];

		for(meta in source)
		{
			Console.log(meta.name + ":" + Printer.printExprList("", meta.params));

			switch(meta.name)
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
		var mockInterface = TypeTools.asTypePath("mockatoo.Mock");

		var extension:TypePath = null;
		var interfaces:Array<TypePath> = null;

		if(isInterface)
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

		for(field in superFields)
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

		switch(field.kind)
		{
			case FFun(f):

				if(field.name == "new")
				{
					overrideConstructor(field, f);
				}
				else
				{
					overrideField(field, f);
				}

				if(field.access.remove(AInline))
				{
					#if haxe3
						#if no_inline
							fields.push(field);
						#else
							Context.warning("Cannot mock inline method [" + id + "." + field.name + "]. Please set '--no-inline' compiler flag.", Context.currentPos());
						#end
					#else
						Context.warning("Cannot mock inline method [" + id + "." + field.name + "] please upgrade to Haxe 2.11 and set '--no-inline' compiler flag (See http://code.google.com/p/haxe/issues/detail?id=1231)", Context.currentPos());
					#end

					return;
					
				}

				if(Context.defined("flash"))
				{
					var skip = false;
					for(m in field.meta)
					{
						if(m.name == ":hack")
						{
							skip = true;
							break;
						}
					}

					if(skip)
						Context.warning("Cannot mock final method [" + id + "." + field.name + "] on flash target.", Context.currentPos());
					else
						fields.push(field);
				}
				else
				{
					fields.push(field);
				}
					
			case FVar(_,_):
				if(isInterface) fields.push(field);
			case FProp(get, set, t,_):

				var getMethod = toGetterSetter(get);
				var setMethod = toGetterSetter(set);

				if(getMethod != "" || setMethod != "")
					propertyMetas.push({name:field.name, set:setMethod, get:getMethod});

				if(isInterface) 
				{
					//force concrete property for getter setter
					addConcretePropertyMetadata(field);

					fields.push(field);


					// need to wrap complex types of Void->Void into Null<Void->Void>
					// when creating getter setters;
					if(isVoidVoid(t))
					{
						t = TPath({
							sub:null,
							name:"Null",
							params: [TPType(t)],
							pack:[]
						});
					}
			 
					if(getMethod != "")
					{
						var getter = createGetterFunction(getMethod, t, field.pos);
						createField(getter, fields);
					}
					if(setMethod != "")
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
		for(meta in field.meta)
		{
			if(meta.name == ":isVar")
			{
				isVar = true;
				break;
			}
		}

		if(!isVar)
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
			access: []
		}
	}


	/*
	Returns true if complex type is Void ->Void
	*/
	function isVoidVoid(type:ComplexType):Bool
	{
		switch(type)
		{
			case TFunction(args,ret): 
				if(args.length == 0 && StringTools.endsWith(TypeTools.toString(ret), "Void"))
				{
					return true;
				}
			case _:
				return false;
		}

		return false;
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
			access: []
		}
	}


	function toGetterSetter(value:String):String
	{
		switch(value)
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

		switch(mockInterface)
		{
			case TInst(t,_):
				var mockFields = ClassFields.getClassFields(t.get(), false);

				for(field in mockFields)
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

		if(f.args.length == 0)
		{
			e = e.call();
		}
		else 
		{
			var args:Array<Expr> = [];

			for(arg in f.args)
			{
				Console.log(arg);
				var argExpr = arg.type.defaultValue();
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
		f.expr = ExprTools.toBlock([eMockConstructorExprs,eReturn, e]);
	}

	function createMockConstructorExprs()
	{
		//create mockProxy instance
		var eThis =  EConst(CIdent("this")).at();
		var eSpy = EConst(CIdent("spy")).at();
		var eInstance = "mockatoo.internal.MockProxy".instantiate([eThis,eSpy]);
		return EConst(CIdent("mockProxy")).at().assign(eInstance);
	}

	/**
	Override an existing field, normalising return types and generating default values
	*/
	function overrideField(field:Field, f:Function)
	{
		if(!isInterface)
		field.access.unshift(AOverride);


		var args = getFunctionArgIdents(f);

		var eMockOutcome = createMockFieldExprs(field, args);
		var eCaseReturns = macro mockatoo.internal.MockOutcome.returns(v);
		var eCaseThrows = macro mockatoo.internal.MockOutcome.throws(v);
		var eCaseCalls = macro mockatoo.internal.MockOutcome.calls(v);
		var eCaseStubs = macro mockatoo.internal.MockOutcome.stubs;
		var eCaseReal = macro mockatoo.internal.MockOutcome.callsRealMethod;
		var eCaseNone = macro mockatoo.internal.MockOutcome.none;

		var eArgs = args.toArray(); //reference to args

		var eIsSpy = "mockProxy.spy".resolve();

		var eSwitch:Expr = null;

		if(f.ret != null && !StringTools.endsWith(TypeTools.toString(f.ret), "Void"))
		{
			f.ret = normaliseReturnType(f.ret);

			Console.log(field.name + ":" + Std.string(f.ret));
		
			var eDefaultReturnValue = f.ret.defaultValue(); //default return type (usually 'null')

			var eSuper =  ("super." + field.name).resolve().call(args);

			if(isInterface)
				eSuper = eDefaultReturnValue;


			var eIf:Expr = macro $eIsSpy ? $eSuper : $eDefaultReturnValue;

			eSwitch = macro switch($eMockOutcome)
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
		else if(isVoidVoid(f.ret))
		{	
			var eReturn = macro function(){};

			var eSuper =  ("super." + field.name).resolve().call(args);

			if(isInterface)
				eSuper = eReturn;

			var eIf:Expr = macro $eIsSpy ? $eSuper : $eReturn;

			eSwitch = macro switch($eMockOutcome)
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
			var eSuper =  ("super." + field.name).resolve().call(args);

			if(isInterface)
				eSuper = eNull;

			var eIf:Expr = macro $eIsSpy ? $eSuper : $eNull;

			eSwitch= macro switch($eMockOutcome)
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

		var fieldMeta = createMockFieldMeta(field, f);
		field.meta.push(fieldMeta);


		//validate optional args
		for(arg in f.args)
		{
			if(!arg.opt) continue;

			Console.log(arg.name + ":" + arg.type.toString());
		}
	}

	function updateVoidVoid(type:ComplexType):ComplexType
	{
		if(!isVoidVoid(type)) return type;

		var tpath = TPath({
			sub:null,
			name:"Void",
			params: [],
			pack:[]
		});

		switch(type)
		{
			case TFunction(fargs,fret):
				fargs.push(tpath);

				return TFunction(fargs,fret);
			case _:
		}
		return type;
	}

	function getFunctionArgIdents(f:Function)
	{
		var args:Array<Expr> = [];

		for(arg in f.args)
		{
			args.push(EConst(CIdent(arg.name)).at());
		}

		return args;
	}

	function createMockFieldExprs(field:Field, args:Array<Expr>):Expr
	{
		var eArgs = args.toArray(); //reference to args
		var eName = EConst(CString(field.name)).at(); //name of current method

		return "mockProxy.getOutcomeFor".resolve().call([eName, eArgs]);
	}
		

	function normaliseReturnType(ret:ComplexType)
	{
		var typePath:TypePath = switch(ret)
		{
			case TPath(p): p;
			default: null;
		}

		if(typePath == null) return ret;


		if(typePath.name == "StdTypes")
		{
			typePath.name = typePath.sub;
			typePath.sub = null;
			ret = TPath(typePath);
		}
		return ret;
	}

	/**
	Creates a @mock metadata value for the field
	E.g @mock([String, ?foo.Bar], ret)
	*/
	function createMockFieldMeta(field:Field, f:Function)
	{
		var args:Array<Expr> = [];
		for(arg in f.args)
		{
			Console.log(arg);

			var value:String = arg.opt ? "?" : "";

			//add the return type including if optional (?)
			if(arg.type != null)
			{
				// arg.type = updateVoidVoid(arg.type);
				var ident = normaliseReturnType(arg.type).toString();
				value += ident;
			}
			args.push(EConst(CString(value)).at());
		}

		var params:Array<Expr> = [args.toArray()];

		if(f.ret != null && !StringTools.endsWith(TypeTools.toString(f.ret), "Void"))
		{
			var ident = normaliseReturnType(f.ret).toString();
			params.push(EConst(CString(ident)).at());
		}
		else if(isVoidVoid(f.ret))
		{
			//is of type Void->Void
			var voidType = updateVoidVoid(f.ret);
			var ident = normaliseReturnType(voidType).toString();
			params.push(EConst(CString(ident)).at());
		}

		return
		{
			pos:Context.currentPos(),
			name:"mockatoo",
			params:params

		};
	}

	/**
	Returns an empty block expression.

	*/
	function createBlock(?args:Array<Expr>=null):Expr
	{
		if(args == null) args = [];
		var exprs = ExprTools.toBlock(args);
		return exprs;
	}

	/**
	Returns an empty constructor field.
	*/
	function createEmptyConstructor():Field
	{	
		var constructorExprs = createMockConstructorExprs();
		var exprs = ExprTools.toBlock([constructorExprs]);


		var arg = {
			value: EConst(CIdent("false")).at(),
			type: TPath({sub:null,params:[],pack:[],name:"Bool"}),
			opt:true,
			name:"spy"
		}

		var f:Function = FunctionTools.func(exprs, [arg], null, null, false);
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
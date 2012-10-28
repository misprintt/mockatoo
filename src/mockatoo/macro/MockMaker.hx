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

using tink.macro.tools.Printer;
using tink.macro.tools.ExprTools;
using tink.macro.tools.TypeTools;
using tink.core.types.Outcome;


#if !haxe_211
typedef TypeParamDecl = {
	var name : String;
	@:optional var constraints : Array<ComplexType>;
	//@:optional var params : Array<TypeParamDecl>;
}

#end

/**
Macro class that generates a Mock implementation of a class or interface
*/
class MockMaker
{
	static var mockedClassHash:Hash<String> = new Hash();

	var expr:Expr;
	var pos:Position;
	var id:String;
	var type:Type;
	var actualType:Type;

	var classType:ClassType;
	var params:Array<Type>;

	var isInterface:Bool;

	var extendTypePath:TypePath;

	var typeDefinition:TypeDefinition;
	var typeDefinitionId:String;

	var hasConstructor = false;

	var generatedExpr:Expr;

	public function new(e:Expr, ?paramTypes:Expr)
	{
		expr = e;
		id = e.toString();

		pos = e.pos;

		type = Context.getType(e.toString());
		actualType = type.reduce();

		trace(id);
		trace(type);
		trace(actualType);

		params = [];

		if(paramTypes != null && isNotNull(paramTypes))
		{
			switch(paramTypes.expr)
			{
				case EArrayDecl(values):

					for(value in values)
					{
						var ident = Printer.print(value);
						params.push(Context.getType(ident));
					}

				default: throw "invalid param [" + Printer.print(paramTypes) + "]";
			}
		}


		switch(actualType)
		{
			case TAnonymous(a):
				createMockFromStruct(a.get().fields);
			case TInst(t, params):
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
			generatedExpr = ExprTools.instantiate(typeDefinitionId, null, typeParams, pos);
		}

		trace(Printer.print(generatedExpr));
		return generatedExpr;	
		
	}

	function createMockFromStruct(fields:Array<ClassField>)
	{
		var args:Array<{ field : String, expr : Expr }> = [];

		var arg:{ field : String, expr : Expr };

		for(field in fields)
		{
			trace(field.name);
			arg = {field:field.name, expr:null};

			switch(field.type)
			{
				case TInst(t, tparams):
					arg.expr = getDefaultValueForType(field.type.toComplex(true));
				case TType(t, tparams):
					arg.expr = getDefaultValueForType(field.type.toComplex(true));
				case TEnum(t, tparams):
					arg.expr = getDefaultValueForType(field.type.toComplex(true));
				case TFun(functionArgs, ret):
					var e = getDefaultValueForType(field.type.toComplex(true));
					var fargs:Array<FunctionArg> = [];

					for(a in functionArgs)
					{
						fargs.push(FunctionTools.toArg(a.name, a.t.toComplex(true),a.opt));
					}

					var f = FunctionTools.func(e, fargs, ret.toComplex(true), [], true);
					arg.expr = EFunction(null, f).at();

				default: throw "Unsupported type [" + field.type + "] for field [" + field.name + "]";
			}

			args.push(arg);
		}
		generatedExpr = EObjectDecl(args).at(pos);
	}

	function createMockFromClass()
	{
		trace("expr: " + expr);
		trace("id: " + id);
		trace("type: " + type);
		trace("actual: " + actualType);

		switch(actualType)
		{
			case TInst(t, typeParams):
				classType = t.get();

				if(params.length == 0)
					params = typeParams;

			default: throw "not implementend";
		}

		if(mockedClassHash.exists(id))
		{
			typeDefinitionId = mockedClassHash.get(id);
			trace("existing: " + id + ", " + typeDefinitionId);
			return;
		}

		isInterface = classType.isInterface;

		trace("params: " + params);
		trace("class " +  classType.name);
		trace("   interface: " + isInterface);
		trace("   params: " + classType.params);
		trace("   pos: " + classType.pos);
		trace("   module: " + classType.module);

		typeDefinition = createTypeDefinition();
		typeDefinitionId = (typeDefinition.pack.length > 0 ? typeDefinition.pack.join(".")  + "." : "") + typeDefinition.name;

		debugPrintClass();

		Context.defineType(typeDefinition);

		mockedClassHash.set(id, typeDefinitionId);

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
		var paramTypes:Array<TypeParamDecl> = [];
		for(param in classType.params)
		{
			paramTypes.push({name:param.name, constraints:[]});
		}

		//trace(paramTypes);

		var a:Array<Type> = [];
		for(p in classType.params)
		{
			a.push(p.t);
		}
		var typeParams = untyped TypeTools.paramsToComplex(a);

		trace(typeParams);

		var extendId = classType.module + "." + classType.name;

		extendTypePath = TypeTools.asTypePath(extendId, typeParams);

		trace(extendTypePath);


		var kind = createKind();

		var fields = createFields();

		if(isInterface || !hasConstructor)
			fields.unshift(createEmptyConstructor());


		var metas = updateMeta(classType.meta.get());
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

		trace(preview);

	}

	function updateMeta(source:Metadata):Metadata
	{
		var metadata:Metadata = [];

		for(meta in source)
		{
			trace(meta.name + ":" + Printer.printExprList("", meta.params));

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

		
		//metadata.push({pos:Context.currentPos(), name:":extern", params:[]});

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
			trace(extendTypePath);
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
						#if haxe_211
							#if no_inline
								fields.push(field);
							#else
								Context.warning("Cannot mock inline method [" + id + "." + field.name + "]. Please set '--no-inline' compiler flag.", Context.currentPos());
							#end
						#else
							Context.warning("Cannot mock inline method [" + id + "." + field.name + "] please upgrade to Haxe 2.11 and set '--no-inline' compiler flag (See http://code.google.com/p/haxe/issues/detail?id=1231)", Context.currentPos());
						#end
						
					}
					else
					{
						fields.push(field);
					}
						
				case FVar(t, e):
					if(isInterface) fields.push(field);
				case FProp(get, set, t, e):
					if(isInterface) fields.push(field);
			}
		}

		fields = appendMockInterfaceFields(fields);
		
		return fields;
	}

	/**
	Appends the fields required by the <code>mockatoo.Mock</code> interface
	*/
	function appendMockInterfaceFields(fields:Array<Field>):Array<Field>
	{
		var mockInterface = Context.getType("mockatoo.Mock");

		switch(mockInterface)
		{
			case TInst(t, typeParams):
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
		var eReturn = EReturn().at();
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
				trace(arg);
				var argExpr = getDefaultValueForType(arg.type);
				args.push(argExpr);
			}
			e = e.call(args);

			//remove super arg paramaters from constructor
			f.args = [];
		}

		//deliberately call return before call to super
		//to prevent target class constructor being executed
		f.expr = ExprTools.toBlock([eMockConstructorExprs,eReturn, e]);
	}

	function createMockConstructorExprs()
	{
		//create mockProxy instance
		var eThis =  EConst(CIdent("this")).at();
		var eInstance = "mockatoo.internal.MockProxy".instantiate([eThis]);
		return EConst(CIdent("mockProxy")).at().assign(eInstance);
	}

	/**
	Override an existing field, normalising return types and generating default values
	*/
	function overrideField(field:Field, f:Function)
	{
		if(!isInterface)
		field.access.unshift(AOverride);

		if(f.ret != null && !StringTools.endsWith(TypeTools.toString(f.ret), "Void"))
		{

			f.ret = normaliseReturnType(f.ret);

			trace(field.name + ":" + Std.string(f.ret));


			
			var mockCall = createMockFieldExprs(field, f);
			var ereturn = EReturn(mockCall).at();
			f.expr = createBlock([ereturn]);
		}
		else
		{
			var mockCall = createMockFieldExprs(field, f, false);

			f.expr = mockCall;
		}

		field.kind = FFun(f);


		var fieldMeta = createMockFieldMeta(field, f);
		field.meta.push(fieldMeta);
	}

	function createMockFieldExprs(field:Field, f:Function, ?includeReturn:Bool=true):Expr
	{

		var args:Array<Expr> = [];

		for(arg in f.args)
		{
			args.push(EConst(CIdent(arg.name)).at());
		}

		var eArgs = args.toArray(); //reference to args
		var eName = EConst(CString(field.name)).at(); //name of current method
		
		if(includeReturn)
		{
			trace(f.ret.toString());

			var eDefaultReturnValue = getDefaultValueForType(f.ret); //default return type (usually 'null')
			trace("  " + eDefaultReturnValue.print());
			return "mockProxy.callMethodAndReturn".resolve().call([eName, eArgs, eDefaultReturnValue]);
		}
		else
		{
			return "mockProxy.callMethod".resolve().call([eName, eArgs]);
		}
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
			trace(arg);

			var value:String = arg.opt ? "?" : "";

			//add the return type including if optional (?)
			if(arg.type == null)
			{
				
			}
			else
			{
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

		return
		{
			pos:Context.currentPos(),
			name:"mockatoo",
			params:params

		};
	}

	/**
	Returns the default 'null' value for a type.

	On static platforms (Flash, CPP, Java, C#), basic types have their own default values :

	every Int is by default initialized to 0
	every Float is by default initialized to NaN on Flash9+, and to 0.0 on CPP, Java and C#
	every Bool is by default initialized to false
	*/
	function getDefaultValueForType(type:ComplexType):Expr
	{
		if(type == null)
			return EConst(CIdent("null")).at();

		var isStaticPlatform:Bool = false;
		var isFlash:Bool = false;

		var staticPlatforms = ["flash", "cpp", "java", "cs"];

		for(platform in staticPlatforms)
		{
			if(Context.defined(platform))
			{
				isStaticPlatform = true;

				if(platform == "flash") isFlash = true;
				break;
			}
		}

		if(isStaticPlatform)
		{
			switch(type)
			{
				case TPath(p):
				{
					if(p.pack.length != 0) return EConst(CIdent("null")).at();

					if(p.name == "StdTypes") p.name = p.sub;

					switch(p.name)
					{
						case "Bool":
							return EConst(CIdent("false")).at();
						case "Int":
							return EConst(CInt("0")).at();
						case "Float":
							if(isFlash)
								return "Math.NaN".resolve();
							else
								return EConst(CFloat("0.0")).at();
						default: null;
					}	
				}
				default: null;
			}
		}
		return EConst(CIdent("null")).at();
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
		var f:Function = FunctionTools.func(exprs, null, null, null, false);
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
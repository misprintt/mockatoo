package mockatoo;


import msys.File;
import msys.Directory;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import tink.macro.tools.MacroTools;
import tink.macro.tools.Printer;
import tink.macro.tools.ExprTools;
import tink.macro.tools.TypeTools;
import tink.macro.tools.FunctionTools;
import tink.core.types.Outcome;

using tink.macro.tools.Printer;
using tink.macro.tools.ExprTools;
using tink.macro.tools.TypeTools;
using tink.core.types.Outcome;


class MockCreator
{
	static public function createMock(e:Expr):Expr
	{
		var m = new MockCreator(e);
		return m.toExpr();
	}

	var expr:Expr;
	var pos:Position;
	var id:String;
	var type:Type;
	var actualType:Type;

	var classType:ClassType;
	var params:Array<Type>;

	var isInterface:Bool;

	var typeDefinition:TypeDefinition;
	var typeDefinitionId:String;


	public function new(e:Expr)
	{
		expr = e;
		id = e.toString();
		pos = e.pos;

		type = Context.getType(e.toString());
		actualType = type.reduce();

		id = actualType.getID().split(".").pop();

		trace("expr: " + expr);
		trace("id: " + id);
		trace("type: " + type);
		trace("actual: " + actualType);

		switch(actualType)
		{
			case TInst(t, params):
				classType = t.get();
				this.params = params; 

			default: throw "not implementend";
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

		Context.defineType(typeDefinition);

		if(type != actualType)
		{

		}
	}

	/**
	Returns the expr instanciating an instance of the mock
	*/
	public function toExpr():Expr
	{
		var typeParams = untyped TypeTools.paramsToComplex(params);
		var expr = ExprTools.instantiate(typeDefinitionId, null, typeParams, pos);

		// var args = typeDefinitionId.resolve();
		// var expr = "Std.Type".resolve(); 
		// 				.field("createEmptyInstance")
		// 				.call([args]);

		trace(Printer.print(expr));

		return expr;
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
		var paramTypes:Array<{name:String, constraints:Array<ComplexType>}> = [];

		for(param in classType.params)
		{
			paramTypes.push({name:param.name, constraints:[]});
		}

		//trace(paramTypes);

		var kind = createKind();

		var fields = createFields();

		if(isInterface)
			fields.unshift(createEmptyConstructor());

		trace(Printer.printFields("", fields));

		return {
			pos: Context.currentPos(),
			params: paramTypes,
			pack: classType.pack,
			name: id + "Mocked",
			meta: classType.meta.get(),
			kind: kind,
			isExtern:false,
			fields:fields
		}
	}

	/**
	Creates the typeDefinition kind that extends the target class
	*/
	function createKind()
	{
		var a:Array<Type> = [];
		for(p in classType.params)
		{
			a.push(p.t);
		}
		var typeParams = untyped TypeTools.paramsToComplex(a);

		trace(typeParams);

		var extendId = classType.module + "." + classType.name;

		var extendPath = TypeTools.asTypePath(extendId, typeParams);

		trace(extendPath);

		var mockInterface = TypeTools.asTypePath("mockatoo.Mock");

		var extension:TypePath = null;
		var interfaces:Array<TypePath> = null;

		if(isInterface)
		{
			interfaces = [extendPath, mockInterface];
		}
		else
		{
			extension = extendPath;
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

		var superFields = util.ClassFields.getClassFields(classType);
		
		for(field in superFields)
		{
			switch(field.kind)
			{
				case FFun(f):

					if(field.name == "new")
					{
						f.ret = null; //remove Void return type from constructor.

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
						f.expr = ExprTools.toBlock([eReturn, e]);
						
					}
					else
					{
						if(!isInterface)
							field.access.push(AOverride);

						if(f.ret != null && !StringTools.endsWith(TypeTools.toString(f.ret), "Void"))
						{
							var eref = getDefaultValueForType(f.ret);
							var ereturn = EReturn(eref).at(null);
							f.expr = ExprTools.toBlock([ereturn]);
						}
						else
						{
							f.expr = createEmptyBlock();
						}
					}					
					fields.push(field);
				case FVar(t, e):
					null;
				case FProp(get, set, t, e):
					null;
			}
		}
		return fields;
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
								return EConst(CIdent("NaN")).at();
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
	function createEmptyBlock():Expr
	{
		var exprs = ExprTools.toBlock([]);
		return exprs;
	}

	/**
	Returns an empty constructor field.
	*/
	function createEmptyConstructor():Field
	{	
		var exprs = createEmptyBlock();
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
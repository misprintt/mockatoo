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

using tink.macro.tools.Printer;
using tink.macro.tools.ExprTools;
using tink.macro.tools.TypeTools;

class Mockatoo
{
	@:macro static public function mock<T>(e:ExprOf<Class<T>>):ExprOf<T>
	{
		init();
		return MockCreator.createMock(e);
	}

	#if macro

	public static var TEMP_DIR:String = ".temp/mockatoo/";
	static var initialized = false;

	static function init()
	{
		if (initialized) return;

		initialized = true;
		
		Directory.create(TEMP_DIR);

		Console.addPrinter(new FilePrinter(TEMP_DIR + "mockatoo.log"));

		Console.start();
		Console.removePrinter(Console.defaultPrinter);
	}

	#end
}

#if macro

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

		trace("params: " + params);
		trace("class " +  classType.name);
		trace("   params: " + classType.params);
		trace("   pos: " + classType.pos);
		trace("   module: " + classType.module);

		typeDefinition = createTypeDefinition();

		typeDefinitionId = (typeDefinition.pack.length > 0 ? typeDefinition.pack.join(".")  + "." : "") + typeDefinition.name;

		Context.defineType(typeDefinition);
	}

	/**
	Returns the expr instanciating an instance of the mock
	*/
	public function toExpr():Expr
	{
		var typeParams = untyped TypeTools.paramsToComplex(params);

		//trace(typeParams);

		var expr = ExprTools.instantiate(typeDefinitionId, null, typeParams, pos);

		trace(Printer.print(expr));

		return expr;
	}

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

		//trace(Printer.printFields("", fields));

		return {
			pos: Context.currentPos(),
			params: paramTypes,
			pack: classType.pack,
			name: "__" + id + "Mock",
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


		var interfaces:Array<TypePath> = [TypeTools.asTypePath("mockatoo.Mock")];
		
		var kind:TypeDefKind = TDClass(

			extendPath,
			interfaces,
			false
			);

		return kind;
	}

	/**
	Overrides all functions defined in the target class (i.e. super class).
	Also cleans up constructor to call super and to not return Void
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

						var e = EConst(CIdent("super")).at(null);
						f.expr = ExprTools.toBlock([ExprTools.call(e)]);
					}
					else
					{
						field.access.push(AOverride);

						if(f.ret != null && !StringTools.endsWith(TypeTools.toString(f.ret), "Void"))
						{
							trace(untyped f.ret);

							//var evar = ExprTools.define("ret", null, f.ret, null);
							//var eref = EConst(CIdent("ret")).at(null);
							var eref = EConst(CIdent("null")).at(null);
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

	function createEmptyBlock():Expr
	{
		var exprs = ExprTools.toBlock([]);
		return exprs;

	}

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

class FilePrinter extends mconsole.FilePrinter
{
	var currentClass:String;
	var currentMethod:String; 

	public function new(path:String)
	{
		File.remove(path);
		super(path);
	}
}

#end
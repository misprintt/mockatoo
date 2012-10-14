package ;

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
		return MockCreator.createMock(e);
		
	}
}

#if macro

class MockCreator
{
	static var idCount = 0;

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

		trace(expr);
		trace(id);
		trace(type);
		trace(actualType);

		switch(actualType)
		{
			case TInst(t, params):
				classType = t.get();
				this.params = params; 

			default: throw "not implementend";
		}

		trace(params);

		trace(classType.name);
		trace(classType.params);
		trace(classType.pos);
		trace(classType.module);

		typeDefinition = createTypeDefinition();

		typeDefinitionId = (typeDefinition.pack.length > 0 ? typeDefinition.pack.join(".")  + "." : "") + typeDefinition.name;


		Context.defineType(typeDefinition);


		var mockType = Context.getType(typeDefinitionId);

		trace(mockType);


		var c = mockType.toComplex(true);

		trace(Printer.printType("",c));
		//trace(typeDefinition);
	}

	/**
	Returns the expr instanciating an instance of the mock
	*/
	public function toExpr():Expr
	{
		//return original type ident
		//var exprDef = EConst(CIdent(id));
		//return exprDef.at(expr.pos);

		//return instance of original type
		//var typeParams = untyped TypeTools.paramsToComplex(params);
		//return ExprTools.instantiate(classType.name, null, typeParams, pos);


		var typeParams = untyped TypeTools.paramsToComplex(params);

		trace(typeParams);

		var expr = ExprTools.instantiate(typeDefinitionId, null, typeParams, pos);

		trace(Printer.print(expr));

		return expr;
	}

	function createTypeDefinition():TypeDefinition
	{
		var paramTypes:Array<{name:String, constraints:Array<ComplexType>}> = [];

		for(param in classType.params)
		{
			trace(param);
			paramTypes.push({name:param.name, constraints:[]});
		}

		trace(paramTypes);

		var kind = createKind();

		var fields = createFields();

		trace(Printer.printFields("", fields));

		var pack = classType.module.split(".");
		//pack.push(id);

		pack = id.split(".");

		return {
			pos: Context.currentPos(),
			params: paramTypes,
			pack: classType.pack,
			name: "__" + id + "Mock",//+ Std.string(idCount ++),
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

		trace(type.getID());

		var extendId = classType.module + "." + classType.name;

		var extendPath = TypeTools.asTypePath(extendId, typeParams);

		trace(extendPath);
		var kind:TypeDefKind = TDClass(

			extendPath,
			null,
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

#end
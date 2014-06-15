package mockatoo;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import mockatoo.exception.VerificationException;
import mockatoo.exception.StubbingException;
import mockatoo.Mockatoo;
import mockatoo.Mock;
import test.TestClasses;
import util.Asserts;
import haxe.ds.StringMap;

import mockatoo.Mockatoo.*;
using mockatoo.Mockatoo;

class MockatooStdTest 
{
	public function new() 
	{
		
	}
	
	// ------------------------------------------------------------------------- mocking

	@Test
	public function should_mock_http():Void
	{
		var mock = Mockatoo.mock(haxe.Http);
		assertMock(mock);
	}

	@Test
	public function should_mock_haxe_Template():Void
	{
		var mock = Mockatoo.mock(haxe.Template);
		assertMock(mock);
	}

	@Test
	public function should_mock_List():Void
	{
		var mock = Mockatoo.mock(List);
		assertMock(mock);
	}

	@Test
	public function should_mock_posInfos():Void
	{
		var mock = Mockatoo.mock(haxe.PosInfos);
		Assert.isNotNull(mock);
	}

	macro static public function mockType(type:haxe.macro.Expr, ?args:haxe.macro.Expr):haxe.macro.Expr
	{
		var e = macro Mockatoo.mock($type, $args);
		e.pos = type.pos;
		e = macro assertMock($e);
		e.pos = type.pos;
		return e; 
	}

	macro static public function mockTypedef(type:haxe.macro.Expr, ?args:haxe.macro.Expr):haxe.macro.Expr
	{
		var e = macro Mockatoo.mock($type, $args);
		e.pos = type.pos;
		e = macro Assert.isNotNull($e);
		e.pos = type.pos;
		return e; 
	}

	@Test
	public function should_mock_std_classes()
	{
		mockType(haxe.Http);
		mockType(haxe.Template);
		mockType(List, [Int]);
		mockType(haxe.Serializer);
		mockType(haxe.Unserializer);
		mockType(haxe.Timer);
		mockTypedef(haxe.PosInfos);

		mockType(haxe.zip.Writer);
		mockType(haxe.zip.Reader);

		mockType(haxe.xml.Fast);

		mockType(haxe.web.Dispatch);

		#if !(flash || cpp || java || cs)
		mockType(haxe.web.Request);
		#end

		mockType(haxe.unit.TestCase);
		mockType(haxe.unit.TestResult);
		mockType(haxe.unit.TestRunner);
		mockType(haxe.unit.TestStatus);

		mockType(haxe.rtti.XmlParser);

		mockType(haxe.remoting.AMFConnection);
		mockType(haxe.remoting.AsyncAdapter);
		mockType(haxe.remoting.AsyncConnection);
		mockType(haxe.remoting.AsyncDebugConnection);
		// mockType(haxe.remoting.AsyncProxy, [String]);

		mockType(haxe.io.BufferInput);
		mockType(haxe.io.Bytes);
		mockType(haxe.io.BytesBuffer);
		mockType(haxe.io.BytesInput);
		mockType(haxe.io.Eof);
		mockType(haxe.io.Input);
		mockType(haxe.io.Output);
		mockType(haxe.io.Path);
		mockType(haxe.io.StringInput);

		mockType(haxe.ds.BalancedTree);
		mockType(haxe.ds.EnumValueMap);
		// mockType(haxe.ds.GenericStack, [Int]);

		#if (haxe_ver >= 3.1)
		mockType(haxe.crypto.Adler32);
		mockType(haxe.crypto.Base64);
		mockType(haxe.crypto.BaseCode);
		mockType(haxe.crypto.Crc32);
		mockType(haxe.crypto.Md5);
		mockType(haxe.crypto.Sha1);
		#end
	}



	// ------------------------------------------------------------------------- utilities

	function assertMock(mock:Mock, ?pos:haxe.PosInfos)
	{
		Assert.isTrue(Std.is(mock, Mock), pos);
	}
}

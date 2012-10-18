import mtask.target.HaxeLib;

class Build extends mtask.core.BuildBase
{
	public function new()
	{
		super();
	}

	@target function haxelib(t:HaxeLib)
	{
		t.description = "Haxe mocking framework";
		t.url = "http://github.com/misprintt/mockatoo";
		t.versionDescription = "First release. generate mock from class or interface. methods are just empty stubs for now.";
		
		t.addDependency("mconsole");
		t.addDependency("tink_macros");

		t.beforeCompile = function(path)
		{
			rm("src/haxelib.xml");
			cp("src/*", path);
		}
	}

	@task function sublime()
	{
		invoke("build haxelib");
		invoke("example");
		invoke("haxelibTest");
	}

	@task function haxelibTest()
	{
		cmd("haxelib", ["test", "bin/release/haxelib.zip"]);
	}

	@task function example()
	{
		msys.FS.cd("example", function(path){
			cmd("haxe", ["build.hxml"]);
		});
	}

	@task function test()
	{
		cmd("haxelib", ["run", "munit", "test", "-coverage"]);
	}

	@task function release()
	{
		invoke("clean");
		invoke("build haxelib");
		invoke("test");
		//invoke("example");

		invoke("haxelibTest");
	}
}

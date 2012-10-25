import mtask.target.HaxeLib;

class Build extends mtask.core.BuildBase
{
	public function new()
	{
		super();
	}

	@target function haxelib(t:HaxeLib)
	{
		t.description = "Mockatoo is a Haxe library for mocks creation, verification and stubbing.";
		t.url = "http://github.com/misprintt/mockatoo";
		t.versionDescription = "Mockatoo is a Haxe library for mocks creation, verification and stubbing. See http://github.com/misprintt/mockatoo for features, documentation and examples.";
		
		t.addDependency("mconsole");
		t.addDependency("tink_macros");

		t.beforeCompile = function(path)
		{
			rm("src/haxelib.xml");
			cp("src/*", path);
			cp("README.md", path);
		}
	}

	@task function sublime()
	{
		invoke("build haxelib");
		invoke("haxelibTest");
		invoke("example");
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

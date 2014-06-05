import mtask.target.HaxeLib;

class Build extends mtask.core.BuildBase
{
	public function new()
	{
		super();
	}

	@target function haxelib(t:HaxeLib)
	{
		t.description = "Mockatoo is a Haxe library for mock creation, verification and stubbing.";
		t.url = "http://github.com/misprintt/mockatoo";

		t.versionDescription = "See https://github.com/misprintt/mockatoo/blob/master/CHANGES.md";
		
		t.addDependency("mconsole");

		t.beforeCompile = function(path)
		{
			rm("src/haxelib.json");
			cp("src/*", path);
			cp("README.md", path);
		}
 
		t.afterCompile = function(path)
		{
			cp("bin/release/haxelib/haxelib.json", "src/haxelib.json");

			try
			{
				rm("src/haxelib.xml");	
				rm("bin/release/haxelib/haxelib.xml");	
			}
			catch(e:Dynamic)
			{

			}
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
		cmd("haxelib", ["local", "bin/release/haxelib.zip"]);
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
		cmd("haxelib", ["run", "munit", "report", "teamcity"]);
	}

	@task function release()
	{
		invoke("clean");
		invoke("build haxelib");
		invoke("test");
		//invoke("example");

		invoke("haxelibTest");
	}

	@task function teamcity()
	{
		invoke("clean");
		invoke("test");

		invoke("build haxelib");
		invoke("haxelibTest");
		invoke("example");
	}
}

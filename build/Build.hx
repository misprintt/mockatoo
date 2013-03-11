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

		t.versionDescription = "Fixed issue #14 - setter for property defined in interface is missing. This update is NOT Haxe 3 compatible (see feature/haxe3 on gitub for compatible branch). See CHANGES for full details.";
		
		t.addDependency("mconsole");
		t.addDependency("tink_macros");

		t.beforeCompile = function(path)
		{
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

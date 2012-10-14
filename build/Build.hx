import mtask.target.HaxeLib;

class Build extends mtask.core.BuildBase
{
	public function new()
	{
		super();
	}

	@target function haxelib(t:HaxeLib)
	{
		t.description = "A description of your library.";
		t.versionDescription = "Initial release.";
		
		// t.addDependency("library");

		t.afterCompile = function(path)
		{
			cp("src/*", path);
		}
	}

	@task function sublime()
	{
		invoke("example");
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
		cmd("haxe", ["run/build.hxml"]);
		invoke("build haxelib");
		invoke("test");
	}
}

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

		t.versionDescription = "Simplified, smarter, macro enhanced API when using 'using' mixin (and still fully backwards compatible with existing API).
<pre class=\"code\"><code class=\"haxe\">var mock = SomeClass.mock();
mock.someMethod().returns(\"foo\");
mock.someOtherMethod(\"foo\").throws(\"some error\");
mock.someMethod().verify(1);</code></pre>See updated documentation on github, and CHANGES for full details.";
		
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

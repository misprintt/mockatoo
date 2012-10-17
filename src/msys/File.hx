package msys;

#if neko

import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;
import haxe.io.Bytes;
import neko.Lib;

#if !haxe_209
import neko.Sys;
#end

// using mcore.util.Arrays;

class File
{
	public static var separator:String = Sys.getCwd().indexOf("\\") > 0 ? "\\" : "/";
	
	/**
	Returns the current working directory without a trailing slash
	@return string path to current working directory
	*/
	static public function getCwd():String
	{
		return File.nativePath(Sys.getCwd());
	}

	//------------------------------------------------------------------------- metadata

	/**
	Checks if the path exists on the file system. Returns true if the path is 
	either a file or a directory.

	@param path 	path to a file or directory
	@return true if exists
	*/
	public static function exists(path:String):Bool
	{
		Console.assert(path != null, "the argument 'path' cannot be null");
		path = File.nativePath(path);
		return FileSystem.exists(path);
	}

	/**
	Returns the file or directory name without any leading directory

	@param path 	path to a file or directory
	@return name of file without directory
	*/
	public static function filename(path:String):String
	{
		Console.assert(path != null, "the argument 'path' cannot be null");
		path = File.nativePath(path);
		return haxe.io.Path.withoutDirectory(path);
	}

	/**
	Returns the parent directory
	
	@param path 	path to a file or directory
	@return string path to parent directory
	*/
	static public function parent(path:String):String
	{
		Console.assert(path != null, "the argument 'path' cannot be null");
		path = File.nativePath(path);

		var isRelative = isRelativePath(path);

		var parts = File.unixPath(path).split("/");
		parts.pop();

		path = File.nativePath(parts.join("/"));

		if (isRelative)
		{
			return absolutePath(path);
		}

		return path;
	}

	public static function append(path:String, subPath:String):String
	{
		Console.assert(path != null, "the argument 'path' cannot be null");
		Console.assert(subPath != null, "the argument 'subPath' cannot be null");

		Console.assert(!isAbsolutePath(subPath), "subPath '" + subPath + "'cannot be absolute path");
		Console.assert(!isRelativePath(subPath), "subPath '" + subPath + "'cannot be relative path");
		
		return nativePath(path + "/" + subPath);
	}

	//------------------------------------------------------------------------- path types

	/**
	Checks if the path exists and is a directory.

	@param path 	path to a file or directory
	@return true if exists and is directory
	*/
	public static function isDirectory(path:String):Bool
	{
		Console.assert(path != null, "the argument 'path' cannot be null");
		path = File.nativePath(path);
		return FileSystem.exists(path) && FileSystem.isDirectory(path);
	}

	/**
	Checks if the path exists and is a file.

	@param path 	path to a file or directory
	@return true if exists and is file
	*/
	public static function isFile(path:String):Bool
	{
		Console.assert(path != null, "the argument 'path' cannot be null");
		path = File.nativePath(path);
		return FileSystem.exists(path) && !FileSystem.isDirectory(path);
	}

	/**
	Returns true if the path is relative to the current working directory
	
	@param path 	path to a file or directory
	@return true if path starts with ./ or ../
	*/
	static public function isRelativePath(path:String):Bool
	{
		Console.assert(path != null, "the argument 'path' cannot be null");
		if (path == "." || path.indexOf("./") == 0 || path.indexOf("..") == 0) return true;
		return false;
	}

	/**
	Tests whether this pathname is absolute.
	The definition of absolute pathname is system dependent. On UNIX systems,
	a pathname is absolute if its prefix is "/". On Microsoft Windows systems,
	a pathname is absolute if its prefix is a drive specifier followed by "\\",
	or if its prefix is "\\".

	@param path 	file or directory path
	@return true if path is absolute
	*/
	public static function isAbsolutePath(path:String):Bool
	{
		if (path.indexOf("/")==0)
		{
			//absolute osx or linux path (e.g. \Users\Foo)
			return true;
		}
		else if (path.indexOf('\\\\') == 0)
		{
			return true;//windows network path (e.g. \\files\something)
		}
		else if (path.indexOf("\\") > 0 && path.indexOf(":") == 1)
		{
			//absolute win path (e.g. c:\something\path)
			return true;
		}
		return false;
	}

	/**
	Returns true if the paths are the same
	
	@param path 	path to a file or directory
	@return true if path starts with ./ or ../
	*/
	static public function equals(path1:String, path2:String):Bool
	{
		Console.assert(path1 != null, "the argument 'path1' cannot be null");
		Console.assert(path2 != null, "the argument 'path2' cannot be null");
		return absolutePath(path1) == absolutePath(path2);
	}


	//------------------------------------------------------------------------- path conversion

	/**
	returns platform appropriate slashes (doesn't force absolute)
	
	Used to prevent accidental combination of forward and back slashes on windows

	E.g. converts c:\foo/bar.txt to c:\foo\bar.txt

	Also converts File.unixPath back to original format

	@param path 	relative or absolute file or folder path
	@return updated path using native platform slashes
	*/
	public static function nativePath(path:String):String
	{
		Console.assert(path != null, "the argument 'path' cannot be null");
		var windowsNetworkPath : Bool = false;
		var windowsAbsolutePath: Bool = false;

		if (path == "/") return path;
		
		if (path.indexOf('\\\\') == 0)
		{
			windowsNetworkPath = true;
			path = path.substr(2);
		}

		var win = ~/^[A-Z]:/i;
		if (win.match(path))
		{
			windowsAbsolutePath = true;
		}

		var backslash = path.indexOf("\\");
		var forwardSlash = path.indexOf("/");

		var seperator:String = "/";

		var parts:Array<String> = null;

		if (windowsAbsolutePath || (backslash > -1 && (backslash < forwardSlash || forwardSlash == -1)))
		{
			seperator = "\\";
			parts = path.split("/");
		}
		else
		{
			parts = path.split("\\");
		}


		path = "";

		for (part in parts)
		{
			//keep escaped spaces "\ " on linux
			if (part.indexOf(" ") == 0) path += "\\";
			else if (path != "") path += seperator;
				
			path += part;
		}

		if (windowsNetworkPath)
			path = "\\\\" + path;
		
		var lastChar = path.charAt(path.length - 1);
		if (lastChar == "/" || lastChar == "\\")
		{
			path = path.substr(0, path.length - 1);
		}

		return path;
	}

	/**
	Coverts a path to unix format.
	For windows paths this will convert backslashes to forward slashes (e.g. c:/foo/something)
	
	@param path 	path to a file or directory
	@return string path using unix style forward slashes 
	*/
	static public function unixPath(path:String):String
	{
		Console.assert(path != null, "the argument 'path' cannot be null");
		path = File.nativePath(path);

		return path.split("\\").join("/");
	}

	/**
	Returns absolute path string 
	*/
	static public function absolutePath(path:String):String
	{
		Console.assert(path != null, "the argument 'path' cannot be null");
		path = nativePath(path);

		if (isAbsolutePath(path))
		{
			return path;
		}
		else if (isRelativePath(path))
		{
			var base = getCwd();

			var parts = unixPath(path).split("/");

			path = "";
			while (parts.length > 0)
			{
				var part = parts.pop();
				if (part == "..") base = parent(base);
				else if (part != ".")
				{
					if (path != "") path = "/" + path;
					path = part + path;
				}
			}
			return nativePath(base + "/" + path); 
		}
		else
		{
			return nativePath(getCwd() + "/" + path);
		}
	}

	static public function relativePath(fromPath:String, toPath:String):String
	{
		throw "Not implemented";
		return null;
	}


	/**
	Deletes the file or directory at path. Directory must be empty.
	To remove contents of directory use Directory.removeTree

	@param path 	file or directory to remove
	*/
	public static function remove(path:String)
	{
		Console.assert(path != null, "the argument 'path' cannot be null");
		path = File.nativePath(path);

		if (!exists(path)) return;

		if (isDirectory(path))
		{
			Console.assert(Directory.isEmpty(path), "the directory '" + path + "' is not empty");

			if (Directory.isEmpty(path))
			{
				FileSystem.deleteDirectory(path);
			}
		}
		else
		{
			FileSystem.deleteFile(path);
		}
	}

	/**
	Recursively copies files and directories from one path to another.

	@param fromPath 	source file or directory
	@param toPath 		destination file or directory
	*/
	public static function copy(fromPath:String, toPath:String)
	{
		Console.assert(fromPath != null, "the argument 'fromPath' cannot be null");
		Console.assert(toPath != null, "the argument 'toPath' cannot be null");

		fromPath = File.nativePath(fromPath);
		toPath = File.nativePath(toPath);

		Console.assert(exists(fromPath), "the source path '" + fromPath + "' does not exist.");

		if (isDirectory(fromPath))
		{
			if (exists(toPath))
			{
				Console.assert(isDirectory(toPath), "cannot copy a directory to '" + toPath + "' because is a file.");
			}
			else
			{
				Directory.create(toPath);
			}
			
			for (subPath in Directory.readDirectory(fromPath))
			{
				var fromSubPath = nativePath(fromPath + "/" + subPath);
				copy(fromPath + "/" + subPath, toPath + "/" + subPath);
			}
		}
		else
		{
			if (exists(toPath))
			{
				Console.assert(!isDirectory(toPath), "cannot copy a file to '" + toPath + "' because is a directory.");
			}

			var directory = haxe.io.Path.directory(toPath);
			if (!exists(directory)) Directory.create(directory);

			neko.io.File.copy(fromPath, toPath);
		}
	}

	/**
	Move a file or directory from one path to another.

	@param fromPath 	source file or directory
	@param toPath 		destination file or directory
	*/
	public static function move(fromPath:String, toPath:String)
	{
		Console.assert(fromPath != null, "the argument 'fromPath' cannot be null");
		Console.assert(toPath != null, "the argument 'toPath' cannot be null");

		fromPath = File.nativePath(fromPath);
		toPath = File.nativePath(toPath);

		Console.assert(exists(fromPath), "the source path '" + fromPath + "' does not exist.");
		Console.assert(!exists(toPath), "the source path '" + toPath + "' already exists.");
		
		var directory = haxe.io.Path.directory(toPath);
		if (!exists(directory)) Directory.create(directory);

		FileSystem.rename(fromPath, toPath);
	}

	/**
	Returns the content of the file at path.

	@param path 	path to a file
	@return string content of the file
	*/
	public static function read(path:String):String
	{
		Console.assert(path != null, "the argument 'path' cannot be null");
		path = File.nativePath(path);
		Console.assert(exists(path), "the file '" + path + "' does not exist.");
		Console.assert(!isDirectory(path), "the path '" + path + "' is a directory and cannot be read.");
		return neko.io.File.getContent(path);
	}

	/**
	Writes content to the file at path, replacing any existing content.
	
	@param path 	path to a file
	@param content  string content to write to file
	*/
	public static function write(path:String, content:String, ?writeMode:FileWriteMode=null)
	{
		Console.assert(path != null, "the argument 'path' cannot be null");
		path = File.nativePath(path);
		Console.assert(content != null, "the argument 'content' cannot be null");

		var directory = haxe.io.Path.directory(path);
		Console.assert(isDirectory(directory), "the directory '" + directory + "' does not exist.");

		if (writeMode == null) writeMode = FileWriteMode.overwrite;

		var out:FileOutput = null;

		switch(writeMode)
		{
			case FileWriteMode.overwrite:
				out = neko.io.File.write(path, true);
			case FileWriteMode.append:
				out = neko.io.File.append(path, true);
		}
		out.writeString(content);
		out.close();
	}

}

enum FileWriteMode
{
	overwrite;
	append;
}

#else

class File {}

#end


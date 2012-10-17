package msys;

#if neko

import sys.FileSystem;
import sys.io.FileOutput;
import haxe.io.Bytes;
import neko.Lib;

using msys.File;
// using mcore.util.Arrays;

#if !haxe_209
import neko.Sys;
#end

class Directory
{
	/**
	Check if a directory is empty

	@param path 	existing directory path
	@return true if directory is empty
	*/
	public static function isEmpty(path:String):Bool
	{
		Console.assert(path != null, "the argument 'path' cannot be null");
		Console.assert(path.isDirectory(), "the path '" + path + "' is not a directory and cannot be read.");
		return readDirectory(path).length == 0;
	}

	/**
	Create a directory at path. Directories are created recursively, so that 
	any intermediate directories are created as well.
	*/
	public static function create(path:String)
	{	
		Console.assert(path != null, "the argument 'path' cannot be null");
		path = File.unixPath(path);

		var parts = path.split("/");
		var current = [];
		
		for (part in parts)
		{
			current.push(part);
			path = current.join("/").nativePath();
			
			if (part.length == 0) continue;
			
			if (path.exists())
			{
				Console.assert(path.isDirectory(), "the path " + path + " is not a directory");
			}
			else
			{
				FileSystem.createDirectory(path);
			}
		}
	}

	/**
	Deletes the file or directory at path.
	@param path 	file or directory to remove
	@param pathFilter 	optional regexp filter (defaults to none)
	*/
	public static function removeTree(path:String)
	{
		Console.assert(path != null, "the argument 'path' cannot be null");
		path = File.nativePath(path);
		
		if (!path.exists()) return;

		Console.assert(path.isDirectory(), "the path '" + path + "' is not a directory");

		for (subPath in readDirectory(path))
		{	
			subPath = path.append(subPath);

			if (subPath.isDirectory())
			{
				removeTree(subPath);
			}
			else
			{
				subPath.remove();
			}
		}

		path.remove();
	}


	/**
	Returns an array of strings naming the files and directories in the directory
	denoted by the path.
	
	@param path 	directory
	@return array of strings naming the files in the path
	*/
	public static function readDirectory(path:String):Array<String>
	{
		Console.assert(path != null, "the argument 'path' cannot be null");
		path = path.nativePath();

		Console.assert(path.exists(), "the path '" + path + "' does not exist");
		Console.assert(path.isDirectory(), "the path '" + path + "' is not a directory");

		var filenames = [];
		for (filename in FileSystem.readDirectory(path))
		{
			filenames.push(filename);
		}
		return filenames;
	}
}

#else

class Directory {}

#end

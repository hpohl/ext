module ext.resource.path;

import std.algorithm;
import std.array;
import std.conv;
import std.path;
import std.string;

import ext.resource.exception;

version(unittest) {
	import std.exception;
}


/**
 * A location is pointing to a package.
 */
struct Location {
	static {
		/// Checks whether the given string is a valid location.
		bool valid(string loc) nothrow pure {
			if (loc.empty) {
				return false;
			}
			return true;
		}
		
		unittest {
			assert(valid("normal.valid.path.but.big"));
			assert(!valid(""));
		}
		
		/// Validates a string to be a location.
		void validate(string loc) pure {
			if (!valid(loc)) {
				throw new ResourceException("Invalid location string detected.");
			}
		}
		
		unittest {
			assertThrown(validate(""));
		}
		
		/// Gets the package name from a location.
		string nameOf(string location) {
			validate(location);
			
			auto idx = lastIndexOf(location, ".");
			
			if (idx == -1) {
				// No dot found, location is name.
				return location;
			} else {
				// Found. Returns contents until the dot.
				return location[idx + 1 .. $];
			}
		}
		
		unittest {
			assert(nameOf("name.location.okay") == "okay");
			assert(nameOf("name") == "name");
			assertThrown(nameOf(""));
		}
		
		/// Gets the path of a location.
		string pathTo(string location) {
			validate(location);
			
			auto idx = lastIndexOf(location, ".");
			
			if (idx == -1) {
				// No dot found, location is name.
				return "";
			} else {
				// Found. Returns contents until the dot.
				return location[0 .. idx];
			}
		}
		
		unittest {
			assert(pathTo("nice.package.path") == "nice.package");
			assert(pathTo("pack") == "");
			assertThrown(pathTo(""));
		}
		
		/// Converts a location to a file name.
		string toFileName(string location) {
			validate(location);
			return replace(location, ".", dirSeparator);
		}
		
		unittest {
			alias dirSeparator s;
			assert(toFileName("nice.path"), "nice" ~ s ~ "path");
			assertThrown(toFileName(""));
		}
		
		/// Takes the path of a location and creates a file name out of it.
		string toDirectoryPath(string location) {
			return replace(pathTo(location), ".", dirSeparator);
		}
		
		unittest {
			alias dirSeparator s;
			assert(toDirectoryPath("nice.path.name.okay"),
				"nice" ~ s ~ "path" ~ s ~ "name");
			assertThrown(toDirectoryPath(""));
		}
	}
	
	/**
	 * Builds a location from an array of strings containing
	 * the directories.
	 * 
	 * ["general", "images"] will lead to general.images
	 */
	this(string[] dirs) {
		if (dirs.empty) {
			throw new ResourceException("No directories for location.");
		}
		
		_value = join(dirs, ".");
		_name = nameOf(_value);
	}
	
	/**
	 * Creates a location from a well formatted value.
	 */
	this(string location) {
		validate(location);
		_value = location;
		_name = nameOf(_value);
	}
	
	bool opEquals(Location loc) {
		return _value == loc._value;
	}
	
	@property {
		nothrow pure {
			/// Returns the name of the package.
			string name() const {
				return _name;
			}
			
			/// Returns the value of the location.
			string value() const {
				return _value;
			}
		}
		
		/// Calls to fileName using the value.
		string fileName() const {
			return toFileName(_value);
		}
		
		/// Calls toDirectoryPath using the value.
		string directory() const {
			return toDirectoryPath(_value);
		}
	}
	
	private {
		string _name;
		string _value;
	}
}

/**
 * A path is pointing to a resource.
 */
struct Path {
	static {
		/// Returns true whether the path string is valid or false if not.
		bool valid(string path) {
			if (path.empty) {
				return false;
			}
			
			auto firstIdx = std.string.indexOf(path, ":");
			auto lastIdx = lastIndexOf(path, ":");
			
			// Make sure there are not multiple dots.
			if (firstIdx != lastIdx || firstIdx == -1) {
				return false;
			}
			
			// Make sure there is something in front of and after the dots.
			if (firstIdx == 0 || lastIdx == path.length - 1) {
				return false;
			}
			
			return true;
		}
		
		unittest {
			assert(valid("location.path:packagename"));
			assert(valid("justonepackage:name"));
			assert(valid("s:h"));
			
			assert(!valid(":nopackagegiven"));
			assert(!valid("packonly:"));
			assert(!valid("nodots"));
			assert(!valid(""));
		}
		
		/// Validates the string, which should be a path.
		void validate(string path) {
			if (!valid(path)) {
				throw new ResourceException("Invalid path string detected.");
			}
		}
		
		unittest {
			assertNotThrown(validate("valid:path"));
			assertThrown(validate("invalidpath:"));
		}
		
		/// Gets the name of the path string.
		string nameOf(string path) {
			validate(path);
			return find(path, ":")[1 .. $];
		}
		
		unittest {
			assert(nameOf("random.path:name") == "name");
			assert(nameOf("rnd:name") == "name");
		}
		
		/// Gets the location of the path string.
		string locationOf(string path) {
			validate(path);
			return to!string(until(path, ":"));
		}
		
		unittest {
			assert(locationOf("this.is.the.location:name") == "this.is.the.location");
			assert(locationOf("loc:na"), "loc");
		}
	}
	/**
	 * Creates a resource with a name and a path which is defaulted
	 * to "". The path is used to define the package where the resource
	 * is loaded from and is dot-seperated depending in which directory
	 * the package is located.
	 * 
	 * "img.general:grass" should be in img/general -> grass item in package.
	 */
	this(string path) {
		_name = nameOf(path);
		_location = Location(locationOf(path));
		_path = path;
	}
	
	/**
	 * Creates a path from the location of the package and the resource name.
	 * 
	 * Yields to: location:name
	 */
	this(Location loc, string name) {
		if (name.empty) {
			throw new ResourceException("Trying to create a path to a resource with
				no name");
		}
		
		_name = name;
		_location = loc;
		_path = loc.value ~ ":" ~ name;
	}
	
	@property nothrow pure {
		/// Returns the name of the resource.
		string name() const {
			return _name;
		}
		
		/// Returns the location to the package.
		Location location() const {
			return _location;
		}
		
		/// Returns the full path.
		string full() const {
			return _path;
		}
	}
	
	private {
		string _name;
		Location _location;
		string _path;
	}
}
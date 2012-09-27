module ext.resource.pool;

import std.algorithm;
import std.array;
import std.conv;
import std.file;
import std.path;
import std.stdio;
import std.string;
import std.typecons;

import ext.resource.exception;
import ext.resource.path;
import ext.resource.resource;


/**
 * Collects resources.
 */
class Package {
	/// The first bytes of every package.
	enum id = "eXTPAckage";
	
	/**
	 * Constructs from the base path to use and the location
	 * of the package. The file doesn't have to exist.
	 */
	this(string basePath, in Location loc) {
		_basePath = basePath;
		_loc = loc;
		_dirName = _basePath ~ dirSeparator ~ _loc.directory;
		_fileName = _basePath ~ dirSeparator ~ _loc.fileName;
	}
	
	/**
	 * Adds a new resource to this package. The locations have to
	 * be equal.
	 */
	void add(Resource res) {
		if (res.path.location != _loc) {
			throw new ResourceException("Cannot add resource " ~ res.path.name ~
				": Unequal locations. Package has " ~ _loc.value ~
				", resource has " ~ res.path.location.value ~ ".");
		}
		
		_resources[res.path.name] = res;
	}
	
	/**
	 * Gets a resource out of this package.
	 */
	R get(R = Resource)(string name) {
		if (name !in _resources) {
			throw new ResourceException("Resource " ~ name ~
				" not found in package " ~ _loc.value ~ ".");
		}
		
		auto ret = cast(R)_resources[name];
		
		if (!ret) {
			throw new ResourceException("Resource " ~ name ~ " in package " ~
				_loc.value ~ " has different type.");
		}
		
		return ret;
	}
	
	/**
	 * Loads all resources available.
	 * The file does not have to exist.
	 */
	void load() {
		if (!exists()) {
			// Nothing to load, exit.
			return;
		}
		
		// Open the file, because it exists.
		auto f = File(_fileName, "r");
		
		// Check if its a ext package file.
		char[id.length] checkId;
		f.rawRead(checkId);
		
		if (checkId != id) {
			throw new ResourceException("Unable to load package " ~
				_loc.value ~ ", not a valid file.");
		}
		
		// As long as we dont have reached the end of the file.
		while (f.tell < f.size) {
			// Read the id of the resource.
			Resource.KeyType[1] id;
			f.rawRead(id);
			
			// Read the resource name length.
			ulong[1] nLen;
			f.rawRead(nLen);
			
			// Read the name of the resource.
			char[] name;
			name.length = nLen[0];
			f.rawRead(name);
			
			// Read the size of the resource.
			ulong[1] size;
			f.rawRead(size);
			
			// Read the data of the resource.
			void[] data;
			data.length = size[0];
			f.rawRead(data);
			
			// If the resource already exists ans has the same type.
			if (name in _resources && id[0] == _resources[name].key) {
				_resources[name].loadFromRaw(data);
			} else {
				// Replace the resource.
				auto namestr = to!string(name);
				auto res = Resource.create(id[0], Path(_loc, namestr));
				res.loadFromRaw(data);
				_resources[namestr] = res;
			}
		}
	}
	
	/**
	 * Saves all resources available to the associated file. If the file
	 * does not exist, creates one.
	 */
	void save() const {
		// If the directory to the file does not exist.
		if (!std.file.exists(_dirName)) {
			mkdirRecurse(_dirName);
		}
		
		// Open the file, or create one if it does not exist. Erase all contents.
		auto f = File(_fileName, "w");
		
		// Write our id.
		f.rawWrite(id);
		
		// Write all resources.
		foreach (res; _resources) {
			// Write the id of the resource.
			f.rawWrite([res.key]);
			
			// Write the length of the name.
			f.rawWrite([cast(ulong)res.path.name.length]);
			
			// Write the name.
			f.rawWrite(res.path.name);
			
			// Write the size of the data.
			void[] data = res.saveToRaw();
			f.rawWrite([cast(ulong)data.length]);
			
			// Write the data.
			f.rawWrite(data);
		}
	}
	
	private {
		string _basePath;
		Location _loc;
		string _dirName;
		string _fileName;
		Resource[string] _resources;
		
		/// Returns wether _fileName is a file or not.
		bool exists() const {
			return std.file.exists(_fileName) && _fileName.isFile;
		}
	}
}

/**
 * A resource pool is the source of all resources.
 */
class Pool {
	/// basePath is the directory where to search for packages.
	this(string basePath) {
		_basePath = basePath;
	}
	
	/// Saves the resource in this pool.
	void save(Resource res) {
		if (res.path.location.value !in _packages) {
			_packages[res.path.location.value] = new Package(_basePath, res.path.location);
		}
		
		_packages[res.path.location.value].add(res);
	}
	
	/// Loads a resource from this pool.
	R load(R = Resource)(in Path path) {
		if (path.location.value !in _packages) {
			auto pkg = new Package(_basePath, path.location);
			_packages[path.location.value] = pkg;
			pkg.load();
		}
		
		return _packages[path.location.value].get!R(path.name);
	}
	
	/// Writes all packages in the pool to disk.
	void write() const {
		foreach (pkg; _packages) {
			pkg.save();
		}
	}
	
	@property nothrow pure {
		/// Returns the path where to search for packages.
		string basePath() const {
			return _basePath;
		}
	}
	
	private {
		string _basePath;
		Package[string] _packages;
	}
}
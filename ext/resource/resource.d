module ext.resource.resource;

import std.algorithm;
import std.conv;

import ext.resource.exception;
import ext.resource.path;


/**
 * Used by derived classes of Resource to automatically register
 * a creator.
 */
mixin template AutoRegister(T, Resource.KeyType id) {
    import ext.resource.path;
    
	private {
		static Resource creator(ref const Path path) {
			return new T(path);
		}
		
		static this() {
			Resource.register(&creator, id);
		}
	}
	
	public override Resource.KeyType key() const nothrow pure {
		return id;
	}
}

/**
 * Everything you see in your game is based on a resource.
 */
class Resource {
	alias int KeyType;
	
	static {
		/// Resource creator.
		alias Resource function(ref const Path) Creator;
		
		/// Registers resource type for serialization.
		void register(Creator creator, KeyType id) {
			_creators[id] = creator;
		}
		
		/// Create a reasource from id and path.
		Resource create(KeyType id, in Path path) {
			return _creators[id](path);
		}
		
		private {
			/// All creators.
			Creator[KeyType] _creators;
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
	this(ref const Path path) {
		_path = path;
	}
	
	@property nothrow pure {
		/// Returns the path to the resource.
		Path path() const {
			return _path;
		}
	}
	
	abstract {
        /// Returns the path to the depencies.
        const(Path)[] depencies() const;
        
		/// Loads the resource from a chunk of data.
		void loadFromRaw(const(void)[] data, Resource[] depencies);
		
		/// Saves the resource.
		void[] saveToRaw() const;
		
		/// The key type to create new resourced using create.
		Resource.KeyType key() const nothrow pure;
	}
	
	private {
		Path _path;
	}	
}
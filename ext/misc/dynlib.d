module ext.misc.dynlib;

/**
 * This module provides functionality for dynamic loading of dynamic linked libraries.
 */

import std.exception;

import ext.misc.exception;


private {
	alias void* FuncPtr;

	auto throwLoadError(string name) {
		return new MiscException("Unable to load library " ~ name ~ ".");
	}

	auto throwUnloadError() {
		return new MiscException("Unable to close library.");
	}

	auto throwSymbolError(string name) {
		return new MiscException("Unable to find symbol " ~ name ~ ".");
	}

	version (Windows) {
		import std.c.windows.windows;

	    alias HMODULE LibraryHandle;

	    LibraryHandle loadLibrary(string name)
	    out(result) {
	    	assert(result);
	    } body {
	    	auto handle = LoadLibrary(name.ptr);
	    	enforce(handle, throwLoadError(name));
	    	return handle;
	    }

	    void closeLibrary(LibraryHandle handle)
	    in {
	    	assert(handle);
	    } body {
	    	enforce(FreeLibrary(handle) != 0, throwUnloadError);
	    }

	    FuncPtr getLibrarySymbol(LibraryHandle handle, string symbol)
	    in {
	    	assert(handle);
	    } out(result) {
	    	assert(result);
	    } body {
	    	auto f = GetProcAddress(handle, symbol.ptr);
	    	enforce(f, throwSymbolError(name));
	    	return f;
	    }

	} else version (Posix) {
		import std.c.linux.linux;

		alias void* LibraryHandle;

		LibraryHandle loadLibrary(string name)
		out(result) {
			assert(result);
		} body {
			auto handle = dlopen(name.ptr, RTLD_LAZY);
			enforce(handle, throwLoadError(name));
			return handle;
		}

		void closeLibrary(LibraryHandle handle)
		in {
			assert(handle);
		} body {
			enforce(dlclose(handle) == 0, throwUnloadError());
		}

		FuncPtr getLibrarySymbol(LibraryHandle handle, string name)
		in {
			assert(handle);
		} out(result) {
			assert(result);
		} body {
			auto f = dlsym(handle, name.ptr);
			enforce(f, throwSymbolError(name));
			return f;
		}
	} else {
		static assert(false, "Unsupported platform.");
	}
}


/**
 * Represents a dynamically loaded library.
 */
class DynLib {
public:
	/// Constructs from a string containing the file name of the library.
	this(string file) {
		_handle = loadLibrary(file);
	}

    /// Automatically closes the library.
	~this() {
		closeLibrary(_handle);
	}

	/// Loads a symbol out of the library given by name.
	FuncPtr loadSymbol(string name) {
		return getLibrarySymbol(_handle, name);
	}


private:
	LibraryHandle _handle;
}

module ext.render.opengl.context;

import std.exception;
import std.stdio;

import ext.math.vector;
import ext.misc.dynlib;
import ext.render.context;
import ext.render.opengl.api;
import ext.render.opengl.exception;
import ext.render.opengl.geometry;
import ext.render.opengl.target;
import ext.render.opengl.texture;
import ext.render.target;
import ext.render.texture;


/**
 * Used by OpenGL context created objects.
 */
mixin template OpenGLObject() {
	/// Automatically cast to an OpenGL context.
	override inout(Context) context() inout nothrow pure {
		return cast(inout(Context))super.context;
	}
	
	/// Provided for convenience.
	void throwOnGLError(string msg = "", string file = __FILE__, size_t line = __LINE__, Throwable next = null) const {
		ext.render.opengl.exception.throwOnGLError(context, msg, file, line, next);
	}
}

/**
 * OpenGL implementation of the render context.
 */
class Context : ext.render.context.Context {
	/// Generates code that loads all OpenGL functions.
	static private string generateFuncLoader() {
		string result;
		
		// Get all function names.
		enum funcs = [__traits(allMembers, Functions)];
		
		// For each function name...
		foreach (func; funcs) {
			
			/// ...load it.
			auto load = "_functions." ~ func ~
					  " = cast(typeof(_functions." ~ func ~ "))_lib.loadSymbol(\"" ~ func ~ "\")";
			result ~= "collectException(" ~ load ~ ");";
		}

		return result;
	}
	
	/// Loads all OpenGL functions using the file name of the dll.
	this(string dllFileName) {
		// Loads the OpenGL dll.
		_lib = new DynLib(dllFileName);
		
		// Load OpenGL functions.
		mixin(generateFuncLoader);
	}
	
	/// Used to call OpenGL functions.
	auto opDispatch(string name, Args...)(Args args) const
    if (name[0 .. 2] == "gl") {
    	mixin("return _functions." ~ name ~ "(args);");
    }
	
	/**
	 * Used to call OpenGL functions and automatically throw on error.
	 * Uses c as prefix, e.g. cglGenTextures.
	 */
	auto opDispatch(string name, Args...)(Args args) const
	if (name[0 .. 3] == "cgl") {
		scope(exit) throwOnGLError(this, name[1 .. $]);
		version(NoOpenGLChecks) {
			// Do not check.
		} else {
			mixin("return _functions." ~ name[1 .. $] ~ "(args);");
		}
	} 
	
	// Implementations of base.
	override {
		ext.render.opengl.texture.Texture createTexture(Format format) {
			return new ext.render.opengl.texture.Texture(format, this);
		}
		
		ext.render.opengl.target.Target createTarget(in Vector2ui size) {
			return new ext.render.opengl.target.Target(this, size);
		}
		
		ext.render.opengl.geometry.Geometry createGeometry() {
			return new ext.render.opengl.geometry.Geometry(this);
		}
	}
	
	private {
		DynLib _lib;
		Functions _functions;
	}
}
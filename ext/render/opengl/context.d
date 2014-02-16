module ext.render.opengl.context;

import std.exception;
import std.stdio;
import std.typecons;

import ext.math.vector;
import ext.misc.dynlib;
import ext.render.context;
import ext.render.opengl.api;
import ext.render.opengl.exception;
import ext.render.opengl.geometry;
import ext.render.opengl.program;
import ext.render.opengl.target;
import ext.render.opengl.texture;
import ext.render.target;
import ext.render.texture;
import ext.resource.material;


/**
 * Used by OpenGL context created objects.
 */
mixin template OpenGLObject() {
    import std.typecons : RefCounted;

	/// Automatically cast to an OpenGL context.
	override inout(Context) context() inout nothrow pure {
		return cast(inout(Context))super.context;
	}
	
	/// Provided for convenience.
	void throwOnGLError(string msg = "", string file = __FILE__, size_t line = __LINE__, Throwable next = null) const {
		ext.render.opengl.exception.throwOnGLError(context, msg, file, line, next);
	}

    /// Used to call OpenGL functions without checks.
    auto opDispatch(string name, Args...)(Args args) const nothrow
    if (name.length > 9 && name[0 .. 9] == "nocheckgl") {
        mixin("return _ctx.funcs.gl" ~ name[9 .. $] ~ "(args);");
    }
    
    /**
     * Used to call OpenGL functions and automatically throw on error.
     */
    auto opDispatch(string name, Args...)(Args args) const
    if (name.length > 2 && name[0 .. 2] == "gl") {
        scope (exit) throwOnGLError(this, name[0 .. $]);
        version (NoOpenGLChecks) {
            // Do not check.
        } else {
            mixin("return _ctx.funcs." ~ name[0 .. $] ~ "(args);");
        }
    }

    private RefCounted!ContextHandle _ctx;
}

package struct ContextHandle {
    DynLib lib;
    Functions* funcs;
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
			auto load = "_handle.funcs." ~ func ~
					  " = cast(typeof(_handle.funcs." ~ func ~ "))_handle.lib.loadSymbol(\"" ~ func ~ "\")";
			result ~= "collectException(" ~ load ~ ");";
		}

		return result;
	}
	
	/// Loads all OpenGL functions using the file name of the dll.
	this(string dllFileName) {
        _handle = RefCounted!ContextHandle();
        _handle.funcs = new Functions;

		// Loads the OpenGL dll.
		_handle.lib = new DynLib(dllFileName);
		
		// Load OpenGL functions.
		mixin (generateFuncLoader);
		
		// Enables.
        this.glEnable(GL_BLEND);
        this.glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		this.glEnable(GL_DEPTH_TEST);
	}

    ~this() {
        writeln("context dtor");
        stdout.flush();
    }
	
	// Implementations of base.
	override {
		ext.render.opengl.texture.Texture createTexture(Format format) {
			return new ext.render.opengl.texture.Texture(format, this);
		}
		
		ext.render.opengl.target.Target createTarget(Vector2ui size) {
			return new ext.render.opengl.target.Target(this, size);
		}
		
		ext.render.opengl.geometry.Geometry createGeometry() {
			return new ext.render.opengl.geometry.Geometry(this);
		}
		
		ext.render.opengl.program.Program createProgram(const Material mat) {
			return new ext.render.opengl.program.Program(this, mat);
		}
	}

    package @property RefCounted!ContextHandle handle() nothrow {
        return _handle;
    }
	
	private {
        RefCounted!ContextHandle _handle;
	}
}
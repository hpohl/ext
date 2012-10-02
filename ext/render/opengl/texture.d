module ext.render.opengl.texture;

import std.stdio;

import ext.math.vector;
import ext.render.opengl.api;
import ext.render.opengl.context;
import ext.render.opengl.exception;
import ext.render.texture;


/**
 * OpenGL implementation of a texture. Makes use of OpenGLs
 * Texture2D
 */
class Texture : ext.render.texture.Texture {
	// Is an OpenGL object.
	mixin OpenGLObject;
	
	static {
		/// Converts a texture format to OpenGL.
		GLenum toGLFormat(Format format) pure {
			switch (format) {
				case Format.RGB: return GL_RGB8;
				case Format.RGBA: return GL_RGBA8;
				default: throw new OpenGLException("Not supported texture format.");
			}
		}
	}
	
	/// Creates by the given context and an OpenGL format.
	this(GLenum format, Context context) {
		super(Format.internal, context);
		_format = format;
		
		// Creates the OpenGL texture object.
		GLuint tmpname;
		context.cglGenTextures(1, &tmpname);
		_name = tmpname;
		scope(failure) context.cglDeleteTextures(1, &_name);
        
        bind();
        context.cglTexParameteri(GL_TEXTURE_2D,
            GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        context.cglTexParameteri(GL_TEXTURE_2D,
            GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        context.cglTexParameteri(GL_TEXTURE_2D,
            GL_TEXTURE_WRAP_S, GL_REPEAT);
        context.cglTexParameteri(GL_TEXTURE_2D,
            GL_TEXTURE_WRAP_T, GL_REPEAT);
	}
	
	/// Creates by the given context and format.
	this(Format format, Context context) {
		super(format, context);
		
		// Convert to OpenGL.
		_format = toGLFormat(format);
		
		// Creates the OpenGL texture object.
		GLuint tmpname;
		context.cglGenTextures(1, &tmpname);
		_name = tmpname;
		scope(failure) context.cglDeleteTextures(1, &_name);
	}
	
	~this() {
		// Delete OpenGL texture.
		context.cglDeleteTextures(1, &_name);
	}
	
	@property {
		// Return the OpenGL name of the texture.
		GLuint name() {
			return _name;
		}
		
		override {
			Vector2ui size() const {
				bind();
				GLint w, h;
				context.cglGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_WIDTH, &w);
				context.cglGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_HEIGHT, &h);
				return Vector2ui(w, h);
			}
			
			void size(in Vector2ui size) {
				bind();
                context.cglTexStorage2D(GL_TEXTURE_2D, 1, _format, size.x, size.y);
			}
			
			inout(ubyte)[] data() inout {
				bind();
				
				// Allocate memory to return.
				inout(ubyte)[] ret;
				auto size = size;
				ret.length = size.x * size.y * numChannels();
				
				// Get the texture data.
				context.cglGetTexImage(GL_TEXTURE_2D, 0, _format,
					 GL_UNSIGNED_BYTE, cast(void*)ret.ptr);
				
				return ret;
			}
			
			void data(const(ubyte)[] data) {
				bind();
				context.cglTexImage2D(GL_TEXTURE_2D, 0, _format, size.x,
					size.y, 0, _format, GL_UNSIGNED_BYTE, cast(const void*)data.ptr);
			}
		}
	}
	
	/// Binds the function to context.
	void bind() const {
		context.cglBindTexture(GL_TEXTURE_2D, _name);
	}
	
	private {
		const GLuint _name;
		const GLenum _format;
		
		/// Returns the number of channels.
		uint numChannels() const pure {
			switch (format) {
				case Format.RGB: return 3;
				case Format.RGBA: return 4;
				default: throw new OpenGLException("Cannot determine channel 
							count from texture format.");
			}
		}
	}
}
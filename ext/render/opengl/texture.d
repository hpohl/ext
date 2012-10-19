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
		/// Converts a texture internal format to OpenGL.
		GLenum toGLInternalFormat(Format format) pure {
			switch (format) {
				case Format.RGB: return GL_RGB8;
				case Format.RGBA: return GL_RGBA8;
				default: throw new OpenGLException("Not supported texture internal format.");
			}
		}
        
        /// Converts a texture format top OpenGL.
        GLenum toGLFormat(Format format) pure {
            switch (format) {
                case Format.RGB: return GL_RGB;
                case Format.RGBA: return GL_RGBA;
                default: throw new OpenGLException("Not supported texture format.");
            }
        }
	}
	
	/// Creates by the given context and format.
	this(Format format, Context context) {
		super(format, context);
		
		// Creates the OpenGL texture object.
        GLuint tmpname;
		context.glGenTextures(1, &tmpname);
        _name = tmpname;
		scope(failure) context.glDeleteTextures(1, &_name);
	}
	
	~this() {
		// Delete OpenGL texture.
		context.glDeleteTextures(1, &_name);
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
				context.glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_WIDTH, &w);
				context.glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_HEIGHT, &h);
				return Vector2ui(w, h);
			}
			
			void size(ref const Vector2ui size) {
				bind();
                context.glTexStorage2D(GL_TEXTURE_2D, 1, toGLInternalFormat(format), size.x, size.y);
			}
			
			ubyte[] data() const {
				bind();
				
				// Allocate memory to return.
				ubyte[] ret;
				auto size = size;
				ret.length = size.x * size.y * numChannels();
				
				// Get the texture data.
				context.glGetTexImage(GL_TEXTURE_2D, 0, toGLFormat(format),
					 GL_UNSIGNED_BYTE, cast(void*)ret.ptr);
				
				return ret;
			}
			
			void data(const(ubyte)[] data) {
				bind();
                context.glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0,
                    size.x, size.y, toGLFormat(format), GL_UNSIGNED_BYTE,
                    cast(const GLvoid*)data.ptr);
			}
		}
	}
	
	/// Binds the function to context.
	void bind() const {
		context.glBindTexture(GL_TEXTURE_2D, _name);
	}
	
	private {
		const GLuint _name;
		
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
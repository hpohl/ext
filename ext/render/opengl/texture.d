module ext.render.opengl.texture;

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
	
	/// Creates by the given context and an OpenGL format.
	this(GLenum format, Context context) {
		super(Format.internal, context);
		_format = format;
		
		// Creates the OpenGL texture object.
		context.cglGenTextures(1, &_name);
		scope(failure) context.cglDeleteTextures(1, &_name);
	}
	
	/// Creates by the given context and format.
	this(Format format, Context context) {
		super(format, context);
		
		// Convert to OpenGL.
		_format = toGLFormat(format);
		
		// Creates the OpenGL texture object.
		context.cglGenTextures(1, &_name);
		scope(failure) context.cglDeleteTextures(1, &_name);
	}
	
	~this() {
		// Delete OpenGL texture.
		context.cglDeleteTextures(1, &_name);
	}
	
	@property {
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
				context.cglTexStorage2D(GL_TEXTURE_2D, 1,
					_format, size.x, size.y);
			}
		}
	}
	
	/// Binds the function to context.
	void bind() const {
		context.cglBindTexture(GL_TEXTURE_2D, _name);
	}
	
	private {
		GLuint _name;
		GLenum _format;
		
		static GLenum toGLFormat(Format format) {
			switch (format) {
				case Format.R: return GL_RED;
				case Format.RGB: return GL_RGB;
				case Format.RGBA: return GL_RGBA;
				default: throw new OpenGLException("Not supported texture format.");
			}
		}
	}
}
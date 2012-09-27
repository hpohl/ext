module ext.render.opengl.geometry;

import ext.render.geometry;
import ext.render.opengl.api;
import ext.render.opengl.context;


/**
 * OpenGL implementation of geometry using vertex buffer
 * objects.
 */
class Geometry : ext.render.geometry.Geometry {
	mixin OpenGLObject;
	
	/// Creates a geometry and specifies the context used.
	this(Context context) {
		super(context);
		
		context.cglGenBuffers(1, &_vbo);
		scope(failure) context.cglDeleteBuffers(1, &_vbo);
	}
	
	~this() {
		scope(exit) {
			context.cglDeleteBuffers(1, &_vbo);
		}
	}
	
	@property {
		/// Returns the name of the VBO used.
		GLuint name() nothrow pure {
			return _vbo;
		}
		
		override {
			Triangle[] data() const {
				bind();
				
				// Get buffer size.
				GLint s;
				context.cglGetBufferParameteriv(GL_ARRAY_BUFFER,
					GL_BUFFER_SIZE, &s);
				
				Triangle[] ret;
				ret.length = s;
				
				// Write to range.
				context.cglGetBufferSubData(GL_ARRAY_BUFFER,
					0, s, ret.ptr);
				
				return ret;
			}
			
			void data(in Triangle[] data) {
				bind();
				
				context.cglBufferData(GL_ARRAY_BUFFER,
					data.length * Triangle.sizeof, data.ptr,
					GL_STATIC_DRAW);
			}
		}
	}
	
	private {
		GLuint _vbo;
		
		/// Bind the buffer to GL_ARRAY_BUFFER.
		void bind() const {
			context.cglBindBuffer(GL_ARRAY_BUFFER, _vbo);
		}
	}
}
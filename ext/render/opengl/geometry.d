module ext.render.opengl.geometry;

import ext.math.matrix;
import ext.render.geometry;
import ext.render.opengl.api;
import ext.render.opengl.context;
import ext.render.opengl.exception;
import ext.render.opengl.program;
import ext.render.program;
import ext.render.target;


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
			ulong numTriangles() const {
				return _numTriangles;
			}
			
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
				
				_numTriangles = data.length;
				
				context.cglBufferData(GL_ARRAY_BUFFER,
					data.length * Triangle.sizeof, data.ptr,
					GL_STATIC_DRAW);
			}
		}
	}
	
	override {
		void draw(Target target, const ext.render.program.Program prog,
			in Matrix4x4f modelview, in Matrix4x4f projection) {
			
			auto oglprog = cast(ext.render.opengl.program.Program)prog;
			
			if (!oglprog) {
				throw new OpenGLException("Cannot draw geometry: Program is not
					an OpenGL program.");
			}
			
			oglprog.use();
			oglprog.uniformModelViewMatrix(modelview);
			oglprog.uniformProjectionMatrix(projection);
			
			bind();
			context.cglDrawArrays(GL_TRIANGLES, 0, cast(GLsizei)_numTriangles);
		}
	}
	
	private {
		GLuint _vbo;
		ulong _numTriangles;
		
		/// Bind the buffer to GL_ARRAY_BUFFER.
		void bind() const {
			context.cglBindBuffer(GL_ARRAY_BUFFER, _vbo);
		}
	}
}
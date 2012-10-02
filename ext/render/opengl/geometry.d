module ext.render.opengl.geometry;

import std.stdio;

import ext.math.matrix;
import ext.render.geometry;
import ext.render.opengl.api;
import ext.render.opengl.context;
import ext.render.opengl.exception;
import ext.render.opengl.program;
import ext.render.opengl.target;
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
		
		context.cglGenVertexArrays(1, &_vao);
		scope(failure) context.cglDeleteVertexArrays(1, &_vao);
		
		context.cglGenBuffers(1, &_vbo);
		scope(failure) context.cglDeleteBuffers(1, &_vbo);
	}
	
	~this() {
		scope(exit) {
            context.cglDeleteVertexArrays(1, &_vao);
			context.cglDeleteBuffers(1, &_vbo);
		}
	}
	
	@property {
        /// Retuns the name of the VAO.
        GLuint vao() nothrow pure {
            return _vao;
        }
        
		/// Returns the name of the VBO used.
		GLuint vbo() nothrow pure {
			return _vbo;
		}
        
        /// Returns the names of the Texture VBOs.
        const(GLuint)[] tvbos() nothrow pure {
            return _tvbos;
        }
		
		override {
			inout(Triangle)[] vertices() inout {
                return _vertices;
			}
			
			void vertices(Triangle[] vertices) {
                _vertices = vertices;
                
                bindVBO();
                context.cglBufferData(GL_ARRAY_BUFFER, Triangle.sizeof * _vertices.length,
                    _vertices.ptr, GL_STATIC_DRAW);
			}
            
            inout(TriangleTexCoords)[][] texCoords() inout {
                return cast(inout(TriangleTexCoords)[][])_texCoords;
            }
            
            void texCoords(TriangleTexCoords[][] texCoords) {
                _texCoords = texCoords;
                
                foreach (i, tcs; texCoords) {
                    if (i >= _tvbos.length) {
                        ++_tvbos.length;
                    }
                    
                    if (!_tvbos[i]) {
                        context.cglGenBuffers(1, &_tvbos[i]);
                        scope(failure) context.cglDeleteBuffers(1, &_tvbos[i]);
                    }
                    
                    context.cglBindBuffer(GL_ARRAY_BUFFER, _tvbos[i]);
                    context.cglBufferData(GL_ARRAY_BUFFER, TriangleTexCoords.sizeof * tcs.length,
                        tcs.ptr, GL_STATIC_DRAW);
                }
            }
		}
	}
	
	override {
		void draw(ext.render.target.Target target, const ext.render.program.Program prog,
			in Matrix4x4f modelview, in Matrix4x4f projection) {
			
			auto oglprog = cast(ext.render.opengl.program.Program)prog;
			
			if (!oglprog) {
				throw new OpenGLException("Cannot draw geometry: Program is not
					an OpenGL program.");
			}
            
            auto ogltarget = cast(ext.render.opengl.target.Target)target;
            
            if (!ogltarget) {
                throw new OpenGLException("Cannot draw geometry: Target is not an
                    OpenGL target.");
            }
            
            ogltarget.bind();
			
			oglprog.use();
			oglprog.uniformModelViewMatrix(modelview);
			oglprog.uniformProjectionMatrix(projection);
			
			bindVAO();
			bindVBO();
			context.cglVertexAttribPointer(
				cast(uint)ext.render.opengl.program.Program.vertexLocation,
				4, GL_FLOAT, GL_FALSE, 0, null);
            context.cglEnableVertexAttribArray(
                cast(uint)ext.render.opengl.program.Program.vertexLocation);
			
			
            size_t smallest = _vertices.length;
            
            foreach (i, tc; _texCoords) {
                if (smallest > tc.length) {
                    smallest = tc.length;
                }
                
                context.cglBindBuffer(GL_ARRAY_BUFFER, _tvbos[i]);
    			context.cglVertexAttribPointer(
    				cast(uint)ext.render.opengl.program.Program.texLocations[i],
    				2, GL_FLOAT, GL_FALSE, 0, null);
            }
			
			context.cglDrawArrays(GL_TRIANGLES, 0, cast(GLsizei)smallest * 3);
		}
	}
	
	private {
		GLuint _vao;
		GLuint _vbo;
        GLuint[] _tvbos;
        
        Triangle[] _vertices;
        TriangleTexCoords[][] _texCoords;
		
		/// Bind the VAO.
		void bindVAO() const {
			context.cglBindVertexArray(_vao);
		}
        
        /// Bind the VBO.
        void bindVBO() const {
            context.cglBindBuffer(GL_ARRAY_BUFFER, _vbo);
        }
	}
}
module ext.render.opengl.geometry;

import std.stdio;
import std.typecons;

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
    
    struct TexCoordDimension {
        GLuint name;
        TriangleTexCoords[] coords;
    }
	
	/// Creates a geometry and specifies the context used.
	this(Context context) {
		super(context);
		
        // Generate VAO.
		context.glGenVertexArrays(1, &_vao);
		scope(failure) context.glDeleteVertexArrays(1, &_vao);
		
        // Generate VBO.
		context.glGenBuffers(1, &_vbo);
		scope(failure) context.glDeleteBuffers(1, &_vbo);
	}
	
	~this() {
        // Come hell or high water.
		scope(exit) {
            context.glDeleteVertexArrays(1, &_vao);
			context.glDeleteBuffers(1, &_vbo);
            
            // Wow, this OpenGL feature is usefule one time.
            //context.glDeleteBuffers(cast(GLsizei)_tvbos.length, _tvbos.ptr);
            
            // Not anymore...
            foreach (tc; _texCoords) {
                context.glDeleteBuffers(1, &tc[1]);
            }
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
        GLuint[] tvbos() nothrow pure {
            GLuint[] ret;
            foreach (tc; _texCoords) {
                ret ~= tc[1];
            }
            return ret;
        }
		
		override {
			inout(Triangle)[] vertices() inout {
                return _vertices;
			}
			
			void vertices(Triangle[] vertices) {
                _vertices = vertices;
                
                // Update VBO.
                bindVBO();
                context.glBufferData(GL_ARRAY_BUFFER, Triangle.sizeof * _vertices.length,
                    _vertices.ptr, GL_STATIC_DRAW);
			}
            
            inout(TriangleTexCoords)[][] texCoords() inout {
                return cast(inout(TriangleTexCoords)[][])_texCoords;
            }
            
            void texCoords(TriangleTexCoords[][] texCoords) {
                // If there are not enough VBOs available, create new.
                if (texCoords.length > _texCoords.length) {
                    auto diff = texCoords.length - _texCoords.length;
                    _texCoords.length = texCoords.length;
                    
                    foreach (i, ref tc; _texCoords[diff - 1 .. $]) {
                        _texCoords[diff - 1 + i][0] = texCoords[diff - 1 + i];
                        context.glGenBuffers(1, &tc[1]);
                    }
                }
                
                // Remove unneded texture VBOs, come hell or high water.
                scope (exit) {
                    if (texCoords.length < _texCoords.length) {
                        auto diff = _texCoords.length - texCoords.length;
                        
                        foreach (ref tc; _texCoords[diff - 1 .. $]) {
                            context.glDeleteBuffers(1, &tc[1]);
                        }
                    }
                }
                
                // Foreach tex coord dimension.
                foreach (i, tc; _texCoords) {
                    // Copy tex coords to VBO.
                    context.glBindBuffer(GL_ARRAY_BUFFER, tc[1]);
                    context.glBufferData(GL_ARRAY_BUFFER, TriangleTexCoords.sizeof * tc[0].length,
                        tc[0].ptr, GL_STATIC_DRAW);
                }
            }
		}
	}
	
	override {
		void draw(ext.render.target.Target target, const ext.render.program.Program prog,
			in Matrix4x4f modelview, in Matrix4x4f projection) {
			
            // Make sure we got an OpenGL program.
			auto oglprog = cast(ext.render.opengl.program.Program)prog;
			if (!oglprog) {
				throw new OpenGLException("Cannot draw geometry: Program is not
					an OpenGL program.");
			}
            
            // Make sure we got an OpenGL target.
            auto ogltarget = cast(ext.render.opengl.target.Target)target;
            if (!ogltarget) {
                throw new OpenGLException("Cannot draw geometry: Target is not an
                    OpenGL target.");
            }
            
            // Bind the target.
            ogltarget.bind();
			
            // Use the program and uniform matrices.
			oglprog.use();
			oglprog.uniformModelViewMatrix(modelview);
			oglprog.uniformProjectionMatrix(projection);
			
            // Enable vertex attribute.
			bindVAO();
			bindVBO();
			context.glVertexAttribPointer(
				cast(uint)ext.render.opengl.program.Program.vertexLocation,
				3, GL_FLOAT, GL_FALSE, 0, null);
            context.glEnableVertexAttribArray(
                cast(uint)ext.render.opengl.program.Program.vertexLocation);
			
			
            // The smallest number of data available.
            size_t smallest = _vertices.length;
            
            // Update texture buffers.
            foreach (i, tc; _texCoords) {
                if (smallest > tc.length) {
                    smallest = tc.length;
                }
                
                context.glBindBuffer(GL_ARRAY_BUFFER, tc[1]);
    			context.glVertexAttribPointer(
    				cast(uint)ext.render.opengl.program.Program.texLocations[i],
    				2, GL_FLOAT, GL_FALSE, 0, null);
                context.glEnableVertexAttribArray(
                    cast(uint)ext.render.opengl.program.Program.texLocations[i]);
            }
			
            // Finally, draw.
			context.glDrawArrays(GL_TRIANGLES, 0, cast(GLsizei)smallest * 3);
		}
	}
	
	private {
		GLuint _vao;
		GLuint _vbo;
        
        Triangle[] _vertices;
        
        Tuple!(TriangleTexCoords[], GLuint)[] _texCoords;
		
		/// Bind the VAO.
		void bindVAO() const {
			context.glBindVertexArray(_vao);
		}
        
        /// Bind the VBO.
        void bindVBO() const {
            context.glBindBuffer(GL_ARRAY_BUFFER, _vbo);
        }
	}
}
module ext.render.opengl.program;

import ext.math.matrix;
import ext.render.opengl.api;
import ext.render.opengl.context;
import ext.render.opengl.exception;
import ext.render.program;
import ext.resource.material;


/**
 * OpenGL of a program using shaders.
 */
class Program : ext.render.program.Program {
    mixin OpenGLObject;
    
    enum vertexLocation = 0;
    enum texLocations = [1, 2, 3, 4, 5, 6, 7, 8];
    
    /// Specifies the OpenGL context to use.
    this(Context con, const Material mat) {
        super(con);
        
        _prog = context.cglCreateProgram();
        scope(failure) context.cglDeleteProgram(_prog);
        
        _vs = context.cglCreateShader(GL_VERTEX_SHADER);
        scope(failure) context.cglDeleteShader(_vs);
        
        _fs = context.cglCreateShader(GL_FRAGMENT_SHADER);
        scope(failure) context.cglDeleteShader(_fs);
        
        fromMaterial(mat);
    }
    
    ~this() {
        scope(exit) {
            context.cglDeleteProgram(_prog);
            context.cglDeleteShader(_vs);
            context.cglDeleteShader(_fs);
        }
    }
    
    /// Binds the program to the used OpenGL context.
    void use() {
        context.cglUseProgram(_prog);
    }
    
    /// Sets the model view matrix.
    void uniformModelViewMatrix(in Matrix4x4f mat) {
        auto loc = context.cglGetUniformLocation(_prog, "mdlview".ptr);
        use();
        context.cglUniformMatrix4fv(loc, 1, GL_TRUE, mat.ptr);
    }
    
    /// Sets the projection matrix.
    void uniformProjectionMatrix(in Matrix4x4f mat) {
        auto loc = context.cglGetUniformLocation(_prog, "proj".ptr);
        use();
        context.cglUniformMatrix4fv(loc, 1, GL_TRUE, mat.ptr);
    }
    
    @property nothrow pure {
        /// Returns the name of the program.
        GLuint program() {
            return _prog;
        }
        
        /// Returns the name of the vertex shader.
        GLuint vertexShader() {
            return _vs;
        }
        
        /// Returns the name of the fragment shader.
        GLuint fragmentShader() {
            return _fs;
        }
    }
    
    override {
        void fromMaterial(const Material mat) {
            enum vsSource = "
                #version 330
                
                layout(location=0) in vec4 position;
                layout(location=1) in vec2 texCoord;
                
                out vec2 exTexCoord;
                
                uniform mat4 mdlview;
                uniform mat4 proj;
                
                
                void main() {
                    gl_Position = proj * position;
                    exTexCoord = texCoord; 
                }
                ";
            
            auto vptr = vsSource.ptr;
            GLsizei vlen = vsSource.length;
            context.cglShaderSource(_vs, 1, &vptr, &vlen);
            context.cglCompileShader(_vs);
            
            enum fsSource = "
                #version 330
                
                in vec2 exTexCoord;
                
                out vec4 color;
                
                uniform sampler2D tex;
                
                
                void main() {
                    //color = vec4(1.0, 0.0, 0.0, 1.0);
                    //color = texture(tex, exTexCoord);
                }
                ";
            
            auto fptr = fsSource.ptr;
            GLsizei flen = fsSource.length;
            context.cglShaderSource(_fs, 1, &fptr, &flen);
            context.cglCompileShader(_fs);
            
            context.cglAttachShader(_prog, _vs);
            context.cglAttachShader(_prog, _fs);
            
            context.cglLinkProgram(_prog);
            
            context.cglValidateProgram(_prog);
            
            GLint stat;
            context.cglGetProgramiv(_prog, GL_VALIDATE_STATUS, &stat);
            
            if (stat != GL_TRUE) {
                throw new OpenGLException("Material generated program is not valid.");
            }
        }
    }
    
    private {
        GLuint _prog;
        GLuint _vs;
        GLuint _fs;
    } 
}
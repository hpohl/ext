module ext.render.opengl.program;

import ext.math.matrix;
import ext.render.opengl.api;
import ext.render.opengl.context;
import ext.render.opengl.exception;
import ext.render.opengl.texture;
import ext.render.program;
import ext.resource.image;
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
        
        _prog = context.glCreateProgram();
        scope(failure) context.glDeleteProgram(_prog);
        
        _vs = context.glCreateShader(GL_VERTEX_SHADER);
        scope(failure) context.glDeleteShader(_vs);
        
        _fs = context.glCreateShader(GL_FRAGMENT_SHADER);
        scope(failure) context.glDeleteShader(_fs);
        
        fromMaterial(mat);
    }
    
    ~this() {
        scope(exit) {
            context.glDeleteProgram(_prog);
            context.glDeleteShader(_vs);
            context.glDeleteShader(_fs);
        }
    }
    
    /// Binds the program to the used OpenGL context.
    void use() {
        context.glActiveTexture(GL_TEXTURE0);
        _textures[0].bind();
        context.glUseProgram(_prog);
        auto loc = context.glGetUniformLocation(_prog, "tex".ptr);
        context.glUniform1i(loc, 0);
    }
    
    /// Sets the model view matrix.
    void uniformModelViewMatrix(in Matrix4x4f mat) {
        auto loc = context.glGetUniformLocation(_prog, "mdlview".ptr);
        use();
        context.glUniformMatrix4fv(loc, 1, GL_TRUE, mat.ptr);
    }
    
    /// Sets the projection matrix.
    void uniformProjectionMatrix(in Matrix4x4f mat) {
        auto loc = context.glGetUniformLocation(_prog, "proj".ptr);
        use();
        context.glUniformMatrix4fv(loc, 1, GL_TRUE, mat.ptr);
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
                    gl_Position = (proj * mdlview) * position;
                    exTexCoord = texCoord; 
                }
                ";
            
            auto vptr = vsSource.ptr;
            GLsizei vlen = vsSource.length;
            context.glShaderSource(_vs, 1, &vptr, &vlen);
            context.glCompileShader(_vs);
            
            enum fsSource = "
                #version 330
                
                in vec2 exTexCoord;
                
                out vec4 color;
                
                uniform sampler2D tex;
                
                
                void main() {
                    //color = vec4(1.0, 0.0, 0.0, 1.0);
                    color = texture(tex, exTexCoord);
                    //color = vec4(exTexCoord, 0.0, 1.0);
                }
                ";
            
            auto fptr = fsSource.ptr;
            GLsizei flen = fsSource.length;
            context.glShaderSource(_fs, 1, &fptr, &flen);
            context.glCompileShader(_fs);
            
            context.glAttachShader(_prog, _vs);
            context.glAttachShader(_prog, _fs);
            
            context.glLinkProgram(_prog);
            
            context.glValidateProgram(_prog);
            
            GLint stat;
            context.glGetProgramiv(_prog, GL_VALIDATE_STATUS, &stat);
            
            if (stat != GL_TRUE) {
                throw new OpenGLException("Material generated program is not valid.");
            }
            
            _textures.length = 0;
            foreach (tex; mat.textures) {
                _textures ~= cast(Texture)tex.getTexture(context);
            }
        }
    }
    
    private {
        GLuint _prog;
        GLuint _vs;
        GLuint _fs;
        Texture[] _textures;
    } 
}
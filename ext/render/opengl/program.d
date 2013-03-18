module ext.render.opengl.program;

import std.ascii;
import std.conv;
import std.stdio;

import ext.math.matrix;
import ext.render.opengl.api;
import ext.render.opengl.context;
import ext.render.opengl.exception;
import ext.render.opengl.texture;
import ext.render.program;
import ext.render.texture;
import ext.resource.image;
import ext.resource.material;


/**
 * OpenGL of a program using shaders. Stub right now.
 */
class Program : ext.render.program.Program {
    mixin OpenGLObject;
    
    /// The OpenGL vertex location in shader.s
    enum vertexLocation = 0;
    
    // Texture locations in shaders.
    enum texLocations = [1, 2, 3, 4, 5, 6, 7, 8];
    
    /// Fragment shader header.
    enum fsHeader = "#version330" ~ newline;
    
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
        context.glUseProgram(_prog);
        
        foreach (i, tex; _textures) {
            context.glActiveTexture(cast(GLenum)(GL_TEXTURE0 + i));
            tex.bind();
            auto loc = context.glGetUniformLocation(_prog, ("tex" ~ to!string(i)).ptr);
            context.glUniform1i(loc, 0);
        }
    }
    
    /// Sets the model view matrix.
    void uniformModelViewMatrix(Matrix4x4f mat) {
        auto loc = context.glGetUniformLocation(_prog, "mdlview".ptr);
        use();
        context.glUniformMatrix4fv(loc, 1, GL_TRUE, mat.ptr);
    }
    
    /// Sets the projection matrix.
    void uniformProjectionMatrix(Matrix4x4f mat) {
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
            _textures.length = 0;
            foreach (tex; mat.textures) {
                _textures ~= cast(ext.render.opengl.texture.Texture)tex.getTexture(context);
            }
            
            context.glAttachShader(_prog, _vs);
            context.glAttachShader(_prog, _fs);
            
            _updateShaders();
            
            context.glLinkProgram(_prog);
            context.glValidateProgram(_prog);
            
            GLint stat;
            context.glGetProgramiv(_prog, GL_VALIDATE_STATUS, &stat);
            
            if (stat != GL_TRUE) {
                GLint size;
                context.glGetProgramiv(_prog, GL_INFO_LOG_LENGTH, &size);
                writeln(size);
                
                char[] log = new char[size];
                context.glGetProgramInfoLog(_prog, size, null, log.ptr);
                writeln(log);
                
                throw new OpenGLException("Material generated program is not valid.");
            }
        }
        
        @property {
            inout(ext.render.texture.Texture)[] textures() inout {
                return _textures;
            }
            
            void textures(ext.render.texture.Texture[] textures) {
                ext.render.opengl.texture.Texture[] oglTexs;
                
                foreach (tex; textures) {
                    auto current = cast(ext.render.opengl.texture.Texture)tex;
                    if (!current) {
                        throw new OpenGLException("Unable to set program textures: Not an OpenGL texture.");
                    }
                    if (current.context != context) {
                        throw new OpenGLException("Unable to set program textures: Invalid OpenGL context.");
                    }
                    oglTexs ~= current;
                }
                
                _textures = oglTexs;
            }
        }
    }
    
    private {
        GLuint _prog;
        GLuint _vs;
        GLuint _fs;
        ext.render.opengl.texture.Texture[] _textures;
        
        /// Updates all shaders.
        void _updateShaders() {
            // Vertex shader.
            string vsSource = "#version 330" ~ newline ~ "layout(location=0) in vec4 position;" ~ newline;
            
            foreach (i; 0 .. _textures.length) {
                vsSource ~= "layout(location=" ~ to!string(texLocations[i]) ~ ") in vec2 texc" ~ to!string(i) ~ ";" ~ newline;
                vsSource ~= "out vec2 extexc" ~ to!string(i) ~ ";" ~ newline;
            }
            
            vsSource ~= "uniform mat4 mdlview;" ~ newline;
            vsSource ~= "uniform mat4 proj;" ~ newline;
            
            vsSource ~= "void main() {" ~ newline;
            vsSource ~= "gl_Position = (proj * mdlview) * position;" ~ newline;
            
            foreach (i; 0 .. _textures.length) {
                vsSource ~= "extexc" ~ to!string(i) ~ " = texc" ~ to!string(i) ~ ";" ~ newline;
            }
            
            vsSource ~= "}" ~ newline;
            
            auto vptr = vsSource.ptr;
            GLsizei vlen = cast(GLsizei)vsSource.length;
            context.glShaderSource(_vs, 1, &vptr, &vlen);
            context.glCompileShader(_vs);
            
            // Fragment shader.
            string fsSource = "#version 330" ~ newline ~ "out vec4 color;" ~ newline;
            
            foreach (i; 0 .. _textures.length) {
                fsSource ~= "in vec2 extexc" ~ to!string(i) ~ ";" ~ newline;
                fsSource ~= "uniform sampler2D tex" ~ to!string(i) ~ ";" ~ newline;
            }
            
            fsSource ~= "void main() {" ~ newline;
            fsSource ~= "color = texture(tex0, extexc0);" ~ newline;
            fsSource ~= "}" ~ newline;
            
            auto fptr = fsSource.ptr;
            GLsizei flen = cast(GLsizei)fsSource.length;
            context.glShaderSource(_fs, 1, &fptr, &flen);
            context.glCompileShader(_fs);
        }
    } 
}
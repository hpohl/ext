module ext.resource.material;

import std.stdio;

import ext.render.context;
import ext.render.program;
import ext.resource.image;
import ext.resource.path;
import ext.resource.resource;


/**
 * Represents a four channeled color.
 */
struct Color {
    /**
     * Patameter names says everything needed. Default to white.
     */
    this(float red = 1.0, float green = 1.0,
        float blue = 1.0, float alpha = 1.0) {
        
        _red = red;
        _green = green;
        _blue = blue;
        _alpha = alpha;
    }
    
    @property nothrow pure {
        /// The red color value.
        float red() const {
            return _red;
        }
        
        /// Sets the red color value.
        void red(float val) {
            _red = val;
        }
        
        /// The green color value.
        float green() const {
            return _green;
        }
        
        /// Sets the green color value.
        void green(float val) {
            _green = val;
        }
        
        /// The blue color value.
        float blue() const {
            return _blue;
        }
        
        /// Sets the blue color value.
        void blue(float val) {
            _blue = val;
        }
        
        /// The alpha color value.
        float alpha() const {
            return _alpha;
        }
        
        /// Sets the alpha color value.
        void alpha(float val) {
            _alpha = val;
        }
    }
    
    private {
        float _red, _green, _blue, _alpha;
    } 
}

/**
 * Material define the look of objects drawn.
 */
class Material : Resource {
    mixin AutoRegister!(Material, 1);
    
    /**
     * Constructor to use.
     */
    this(in Path path) {
        super(path);
    }
    
    /// Always creates a new program out of this material.
    Program genProgram(Context con) const {
        return con.createProgram(this);
    }
    
    /// Returns a new program if no one has been created for this context.
    inout(Program) getProgram(Context con) inout {
        if (con !in _programs) {
            auto prog = genProgram(con);
            //(*cast(Material*)(&this))._programs[con] = prog;
            return cast(inout Program)prog;
        }
        return _programs[con];
    }
    
    @property nothrow pure {
        /// The ambient color.
        Color ambient() const {
            return _ambient;
        }
        
        /// Sets the ambient color.
        void ambient(in Color color) {
            _ambient = color;
        }
        
        /// The diffuse color.
        Color diffuse() const {
            return _diffuse;
        }
        
        /// Sets the diffuse color.
        void diffuse(in Color color) {
            _diffuse = color;
        }
        
        /// The specular color.
        Color specular() const {
            return _specular;
        }
        
        /// Sets the specular color.
        void specular(in Color color) {
            _specular = color;
        }
        
        /// Returns the associated textures as images.
        inout(Image)[] textures() inout {
            return _textures;
        }
        
        /// Sets the associated textures.
        void textures(Image[] textures) {
            _textures = textures;
        }
        
        /// Appends a texture to the textures range.
        void appendTexture(Image img) {
            _textures ~= img;
        }
    }
    
    override {
        void[] saveToRaw() const {
            Color[] cols;
            cols ~= _ambient;
            cols ~= _diffuse;
            cols ~= _specular;
            return cast(void[])cols;
        }
        
        void loadFromRaw(const(void)[] data) {
            auto cols = cast(const(Color)[])data;
            _ambient = cols[0];
            _diffuse = cols[1];
            _specular = cols[2];
        }
    }
    
    private {
        Color _ambient;
        Color _diffuse;
        Color _specular;
        
        Image[] _textures;
        
        Program[Context] _programs;
    }
}
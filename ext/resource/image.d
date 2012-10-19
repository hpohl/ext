module ext.resource.image;

/**
 * This module currently uses DevIL as image library.
 * There are alternatives and an abstraction like ImageCodec is
 * planned, but for now this will do the job.
 */

import std.conv;
import std.file;
import std.path;
import std.stdio;
import std.system;

import ext.math.vector;
import ext.render.context;
import ext.render.texture;
import ext.resource.exception;
import ext.resource.path;
import ext.resource.resource;


/**
 * Image data formats.
 */
enum Format {
	RGB,
	RGBA
}

ushort bppOf(Format format) {
    switch (format) {
        case Format.RGB: return 24;
        case Format.RGBA: return 32;
        default: throw new ResourceException("Cannot get format BPP: Unknown format.");
    }
}

/**
 * A usual image. Used for textures etc...
 * The data type is always ubyte.
 */
class Image : Resource {
    enum resourceKey = 0;
    mixin AutoRegister!(Image, resourceKey);
    
    /// Constructor to use.
    this(ref const Path path) {
        super(path);
    }
    
    /// Loads the image from a file.
    void loadFromFile(string fileName) {
        if (extension(fileName) != ".tga") {
            throw new ResourceException("Invalid file format.");
        }
        
        // TGA header.
        struct Header {
            align (1):
                byte idLen;
                byte palType;
                byte type;
                short palBegin;
                short palLen;
                byte palEntrySize;
                short xZero;
                short yZero;
                short width;
                short height;
                byte bpp;
                byte attrib;
        }
        
        // Open the file for read.
        auto f = File(fileName, "rb");
        
        // Read in the file header.
        Header[1] header;
        f.rawRead(header);
        
        // File checks...
        if (header[0].palType != 0) {
            throw new ResourceException("Unsupported TGA format.");
        }
        
        if (header[0].type != 2) {
            assert(false);
            throw new ResourceException("Unsupported TGA format.");
        }
        
        if (header[0].bpp != 24 && header[0].bpp != 32) {
            throw new ResourceException("Unsupported TGA format.");
        }
        
        // Jump over id.
        f.seek(header[0].idLen, SEEK_CUR);
        _data.length = header[0].width * header[0].height * (header[0].bpp / 8);
        
        // Set format.
        switch (header[0].bpp) {
            case 24: _format = Format.RGB; break;
            case 32: _format = Format.RGBA; break;
            default: throw new ResourceException("Invalid image bpp.");
        }
        
        // Image order depends on endianess...
        static if (endian == Endian.littleEndian) {
            // BGR is used.
            if (header[0].bpp == 24) {
                size_t i;
                foreach (ubyte[] col; f.byChunk(3)) {
                    if (i * 3 >= _data.length) {
                        break;
                    }
                    
                    _data[i * 3] = col[2];
                    _data[i * 3 + 1] = col[1];
                    _data[i * 3 + 2] = col[0];
                    ++i;
                }
            } else if (header[0].bpp == 32) {
                size_t i;
                foreach (ubyte[] col; f.byChunk(4)) {
                    if (i * 4 >= _data.length) {
                        break;
                    }
                    
                    _data[i * 4] = col[2];
                    _data[i * 4 + 1] = col[1];
                    _data[i * 4 + 2] = col[0];
                    _data[i * 4 + 3] = col[3];
                    
                    ++i;
                }
            } else {
                throw new ResourceException("Invalid image bpp.");
            }
        } else {
            // Directly read in.
            f.rawRead(_data);
        }
        
        // Set size..
        _size = Vector2ui(header[0].width, header[0].height);
    }
    
    /// Creates _always_ a new texture from this image using the given context.
    Texture genTexture(Context con) const {
        // Determine the matching texture format.
        alias ext.render.texture.Format TexFormat;
        TexFormat texFormat;
        
        switch (_format) {
            case Format.RGB: texFormat = TexFormat.RGB; break;
            case Format.RGBA: texFormat = TexFormat.RGBA; break;
            default: throw new ResourceException("Cannot convert image to texture: " ~
                    "Unsupported image format.");
        }
        
        // Create the texture and allocate memory by resizing it.
        auto tex = con.createTexture(texFormat);
        auto s = size;
        tex.size = s;
        
        // Finally, set the data of the texture.
        tex.data = _data;
        
        return tex;
    }
    
    /**
     * Creates a texture from this image for this context if not
     * already created.
     */
    inout(Texture) getTexture(Context con) inout {
        if (con in _textures) {
            return _textures[con];
        } else {
            auto tex = genTexture(con);
            (*cast(Image*)(&this))._textures[con] = tex;
            return cast(inout Texture)tex;
        }
    }
    
    @property {
        /// Returns the image size.
        Vector2ui size() const {
            return _size;
        }
        
        /// Returns the image width.
        uint width() const {
            return _size.x;
        }
        
        /// Returns the image height.
        uint height() const {
            return _size.y;
        }
    }
    
    override {
        const(Path)[] depencies() const {
            return [];
        }
        
        void loadFromRaw(const(void)[] data, Resource[] depencies) {
            _format = *cast(Format*)(data.ptr);
            _size = *cast(Vector2ui*)(data.ptr + _format.sizeof);
            
            auto ptr = cast(ubyte*)(data.ptr + _format.sizeof + _size.sizeof);
                
            _data.length = size.x * size.y * (bppOf(_format) / 8);
            
            foreach (i, ref c; _data) {
                _data[i] = ptr[i];
            }
        }
        
        void[] saveToRaw() const {
            void[] ret;
            ret.length = _format.sizeof + _size.sizeof;
            
            *cast(Format*)ret.ptr = _format;
            *cast(Vector2ui*)(ret.ptr + _format.sizeof) = _size;
            
            ret ~= _data.dup;
            
            return ret;
        }
    }
    
    private {
        Format _format;
        Vector2ui _size;
        ubyte[] _data;
        Texture[Context] _textures;
    }
}
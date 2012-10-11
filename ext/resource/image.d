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
import ext.resource.external.devil;
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
    this(in Path path) {
        super(path);
    }
    
    /// Loads the image from a file.
    void loadFromFile(string fileName) {
        if (extension(fileName) != ".tga") {
            throw new ResourceException("Invalid file format.");
        }
        
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
        
        auto f = File(fileName, "rb");
        
        Header[1] header;
        f.rawRead(header);
        
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
        
        f.seek(header[0].idLen, SEEK_CUR);
        _data.length = header[0].width * header[0].height * (header[0].bpp / 8);
        
        switch (header[0].bpp) {
            case 24: _format = Format.RGB; break;
            case 32: _format = Format.RGBA; break;
            default: throw new ResourceException("Invalid image bpp.");
        }
        
        static if (endian == Endian.littleEndian) {
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
            f.rawRead(_data);
        }
        
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
        tex.size = size;
        
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
        void loadFromRaw(const(void)[] data) {
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

version(none) {

/**
 * A usual image. Used for textures etc...
 * The data type is always ubyte.
 */
class Image : Resource {
	enum resourceKey = 0;
	mixin AutoRegister!(Image, resourceKey);
	
	static {
		private {
			/// Returns a DevIL loading type for a file extension.
			ILenum extensionToType(string ext) {
				switch (ext) {
					case "bmp": return IL_BMP;
					case "png": return IL_PNG;
                    case "tga": return IL_TGA;
					default: throw new ResourceException("Invalid image file extension.");
				}
			}
			
			/// Returns an image format from a DevIL format.
			Format devilToFormat(ILenum format) {
				switch (format) {
					case IL_RGB: return Format.RGB;
					case IL_RGBA: return Format.RGBA;
					default: throw new ResourceException("Invalid DevIL image format.");
				}
			}
			
			/// Checks for DevIL errors and throws and ResourceException on error.
			void checkErrors(string file = __FILE__, int line = __LINE__) {
				auto err = ilGetError();
				if (err != IL_NO_ERROR) {
					string errstr = to!string(iluErrorString(err));
					throw new ResourceException("DevIL error occured: " ~ errstr,
						file, line);
				}
			}
		}
	}
	
	/// Name is the resource name and path is the path.
	this(in Path path) {
		super(path);
		
		_name = ilGenImage();
		
		reset();
		checkErrors();
	}
	
	~this() {
		scope(exit) {
			ilDeleteImage(_name);
			checkErrors();
		}
	}
	
	/// Loads the image from a file.
	void loadFromFile(string fileName) {
		// Get file infos.
		string ext = extension(fileName)[1 .. $];
		auto fileType = extensionToType(ext);
		auto data = read(fileName);
		
		// Bind the image and load the data.
		bind();
		ilLoadL(fileType, data.ptr, cast(uint)data.length);
        iluFlipImage();
		
		// If errors occur, reset the image to meaningful state, basic guarantee.
		scope(failure) reset();
		
		// The data type always has to be unsigned byte.
		auto type = ilGetInteger(IL_IMAGE_TYPE);
		if (type != IL_UNSIGNED_BYTE) {
			throw new ResourceException("Image " ~ path.full ~ ": Trying to load" ~
				" an image with a data type which is not unsigned byte. Path: " ~
				fileName ~ ".");
		}
		
		// Get the texture format out of DevIL.
		updateFormat();
		
		checkErrors();
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
		tex.size = size;
		
		// Get the raw data of the image.
		bind();
		auto dataptr = ilGetData();
		
		auto s = ilGetInteger(IL_IMAGE_SIZE_OF_DATA);
		auto data = new ubyte[s];
		
		// Copy the raw data to the range.
		foreach (i, ref b; data) {
			b = dataptr[i];
		}
		
		// Finally, set the data of the texture.
		tex.data = data;
        
        checkErrors();
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
	
	/**
	 * Resets the image to its default state.
	 */
	void reset() {
		bind();
		
		// Set the image to 1x1, RGB.
		byte[3] d;
		ilTexImage(1, 1, 1, 3, IL_RGB, IL_BYTE, d.ptr);
		_format = Format.RGB;
		
		checkErrors();
	}
	
	@property {
		/// Returns the image size.
		Vector2ui size() const {
			bind();
			return Vector2ui(ilGetInteger(IL_IMAGE_WIDTH),
				ilGetInteger(IL_IMAGE_HEIGHT));
		}
		
		/// Returns the image width.
		uint width() const {
			bind();
			return ilGetInteger(IL_IMAGE_WIDTH);
		}
		
		/// Returns the image height.
		uint height() const {
			bind();
			return ilGetInteger(IL_IMAGE_HEIGHT);
		}
	}
	
	override {
		void loadFromRaw(const(void)[] data) {
			bind();
			ilLoadL(IL_PNG, data.ptr, cast(uint)data.length);
			updateFormat();
			checkErrors();
		}
		
		void[] saveToRaw() const {
			bind();
			
			auto s = ilGetInteger(IL_IMAGE_SIZE_OF_DATA);
			void[] ret;
			ret.length = s;
			ilSaveL(IL_PNG, ret.ptr, cast(uint)ret.length);
			
			checkErrors();
			return ret;
		}
	}
	
	private {
		ILuint _name;
		Format _format;
		Texture[Context] _textures;
		
		/// Bind the current image.
		void bind() const {
			ilBindImage(_name);
			checkErrors();
		}
		
		/// Get the format from the DevIL image.
		void updateFormat() {
			bind();
			auto devilFormat = ilGetInteger(IL_IMAGE_FORMAT);
			_format = devilToFormat(devilFormat);
		}
	}
}
    
}
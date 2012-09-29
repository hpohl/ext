module ext.resource.image;

/**
 * This module currently uses DevIL as image library.
 * There are alternatives and an abstraction like ImageCodec is
 * planned, but for now this will do the job.
 */

import std.conv;
import std.file;
import std.path;

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
	Texture genTexture(Context con) {
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
		foreach (i, b; data) {
			b = dataptr[i];
		}
		
		// Finally, set the data of the texture.
		tex.data = data;
		
		return tex;
	}
	
	/**
	 * Creates a texture from this image for this context if not
	 * already created.
	 */
	Texture getTexture(Context con) {
		if (con in _textures) {
			return _textures[con];
		} else {
			auto tex = genTexture(con);
			_textures[con] = tex;
			return tex;
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
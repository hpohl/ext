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
import std.zlib;

import ext.math.vector;
import ext.render.context;
import ext.render.texture;
import ext.resource.exception;
import ext.resource.external.devil;
import ext.resource.path;
import ext.resource.resource;


/**
 * A usual image. Used for textures etc...
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
		checkErrors();
	}
	
	~this() {
		scope(exit) {
			ilDeleteImage(_name);
		}
		checkErrors();
	}
	
	/// Loads the image from a file.
	void loadFromFile(string fileName) {
		string ext = extension(fileName)[1 .. $];
		auto type = extensionToType(ext);
		auto data = read(fileName);	
		bind();
		
		ilLoadL(type, data.ptr, cast(uint)data.length);
	}
	
	/// Creates _always_ a new texture from this image using the given context.
	Texture genTexture(Context con) {
		auto tex = con.createTexture(Format.RGBA);
		return tex;
	}
	
	/**
	 * Creates a texture from this image for this context if not
	 * already created.
	 */
	Texture getTexture(Context con) {
		if (con in _textures) {
			return _textures[con];
		}
		
		else return genTexture(con);
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
		void loadFromRaw(in void[] data) {
			bind();
			ilLoadL(IL_PNG, data.ptr, cast(uint)data.length);
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
		Texture[Context] _textures;
		
		/// Bind the current image.
		void bind() const {
			ilBindImage(_name);
			checkErrors();
		}
	}
}
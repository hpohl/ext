module ext.render.texture;

import ext.math.vector;
import ext.render.context;


/// Data format of textures.
enum Format {
    RGB,
	RGBA,
	internal
}

/**
 * A texture is a 2D drawable object.
 */
class Texture : ContextCreated {
	/// Constructs it from a context, which should be the used one.
	this(Format format, Context context) {
		super(context);
		_format = format;
	}
	
	// Properties...
	@property {
		/// Returns the format of the texture.
		Format format() const nothrow pure {
			return _format;
		}
		
		/// Returns the size.
		abstract Vector2ui size() const;
		
		/// Resizes the texture.
		abstract void size(in Vector2ui size);
		
		/// Returns the image data.
		abstract inout(ubyte)[] data() inout;
		
		/// Sets the image data.
		abstract void data(const(ubyte)[] data);
	}
	
	private {
		Format _format;
	}
}
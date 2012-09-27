module ext.gui.picture;

import ext.gui.widget;
import ext.render.context;
import ext.render.geometry;
import ext.render.target;
import ext.render.texture;


/**
 * A picture draws a texture at the given position
 * and size.
 */
class Picture : Widget {
	/// Tex will be displayed.
	this(Texture tex) {
		_texture = tex;
		_geometry = _texture.context.createGeometry();
	}
	
	@property nothrow pure {
		/// Returns the associated texture.
		inout(Texture) texture() inout {
			return _texture;
		}
		
		/// Sets the texture to be drawn.
		void texture(Texture texture) {
			_texture = texture;
		}
	}
	
	override {
		void draw(Target target) {
			
		}
	}
	
	private {
		Texture _texture;
		Geometry _geometry;
	}
}
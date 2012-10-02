module ext.gui.picture;

import ext.gui.widget;
import ext.math.matrix;
import ext.render.context;
import ext.render.geometry;
import ext.render.target;
import ext.render.texture;
import ext.resource.image;
import ext.resource.material;
import ext.resource.path;


/**
 * A picture draws an image at the given position
 * and size.
 */
class Picture : Widget {
	/// Img will be displayed.
	this(Image img) {
		_img = img;
		
		_mat = new Material(Path("ext.gui.picture:mat"));
		_mat.appendTexture(_img);
	}
	
	@property nothrow pure {
		/// Returns the associated image.
		inout(Image) image() inout {
			return _img;
		}
		
		/// Sets the image to be drawn.
		void image(Image img) {
			_img = img;
		}
	}
	
	override {
		void draw(Target target) {
			if (target.context !in _geometries) {
				auto geo = target.context.createGeometry();
				geo.setToQuad(1.0, true);
				_geometries[target.context] = geo;
			}
			
			auto geo = _geometries[target.context];
			
			Matrix4x4f proj;
			orthographic(proj, 0.0, 1.0, 0.0, 1.0, -1.0, 1.0);
			
			Matrix4x4f mdlview;
			
			geo.draw(target, _mat.getProgram(geo.context),
				mdlview, proj);
		}
	}
	
	private {
		Image _img;
		Geometry[Context] _geometries;
		Material _mat;
	}
}
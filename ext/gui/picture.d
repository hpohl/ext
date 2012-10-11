module ext.gui.picture;

import std.stdio;

import ext.gui.udim;
import ext.gui.widget;
import ext.math.matrix;
import ext.math.vector;
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
		
        // Default picture size.
        size = UDim(Vector2f(0.25, 0.25));
        
        // Create the used material and set texture.
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
            /// If the size is zero, we don't need to draw anything.
            if (size == UDim(Vector2f(0.0, 0.0), Vector2i(0, 0))) {
                return;
            }
            
            // If we don't have created the geometry for this context yet, create it.
			if (target.context !in _geometries) {
				auto geo = target.context.createGeometry();
				geo.setToQuad(1.0, true);
				_geometries[target.context] = geo;
			}
			
            // Get the gerometry.
			auto geo = _geometries[target.context];
			
            // Orthographic projection.
			Matrix4x4f proj;
			orthographic(proj, 0.0, 1.0, 0.0, 1.0, -1.0, 1.0);
            
            // Calculate modelview matrix.
			Matrix4x4f mdlview;
            identity(mdlview);
            
            auto currentrel = size.rel + (cast(Vector2f)size.abs / cast(Vector2f)target.size);
            
            // Set the relative size.
            auto relscale = Vector3f(currentrel, 1.0);
            mdlview.scale(relscale);
            
            // Translate to middle.
            mdlview.translate(Vector3f(currentrel / 2.0, 0.0));
            mdlview.translate(Vector3f(0.0, 1.0 - currentrel.y, 0.0));
            
            // Translate relative position.
            auto reltrans = Vector3f(pos.rel.x, -pos.rel.y, 0.0);
            mdlview.translate(reltrans);
            
            // Translate the absolute position.
            auto abstrans = Vector3f(cast(float)pos.abs.x / cast(float)target.size.x,
                -cast(float)pos.abs.y / cast(float)target.size.y, 0.0);
            mdlview.translate(abstrans);
            
            auto prog = _mat.getProgram(geo.context);
			geo.draw(target, prog, mdlview, proj);
		}
	}
	
	private {
		Image _img;
		Geometry[Context] _geometries;
		Material _mat;
	}
}
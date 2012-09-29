module ext.render.geometry;

import ext.math.vector;
import ext.render.context;


/**
 * Represents a triangle in space.
 */
struct Triangle {
	/// First point.
	Vector3f a;
	
	/// Second point.
	Vector3f b;
		
	/// Third point.
	Vector3f c;
	
	/// Range of texture coordinates.
	Vector2f[3][] texCoords;
}

/**
 * Represents any geometry drawn.
 */
class Geometry : ContextCreated {
	/// Uses this context.
	this(Context context) {
		super(context);
	}	
	
	abstract {
		@property {
			/// Returns the triangles.
			Triangle[] data() const;
			
			/// Sets the triangles.
			void data(in Triangle[] data);
		}
	}
}
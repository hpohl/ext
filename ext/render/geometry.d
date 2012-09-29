module ext.render.geometry;

import ext.math.matrix;
import ext.math.vector;
import ext.render.context;
import ext.render.program;
import ext.render.target;


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
	
	/// Resets the geometry to a quad.
	void setToQuad(float size, bool texCoords) {
		Triangle[2] quad;
		
		auto halfSize = size / 2.0;
		
		/*
		 * 
		 * (A2, B3)
		 * |\-----|(B2)
		 * | \    |
		 * |  \   |
		 * |   \  |
		 * |    \ |
		 * |-----\|(A1, B1)
		 * (A3)
		 * 
		 */
		
		quad[0].a = Vector3f(+halfSize, -halfSize, 0.0);
		quad[0].b = Vector3f(-halfSize, +halfSize, 0.0);
		quad[0].c = Vector3f(-halfSize, -halfSize, 0.0);
		
		quad[1].a = Vector3f(+halfSize, -halfSize, 0.0);
		quad[1].b = Vector3f(+halfSize, +halfSize, 0.0);
		quad[1].c = Vector3f(-halfSize, +halfSize, 0.0);
		
		if (texCoords) {
			quad[0].texCoords.length = 1;
			quad[1].texCoords.length = 1;
			
			quad[0].texCoords[0][0] = Vector2f(1.0, 0.0);
			quad[0].texCoords[0][1] = Vector2f(0.0, 1.0);
			quad[0].texCoords[0][1] = Vector2f(0.0, 1.0);
			
			quad[1].texCoords[0][0] = Vector2f(1.0, 0.0);
			quad[1].texCoords[0][1] = Vector2f(1.0, 1.0);
			quad[1].texCoords[0][2] = Vector2f(0.0, 1.0);
		}
		
		data = quad;
	}
	
	abstract {
		/**
		 * Draws the geometry to the target using the given modelview-
		 * and projection matrix.
		 */
		void draw(Target target, const Program prog,
			in Matrix4x4f modelview, in Matrix4x4f projection);
		
		@property {
			/// Returns the number of triangles.
			ulong numTriangles() const;
			
			/// Returns the triangles.
			Triangle[] data() const;
			
			/// Sets the triangles.
			void data(in Triangle[] data);
		}
	}
}
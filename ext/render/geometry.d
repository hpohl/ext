module ext.render.geometry;

import ext.math.matrix;
import ext.math.vector;
import ext.render.context;
import ext.render.program;
import ext.render.target;


/**
 * Texture coordiantes of a triangle.
 */
struct TriangleTexCoords {
    /// First point.
    Vector2f a;
    
    /// Second point.
    Vector2f b;
    
    /// Third point.
    Vector2f c;
}
    
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
}

/**
 * Represents any geometry drawn.
 */
class Geometry : ContextCreated {
	/// Uses this context.
	this(Context context) {
		super(context);
	}

	/// Enum to specify whether texture coordinates should be generated or not.
	enum GenTexCoords {
		yes, no
	}
	
	/// Resets the geometry to a quad.
	void setToQuad(float size, GenTexCoords genTexCoords = GenTexCoords.yes) {
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
        
        vertices = quad;
		
		if (genTexCoords == GenTexCoords.yes) {
            TriangleTexCoords[][] tcs;
            tcs.length = 1;
            tcs[0].length = 2;
			
			tcs[0][0].a = Vector2f(1.0, 0.0);
			tcs[0][0].b = Vector2f(0.0, 1.0);
			tcs[0][0].c = Vector2f(0.0, 0.0);
			
			tcs[0][1].a = Vector2f(1.0, 0.0);
			tcs[0][1].b = Vector2f(1.0, 1.0);
			tcs[0][1].c = Vector2f(0.0, 1.0);
            
            this.texCoords = tcs;
		}
	}
	
	abstract {
		/**
		 * Draws the geometry to the target using the given modelview-
		 * and projection matrix.
		 */
		void draw(Target target, const Program prog,
                  Matrix4x4f modelview, Matrix4x4f projection);
		
		@property {
			/// Returns the vertices as triangles.
			inout(Triangle)[] vertices() inout;
			
			/// Sets the vertices
			void vertices(Triangle[] vertices);
            
            /// Returns the texture coordiantes.
            inout(TriangleTexCoords)[][] texCoords() inout;
            
            /// Sets the texture coordiantes.
            void texCoords(TriangleTexCoords[][] texCoords);
		}
	}
}
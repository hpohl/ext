module ext.render.target;

import ext.math.vector;
import ext.render.context;
import ext.render.texture;


/**
 * A render target, which is used to render at. Can also
 * be used as texture.
 */
class Target : ContextCreated {
	/// The default target size.
	enum defaultSize = Vector2ui(512, 512);
	
	this(Context context) {
		super(context);
	}
	
	// To be implemented...
	abstract {
		/// Clears the render target.
		void clear();
        
        /// Clears the depth only.
        void clearDepth();
		
		@property {
			/// Returns the size.
			abstract Vector2ui size() const;
		
			/// Resizes the target.
			abstract void size(Vector2ui size);
			
			/// The texture used.
			inout(Texture) texture() inout;
		}
	}
}
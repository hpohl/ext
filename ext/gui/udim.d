module ext.gui.udim;

import ext.math.vector;


/**
 * Represents an unified dimension. This is the same concept
 * found in Crazy Eddies GUI system.
 */
struct UDim {
	/**
	 * Creates a unified dimension from relative and absolute
	 * 2D coordinates.
	 */
	this(ref const Vector2f rel, ref const Vector2i abs = Vector2i(0, 0)) {
		_rel = rel;
		_abs = abs;
	}
	
	@property nothrow pure {
		/// Returns the relative position (0 .. 1).
		auto ref rel() inout {
			return _rel;
		}
        
        /// Sets the relative position.
        void rel(ref const Vector2f rel) {
            _rel = rel;
        }
		
		/// Returns the absolute position.
		const Vector2i abs() const {
			return _abs;
		}
        
        /// Sets the absolute position.
        void abs(ref const Vector2i abs) {
            _abs = abs;
        }
	}
	
	private {
        Vector2f _rel;
		Vector2i _abs;
	}
}
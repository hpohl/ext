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
	this(in Vector2f rel = Vector2f(0.0, 0.0),
		in Vector2i abs = Vector2i(0, 0)) {
		_rel = rel;
		_abs = abs;
	}
	
	@property nothrow pure {
		/// Returns the relative position (0 .. 1).
		auto ref rel() inout {
			return _rel;
		}
		
		/// Returns the absolute position.
		auto ref abs() inout {
			return _abs;
		}
	}
	
	private {
		Vector2f _rel;
		Vector2i _abs;
	}
}
module ext.gui.widget;

import ext.gui.udim;
import ext.render.target;


/**
 * This is the base class of all GUI-related things
 * you can see and play with on the screen, e.g. images,
 * buttons, etc.
 */
class Widget {
	/// Creates a widget from it's position and size.
	this(in UDim position = UDim(), in UDim size = UDim()) {
		_pos = position;
		_size = size;
	}
	
	abstract {
		/// Draws the widget.
		void draw(Target target);
	}
	
	@property nothrow pure {
		/// Returns the position in UDim.
		auto ref pos() inout {
			return _pos;
		}
		
		/// Returns the size in UDim.
		auto ref size() inout {
			return _size;
		}
	}
	
	private {
		UDim _pos;
		UDim _size;
	}
}
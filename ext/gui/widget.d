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
	this(ref const UDim position = UDim(), ref const UDim size = UDim()) {
		_pos = position;
		_size = size;
	}
	
	abstract {
		/// Draws the widget.
		void draw(Target target);
	}
	
	@property nothrow pure {
		/// Returns the position in UDim.
		UDim pos() const {
			return _pos;
		}
        
        /// Sets the position.
        void pos(ref const UDim pos) {
            _pos = pos;
        }
		
		/// Returns the size in UDim.
		UDim size() const {
			return _size;
		}
        
        /// Sets the size.
        void size(ref const UDim size) {
            _size = size;
        }
	}
	
	private {
		UDim _pos;
		UDim _size;
	}
}
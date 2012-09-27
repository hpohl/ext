module ext.gui.layout;

import ext.gui.widget;
import ext.render.target;
import ext.window.inputdevice;


/**
 * A layout is a combination of different widgets to
 * build a GUI. It also draws the mouse cursor if
 * needed.
 */
class Layout {
	/**
	 * Creates a layout from an input device of which
	 *  to take the input from.
	 */
	this(InputDevice inputDevice) {
		_inputDevice = inputDevice;
	}
	
	/// Draws all widgets of the layout to the target.
	void draw(Target target) {
		foreach (wid; _widgets) {
			wid.draw(target);
		}
	}
	
	@property nothrow pure {
		/// Returns all widgets of this layout.
		inout(Widget[]) widgets() inout {
			return _widgets;
		}
	}
	
	private {
		InputDevice _inputDevice;
		Widget[] _widgets;
	}	
}
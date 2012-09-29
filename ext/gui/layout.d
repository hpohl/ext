module ext.gui.layout;

import std.algorithm;

import ext.gui.exception;
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
	
	@property {
		/// Add a widget to this layout.
		void add(Widget w) {
			if (find(_widgets, w).length) {
				return;
			}
			_widgets ~= w;
		}
		
		/// Remove a widget.
		void remove(Widget widget) {
			auto idx = countUntil(_widgets, widget);
			if (idx != -1) {
				std.algorithm.remove(_widgets, idx);
			} else {
				throw new GUIException("Widget cannot be removed: It does not exist.");
			}
		}
		
		nothrow pure {
			/// Returns all widgets of this layout.
			inout(Widget[]) widgets() inout {
				return _widgets;
			}
		}
	}
	
	private {
		InputDevice _inputDevice;
		Widget[] _widgets;
	}	
}
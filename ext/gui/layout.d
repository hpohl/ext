module ext.gui.layout;

import std.algorithm;

import ext.gui.exception;
import ext.gui.picture;
import ext.gui.udim;
import ext.gui.widget;
import ext.math.vector;
import ext.render.target;
import ext.resource.image;
import ext.window.inputdevice;


/**
 * A layout is a combination of different widgets to
 * build a GUI. It also draws the mouse cursor if
 * needed.
 */
class Layout {
	/**
	 * Creates a layout from an input device of which
	 * to take the input from. Also specializes how the
     * mouse pointer should look like.
	 */
	this(InputDevice inputDevice, Image mousePointer) {
		_inputDevice = inputDevice;
		_mousePointer = new Picture(mousePointer);
		_mousePointer.size = UDim(Vector2f(0.0, 0.0), Vector2i(32, 32));
	}
	
	/// Draws all widgets of the layout to the target.
	void draw(Target target) {
		foreach (wid; _widgets) {
			wid.draw(target);
			target.clearDepth();
		}
		
		// Update mouse position & draw cursor.
		auto rel = Vector2f(0.0, 0.0);
		auto abs = cast(Vector2i)_inputDevice.mousePosition;
		_mousePointer.pos = UDim(rel, abs);
		_mousePointer.draw(target);
	}
	
	@property {
		/// Add a widget to this layout.
		void add(Widget w) {
			if (find(_widgets, w).length) {
				throw new GUIException("Cannot add widget to layout: Already added.");
			}
			_widgets ~= w;
		}
		
		/// Remove a widget.
		void remove(Widget widget) {
			auto idx = countUntil(_widgets, widget);
			if (idx != -1) {
				_widgets = _widgets.remove(idx);
			} else {
				throw new GUIException("Widget cannot be removed: It does not exist.");
			}
		}
		
		nothrow pure {
			/// Returns all widgets of this layout.
			inout(Widget)[] widgets() inout {
				return _widgets;
			}
			
			/// Return the picture of the mouse pointer.
			inout(Picture) mousePointer() inout {
				return _mousePointer;
			}
		}
	}
	
	private {
		InputDevice _inputDevice;
		Widget[] _widgets;
		Picture _mousePointer;
	}	
}
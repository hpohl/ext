module ext.window.inputdevice;

import std.ascii;
import std.signals;

import ext.math.vector;


/**
 * An enum containing all mouse buttons.
 */
enum MouseButton {
	left,
	middle,
	right
}

/**
 * An input device catches input events and sends them out to public.
 */
abstract class InputDevice {
	
	/// If the mouse button given by mb is pressed.
	abstract bool isPressed(MouseButton mb);
}
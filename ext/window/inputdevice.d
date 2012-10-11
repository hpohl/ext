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
 * An enum containing all keys.
 */
enum Key {
    A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z,
    a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z,
}

/**
 * An input device catches input events and sends them out to public.
 */
abstract class InputDevice {
	
	/// If the mouse button given by mb is pressed.
	abstract bool isPressed(MouseButton mb);
    
    /// Returns the mouse position.
    @property Vector2ui mousePosition();
    
    /// If the key is pressed.
    abstract bool isPressed(Key k);
}
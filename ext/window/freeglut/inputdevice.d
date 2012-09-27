module ext.window.freeglut.inputdevice;

import std.algorithm;
import std.container;

import ext.window.exception;
import ext.window.freeglut.api;
import ext.window.inputdevice;


/**
 * FreeGLUT implementation of the input device.
 */
class InputDevice : ext.window.inputdevice.InputDevice {
	
	override {
		bool isPressed(MouseButton mb) {
			return mb in _mbs;
		}
	}
	
	package {
		/// Injects a mouse button state update from GLUT.
		void injectMouse(int button, int state) {
			MouseButton mb;
			
			switch (button) {
				case GLUT_LEFT_BUTTON: mb = MouseButton.left; break;
				case GLUT_MIDDLE_BUTTON: mb = MouseButton.middle; break;
				case GLUT_RIGHT_BUTTON: mb = MouseButton.right; break;
				default: throw new WindowException("Invalid FreeGLUT mouse button."); break;
			}
			
			if (state == GLUT_DOWN) {
				if (!(mb in _mbs)) {
					_mbs.stableInsert(mb);
				}
			} else if (state == GLUT_UP) {
				_mbs.removeKey(mb);
			}
		}
	}
	
	private {
		RedBlackTree!MouseButton _mbs;
	}
}
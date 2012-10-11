module ext.window.freeglut.inputdevice;

import std.algorithm;
import std.ascii;
import std.container;
import std.conv;

import ext.math.vector;
import ext.window.exception;
import ext.window.freeglut.api;
import ext.window.inputdevice;


/**
 * FreeGLUT implementation of the input device.
 */
class InputDevice : ext.window.inputdevice.InputDevice {
    static {
        private {
            Key keycodeToKey(char key) {
                string switchCode() {
                    string ret;
                    foreach (c; letters) {
                        ret ~= "case '" ~ c ~ "': return Key." ~ c ~ ";";
                    }
                    
                    return ret;
                }
                
                switch (key) {
                    mixin(switchCode());
                    default: throw new WindowException("FreeGLUT: Invalid key code.");
                }
            }
        }
    }
    
    this() {
        _mbs = new RedBlackTree!MouseButton;
        _keys = new RedBlackTree!Key;
    }
    
	override {
		bool isPressed(MouseButton mb) {
			return mb in _mbs;
		}
        
        @property Vector2ui mousePosition() {
            return _mousePos;
        }
        
        bool isPressed(Key k) {
            return k in _keys;
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
					_mbs.insert(mb);
				}
			} else if (state == GLUT_UP) {
				_mbs.removeKey(mb);
			}
		}
        
        /// Injects a mouse position update.
        void injectMousePosition(int x, int y) {
            _mousePos.x = x;
            _mousePos.y = y;
        }
        
        /// Injects a keyboard press event from GLUT.
        void injectKeyPressed(char keyc) {
            auto key = keycodeToKey(keyc);
            
            if (key !in _keys) {
                _keys.insert(key);
            }
        }
        
        /// Injects a keyboard release event from GLUT.
        void injectKeyReleased(char keyc) {
            auto key = keycodeToKey(keyc);
            _keys.removeKey(key);
        }
	}
	
	private { 
		RedBlackTree!MouseButton _mbs;
        RedBlackTree!Key _keys;
        Vector2ui _mousePos;
	}
}
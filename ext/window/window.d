module ext.window.window;

import std.signals;

import ext.math.vector;
import ext.render.target;
import ext.window.inputdevice;


/**
 * Implemented by window systems, e.g. FreeGLUT.
 */ 
class Window {
	
	/// The default window title. Implementations have to default to it.
	enum defaultTitle = "ext window";
	
	// Abstracts...
	abstract {
		/// Update all windows.
		void update();
		
		// Properties...
		@property {
			/// Returns the title of the window.
			string title() const;
			
			/// Sets the title.
			void title(string title);
			
			/// Returns the current size of the window.
			Vector2ui size() const;
			
			/// Resized the window.
			void size(in Vector2ui size);
			
			/// Returns the render target given by the window.
			inout(Target) target() inout;
			
			/// Returns the input system.
			inout(InputDevice) inputDevice() inout;
		}
	}
	
	//////////////////////////////////////////////////////
	/// Emmited when window is ready to be drawn.
	private static struct DrawSignal {
		mixin Signal!();
	}
	
	DrawSignal draw;
}
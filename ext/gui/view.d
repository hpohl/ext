module ext.gui.view;

import ext.gui.widget;
import ext.render.target;


/**
 * A view shows whatever is drawn on its target at
 * it's given position.
 */
class View : Widget {
	/// Creates a view which draws the given target.
	this(Target target) {
		_target = target;
	}
	
	@property nothrow pure {
		/// Returns the target which the view will draw.
		inout(Target) target() inout {
			return _target;
		}
	}
	
	override {
		void draw(Target target) {
			
		}
	}
	
	private {
		Target _target;
	}
}
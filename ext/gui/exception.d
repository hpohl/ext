module ext.gui.exception;

import ext.misc.exception;


/**
 * Every exception thrown by the gui module is derived from this.
 */
class GUIException : ExtException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
	}
}
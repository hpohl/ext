module ext.resource.exception;

import ext.misc.exception;


/**
 * Every exception thrown by the resourc module is derived from this.
 */
class ResourceException : ExtException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) nothrow pure {
        super(msg, file, line, next);
	}
}
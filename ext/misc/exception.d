module ext.misc.exception;

/**
 * This module contains various utilites and classes for exception handling.
 */

/// Every exception thrown by ext is derived from this one.
class ExtException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}

/// Every exception thrown by ext.misc package is derived from this one.
class MiscException : ExtException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
	}
}
module ext.render.opengl.exception;

/**
 * This module provides tools for throwing exceptions on OpenGL errors.
 */

import ext.render.exception;
import ext.render.opengl.api;
import ext.render.opengl.context;

/**
 * Converts and OpenGL error code to a string.
 * Throws: OpenGLException if the error code is invalid.
 */
string errorToString(GLenum error) {
	switch (error) {
		case GL_NO_ERROR: return "no error";
		case GL_INVALID_ENUM: return "invalid enum";
		case GL_INVALID_VALUE: return "invalid value";
		case GL_INVALID_OPERATION: return "invalid operation";
		case GL_INVALID_FRAMEBUFFER_OPERATION: return "invalid framebuffer operation";
		case GL_OUT_OF_MEMORY: return "out of memory";
		case GL_STACK_UNDERFLOW: return "stack underflow";
		case GL_STACK_OVERFLOW: return "stack overflow";
		default: throw new OpenGLException("Invalid error code.");
	}
}

/**
 * Every exception thrown by the OpenGL module is derived from this class.
 */
class OpenGLException : RenderException {
	this(string msg, string file = __FILE__, size_t line = __LINE__,
         Throwable next = null) nothrow pure {
		super(msg, file, line, next);
	}
}

/**
 * Used if there occured an OpenGL error.
 */
class OpenGLErrorException : OpenGLException {
	this(GLenum error, string msg, string file = __FILE__,
         size_t line = __LINE__, Throwable next = null) nothrow pure {
		super(msg, file, line, next);
		this.error = error;
	}
	
	/// The error code. Can be converted using errorToString.
	GLenum error = GL_NO_ERROR;
}

/**
 * Throws if an OpenGL error occured.
 */
void throwOnGLError(const Context ctx, string msg = "", string file = __FILE__,
                    size_t line = __LINE__, Throwable next = null) nothrow {
    GLenum err;
    try {
	    err = ctx.nocheckglGetError();
    } catch (Exception) { }
	if (err != GL_NO_ERROR) {
		//throw new OpenGLErrorException(err, msg ~ ", " ~ errorToString(err), file, line, next);
	}
}
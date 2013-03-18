module ext.render.opengl.target;

import std.stdio;

import ext.math.vector;
import ext.render.opengl.api;
import ext.render.opengl.context;
import ext.render.opengl.exception;
import ext.render.opengl.texture;
import ext.render.target;
import ext.render.texture;


/**
 * OpenGL implementation of a render target using
 * Framebuffers.
 */
class Target : ext.render.target.Target {
	// Is an OpenGL object.
	mixin OpenGLObject;
	
	/// Creates a target from an OpenGL context.
	this(Context context, Vector2ui size = defaultSize) {
		super(context);
		_size = size;
		
		// Create framebuffer object.
		context.glGenFramebuffers(1, &_fbo);
		scope(failure) context.glDeleteFramebuffers(1, &_fbo);
		
		bind();
		
		// Create OpenGL texture as colour attachment.
		_colorAttachment = new ext.render.opengl.texture.Texture(Format.RGBA, context);
		_colorAttachment.size = size;

		// Bind colour attachment.
		context.glBindTexture(GL_TEXTURE_2D, _colorAttachment.name);
		context.glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
			GL_TEXTURE_2D, _colorAttachment.name, 0);

		// Generate OpenGL render buffer as depth attachment.
		context.glGenRenderbuffers(1, &_rbo);
		scope(failure) context.glDeleteRenderbuffers(1, &_rbo);
		
		context.glBindRenderbuffer(GL_RENDERBUFFER, _rbo);
		context.glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, size.x, size.y);
		
		// Bind depth attachment.
		context.glFramebufferRenderbuffer(GL_FRAMEBUFFER,
			GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _rbo);
		
		// Check for completeness.
		auto completeness = context.glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (completeness != GL_FRAMEBUFFER_COMPLETE) {
            throw new OpenGLException("Framebuffer not complete.");
        }
	}
	
	~this() {
		// Release as much as possible, come hell or high water.
		scope(exit) {
			context.glDeleteFramebuffers(1, &_fbo);
			context.glDeleteRenderbuffers(1, &_rbo);
		}
	}
    
    /// Binds the framebuffer.
    void bind() {
        context.glBindFramebuffer(GL_FRAMEBUFFER, _fbo);
    }
	
	// Properties...
	@property nothrow pure {
        /// Returns the name of the frame buffer.
		GLuint fbo() {
			return _fbo;
		}
		
        // The texture to draw to.
		ext.render.opengl.texture.Texture colorAttachment() {
			return _colorAttachment;
		}
		
        // The render buffer name.
		GLuint rbo() {
			return _rbo;
		}
	}
	
	override {
		void clear() {
			bind();
			context.glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		}
        
        void clearDepth() {
            bind();
            context.glClear(GL_DEPTH_BUFFER_BIT);
        }
		
		@property {
			Vector2ui size() const {
				return _size;
			}
			
			void size(Vector2ui size) {
				assert(false, "Not yet implemented.");
			}
			
			inout(ext.render.opengl.texture.Texture) texture() inout {
				return _colorAttachment;
			}
		}
	}
	
	
	private {
		GLuint _fbo;
		ext.render.opengl.texture.Texture _colorAttachment;
		GLuint _rbo;
		Vector2ui _size;
	}
}
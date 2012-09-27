module ext.render.opengl.target;

import std.stdio;

import ext.math.vector;
import ext.render.opengl.api;
import ext.render.opengl.context;
import ext.render.opengl.exception;
import ext.render.opengl.texture;
import ext.render.target;


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
		context.cglGenFramebuffers(1, &_fbo);
		scope(failure) context.cglDeleteFramebuffers(1, &_fbo);
		
		bind();
		
		// Create OpenGL texture as colour attachment.
		_colorAttachment = new Texture(GL_RGBA8, context);
		_colorAttachment.size = size;

		// Bind colour attachment.
		context.cglBindTexture(GL_TEXTURE_2D, _colorAttachment.name);
		context.cglFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
			GL_TEXTURE_2D, _colorAttachment.name, 0);

		// Generate OpenGL render buffer as depth attachment.
		context.cglGenRenderbuffers(1, &_rbo);
		scope(failure) context.cglDeleteRenderbuffers(1, &_rbo);
		
		context.cglBindRenderbuffer(GL_RENDERBUFFER, _rbo);
		context.cglRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, size.x, size.y);
		
		// Bind depth attachment.
		context.cglFramebufferRenderbuffer(GL_FRAMEBUFFER,
			GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _rbo);
		
		// Check for completeness.
		auto completeness = context.cglCheckFramebufferStatus(GL_FRAMEBUFFER);
		
		//writeln(completeness);
	}
	
	~this() {
		// Release as much as possible, come hell or high water.
		scope(exit) {
			context.cglDeleteFramebuffers(1, &_fbo);
			context.cglDeleteRenderbuffers(1, &_rbo);
		}
	}
	
	// Properties...
	@property {
		GLuint fbo() {
			return _fbo;
		}
		
		Texture colorAttachment() {
			return _colorAttachment;
		}
		
		GLuint rbo() {
			return _rbo;
		}
	}
	
	override {
		void clear() {
			bind();
			context.cglClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		}
		
		@property {
			Vector2ui size() const {
				return _size;
			}
			
			void size(in Vector2ui size) {
				assert(false, "Not yet implemented.");
			}
			
			inout(Texture) texture() inout {
				return _colorAttachment;
			}
		}
	}
	
	
	private {
		GLuint _fbo;
		Texture _colorAttachment;
		GLuint _rbo;
		Vector2ui _size;
		
		/// Binds the framebuffer.
		void bind() const {
			context.cglBindFramebuffer(GL_FRAMEBUFFER, _fbo);
		}
	}
}
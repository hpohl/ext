module ext.window.freeglut.window;

import std.stdio;
import std.c.stdlib;

import ext.math.matrix;
import ext.math.vector;
import ext.render.opengl.api;
import ext.render.opengl.context;
import ext.render.opengl.exception;
import ext.render.opengl.target;
import ext.window.exception;
import ext.window.freeglut.api;
import ext.window.freeglut.inputdevice;
import ext.window.window;


/**
 * FreeGLUT implementation.
 */
class Window : ext.window.window.Window {
	static {
		/// Initializes FreeGLUT.
		static this() {
			int argc = 0;
			glutInit(&argc, null);
		}
		
		private {
			// FreeGLUT callbacks.
			extern (C) {
				void display() {
					try {
						// Get the current window & context
						auto w = current();
						auto c = w._context;
						
						/*
						 * Draw the target on a quad using orthogonal projection. We do this,
						 * because it is not possible to create a render target from the
						 * window-created target (OpenGL name 0).
						 */ 
						c.cglBindFramebuffer(GL_FRAMEBUFFER, 0);
						
						c.cglClear(GL_COLOR_BUFFER_BIT);
						
						c.cglBindVertexArray(w._va);
						
						c.cglUseProgram(w._prog);
						
						c.cglActiveTexture(GL_TEXTURE0);
						c.cglBindTexture(GL_TEXTURE_2D, w._target.colorAttachment.name);
						
						auto loc = c.cglGetUniformLocation(w._prog, "tex".ptr);
						c.cglUniform1i(loc, 0);
						
						Matrix!(4, 4, GLfloat) proj;
						orthographic(proj, 0.0, 1.0, 0.0, 1.0, -1.0, 1.0);
						loc = c.cglGetUniformLocation(w._prog, "proj".ptr);
						c.cglUniformMatrix4fv(loc, 1, GL_TRUE, proj.ptr);
						
						c.cglBindBuffer(GL_ARRAY_BUFFER, w._vbo);
						c.cglVertexAttribPointer(10, 4, GL_FLOAT, GL_FALSE, 0, null);
						c.cglEnableVertexAttribArray(10);
						
						c.cglBindBuffer(GL_ARRAY_BUFFER, w._tvbo);
						c.cglVertexAttribPointer(11, 2, GL_FLOAT, GL_FALSE, 0, null);
						c.cglEnableVertexAttribArray(11);
						
						c.cglDrawArrays(GL_TRIANGLE_FAN, 0, 4);
						
						// Finally swap the front and back buffer and ask to render again.
						glutSwapBuffers();
						glutPostRedisplay();
						
					} catch (OpenGLErrorException e) {
						writeln("Catched OpenGL error while drawing root target within FreeGLUT:");
						writeln(e.msg ~ ": " ~ errorToString(e.error));
						exit(1);
					} catch (Error e) {
						writeln(e.file);
					} catch (Throwable) {
						writeln("Unable to draw root target within FreeGLUT.");
						exit(1);
					}
				}
				
				void mouse(int button, int state, int, int) {
					current.inputDevice.injectMouse(button, state);
				}
			}
			
			// Gets the current window.
			static Window current() {
				int id = glutGetWindow();
				return _windows[id];
			}
			
			Window[int] _windows;
		}
	}
	
	/// Creates the window and fills it with default values.
	this() {
		// Use OpenGL 3.3
		glutInitContextVersion(3, 3);
		glutInitContextProfile(GLUT_CORE_PROFILE);
		glutInitContextFlags(GLUT_FORWARD_COMPATIBLE);
		
		// Use double buffering.
		glutInitDisplayMode(GLUT_DOUBLE);
				
		// Create GLUT window.
		_id = glutCreateWindow(_title.ptr);
		
		// Setup input device
		_inputDevice = new InputDevice;
		
		// Setup callback functions.
		glutDisplayFunc(&display);
		glutMouseFunc(&mouse);
		
		// Initialise OpenGL context.
		_context = new Context("/usr/lib/libGL.so");
		
		// Create root target.
		_target = _context.createTarget(size);
		
		// Prepare for displaying the target on screen using a quad.
		_context.cglGenVertexArrays(1, &_va);
		scope(failure) _context.cglDeleteVertexArrays(1, &_va);
		
		_context.cglGenBuffers(1, &_vbo);
		scope(failure) _context.cglDeleteBuffers(1, &_vbo);
		
		_context.cglGenBuffers(1, &_tvbo);
		scope(failure) _context.cglDeleteBuffers(1, &_tvbo);
		
		GLfloat[] quad = [
			1.0, 0.0, 0.0, 1.0,
			1.0, 1.0, 0.0, 1.0,
			0.0, 1.0, 0.0, 1.0,
			0.0, 0.0, 0.0, 1.0
		];
		
		_context.cglBindBuffer(GL_ARRAY_BUFFER, _vbo);
		_context.cglBufferData(GL_ARRAY_BUFFER, quad.length * GLfloat.sizeof,
			quad.ptr, GL_STATIC_DRAW);
		
		GLfloat[] texCoords = [
			1.0, 0.0,
			1.0, 1.0,
			0.0, 1.0,
			0.0, 0.0
		];
		
		_context.cglBindBuffer(GL_ARRAY_BUFFER, _tvbo);
		_context.cglBufferData(GL_ARRAY_BUFFER, texCoords.length * GLfloat.sizeof,
			texCoords.ptr, GL_STATIC_DRAW);
		
		// Prepare shaders.
		_vert = _context.cglCreateShader(GL_VERTEX_SHADER);
		scope(failure) _context.cglDeleteShader(_vert);
		
		const char[] vertSource = "
			#version 330
			
			layout(location=10) in vec4 position;
			layout(location=11) in vec2 texCoord;
			
			out vec2 exTexCoord;
			
			uniform mat4 proj;
			
			void main() {
				gl_Position = proj * position;
				exTexCoord = texCoord; 
			}
			";
		
		
		auto vptr = vertSource.ptr;
		GLint vlen = vertSource.length;
		_context.cglShaderSource(_vert, 1, &vptr, &vlen);
		_context.cglCompileShader(_vert);
		
		_frag = _context.cglCreateShader(GL_FRAGMENT_SHADER);
		scope(failure) _context.cglDeleteShader(_frag);
		
		const char[] fragSource = "
			#version 330
			
			in vec2 exTexCoord;
			
			out vec4 color;
			
			uniform sampler2D tex;
			
			void main() {
				color = texture(tex, exTexCoord);
			}
			";
		
		auto fptr = fragSource.ptr;
		GLint flen = fragSource.length;
		_context.cglShaderSource(_frag, 1, &fptr, &flen);
		_context.cglCompileShader(_frag);
		
		_prog = _context.cglCreateProgram();
		scope(failure) _context.cglDeleteProgram(_prog);
		
		_context.cglAttachShader(_prog, _vert);
		_context.cglAttachShader(_prog, _frag);
		_context.cglLinkProgram(_prog);
		
		GLint len;
		_context.cglGetProgramiv(_prog, GL_INFO_LOG_LENGTH, &len);
		
		char[] log;
		log.length = len;
		
		_context.cglGetProgramInfoLog(_prog, len, null, log.ptr);
		
		writeln(log);
		
		// Add us to all windows.
		_windows[_id] = this;
	}
	
	/// Automatically closes and destroys the window.
	~this() {
		glutDestroyWindow(_id);
	}
	
	override {
		void update() {
			glutMainLoopEvent();
		}
		
		@property {
			string title() const {
				return _title;
			}
			
			void title(string title) {
				set();
				
				// Save the title locally.
				_title = title;
				glutSetWindowTitle(_title.ptr);
			}
			
			Vector2ui size() const {
				set();
				auto w = glutGet(GLUT_WINDOW_WIDTH);
				auto h = glutGet(GLUT_WINDOW_HEIGHT);
				return Vector2ui(w, h);
			}
			
			void size(in Vector2ui size) {
				set();
				glutReshapeWindow(size.x, size.y);
			}
			
			inout(Target) target() inout {
				return _target;
			}
			
			inout(InputDevice) inputDevice() inout {
				return _inputDevice;
			}
		}
	}
	
	private {
		int _id;
		string _title = defaultTitle;
		
		Context _context;
		Target _target;
		InputDevice _inputDevice;
		
		// Used to display the target.
		GLuint _va;
		GLuint _vbo;
		GLuint _tvbo;
		GLuint _vert;
		GLuint _frag;
		GLuint _prog;
		
		/// Binds the window.
		void set() const {
			glutSetWindow(_id);
		}
	}
}
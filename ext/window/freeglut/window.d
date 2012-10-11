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
						c.glBindFramebuffer(GL_FRAMEBUFFER, 0);
						c.glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
						
						c.glUseProgram(w._prog);
						
                        // Uniform framebuffer texture.
						c.glActiveTexture(GL_TEXTURE0);
						c.glBindTexture(GL_TEXTURE_2D, w._target.colorAttachment.name);
						auto loc = c.glGetUniformLocation(w._prog, "tex".ptr);
						c.glUniform1i(loc, 0);
						
						Matrix!(4, 4, GLfloat) proj;
						orthographic(proj, 0.0, 1.0, 0.0, 1.0, -1.0, 1.0);
						loc = c.glGetUniformLocation(w._prog, "proj".ptr);
						c.glUniformMatrix4fv(loc, 1, GL_TRUE, proj.ptr);
                        
                        c.glBindVertexArray(w._va);
                        
						c.glBindBuffer(GL_ARRAY_BUFFER, w._vbo);
						c.glVertexAttribPointer(10, 4, GL_FLOAT, GL_FALSE, 0, null);
						c.glEnableVertexAttribArray(10);
						
						c.glBindBuffer(GL_ARRAY_BUFFER, w._tvbo);
						c.glVertexAttribPointer(11, 2, GL_FLOAT, GL_FALSE, 0, null);
						c.glEnableVertexAttribArray(11);
						
						c.glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
						
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
                    try {
					    current().inputDevice.injectMouse(button, state);
                    } catch (Throwable t) {
                        writeln("Unable to inject mouse press event: " ~ t.msg);
                    }
				}
                
                void motion(int x, int y) {
                    try {
                        current().inputDevice.injectMousePosition(x, y);
                    } catch (Throwable t) {
                        writeln("Unable to inject mouse position: " ~ t.msg);
                    }
                }
                
                void passiveMotion(int x, int y) {
                    try {
                        current().inputDevice.injectMousePosition(x, y);
                    } catch (Throwable t) {
                        writeln("Unable to inject mouse position: " ~ t.msg);
                    }
                }
                
                void keyboard(char key, int x, int y) {
                    try {
                        current().inputDevice.injectKeyPressed(key);
                    } catch (Throwable t) {
                        writeln("Unable to inject key press event: " ~ t.msg);
                    }
                }
                
                void keyboardUp(char key, int x, int y) {
                    try {
                        current().inputDevice.injectKeyReleased(key);
                    } catch (Throwable t) {
                        writeln("Unable to inject key release event: " ~ t.msg);
                    }
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
		glutInitContextProfile(GLUT_COMPATIBILITY_PROFILE);
		//glutInitContextFlags(GLUT_BAC);
		
		// Use double buffering.
		glutInitDisplayMode(GLUT_DOUBLE);
        
        // Default size.
        glutInitWindowSize(defaultSize.x, defaultSize.y);
				
		// Create GLUT window.
		_id = glutCreateWindow(_title.ptr);
		
		// Setup input device
		_inputDevice = new InputDevice;
		
		// Setup callback functions.
		glutDisplayFunc(&display);
		glutMouseFunc(&mouse);
        glutMotionFunc(&motion);
        glutPassiveMotionFunc(&passiveMotion);
        glutKeyboardFunc(&keyboard);
        glutKeyboardUpFunc(&keyboardUp);
        
        // Hide cursor.
        glutSetCursor(GLUT_CURSOR_NONE);
		
		// Initialise OpenGL context.
		_context = new Context("/usr/lib/libGL.so");
		
		// Create root target.
        auto s = size();
		_target = _context.createTarget(s);
		
		// Prepare for displaying the target on screen using a quad.
		_context.glGenVertexArrays(1, &_va);
		scope(failure) _context.glDeleteVertexArrays(1, &_va);
		
		_context.glGenBuffers(1, &_vbo);
		scope(failure) _context.glDeleteBuffers(1, &_vbo);
		
		_context.glGenBuffers(1, &_tvbo);
		scope(failure) _context.glDeleteBuffers(1, &_tvbo);
		
		GLfloat[] quad = [
			1.0, 0.0, 0.0, 1.0,
			1.0, 1.0, 0.0, 1.0,
			0.0, 1.0, 0.0, 1.0,
			0.0, 0.0, 0.0, 1.0
		];
		
		_context.glBindBuffer(GL_ARRAY_BUFFER, _vbo);
		_context.glBufferData(GL_ARRAY_BUFFER, quad.length * GLfloat.sizeof,
			quad.ptr, GL_STATIC_DRAW);
		
		GLfloat[] texCoords = [
			1.0, 0.0,
			1.0, 1.0,
			0.0, 1.0,
			0.0, 0.0
		];
		
		_context.glBindBuffer(GL_ARRAY_BUFFER, _tvbo);
		_context.glBufferData(GL_ARRAY_BUFFER, texCoords.length * GLfloat.sizeof,
			texCoords.ptr, GL_STATIC_DRAW);
		
		// Prepare shaders.
		_vert = _context.glCreateShader(GL_VERTEX_SHADER);
		scope(failure) _context.glDeleteShader(_vert);
		
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
		_context.glShaderSource(_vert, 1, &vptr, &vlen);
		_context.glCompileShader(_vert);
		
		_frag = _context.glCreateShader(GL_FRAGMENT_SHADER);
		scope(failure) _context.glDeleteShader(_frag);
		
		const char[] fragSource = "
			#version 330
			
			in vec2 exTexCoord;
			
			out vec4 color;
			
			uniform sampler2D tex;
			
			void main() {
                //color = vec4(1.0, 0.0, 0.0, 1.0);
				color = texture(tex, exTexCoord);
                //color = vec4(exTexCoord, 0.0, 1.0);
			}
			";
		
		auto fptr = fragSource.ptr;
		GLint flen = fragSource.length;
		_context.glShaderSource(_frag, 1, &fptr, &flen);
		_context.glCompileShader(_frag);
		
		_prog = _context.glCreateProgram();
		scope(failure) _context.glDeleteProgram(_prog);
		
		_context.glAttachShader(_prog, _vert);
		_context.glAttachShader(_prog, _frag);
		_context.glLinkProgram(_prog);
		
		GLint len;
		_context.glGetProgramiv(_prog, GL_INFO_LOG_LENGTH, &len);
		
		char[] log;
		log.length = len;
		
		_context.glGetProgramInfoLog(_prog, len, null, log.ptr);
		
		writeln(log);
		
		// Add us to all windows for FreeGLUT lookup.
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
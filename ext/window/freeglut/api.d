module ext.window.freeglut.api;

import core.stdc.config;


alias uint GLenum;
alias ubyte GLboolean;
alias uint GLbitfield;
alias byte GLbyte;
alias short GLshort;
alias int GLint;
alias int GLsizei;
alias ubyte GLubyte;
alias ushort GLushort;
alias uint GLuint;
alias ushort GLhalf;
alias float GLfloat;
alias float GLclampf;
alias double GLdouble;
alias double GLclampd;
alias void GLvoid;

nothrow package extern (C):

// -----------------------------------------
// Standard GLUT
// Special key codes
enum {
    GLUT_KEY_F1 = 0x0001,
    GLUT_KEY_F2 = 0x0002,
    GLUT_KEY_F3 = 0x0003,
    GLUT_KEY_F4 = 0x0004,
    GLUT_KEY_F5 = 0x0005,
    GLUT_KEY_F6 = 0x0006,
    GLUT_KEY_F7 = 0x0007,
    GLUT_KEY_F8 = 0x0008,
    GLUT_KEY_F9 = 0x0009,
    GLUT_KEY_F10 = 0x000A,
    GLUT_KEY_F11 = 0x000B,
    GLUT_KEY_F12 = 0x000C,
    GLUT_KEY_LEFT = 0x0064,
    GLUT_KEY_UP = 0x0065,
    GLUT_KEY_RIGHT = 0x0066,
    GLUT_KEY_DOWN = 0x0067,
    GLUT_KEY_PAGE_UP = 0x0068,
    GLUT_KEY_PAGE_DOWN = 0x0069,
    GLUT_KEY_HOME = 0x006A,
    GLUT_KEY_END = 0x006B,
    GLUT_KEY_INSERT = 0x006C,
}

// Mouse state definitions
enum {
    GLUT_LEFT_BUTTON = 0x0000,
    GLUT_MIDDLE_BUTTON = 0x0001,
    GLUT_RIGHT_BUTTON = 0x0002,
    GLUT_DOWN = 0x0000,
    GLUT_UP = 0x0001,
    GLUT_LEFT = 0x0000,
    GLUT_ENTERED = 0x0001,
}

// Display mode definitions
enum {
    GLUT_RGB = 0x0000,
    GLUT_RGBA = 0x0000,
    GLUT_INDEX = 0x0001,
    GLUT_SINGLE = 0x0000,
    GLUT_DOUBLE = 0x0002,
    GLUT_ACCUM = 0x0004,
    GLUT_ALPHA = 0x0008,
    GLUT_DEPTH = 0x0010,
    GLUT_STENCIL = 0x0020,
    GLUT_MULTISAMPLE = 0x0080,
    GLUT_STEREO = 0x0100,
    GLUT_LUMINANCE = 0x0200,
}

// Windows and menu related definitions
enum {
    GLUT_MENU_NOT_IN_USE = 0x0000,
    GLUT_MENU_IN_USE = 0x0001,
    GLUT_NOT_VISIBLE = 0x0000,
    GLUT_VISIBLE = 0x0001,
    GLUT_HIDDEN = 0x0000,
    GLUT_FULLY_RETAINED = 0x0001,
    GLUT_PARTIALLY_RETAINED = 0x0002,
    GLUT_FULLY_COVERED = 0x0003,
}

// glutGet parameters
enum {
    GLUT_WINDOW_X = 0x0064,
    GLUT_WINDOW_Y = 0x0065,
    GLUT_WINDOW_WIDTH = 0x0066,
    GLUT_WINDOW_HEIGHT = 0x0067,
    GLUT_WINDOW_BUFFER_SIZE = 0x0068,
    GLUT_WINDOW_STENCIL_SIZE = 0x0069,
    GLUT_WINDOW_DEPTH_SIZE = 0x006A,
    GLUT_WINDOW_RED_SIZE = 0x006B,
    GLUT_WINDOW_GREEN_SIZE = 0x006C,
    GLUT_WINDOW_BLUE_SIZE = 0x006D,
    GLUT_WINDOW_ALPHA_SIZE = 0x006E,
    GLUT_WINDOW_ACCUM_RED_SIZE = 0x006F,
    GLUT_WINDOW_ACCUM_GREEN_SIZE = 0x0070,
    GLUT_WINDOW_ACCUM_BLUE_SIZE = 0x0071,
    GLUT_WINDOW_ACCUM_ALPHA_SIZE = 0x0072,
    GLUT_WINDOW_DOUBLEBUFFER = 0x0073,
    GLUT_WINDOW_RGBA = 0x0074,
    GLUT_WINDOW_PARENT = 0x0075,
    GLUT_WINDOW_NUM_CHILDREN = 0x0076,
    GLUT_WINDOW_COLORMAP_SIZE = 0x0077,
    GLUT_WINDOW_NUM_SAMPLES = 0x0078,
    GLUT_WINDOW_STEREO = 0x0079,
    GLUT_WINDOW_CURSOR = 0x007A,

    GLUT_SCREEN_WIDTH = 0x00C8,
    GLUT_SCREEN_HEIGHT = 0x00C9,
    GLUT_SCREEN_WIDTH_MM = 0x00CA,
    GLUT_SCREEN_HEIGHT_MM = 0x00CB,
    GLUT_MENU_NUM_ITEMS = 0x012C,
    GLUT_DISPLAY_MODE_POSSIBLE = 0x0190,
    GLUT_INIT_WINDOW_X = 0x01F4,
    GLUT_INIT_WINDOW_Y = 0x01F5,
    GLUT_INIT_WINDOW_WIDTH = 0x01F6,
    GLUT_INIT_WINDOW_HEIGHT = 0x01F7,
    GLUT_INIT_DISPLAY_MODE = 0x01F8,
    GLUT_ELAPSED_TIME = 0x02BC,
    GLUT_WINDOW_FORMAT_ID = 0x007B,
}

// glutDeviceGet parameters
enum {
    GLUT_HAS_KEYBOARD = 0x0258,
    GLUT_HAS_MOUSE = 0x0259,
    GLUT_HAS_SPACEBALL = 0x025A,
    GLUT_HAS_DIAL_AND_BUTTON_BOX = 0x025B,
    GLUT_HAS_TABLET = 0x025C,
    GLUT_NUM_MOUSE_BUTTONS = 0x025D,
    GLUT_NUM_SPACEBALL_BUTTONS = 0x025E,
    GLUT_NUM_BUTTON_BOX_BUTTONS = 0x025F,
    GLUT_NUM_DIALS = 0x0260,
    GLUT_NUM_TABLET_BUTTONS = 0x0261,
    GLUT_DEVICE_IGNORE_KEY_REPEAT = 0x0262,
    GLUT_DEVICE_KEY_REPEAT = 0x0263,
    GLUT_HAS_JOYSTICK = 0x0264,
    GLUT_OWNS_JOYSTICK = 0x0265,
    GLUT_JOYSTICK_BUTTONS = 0x0266,
    GLUT_JOYSTICK_AXES = 0x0267,
    GLUT_JOYSTICK_POLL_RATE = 0x0268,
}

// glutLayerGet parameters
enum {
    GLUT_OVERLAY_POSSIBLE = 0x0320,
    GLUT_LAYER_IN_USE = 0x0321,
    GLUT_HAS_OVERLAY = 0x0322,
    GLUT_TRANSPARENT_INDEX = 0x0323,
    GLUT_NORMAL_DAMAGED = 0x0324,
    GLUT_OVERLAY_DAMAGED = 0x0325,
}

// glutVideoResizeGet parameters
enum {
    GLUT_VIDEO_RESIZE_POSSIBLE = 0x0384,
    GLUT_VIDEO_RESIZE_IN_USE = 0x0385,
    GLUT_VIDEO_RESIZE_X_DELTA = 0x0386,
    GLUT_VIDEO_RESIZE_Y_DELTA = 0x0387,
    GLUT_VIDEO_RESIZE_WIDTH_DELTA = 0x0388,
    GLUT_VIDEO_RESIZE_HEIGHT_DELTA = 0x0389,
    GLUT_VIDEO_RESIZE_X = 0x038A,
    GLUT_VIDEO_RESIZE_Y = 0x038B,
    GLUT_VIDEO_RESIZE_WIDTH = 0x038C,
    GLUT_VIDEO_RESIZE_HEIGHT = 0x038D,
}

// glutUseLayer parameters
enum {
    GLUT_NORMAL = 0x0000,
    GLUT_OVERLAY = 0x0001,
}

// glutGetModifiers parameters
enum {
    GLUT_ACTIVE_SHIFT = 0x0001,
    GLUT_ACTIVE_CTRL = 0x0002,
    GLUT_ACTIVE_ALT = 0x0004,
}

// glutSetCursor parameters
enum {
    GLUT_CURSOR_RIGHT_ARROW = 0x0000,
    GLUT_CURSOR_LEFT_ARROW = 0x0001,
    GLUT_CURSOR_INFO = 0x0002,
    GLUT_CURSOR_DESTROY = 0x0003,
    GLUT_CURSOR_HELP = 0x0004,
    GLUT_CURSOR_CYCLE = 0x0005,
    GLUT_CURSOR_SPRAY = 0x0006,
    GLUT_CURSOR_WAIT = 0x0007,
    GLUT_CURSOR_TEXT = 0x0008,
    GLUT_CURSOR_CROSSHAIR = 0x0009,
    GLUT_CURSOR_UP_DOWN = 0x000A,
    GLUT_CURSOR_LEFT_RIGHT = 0x000B,
    GLUT_CURSOR_TOP_SIDE = 0x000C,
    GLUT_CURSOR_BOTTOM_SIDE = 0x000D,
    GLUT_CURSOR_LEFT_SIDE = 0x000E,
    GLUT_CURSOR_RIGHT_SIDE = 0x000F,
    GLUT_CURSOR_TOP_LEFT_CORNER = 0x0010,
    GLUT_CURSOR_TOP_RIGHT_CORNER = 0x0011,
    GLUT_CURSOR_BOTTOM_RIGHT_CORNER = 0x0012,
    GLUT_CURSOR_BOTTOM_LEFT_CORNER = 0x0013,
    GLUT_CURSOR_INHERIT = 0x0064,
    GLUT_CURSOR_NONE = 0x0065,
    GLUT_CURSOR_FULL_CROSSHAIR = 0x0066,
}

// Additional keyboard and joystick definitions
enum {
    GLUT_KEY_REPEAT_OFF = 0x0000,
    GLUT_KEY_REPEAT_ON = 0x0001,
    GLUT_KEY_REPEAT_DEFAULT = 0x0002,

    GLUT_JOYSTICK_BUTTON_A = 0x0001,
    GLUT_JOYSTICK_BUTTON_B = 0x0002,
    GLUT_JOYSTICK_BUTTON_C = 0x0004,
    GLUT_JOYSTICK_BUTTON_D = 0x0008,
}

// Game mode definitions
enum {
    GLUT_GAME_MODE_ACTIVE = 0x0000,
    GLUT_GAME_MODE_POSSIBLE = 0x0001,
    GLUT_GAME_MODE_WIDTH = 0x0002,
    GLUT_GAME_MODE_HEIGHT = 0x0003,
    GLUT_GAME_MODE_PIXEL_DEPTH = 0x0004,
    GLUT_GAME_MODE_REFRESH_RATE = 0x0005,
    GLUT_GAME_MODE_DISPLAY_CHANGED = 0x0006,
}


// ---------------------------------------------------------
// Initialisation functions
void glutInit(int* pargc, char** argv);
void glutInitWindowPosition(int x, int y);
void glutInitWindowSize(int width, int height);
void glutInitDisplayMode(uint displayMode);
void glutInitDisplayString(const char* displayMode);

// Process loop functions
void glutMainLoop();

// Window management functions
int  glutCreateWindow(const char* title);
int  glutCreateSubWindow(int window, int x, int y, int width, int height);
void glutDestroyWindow(int window);
void glutSetWindow(int window);
int  glutGetWindow();
void glutSetWindowTitle(const char* title);
void glutSetIconTitle(const char* title);
void glutReshapeWindow(int width, int height);
void glutPositionWindow(int x, int y);
void glutShowWindow();
void glutHideWindow();
void glutIconifyWindow();
void glutPushWindow();
void glutPopWindow();
void glutFullScreen();

// Display-connected functions
void glutPostWindowRedisplay(int window);
void glutPostRedisplay();
void glutSwapBuffers();

// Mouse cursor functions
void glutWarpPointer(int x, int y);
void glutSetCursor(int cursor);

// Overlay stuff
void glutEstablishOverlay();
void glutRemoveOverlay();
void glutUseLayer(GLenum layer);
void glutPostOverlayRedisplay();
void glutPostWindowOverlayRedisplay(int window);
void glutShowOverlay();
void glutHideOverlay();

// Menu stuff
int  glutCreateMenu(void function(int menu));
void glutDestroyMenu(int menu);
int  glutGetMenu();
void glutSetMenu(int menu);
void glutAddMenuEntry(const char* label, int value);
void glutAddSubMenu(const char* label, int subMenu);
void glutChangeToMenuEntry(int item, const char* label, int value);
void glutChangeToSubMenu(int item, const char* label, int value);
void glutRemoveMenuItem(int item);
void glutAttachMenu(int button);
void glutDetachMenu(int button);

// Global callback functions
void glutTimerFunc(uint time, void function(int), int value);
void glutIdleFunc(void function());

// Window-specific callback functions
void glutKeyboardFunc(void function(char, int, int));
void glutSpecialFunc(void function(int, int, int));
void glutReshapeFunc(void function(int, int));
void glutVisibilityFunc(void function(int));
void glutDisplayFunc(void function());
void glutMouseFunc(void function(int, int, int, int));
void glutMotionFunc(void function(int, int));
void glutPassiveMotionFunc(void function(int, int));
void glutEntryFunc(void function(int));

void glutKeyboardUpFunc(void function(char, int, int));
void glutSpecialUpFunc(void function(int, int, int));
void glutJoystickFunc(void function(uint, int, int, int), int pollInterval);
void glutMenuStateFunc(void function(int));
void glutMenuStatusFunc(void function(int, int, int));
void glutOverlayDisplayFunc(void function());
void glutWindowStatusFunc(void function(int));

void glutSpaceballMotionFunc(void function(int, int, int));
void glutSpaceballRotateFunc(void function(int, int, int));
void glutSpaceballButtonFunc(void function(int, int));
void glutButtonBoxFunc(void function(int, int));
void glutDialsFunc(void function(int, int));
void glutTabletMotionFunc(void function(int, int));
void glutTabletButtonFunc(void function(int, int, int, int));

// State setting and retrieval functions
int  glutGet(GLenum query);
int  glutDeviceGet(GLenum query);
int  glutGetModifiers();
int  glutLayerGet(GLenum query);

// Font stuff
void glutBitmapCharacter(void* font, int character);
int  glutBitmapWidth(void* font, int character);
void glutStrokeCharacter(void* font, int character);
int  glutStrokeWidth(void* font, int character);
int  glutBitmapLength(void* font, const char* string);
int  glutStrokeLength(void* font, const char* string);

// Geometry functions
void glutWireCube(GLdouble size);
void glutSolidCube(GLdouble size);
void glutWireSphere(GLdouble radius, GLint slices, GLint stacks);
void glutSolidSphere(GLdouble radius, GLint slices, GLint stacks);
void glutWireCone(GLdouble base, GLdouble height, GLint slices, GLint stacks);
void glutSolidCone(GLdouble base, GLdouble height, GLint slices, GLint stacks);

void glutWireTorus(GLdouble innerRadius, GLdouble outerRadius, GLint sides, GLint rings);
void glutSolidTorus(GLdouble innerRadius, GLdouble outerRadius, GLint sides, GLint rings);
void glutWireDodecahedron();
void glutSolidDodecahedron();
void glutWireOctahedron();
void glutSolidOctahedron();
void glutWireTetrahedron();
void glutSolidTetrahedron();
void glutWireIcosahedron();
void glutSolidIcosahedron();

// Teapot rendering functions
void glutWireTeapot(GLdouble size);
void glutSolidTeapot(GLdouble size);

// Game mode functions
void glutGameModeString(const char* string);
int  glutEnterGameMode();
void glutLeaveGameMode();
int  glutGameModeGet(GLenum query);

// Video resize functions
int  glutVideoResizeGet(GLenum query);
void glutSetupVideoResizing();
void glutStopVideoResizing();
void glutVideoResize(int x, int y, int width, int height);
void glutVideoPan(int x, int y, int width, int height);

// Colourmap functions
void glutSetColor(int color, GLfloat red, GLfloat green, GLfloat blue);
GLfloat glutGetColor(int color, int component);
void glutCopyColormap(int window);

// Misc keyboard and joystick functions
void glutIgnoreKeyRepeat(int ignore);
void glutSetKeyRepeat(int repeatMode);
void glutForceJoystickFunc();

// Misc functions
int  glutExtensionSupported(const char* extension);
void glutReportErrors();


// -------------------------------------------------
// FreeGLUT extensions
// Additional GLUT key definitions for the special key function
enum {
    GLUT_KEY_NUM_LOCK = 0x006D,
    GLUT_KEY_BEGIN = 0x006E,
    GLUT_KEY_DELETE = 0x006F,
    GLUT_KEY_SHIFT_L = 0x0070,
    GLUT_KEY_SHIFT_R = 0x0071,
    GLUT_KEY_CTRL_L = 0x0072,
    GLUT_KEY_CTRL_R = 0x0073,
    GLUT_KEY_ALT_L = 0x0074,
    GLUT_KEY_ALT_R = 0x0075,
}

// Behavior when the user click on an "x" to close a window
enum {
    GLUT_ACTION_EXIT = 0,
    GLUT_ACTION_GLUTMAINLOOP_RETURNS = 1,
    GLUT_ACTION_CONTINUE_EXECUTION = 2,
}

// Create a new rendering context when the user opens a new window?
enum {
    GLUT_CREATE_NEW_CONTEXT = 0,
    GLUT_USE_CURRENT_CONTEXT = 1,
}

// glutGet parameters
enum {
     GLUT_INIT_STATE = 0x007C,

     GLUT_ACTION_ON_WINDOW_CLOSE = 0x01F9,

     GLUT_WINDOW_BORDER_WIDTH = 0x01FA,
     GLUT_WINDOW_HEADER_HEIGHT = 0x01FB,

     GLUT_VERSION = 0x01FC,

     GLUT_RENDERING_CONTEXT = 0x01FD,
     GLUT_DIRECT_RENDERING = 0x01FE,

     GLUT_FULL_SCREEN = 0x01FF,
}

// Context-related flags
enum {
     GLUT_INIT_MAJOR_VERSION = 0x0200,
     GLUT_INIT_MINOR_VERSION = 0x0201,
     GLUT_INIT_FLAGS = 0x0202,
     GLUT_INIT_PROFILE = 0x0203,
}

// Flags for glutInitContextFlags
enum {
     GLUT_DEBUG = 0x0001,
     GLUT_FORWARD_COMPATIBLE = 0x0002,
}

// Flags for glutInitContextProfile
enum {
    GLUT_CORE_PROFILE = 0x0001,
    GLUT_COMPATIBILITY_PROFILE = 0x0002,
}

// Process loop functions
void glutMainLoopEvent();
void glutLeaveMainLoop();
void glutExit();

// Window management functions
void glutFullScreenToggle();
void glutLeaveFullScreen();

// Window-specific callback functions
void glutMouseWheelFunc(void function(int, int, int, int));
void glutCloseFunc(void function());
void glutWMCloseFunc(void function());
void glutMenuDestroyFunc(void function());

// State setting and retrieval functions
void glutSetOption (GLenum option_flag, int value);
int * glutGetModeValues(GLenum mode, int * size);
void* glutGetWindowData();
void glutSetWindowData(void* data);
void* glutGetMenuData();
void glutSetMenuData(void* data);

// Font stuff
int  glutBitmapHeight(void* font);
GLfloat glutStrokeHeight(void* font);
void glutBitmapString(void* font, const char* string);
void glutStrokeString(void* font, const char* string);

// Geometry functions
void glutWireRhombicDodecahedron();
void glutSolidRhombicDodecahedron();
void glutWireSierpinskiSponge (int num_levels, GLdouble offset[3], GLdouble scale);
void glutSolidSierpinskiSponge (int num_levels, GLdouble offset[3], GLdouble scale);
void glutWireCylinder(GLdouble radius, GLdouble height, GLint slices, GLint stacks);
void glutSolidCylinder(GLdouble radius, GLdouble height, GLint slices, GLint stacks);

// Multi-touch/multi-pointer extensions
void glutMultiEntryFunc(void function(int, int));
void glutMultiButtonFunc(void function(int, int, int, int, int));
void glutMultiMotionFunc(void function(int, int, int));
void glutMultiPassiveFunc(void function(int, int, int));

// Initialization functions
void glutInitContextVersion(int majorVersion, int minorVersion);
void glutInitContextFlags(int flags);
void glutInitContextProfile(int profile);

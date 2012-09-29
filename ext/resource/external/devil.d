module ext.resource.external.devil;

nothrow extern(C):


alias uint ILenum;
alias byte ILboolean;
alias uint ILbitfield;
alias byte ILbyte;
alias short ILshort;
alias int ILint;
alias size_t ILsizei;
alias ubyte ILubyte;
alias ushort ILushort;
alias uint ILuint;
alias float ILfloat;
alias float ILclampf;
alias double ILdouble;
alias double ILclampd;
alias long ILint64;
alias ulong ILuint64;

// ilGetInteger.
enum IL_VERSION_NUM = 0x0DE2;
enum IL_IMAGE_WIDTH = 0x0DE4;
enum IL_IMAGE_HEIGHT = 0x0DE5;
enum IL_IMAGE_DEPTH = 0x0DE6;
enum IL_IMAGE_SIZE_OF_DATA = 0x0DE7;
enum IL_IMAGE_BPP = 0x0DE8;
enum IL_IMAGE_BYTES_PER_PIXEL = 0x0DE8;
enum IL_IMAGE_BITS_PER_PIXEL = 0x0DE9;
enum IL_IMAGE_FORMAT = 0x0DEA;
enum IL_IMAGE_TYPE = 0x0DEB;
enum IL_PALETTE_TYPE = 0x0DEC;
enum IL_PALETTE_SIZE = 0x0DED;
enum IL_PALETTE_BPP = 0x0DEE;
enum IL_PALETTE_NUM_COLS = 0x0DEF;
enum IL_PALETTE_BASE_TYPE = 0x0DF0;
enum IL_NUM_FACES = 0x0DE1;
enum IL_NUM_IMAGES = 0x0DF1;
enum IL_NUM_MIPMAPS = 0x0DF2;
enum IL_NUM_LAYERS = 0x0DF3;
enum IL_ACTIVE_IMAGE = 0x0DF4;
enum IL_ACTIVE_MIPMAP = 0x0DF5;
enum IL_ACTIVE_LAYER = 0x0DF6;
enum IL_ACTIVE_FACE = 0x0E00;
enum IL_CUR_IMAGE = 0x0DF7;
enum IL_IMAGE_DURATION = 0x0DF8;
enum IL_IMAGE_PLANESIZE = 0x0DF9;
enum IL_IMAGE_BPC = 0x0DFA;
enum IL_IMAGE_OFFX = 0x0DFB;
enum IL_IMAGE_OFFY = 0x0DFC;
enum IL_IMAGE_CUBEFLAGS = 0x0DFD;
enum IL_IMAGE_ORIGIN = 0x0DFE;
enum IL_IMAGE_CHANNELS = 0x0DFF;

// Image data formats.
enum IL_COLOR_INDEX = 0x1900;
enum IL_ALPHA = 0x1906;
enum IL_RGB = 0x1907;
enum IL_RGBA = 0x1908;
enum IL_BGR = 0x80E0;
enum IL_BGRA = 0x80E1;
enum IL_LUMINANCE = 0x1909;
enum IL_LUMINANCE_ALPHA = 0x190A;

// Image data types.
enum IL_BYTE = 0x1400;
enum IL_UNSIGNED_BYTE = 0x1401;
enum IL_SHORT = 0x1402;
enum IL_UNSIGNED_SHORT = 0x1403;
enum IL_INT = 0x1404;
enum IL_UNSIGNED_INT = 0x1405;
enum IL_FLOAT = 0x1406;
enum IL_DOUBLE = 0x140A;
enum IL_HALF = 0x140B;

// Image file formats.
enum IL_BMP = 0x0420;
enum IL_PNG = 0x042A;

enum IL_NO_ERROR = 0x0000;

// Needed functions.
void ilBindImage(ILuint Image);
void ilDeleteImage(const ILuint Num);
ILuint ilGenImage();
ILubyte* ilGetData();
ILenum ilGetError();
ILint ilGetInteger(ILenum Mode);
void ilInit();
ILboolean ilLoadL(ILenum Type, const void* Lump, ILuint Size);
ILuint ilSaveL(ILenum Type, void* Lump, ILuint Size);
ILboolean ilTexImage(ILuint Width, ILuint Height, ILuint Depth, ILubyte NumChannels, ILenum Format, ILenum Type, void* Data);

const(char)* iluErrorString(ILenum Error);
void iluInit();


static this() {
	ilInit();
	iluInit();
}
module ext.resource.external.freeimage;

import std.system;


/*enum FREEIMAGE_BIGENDIAN = endian == Endian.bigEndian;

// This really only affects 24 and 32 bit formats, the rest are always RGB order.
enum FREEIMAGE_COLORORDER_BGR = 0;
enum FREEIMAGE_COLORORDER_RGB = 1;
enum FREEIMAGE_COLORORDER = endian == Endian.bigEndian ? FREEIMAGE_COLORORDER_RGB : FREEIMAGE_COLORORDER_BGR;

// Bitmap types -------------------------------------------------------------

struct FIBITMAP {
    void* data;
}

struct FIMULTIBITMAP {
    void* data;
}

// Types used in the library (directly copied from Windows) -----------------

enum FALSE = 0;
enum TRUE = 1;
enum NULL = null;

enum SEEK_SET = 0;
enum SEEK_CUR = 1;
enum SEEK_END = 2;

struct RGBQUAD {
    static if (FREEIMAGE_COLORORDER == FREEIMAGE_COLORORDER_BGR) {
        BYTE rgbBlue;
        BYTE rgbGreen;
        BYTE rgbRed;
    } else {
        BYTE rgbRed;
        BYTE rgbGreen;
        BYTE rgbBlue;
    }
    BYTE rgbReserved;
}

struct RGBTRIPLE {
    static if (FREEIMAGE_COLORORDER == FREEIMAGE_COLORORDER_BGR) {
        BYTE rgbtBlue;
        BYTE rgbtGreen;
        BYTE rgbtRed;
    } else {
        BYTE rgbtRed;
        BYTE rgbtGreen;
        BYTE rgbtBlue;
    }
}

struct BITMAPINFOHEADER {
    DWORD biSize;
    LONG  biWidth; 
    LONG  biHeight; 
    WORD  biPlanes; 
    WORD  biBitCount;
    DWORD biCompression; 
    DWORD biSizeImage; 
    LONG  biXPelsPerMeter; 
    LONG  biYPelsPerMeter; 
    DWORD biClrUsed; 
    DWORD biClrImportant;
}

alias BITMAPINFOHEADER* PBITMAPINFOHEADER;

struct BITMAPINFO {
    BITMAPINFOHEADER bmiHeader;
    RGBQUAD bmiColors[1];
}

alias BITMAPINFO* PBITMAPINFO;

// Types used in the library (specific to FreeImage) -----------------------
// 48-bit RGB
struct FIRGB16 {
    WORD red;
    WORD green;
    WORD blue;
}

// 64-bit RGBA
struct FIRGBA16 {
    WORD red;
    WORD green;
    WORD blue;
    WORD alpha;
}

// 96-bit RGB float
struct FIRGBF {
    float red;
    float green;
    float blue;
}

// 128-bit RGBA float
struct FIRGBAF {
    float red;
    float green;
    float blue;
    float alpha;
}

// Data structure for COMPLEX type (complex number)
struct FICOMPLEX {
    // real part
    double r;
    // imaginary part
    double i;
}

// Indexes for byte arrays, masks and shifts for treating pixels as words ---
// These coincide with the order of RGBQUAD and RGBTRIPLE -------------------

static if (!FREEIMAGE_BIGENDIAN) {
    static if (FREEIMAGE_COLORORDER == FREEIMAGE_COLORORDER_BGR) {
#define FI_RGBA_RED             2
#define FI_RGBA_GREEN           1
#define FI_RGBA_BLUE            0
#define FI_RGBA_ALPHA           3
#define FI_RGBA_RED_MASK        0x00FF0000
#define FI_RGBA_GREEN_MASK      0x0000FF00
#define FI_RGBA_BLUE_MASK       0x000000FF
#define FI_RGBA_ALPHA_MASK      0xFF000000
#define FI_RGBA_RED_SHIFT       16
#define FI_RGBA_GREEN_SHIFT     8
#define FI_RGBA_BLUE_SHIFT      0
#define FI_RGBA_ALPHA_SHIFT     24
    } else {
#define FI_RGBA_RED             0
#define FI_RGBA_GREEN           1
#define FI_RGBA_BLUE            2
#define FI_RGBA_ALPHA           3
#define FI_RGBA_RED_MASK        0x000000FF
#define FI_RGBA_GREEN_MASK      0x0000FF00
#define FI_RGBA_BLUE_MASK       0x00FF0000
#define FI_RGBA_ALPHA_MASK      0xFF000000
#define FI_RGBA_RED_SHIFT       0
#define FI_RGBA_GREEN_SHIFT     8
#define FI_RGBA_BLUE_SHIFT      16
#define FI_RGBA_ALPHA_SHIFT     24
    }
}

// Basic types -------------------------------------------------------------
alias int BOOL;
alias ubyte BYTE;
alias ushort WORD;
alias uint DWORD;
alias int LONG;
alias long FIINT64;
alias ulong FIUINT64;


// Init / Error routines ----------------------------------------------------

void FreeImage_Initialise(BOOL load_local_plugins_only = FALSE);
void FreeImage_DeInitialise(void);

// Version routines ---------------------------------------------------------

const char *FreeImage_GetVersion(void);
const char *FreeImage_GetCopyrightMessage(void);

// Message output functions -------------------------------------------------

alias function*FreeImage_OutputMessageFunction)(FREE_IMAGE_FORMAT fif, const char *msg);
alias void (*FreeImage_OutputMessageFunctionStdCall)(FREE_IMAGE_FORMAT fif, const char *msg); 

void FreeImage_SetOutputMessageStdCall(FreeImage_OutputMessageFunctionStdCall omf); 
void FreeImage_SetOutputMessage(FreeImage_OutputMessageFunction omf);
void FreeImage_OutputMessageProc(int fif, const char *fmt, ...);

// Allocate / Clone / Unload routines ---------------------------------------

FIBITMAP *FreeImage_Allocate(int width, int height, int bpp, unsigned red_mask = 0, unsigned green_mask = 0, unsigned blue_mask = 0);
FIBITMAP *FreeImage_AllocateT(FREE_IMAGE_TYPE type, int width, int height, int bpp = 8, unsigned red_mask = 0, unsigned green_mask = 0, unsigned blue_mask = 0);
FIBITMAP * FreeImage_Clone(FIBITMAP *dib);
void FreeImage_Unload(FIBITMAP *dib);

// Header loading routines
BOOL FreeImage_HasPixels(FIBITMAP *dib);

// Load / Save routines -----------------------------------------------------

FIBITMAP *FreeImage_Load(FREE_IMAGE_FORMAT fif, const char *filename, int flags = 0);
FIBITMAP *FreeImage_LoadU(FREE_IMAGE_FORMAT fif, const wchar_t *filename, int flags = 0);
FIBITMAP *FreeImage_LoadFromHandle(FREE_IMAGE_FORMAT fif, FreeImageIO *io, fi_handle handle, int flags = 0);
BOOL FreeImage_Save(FREE_IMAGE_FORMAT fif, FIBITMAP *dib, const char *filename, int flags = 0);
BOOL FreeImage_SaveU(FREE_IMAGE_FORMAT fif, FIBITMAP *dib, const wchar_t *filename, int flags = 0);
BOOL FreeImage_SaveToHandle(FREE_IMAGE_FORMAT fif, FIBITMAP *dib, FreeImageIO *io, fi_handle handle, int flags = 0);

// Memory I/O stream routines -----------------------------------------------

FIMEMORY *FreeImage_OpenMemory(BYTE *data = 0, DWORD size_in_bytes = 0);
void FreeImage_CloseMemory(FIMEMORY *stream);
FIBITMAP *FreeImage_LoadFromMemory(FREE_IMAGE_FORMAT fif, FIMEMORY *stream, int flags = 0);
BOOL FreeImage_SaveToMemory(FREE_IMAGE_FORMAT fif, FIBITMAP *dib, FIMEMORY *stream, int flags = 0);
long FreeImage_TellMemory(FIMEMORY *stream);
BOOL FreeImage_SeekMemory(FIMEMORY *stream, long offset, int origin);
BOOL FreeImage_AcquireMemory(FIMEMORY *stream, BYTE **data, DWORD *size_in_bytes);
unsigned FreeImage_ReadMemory(void *buffer, unsigned size, unsigned count, FIMEMORY *stream);
unsigned FreeImage_WriteMemory(const void *buffer, unsigned size, unsigned count, FIMEMORY *stream);

FIMULTIBITMAP *FreeImage_LoadMultiBitmapFromMemory(FREE_IMAGE_FORMAT fif, FIMEMORY *stream, int flags = 0);
BOOL FreeImage_SaveMultiBitmapToMemory(FREE_IMAGE_FORMAT fif, FIMULTIBITMAP *bitmap, FIMEMORY *stream, int flags);

// Plugin Interface ---------------------------------------------------------

FREE_IMAGE_FORMAT FreeImage_RegisterLocalPlugin(FI_InitProc proc_address, const char *format = 0, const char *description = 0, const char *extension = 0, const char *regexpr = 0);
FREE_IMAGE_FORMAT FreeImage_RegisterExternalPlugin(const char *path, const char *format = 0, const char *description = 0, const char *extension = 0, const char *regexpr = 0);
int FreeImage_GetFIFCount(void);
int FreeImage_SetPluginEnabled(FREE_IMAGE_FORMAT fif, BOOL enable);
int FreeImage_IsPluginEnabled(FREE_IMAGE_FORMAT fif);
FREE_IMAGE_FORMAT FreeImage_GetFIFFromFormat(const char *format);
FREE_IMAGE_FORMAT FreeImage_GetFIFFromMime(const char *mime);
const char *FreeImage_GetFormatFromFIF(FREE_IMAGE_FORMAT fif);
const char *FreeImage_GetFIFExtensionList(FREE_IMAGE_FORMAT fif);
const char *FreeImage_GetFIFDescription(FREE_IMAGE_FORMAT fif);
const char *FreeImage_GetFIFRegExpr(FREE_IMAGE_FORMAT fif);
const char *FreeImage_GetFIFMimeType(FREE_IMAGE_FORMAT fif);
FREE_IMAGE_FORMAT FreeImage_GetFIFFromFilename(const char *filename);
FREE_IMAGE_FORMAT FreeImage_GetFIFFromFilenameU(const wchar_t *filename);
BOOL FreeImage_FIFSupportsReading(FREE_IMAGE_FORMAT fif);
BOOL FreeImage_FIFSupportsWriting(FREE_IMAGE_FORMAT fif);
BOOL FreeImage_FIFSupportsExportBPP(FREE_IMAGE_FORMAT fif, int bpp);
BOOL FreeImage_FIFSupportsExportType(FREE_IMAGE_FORMAT fif, FREE_IMAGE_TYPE type);
BOOL FreeImage_FIFSupportsICCProfiles(FREE_IMAGE_FORMAT fif);
BOOL FreeImage_FIFSupportsNoPixels(FREE_IMAGE_FORMAT fif);

// Multipaging interface ----------------------------------------------------

FIMULTIBITMAP * FreeImage_OpenMultiBitmap(FREE_IMAGE_FORMAT fif, const char *filename, BOOL create_new, BOOL read_only, BOOL keep_cache_in_memory = FALSE, int flags = 0);
FIMULTIBITMAP * FreeImage_OpenMultiBitmapFromHandle(FREE_IMAGE_FORMAT fif, FreeImageIO *io, fi_handle handle, int flags = 0);
BOOL FreeImage_SaveMultiBitmapToHandle(FREE_IMAGE_FORMAT fif, FIMULTIBITMAP *bitmap, FreeImageIO *io, fi_handle handle, int flags = 0);
BOOL FreeImage_CloseMultiBitmap(FIMULTIBITMAP *bitmap, int flags = 0);
int FreeImage_GetPageCount(FIMULTIBITMAP *bitmap);
void FreeImage_AppendPage(FIMULTIBITMAP *bitmap, FIBITMAP *data);
void FreeImage_InsertPage(FIMULTIBITMAP *bitmap, int page, FIBITMAP *data);
void FreeImage_DeletePage(FIMULTIBITMAP *bitmap, int page);
FIBITMAP * FreeImage_LockPage(FIMULTIBITMAP *bitmap, int page);
void FreeImage_UnlockPage(FIMULTIBITMAP *bitmap, FIBITMAP *data, BOOL changed);
BOOL FreeImage_MovePage(FIMULTIBITMAP *bitmap, int target, int source);
BOOL FreeImage_GetLockedPageNumbers(FIMULTIBITMAP *bitmap, int *pages, int *count);

// Filetype request routines ------------------------------------------------

FREE_IMAGE_FORMAT FreeImage_GetFileType(const char *filename, int size = 0);
FREE_IMAGE_FORMAT FreeImage_GetFileTypeU(const wchar_t *filename, int size = 0);
FREE_IMAGE_FORMAT FreeImage_GetFileTypeFromHandle(FreeImageIO *io, fi_handle handle, int size = 0);
FREE_IMAGE_FORMAT FreeImage_GetFileTypeFromMemory(FIMEMORY *stream, int size = 0);

// Image type request routine -----------------------------------------------

FREE_IMAGE_TYPE FreeImage_GetImageType(FIBITMAP *dib);

// FreeImage helper routines ------------------------------------------------

BOOL FreeImage_IsLittleEndian(void);
BOOL FreeImage_LookupX11Color(const char *szColor, BYTE *nRed, BYTE *nGreen, BYTE *nBlue);
BOOL FreeImage_LookupSVGColor(const char *szColor, BYTE *nRed, BYTE *nGreen, BYTE *nBlue);

// Pixel access routines ----------------------------------------------------

BYTE *FreeImage_GetBits(FIBITMAP *dib);
BYTE *FreeImage_GetScanLine(FIBITMAP *dib, int scanline);

BOOL FreeImage_GetPixelIndex(FIBITMAP *dib, unsigned x, unsigned y, BYTE *value);
BOOL FreeImage_GetPixelColor(FIBITMAP *dib, unsigned x, unsigned y, RGBQUAD *value);
BOOL FreeImage_SetPixelIndex(FIBITMAP *dib, unsigned x, unsigned y, BYTE *value);
BOOL FreeImage_SetPixelColor(FIBITMAP *dib, unsigned x, unsigned y, RGBQUAD *value);

// DIB info routines --------------------------------------------------------

unsigned FreeImage_GetColorsUsed(FIBITMAP *dib);
unsigned FreeImage_GetBPP(FIBITMAP *dib);
unsigned FreeImage_GetWidth(FIBITMAP *dib);
unsigned FreeImage_GetHeight(FIBITMAP *dib);
unsigned FreeImage_GetLine(FIBITMAP *dib);
unsigned FreeImage_GetPitch(FIBITMAP *dib);
unsigned FreeImage_GetDIBSize(FIBITMAP *dib);
RGBQUAD *FreeImage_GetPalette(FIBITMAP *dib);

unsigned FreeImage_GetDotsPerMeterX(FIBITMAP *dib);
unsigned FreeImage_GetDotsPerMeterY(FIBITMAP *dib);
void FreeImage_SetDotsPerMeterX(FIBITMAP *dib, unsigned res);
void FreeImage_SetDotsPerMeterY(FIBITMAP *dib, unsigned res);

BITMAPINFOHEADER *FreeImage_GetInfoHeader(FIBITMAP *dib);
BITMAPINFO *FreeImage_GetInfo(FIBITMAP *dib);
FREE_IMAGE_COLOR_TYPE FreeImage_GetColorType(FIBITMAP *dib);

unsigned FreeImage_GetRedMask(FIBITMAP *dib);
unsigned FreeImage_GetGreenMask(FIBITMAP *dib);
unsigned FreeImage_GetBlueMask(FIBITMAP *dib);

unsigned FreeImage_GetTransparencyCount(FIBITMAP *dib);
BYTE * FreeImage_GetTransparencyTable(FIBITMAP *dib);
void FreeImage_SetTransparent(FIBITMAP *dib, BOOL enabled);
void FreeImage_SetTransparencyTable(FIBITMAP *dib, BYTE *table, int count);
BOOL FreeImage_IsTransparent(FIBITMAP *dib);
void FreeImage_SetTransparentIndex(FIBITMAP *dib, int index);
int FreeImage_GetTransparentIndex(FIBITMAP *dib);

BOOL FreeImage_HasBackgroundColor(FIBITMAP *dib);
BOOL FreeImage_GetBackgroundColor(FIBITMAP *dib, RGBQUAD *bkcolor);
BOOL FreeImage_SetBackgroundColor(FIBITMAP *dib, RGBQUAD *bkcolor);

FIBITMAP *FreeImage_GetThumbnail(FIBITMAP *dib);
BOOL FreeImage_SetThumbnail(FIBITMAP *dib, FIBITMAP *thumbnail);

// ICC profile routines -----------------------------------------------------

FIICCPROFILE *FreeImage_GetICCProfile(FIBITMAP *dib);
FIICCPROFILE *FreeImage_CreateICCProfile(FIBITMAP *dib, void *data, long size);
void FreeImage_DestroyICCProfile(FIBITMAP *dib);

// Line conversion routines -------------------------------------------------

void FreeImage_ConvertLine1To4(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine8To4(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void FreeImage_ConvertLine16To4_555(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine16To4_565(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine24To4(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine32To4(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine1To8(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine4To8(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine16To8_555(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine16To8_565(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine24To8(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine32To8(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine1To16_555(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void FreeImage_ConvertLine4To16_555(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void FreeImage_ConvertLine8To16_555(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void FreeImage_ConvertLine16_565_To16_555(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine24To16_555(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine32To16_555(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine1To16_565(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void FreeImage_ConvertLine4To16_565(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void FreeImage_ConvertLine8To16_565(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void FreeImage_ConvertLine16_555_To16_565(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine24To16_565(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine32To16_565(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine1To24(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void FreeImage_ConvertLine4To24(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void FreeImage_ConvertLine8To24(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void FreeImage_ConvertLine16To24_555(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine16To24_565(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine32To24(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine1To32(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void FreeImage_ConvertLine4To32(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void FreeImage_ConvertLine8To32(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void FreeImage_ConvertLine16To32_555(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine16To32_565(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine24To32(BYTE *target, BYTE *source, int width_in_pixels);

// Smart conversion routines ------------------------------------------------

FIBITMAP *FreeImage_ConvertTo4Bits(FIBITMAP *dib);
FIBITMAP *FreeImage_ConvertTo8Bits(FIBITMAP *dib);
FIBITMAP *FreeImage_ConvertToGreyscale(FIBITMAP *dib);
FIBITMAP *FreeImage_ConvertTo16Bits555(FIBITMAP *dib);
FIBITMAP *FreeImage_ConvertTo16Bits565(FIBITMAP *dib);
FIBITMAP *FreeImage_ConvertTo24Bits(FIBITMAP *dib);
FIBITMAP *FreeImage_ConvertTo32Bits(FIBITMAP *dib);
FIBITMAP *FreeImage_ColorQuantize(FIBITMAP *dib, FREE_IMAGE_QUANTIZE quantize);
FIBITMAP *FreeImage_ColorQuantizeEx(FIBITMAP *dib, FREE_IMAGE_QUANTIZE quantize = FIQ_WUQUANT, int PaletteSize = 256, int ReserveSize = 0, RGBQUAD *ReservePalette = NULL);
FIBITMAP *FreeImage_Threshold(FIBITMAP *dib, BYTE T);
FIBITMAP *FreeImage_Dither(FIBITMAP *dib, FREE_IMAGE_DITHER algorithm);

FIBITMAP *FreeImage_ConvertFromRawBits(BYTE *bits, int width, int height, int pitch, unsigned bpp, unsigned red_mask, unsigned green_mask, unsigned blue_mask, BOOL topdown = FALSE);
void FreeImage_ConvertToRawBits(BYTE *bits, FIBITMAP *dib, int pitch, unsigned bpp, unsigned red_mask, unsigned green_mask, unsigned blue_mask, BOOL topdown = FALSE);

FIBITMAP *FreeImage_ConvertToFloat(FIBITMAP *dib);
FIBITMAP *FreeImage_ConvertToRGBF(FIBITMAP *dib);
FIBITMAP *FreeImage_ConvertToUINT16(FIBITMAP *dib);
FIBITMAP *FreeImage_ConvertToRGB16(FIBITMAP *dib);

FIBITMAP *FreeImage_ConvertToStandardType(FIBITMAP *src, BOOL scale_linear = TRUE);
FIBITMAP *FreeImage_ConvertToType(FIBITMAP *src, FREE_IMAGE_TYPE dst_type, BOOL scale_linear = TRUE);

// tone mapping operators
FIBITMAP *FreeImage_ToneMapping(FIBITMAP *dib, FREE_IMAGE_TMO tmo, double first_param = 0, double second_param = 0);
FIBITMAP *FreeImage_TmoDrago03(FIBITMAP *src, double gamma = 2.2, double exposure = 0);
FIBITMAP *FreeImage_TmoReinhard05(FIBITMAP *src, double intensity = 0, double contrast = 0);
FIBITMAP *FreeImage_TmoReinhard05Ex(FIBITMAP *src, double intensity = 0, double contrast = 0, double adaptation = 1, double color_correction = 0);

FIBITMAP *FreeImage_TmoFattal02(FIBITMAP *src, double color_saturation = 0.5, double attenuation = 0.85);

// ZLib interface -----------------------------------------------------------

DWORD FreeImage_ZLibCompress(BYTE *target, DWORD target_size, BYTE *source, DWORD source_size);
DWORD FreeImage_ZLibUncompress(BYTE *target, DWORD target_size, BYTE *source, DWORD source_size);
DWORD FreeImage_ZLibGZip(BYTE *target, DWORD target_size, BYTE *source, DWORD source_size);
DWORD FreeImage_ZLibGUnzip(BYTE *target, DWORD target_size, BYTE *source, DWORD source_size);
DWORD FreeImage_ZLibCRC32(DWORD crc, BYTE *source, DWORD source_size);

// --------------------------------------------------------------------------
// Metadata routines --------------------------------------------------------
// --------------------------------------------------------------------------

// tag creation / destruction
FITAG *FreeImage_CreateTag(void);
void FreeImage_DeleteTag(FITAG *tag);
FITAG *FreeImage_CloneTag(FITAG *tag);

// tag getters and setters
const char *FreeImage_GetTagKey(FITAG *tag);
const char *FreeImage_GetTagDescription(FITAG *tag);
WORD FreeImage_GetTagID(FITAG *tag);
FREE_IMAGE_MDTYPE FreeImage_GetTagType(FITAG *tag);
DWORD FreeImage_GetTagCount(FITAG *tag);
DWORD FreeImage_GetTagLength(FITAG *tag);
const void *FreeImage_GetTagValue(FITAG *tag);

BOOL FreeImage_SetTagKey(FITAG *tag, const char *key);
BOOL FreeImage_SetTagDescription(FITAG *tag, const char *description);
BOOL FreeImage_SetTagID(FITAG *tag, WORD id);
BOOL FreeImage_SetTagType(FITAG *tag, FREE_IMAGE_MDTYPE type);
BOOL FreeImage_SetTagCount(FITAG *tag, DWORD count);
BOOL FreeImage_SetTagLength(FITAG *tag, DWORD length);
BOOL FreeImage_SetTagValue(FITAG *tag, const void *value);

// iterator
FIMETADATA *FreeImage_FindFirstMetadata(FREE_IMAGE_MDMODEL model, FIBITMAP *dib, FITAG **tag);
BOOL FreeImage_FindNextMetadata(FIMETADATA *mdhandle, FITAG **tag);
void FreeImage_FindCloseMetadata(FIMETADATA *mdhandle);

// metadata setter and getter
BOOL FreeImage_SetMetadata(FREE_IMAGE_MDMODEL model, FIBITMAP *dib, const char *key, FITAG *tag);
BOOL FreeImage_GetMetadata(FREE_IMAGE_MDMODEL model, FIBITMAP *dib, const char *key, FITAG **tag);

// helpers
unsigned FreeImage_GetMetadataCount(FREE_IMAGE_MDMODEL model, FIBITMAP *dib);
BOOL FreeImage_CloneMetadata(FIBITMAP *dst, FIBITMAP *src);

// tag to C string conversion
const char* FreeImage_TagToString(FREE_IMAGE_MDMODEL model, FITAG *tag, char *Make = NULL);

// --------------------------------------------------------------------------
// Image manipulation toolkit -----------------------------------------------
// --------------------------------------------------------------------------

// rotation and flipping
/// @deprecated see FreeImage_Rotate
FIBITMAP *FreeImage_RotateClassic(FIBITMAP *dib, double angle);
FIBITMAP *FreeImage_Rotate(FIBITMAP *dib, double angle, const void *bkcolor = NULL);
FIBITMAP *FreeImage_RotateEx(FIBITMAP *dib, double angle, double x_shift, double y_shift, double x_origin, double y_origin, BOOL use_mask);
BOOL FreeImage_FlipHorizontal(FIBITMAP *dib);
BOOL FreeImage_FlipVertical(FIBITMAP *dib);
BOOL FreeImage_JPEGTransform(const char *src_file, const char *dst_file, FREE_IMAGE_JPEG_OPERATION operation, BOOL perfect = FALSE);
BOOL FreeImage_JPEGTransformU(const wchar_t *src_file, const wchar_t *dst_file, FREE_IMAGE_JPEG_OPERATION operation, BOOL perfect = FALSE);

// upsampling / downsampling
FIBITMAP *FreeImage_Rescale(FIBITMAP *dib, int dst_width, int dst_height, FREE_IMAGE_FILTER filter);
FIBITMAP *FreeImage_MakeThumbnail(FIBITMAP *dib, int max_pixel_size, BOOL convert = TRUE);

// color manipulation routines (point operations)
BOOL FreeImage_AdjustCurve(FIBITMAP *dib, BYTE *LUT, FREE_IMAGE_COLOR_CHANNEL channel);
BOOL FreeImage_AdjustGamma(FIBITMAP *dib, double gamma);
BOOL FreeImage_AdjustBrightness(FIBITMAP *dib, double percentage);
BOOL FreeImage_AdjustContrast(FIBITMAP *dib, double percentage);
BOOL FreeImage_Invert(FIBITMAP *dib);
BOOL FreeImage_GetHistogram(FIBITMAP *dib, DWORD *histo, FREE_IMAGE_COLOR_CHANNEL channel = FICC_BLACK);
int FreeImage_GetAdjustColorsLookupTable(BYTE *LUT, double brightness, double contrast, double gamma, BOOL invert);
BOOL FreeImage_AdjustColors(FIBITMAP *dib, double brightness, double contrast, double gamma, BOOL invert = FALSE);
unsigned FreeImage_ApplyColorMapping(FIBITMAP *dib, RGBQUAD *srccolors, RGBQUAD *dstcolors, unsigned count, BOOL ignore_alpha, BOOL swap);
unsigned FreeImage_SwapColors(FIBITMAP *dib, RGBQUAD *color_a, RGBQUAD *color_b, BOOL ignore_alpha);
unsigned FreeImage_ApplyPaletteIndexMapping(FIBITMAP *dib, BYTE *srcindices,   BYTE *dstindices, unsigned count, BOOL swap);
unsigned FreeImage_SwapPaletteIndices(FIBITMAP *dib, BYTE *index_a, BYTE *index_b);

// channel processing routines
FIBITMAP *FreeImage_GetChannel(FIBITMAP *dib, FREE_IMAGE_COLOR_CHANNEL channel);
BOOL FreeImage_SetChannel(FIBITMAP *dst, FIBITMAP *src, FREE_IMAGE_COLOR_CHANNEL channel);
FIBITMAP *FreeImage_GetComplexChannel(FIBITMAP *src, FREE_IMAGE_COLOR_CHANNEL channel);
BOOL FreeImage_SetComplexChannel(FIBITMAP *dst, FIBITMAP *src, FREE_IMAGE_COLOR_CHANNEL channel);

// copy / paste / composite routines
FIBITMAP *FreeImage_Copy(FIBITMAP *dib, int left, int top, int right, int bottom);
BOOL FreeImage_Paste(FIBITMAP *dst, FIBITMAP *src, int left, int top, int alpha);
FIBITMAP *FreeImage_Composite(FIBITMAP *fg, BOOL useFileBkg = FALSE, RGBQUAD *appBkColor = NULL, FIBITMAP *bg = NULL);
BOOL FreeImage_JPEGCrop(const char *src_file, const char *dst_file, int left, int top, int right, int bottom);
BOOL FreeImage_JPEGCropU(const wchar_t *src_file, const wchar_t *dst_file, int left, int top, int right, int bottom);
BOOL FreeImage_PreMultiplyWithAlpha(FIBITMAP *dib);

// background filling routines
BOOL FreeImage_FillBackground(FIBITMAP *dib, const void *color, int options = 0);
FIBITMAP *FreeImage_EnlargeCanvas(FIBITMAP *src, int left, int top, int right, int bottom, const void *color, int options = 0);
FIBITMAP *FreeImage_AllocateEx(int width, int height, int bpp, const RGBQUAD *color, int options = 0, const RGBQUAD *palette = NULL, unsigned red_mask = 0, unsigned green_mask = 0, unsigned blue_mask = 0);
FIBITMAP *FreeImage_AllocateExT(FREE_IMAGE_TYPE type, int width, int height, int bpp, const void *color, int options = 0, const RGBQUAD *palette = NULL, unsigned red_mask = 0, unsigned green_mask = 0, unsigned blue_mask = 0);

// miscellaneous algorithms
FIBITMAP *FreeImage_MultigridPoissonSolver(FIBITMAP *Laplacian, int ncycle = 3);*/
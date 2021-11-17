//
// Header for graphics surfaces.
//
//! \file tonc_surface.h
//! \author J Vijn
//! \date 20080119 - 20080514
//
/* === NOTES ===
*/
module tonc.tonc_surface;

import tonc.tonc_types;


extern (C):

/*! \defgroup	grpSurface	Surface functions
	\ingroup	grpVideo
	Tonclib's Surface system provides the basic functionality for
	drawing onto graphic surfaces of different types. This includes
	- <b>bmp16</b>: 16bpp bitmap surfaces
	- <b>bmp8</b>: 8bpp bitmap surfaces.
	- <b>chr4</b>(c/r): 4bpp tiled surfaces.
	This covers almost all of the GBA graphic modes.
*/

/*! \defgroup	grpSbmp16	16bpp bitmap surfaces
	\ingroup	grpSurface
	Routines for 16bpp linear surfaces. For use in modes 3 and 5. Can
	also be used for regular tilemaps to a point.
*/

/*! \defgroup	grpSbmp8	8bpp bitmap surfaces
	\ingroup	grpSurface
	Routines for 8bpp linear surfaces. For use in mode 4 and
	affine tilemaps.
*/

/*! \defgroup	grpSchr4c	4bpp tiled surfaces, column major
	\ingroup	grpSurface
	<p>
	A (4bpp) tiled surface is formed when each tilemap entry
	references a unique tile (this is done by schr4c_prep_map()).
	The pixels on the tiles will then uniquely map onto pixels on the
	screen.
	</p>
	<p>
	There are two ways of map-layout here: row-major indexing and
	column-major indexing. The difference if is that tile 1 is to the
	right of tile 0 in the former, but under it in the latter.
	</p>
<pre>
30x20t screen:
  Row-major:
     0  1  2  3 ...
    30 31 32 33 ...
    60 61 62 63 ...

  Column-major:
     0 20 40 60 ...
     1 21 41 61 ...
     2 22 41 62 ...
</pre>
	<p>
	With 4bpp tiles, the column-major version makes the <i>y</i>
	coordinate match up nicely with successive words. For this reason,
	column-major is preferred over row-major.
	</p>
*/

/*! \defgroup	grpSchr4r	4bpp tiled surfaces, row major
	\ingroup	grpSurface
	<p>
	A (4bpp) tiled surface is formed when each tilemap entry
	references a unique tile (this is done by schr4r_prep_map()).
	The pixels on the tiles will then uniquely map onto pixels on the
	screen.
	</p>
	<p>
	There are two ways of map-layout here: row-major indexing and
	column-major indexing. The difference if is that tile 1 is to the
	right of tile 0 in the former, but under it in the latter.
	</p>
<pre>
30x20t screen:
  Row-major:
     0  1  2  3 ...
    30 31 32 33 ...
    60 61 62 63 ...

  Column-major:
     0 20 40 60 ...
     1 21 41 61 ...
     2 22 41 62 ...
</pre>
	<p>
	With 4bpp tiles, the column-major version makes the <i>y</i>
	coordinate match up nicely with successive words. For this reason,
	column-major is preferred over row-major.
	</p>
*/

/*! \addtogroup grpSurface	*/
/*!	\{	*/

// --------------------------------------------------------------------
// CLASSES
// --------------------------------------------------------------------

//! Surface types
enum ESurfaceType
{
    SRF_NONE = 0, //!< No specific type. 
    SRF_BMP16 = 1, //!< 16bpp linear (bitmap/tilemap).
    SRF_BMP8 = 2, //!< 8bpp linear (bitmap/tilemap).
    //SRF_SBB		=3,		//!< 16bpp tilemap in screenblocks
    SRF_CHR4R = 4, //!< 4bpp tiles, row-major.
    SRF_CHR4C = 5, //!< 4bpp tiles, column-major.
    SRF_CHR8 = 6, //!< 8bpp tiles, row-major.
    SRF_ALLOCATED = 0x80 //!< Pointers have been allocated.
}

// --------------------------------------------------------------------
// CLASSES
// --------------------------------------------------------------------

struct TSurface
{
    ubyte* data; //!< Surface data pointer.
    uint pitch; //!< Scanline pitch in bytes (PONDER: alignment?).
    ushort width; //!< Image width in pixels.	
    ushort height; //!< Image width in pixels.
    ubyte bpp; //!< Bits per pixel.
    ubyte type; //!< Surface type (not used that much).
    ushort palSize; //!< Number of colors.
    ushort* palData; //!< Pointer to palette.
}

/*!	\}	*/

//! \name Rendering procedure types 
//\{
alias fnGetPixel = uint function (const(TSurface)* src, int x, int y);

alias fnPlot = void function (const(TSurface)* dst, int x, int y, uint clr);
alias fnHLine = void function (const(TSurface)* dst, int x1, int y, int x2, uint clr);
alias fnVLine = void function (const(TSurface)* dst, int x, int y1, int y2, uint clr);
alias fnLine = void function (const(TSurface)* dst, int x1, int y1, int x2, int y2, uint clr);

alias fnRect = void function (
    const(TSurface)* dst,
    int left,
    int top,
    int right,
    int bottom,
    uint clr);
alias fnFrame = void function (
    const(TSurface)* dst,
    int left,
    int top,
    int right,
    int bottom,
    uint clr);

alias fnBlit = void function (
    const(TSurface)* dst,
    int dstX,
    int dstY,
    uint width,
    uint height,
    const(TSurface)* src,
    int srcX,
    int srcY);
alias fnFlood = void function (const(TSurface)* dst, int x, int y, uint clr);

// Rendering procedure table
struct TSurfaceProcTab
{
    const(char)* name;
    fnGetPixel getPixel;
    fnPlot plot;
    fnHLine hline;
    fnVLine vline;
    fnLine line;
    fnRect rect;
    fnFrame frame;
    fnBlit blit;
    fnFlood flood;
}

//\}

// --------------------------------------------------------------------
// GLOBALS
// --------------------------------------------------------------------

extern __gshared const TSurface m3_surface;
extern __gshared TSurface m4_surface;
extern __gshared TSurface m5_surface;

extern __gshared const TSurfaceProcTab bmp16_tab;
extern __gshared const TSurfaceProcTab bmp8_tab;
extern __gshared const TSurfaceProcTab chr4c_tab;

// --------------------------------------------------------------------
// PROTOTYPES
// --------------------------------------------------------------------

/*! \addtogroup grpSurface
	\brief	Basic video surface API.
	The TSurface struct and the various functions working on it
	provide a basic API for working with different types of
	graphic surfaces, like 16bpp bitmaps, 8bpp bitmaps, but also
	tiled surfaces.<br>

	- <b>SRF_BMP8</b>:	8bpp linear (Mode 4 / affine BGs)
	- <b>SRF_BMP16</b>	16bpp bitmaps (Mode 3/5 / regular BGs to some extent)
	- <b>SRF_CHR4C</b>	4bpp tiles, column-major (Regular tiled BG)
	- <b>SRF_CHR4R</b>	4bpp tiles, row-major (Regular tiled BG, OBJs)

	For each of these functions exist for the most important drawing
	options: plotting, lines and rectangles. For BMP8/BMP16 and to
	some extent CHR4C, there are blitters as well.
*/
/*!	\{	*/

void srf_init (
    TSurface* srf,
    ESurfaceType type,
    const(void)* data,
    uint width,
    uint height,
    uint bpp,
    ushort* pal);
void srf_pal_copy (const(TSurface)* dst, const(TSurface)* src, uint count);

void* srf_get_ptr (const(TSurface)* srf, uint x, uint y);

uint srf_align (uint width, uint bpp);
void srf_set_ptr (TSurface* srf, const(void)* ptr);
void srf_set_pal (TSurface* srf, const(ushort)* pal, uint size);

void* _srf_get_ptr (const(TSurface)* srf, uint x, uint y, uint stride);

/*!	\}	*/

/*! \addtogroup grpSbmp16	*/
/*!	\{	*/

uint sbmp16_get_pixel (const(TSurface)* src, int x, int y);

void sbmp16_plot (const(TSurface)* dst, int x, int y, uint clr);
void sbmp16_hline (const(TSurface)* dst, int x1, int y, int x2, uint clr);
void sbmp16_vline (const(TSurface)* dst, int x, int y1, int y2, uint clr);
void sbmp16_line (const(TSurface)* dst, int x1, int y1, int x2, int y2, uint clr);

void sbmp16_rect (
    const(TSurface)* dst,
    int left,
    int top,
    int right,
    int bottom,
    uint clr);
void sbmp16_frame (
    const(TSurface)* dst,
    int left,
    int top,
    int right,
    int bottom,
    uint clr);
void sbmp16_blit (
    const(TSurface)* dst,
    int dstX,
    int dstY,
    uint width,
    uint height,
    const(TSurface)* src,
    int srcX,
    int srcY);
void sbmp16_floodfill (const(TSurface)* dst, int x, int y, uint clr);

// Fast inlines .
void _sbmp16_plot (const(TSurface)* dst, int x, int y, uint clr);
uint _sbmp16_get_pixel (const(TSurface)* src, int x, int y);

/*!	\}	*/

/*! \addtogroup grpSbmp8	*/
/*!	\{	*/

uint sbmp8_get_pixel (const(TSurface)* src, int x, int y);

void sbmp8_plot (const(TSurface)* dst, int x, int y, uint clr);
void sbmp8_hline (const(TSurface)* dst, int x1, int y, int x2, uint clr);
void sbmp8_vline (const(TSurface)* dst, int x, int y1, int y2, uint clr);
void sbmp8_line (const(TSurface)* dst, int x1, int y1, int x2, int y2, uint clr);

void sbmp8_rect (
    const(TSurface)* dst,
    int left,
    int top,
    int right,
    int bottom,
    uint clr);
void sbmp8_frame (
    const(TSurface)* dst,
    int left,
    int top,
    int right,
    int bottom,
    uint clr);
void sbmp8_blit (
    const(TSurface)* dst,
    int dstX,
    int dstY,
    uint width,
    uint height,
    const(TSurface)* src,
    int srcX,
    int srcY);
void sbmp8_floodfill (const(TSurface)* dst, int x, int y, uint clr);

// Fast inlines .
void _sbmp8_plot (const(TSurface)* dst, int x, int y, uint clr);
uint _sbmp8_get_pixel (const(TSurface)* src, int x, int y);

/*!	\}	*/

/*! \addtogroup grpSchr4c	*/
/*!	\{	*/

uint schr4c_get_pixel (const(TSurface)* src, int x, int y);

void schr4c_plot (const(TSurface)* dst, int x, int y, uint clr);
void schr4c_hline (const(TSurface)* dst, int x1, int y, int x2, uint clr);
void schr4c_vline (const(TSurface)* dst, int x, int y1, int y2, uint clr);
void schr4c_line (const(TSurface)* dst, int x1, int y1, int x2, int y2, uint clr);

void schr4c_rect (
    const(TSurface)* dst,
    int left,
    int top,
    int right,
    int bottom,
    uint clr);
void schr4c_frame (
    const(TSurface)* dst,
    int left,
    int top,
    int right,
    int bottom,
    uint clr);

void schr4c_blit (
    const(TSurface)* dst,
    int dstX,
    int dstY,
    uint width,
    uint height,
    const(TSurface)* src,
    int srcX,
    int srcY);
void schr4c_floodfill (const(TSurface)* dst, int x, int y, uint clr);

// Additional routines
void schr4c_prep_map (const(TSurface)* srf, ushort* map, ushort se0);
uint* schr4c_get_ptr (const(TSurface)* srf, int x, int y);

// Fast inlines .
void _schr4c_plot (const(TSurface)* dst, int x, int y, uint clr);
uint _schr4c_get_pixel (const(TSurface)* src, int x, int y);

/*!	\}	*/

/*! \addtogroup grpSchr4r	*/
/*!	\{	*/

uint schr4r_get_pixel (const(TSurface)* src, int x, int y);

void schr4r_plot (const(TSurface)* dst, int x, int y, uint clr);
void schr4r_hline (const(TSurface)* dst, int x1, int y, int x2, uint clr);
void schr4r_vline (const(TSurface)* dst, int x, int y1, int y2, uint clr);
void schr4r_line (const(TSurface)* dst, int x1, int y1, int x2, int y2, uint clr);

void schr4r_rect (
    const(TSurface)* dst,
    int left,
    int top,
    int right,
    int bottom,
    uint clr);
void schr4r_frame (
    const(TSurface)* dst,
    int left,
    int top,
    int right,
    int bottom,
    uint clr);

//void schr4r_blit(const TSurface *dst, int dstX, int dstY, 
//	uint width, uint height, const TSurface *src, int srcX, int srcY);
//void schr4r_floodfill(const TSurface *dst, int x, int y, u32 clr);

// Additional routines
void schr4r_prep_map (const(TSurface)* srf, ushort* map, ushort se0);
uint* schr4r_get_ptr (const(TSurface)* srf, int x, int y);

// Fast inlines.
void _schr4r_plot (const(TSurface)* dst, int x, int y, uint clr);
uint _schr4r_get_pixel (const(TSurface)* src, int x, int y);

/*!	\}	*/

// --------------------------------------------------------------------
// MAIN INLINES
// --------------------------------------------------------------------

//! Get the word-aligned number of bytes for a scanline.
/*!
	\param width	Number of pixels.
	\param bpp		Bits per pixel.
*/
uint srf_align (uint width, uint bpp);

//! Set Data-pointer surface for \a srf.
void srf_set_ptr (TSurface* srf, const(void)* ptr);

//! Set the palette pointer and its size.
void srf_set_pal (TSurface* srf, const(ushort)* pal, uint size);

// --------------------------------------------------------------------
// Quick (and dirty) inline routines
// --------------------------------------------------------------------

//! Inline and semi-safe version of srf_get_ptr(). Use with caution.
void* _srf_get_ptr (const(TSurface)* srf, uint x, uint y, uint stride);

//! Get the pixel value of \a src at (\a x, \a y); inline version.
uint _sbmp16_get_pixel (const(TSurface)* src, int x, int y);

//! Plot a single pixel on a 16-bit buffer; inline version.
void _sbmp16_plot (const(TSurface)* dst, int x, int y, uint clr);

//! Get the pixel value of \a src at (\a x, \a y); inline version.
uint _sbmp8_get_pixel (const(TSurface)* src, int x, int y);

//! Plot a single pixel on a 8-bit surface; inline version.
void _sbmp8_plot (const(TSurface)* dst, int x, int y, uint clr);

//! Get the pixel value of \a src at (\a x, \a y); inline version.
uint _schr4c_get_pixel (const(TSurface)* src, int x, int y);

//! Plot a single pixel on a 4bpp tiled,col-jamor surface; inline version.
void _schr4c_plot (const(TSurface)* dst, int x, int y, uint clr);

//! Get the pixel value of \a src at (\a x, \a y); inline version.
uint _schr4r_get_pixel (const(TSurface)* src, int x, int y);

//! Plot a single pixel on a 4bpp tiled,row-major surface; inline version.
void _schr4r_plot (const(TSurface)* dst, int x, int y, uint clr);

// TONC_SURFACE

// EOF

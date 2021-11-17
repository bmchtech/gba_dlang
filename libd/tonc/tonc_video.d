//
//  Basic video functions
//
//! \file tonc_video.h
//! \author J Vijn
//! \date 20060604 - 20080311
//
// === NOTES ===
// * Basic video-IO, color, background and object functionality

module tonc.tonc_video;

import tonc.tonc_types;
import tonc.tonc_memmap;
import tonc.tonc_memdef;
import tonc.tonc_core;

extern (C):

/*! \defgroup grpVideoPal	Colors
	\ingroup grpVideo
*/

/*! \defgroup grpVideoBg	Tiled Backgrounds
	\ingroup grpVideo
*/

/*! \defgroup grpVideoBmp	Bitmaps
	\ingroup grpVideo

	Basic functions for dealing with bitmapped graphics.
	\deprecated	The bmp8/bmp16 functions have been superceded by the
		surface functions (sbmp8/sbmp16) for the most part. The
		former group has been kept mostly for reference purposes.
*/

/*! \defgroup grpVideoObj	Objects
	\ingroup grpVideo
*/

/*! \defgroup grpVideoAffine	Affine functions
	\ingroup grpVideo
*/

// --------------------------------------------------------------------
// VIDEO CORE
// --------------------------------------------------------------------

// --- Constants ------------------------------------------------------

// sizes in pixels
enum SCREEN_WIDTH = 240;
enum SCREEN_HEIGHT = 160;

enum M3_WIDTH = SCREEN_WIDTH;
enum M3_HEIGHT = SCREEN_HEIGHT;
enum M4_WIDTH = SCREEN_WIDTH;
enum M4_HEIGHT = SCREEN_HEIGHT;
enum M5_WIDTH = 160;
enum M5_HEIGHT = 128;

// sizes in tiles
enum SCREEN_WIDTH_T = SCREEN_WIDTH / 8;
enum SCREEN_HEIGHT_T = SCREEN_HEIGHT / 8;

// total scanlines
enum SCREEN_LINES = 228;

// or a bit shorter
enum SCR_W = SCREEN_WIDTH;
enum SCR_H = SCREEN_HEIGHT;
enum SCR_WT = SCREEN_WIDTH_T;
enum SCR_HT = SCREEN_HEIGHT_T;

enum LAYER_BG0 = 0x0001;
enum LAYER_BG1 = 0x0002;
enum LAYER_BG2 = 0x0004;
enum LAYER_BG3 = 0x0008;
enum LAYER_OBJ = 0x0010;
enum LAYER_BD = 0x0020;

// --- Prototypes -----------------------------------------------------

void vid_vsync ();
void vid_wait (uint frames);
ushort* vid_flip ();

// --------------------------------------------------------------------
// COLOR and PALETTE
// --------------------------------------------------------------------

//! \addtogroup grpVideoPal
/*!	\{	*/

//! \name Base Color constants
//\{

enum CLR_BLACK = 0x0000;
enum CLR_RED = 0x001F;
enum CLR_LIME = 0x03E0; // yup. Green == darker green
enum CLR_YELLOW = 0x03FF;
enum CLR_BLUE = 0x7C00;
enum CLR_MAG = 0x7C1F;
enum CLR_CYAN = 0x7FE0;
enum CLR_WHITE = 0x7FFF;

//\}

//! \name Additional colors
//\{

enum CLR_DEAD = 0xDEAD;
enum CLR_MAROON = 0x0010;
enum CLR_GREEN = 0x0200;
enum CLR_OLIVE = 0x0210;
enum CLR_ORANGE = 0x021F;
enum CLR_NAVY = 0x4000;
enum CLR_PURPLE = 0x4010;
enum CLR_TEAL = 0x4200;
enum CLR_GRAY = 0x4210;
enum CLR_MEDGRAY = 0x5294;
enum CLR_SILVER = 0x6318;
enum CLR_MONEYGREEN = 0x6378;
enum CLR_FUCHSIA = 0x7C1F;
enum CLR_SKYBLUE = 0x7B34;
enum CLR_CREAM = 0x7BFF;

//\}

enum CLR_MASK = 0x001F;

enum RED_MASK = 0x001F;
enum RED_SHIFT = 0;
enum GREEN_MASK = 0x03E0;
enum GREEN_SHIFT = 5;
enum BLUE_MASK = 0x7C00;
enum BLUE_SHIFT = 10;

void clr_rotate (COLOR* clrs, uint nclrs, int ror);
void clr_blend (
    const(COLOR)* srca,
    const(COLOR)* srcb,
    COLOR* dst,
    uint nclrs,
    uint alpha);
void clr_fade (
    const(COLOR)* src,
    COLOR clr,
    COLOR* dst,
    uint nclrs,
    uint alpha);

void clr_grayscale (COLOR* dst, const(COLOR)* src, uint nclrs);
void clr_rgbscale (COLOR* dst, const(COLOR)* src, uint nclrs, COLOR clr);

void clr_adj_brightness (COLOR* dst, const(COLOR)* src, uint nclrs, FIXED bright);
void clr_adj_contrast (COLOR* dst, const(COLOR)* src, uint nclrs, FIXED contrast);
void clr_adj_intensity (COLOR* dst, const(COLOR)* src, uint nclrs, FIXED intensity);

void pal_gradient (COLOR* pal, int first, int last);
void pal_gradient_ex (COLOR* pal, int first, int last, COLOR clr_first, COLOR clr_last);

//!	Blends color arrays \a srca and \a srcb into \a dst.
/*!	\param srca	Source array A.
*	\param srcb	Source array B
*	\param dst	Destination array.
*	\param nclrs	Number of colors.
*	\param alpha	Blend weight (range: 0-32).
*	\note Handles 2 colors per loop. Very fast.
*/
void clr_blend_fast (
    COLOR* srca,
    COLOR* srcb,
    COLOR* dst,
    uint nclrs,
    uint alpha);

//!	Fades color arrays \a srca to \a clr into \a dst.
/*!	\param src	Source array.
*	\param clr	Final color (at alpha=32).
*	\param dst	Destination array.
*	\param nclrs	Number of colors.
*	\param alpha	Blend weight (range: 0-32).
*	\note Handles 2 colors per loop. Very fast.
*/
void clr_fade_fast (COLOR* src, COLOR clr, COLOR* dst, uint nclrs, uint alpha);

COLOR RGB15 (int red, int green, int blue);
COLOR RGB15_SAFE (int red, int green, int blue);

COLOR RGB8 (ubyte red, ubyte green, ubyte blue);

/*!	\}	*/

/*! \addtogroup grpVideoBmp	*/
/*	\{	*/

//! \name Generic 8bpp bitmaps
//\{

void bmp8_plot (int x, int y, uint clr, void* dstBase, uint dstP);

void bmp8_hline (int x1, int y, int x2, uint clr, void* dstBase, uint dstP);
void bmp8_vline (int x, int y1, int y2, uint clr, void* dstBase, uint dstP);
void bmp8_line (
    int x1,
    int y1,
    int x2,
    int y2,
    uint clr,
    void* dstBase,
    uint dstP);

void bmp8_rect (
    int left,
    int top,
    int right,
    int bottom,
    uint clr,
    void* dstBase,
    uint dstP);
void bmp8_frame (
    int left,
    int top,
    int right,
    int bottom,
    uint clr,
    void* dstBase,
    uint dstP);
//\}

//! \name Generic 16bpp bitmaps
//\{
void bmp16_plot (int x, int y, uint clr, void* dstBase, uint dstP);

void bmp16_hline (int x1, int y, int x2, uint clr, void* dstBase, uint dstP);
void bmp16_vline (int x, int y1, int y2, uint clr, void* dstBase, uint dstP);
void bmp16_line (int x1, int y1, int x2, int y2, uint clr, void* dstBase, uint dstP);

void bmp16_rect (
    int left,
    int top,
    int right,
    int bottom,
    uint clr,
    void* dstBase,
    uint dstP);
void bmp16_frame (
    int left,
    int top,
    int right,
    int bottom,
    uint clr,
    void* dstBase,
    uint dstP);
//\}

/*!	\}	*/

// --------------------------------------------------------------------
// TILED BACKGROUNDS
// --------------------------------------------------------------------

//! \addtogroup grpVideoBg
/*!	\{	*/

// --- Macros ---------------------------------------------------------

extern (D) auto CBB_CLEAR(T)(auto ref T cbb)
{
    return memset32(&tile_mem[cbb], 0, CBB_SIZE / 4);
}

extern (D) auto SBB_CLEAR(T)(auto ref T sbb)
{
    return memset32(&se_mem[sbb], 0, SBB_SIZE / 4);
}

extern (D) auto SBB_CLEAR_ROW(T0, T1)(auto ref T0 sbb, auto ref T1 row)
{
    return memset32(&se_mem[sbb][row * 32], 0, 32 / 2);
}

// --- bg-types and availability checks for vid-modes 0,1,2 ---
//         3 2 1 0  avail type
// mode 0  r r r r   000F 0000
// mode 1  - a r r   0070 0040
// mode 2  a a - -   0C00 0C00  |
//                 0x0C7F0C40  
enum __BG_TYPES = (0x0C7F << 16) | (0x0C40);

// Get affinity and availability of background n (output is 0 or 1)
extern (D) auto BG_IS_AFFINE(T)(auto ref T n)
{
    return (__BG_TYPES >> (4 * (REG_DISPCNT & 7) + n)) & 1;
}

extern (D) auto BG_IS_AVAIL(T)(auto ref T n)
{
    return (__BG_TYPES >> (4 * (REG_DISPCNT & 7) + n + 16)) & 1;
}

void se_fill (SCR_ENTRY* sbb, SCR_ENTRY se);
void se_plot (SCR_ENTRY* sbb, int x, int y, SCR_ENTRY se);
void se_rect (SCR_ENTRY* sbb, int left, int top, int right, int bottom, SCR_ENTRY se);
void se_frame (SCR_ENTRY* sbb, int left, int top, int right, int bottom, SCR_ENTRY se);

void se_window (SCR_ENTRY* sbb, int left, int top, int right, int bottom, SCR_ENTRY se0);

void se_hline (SCR_ENTRY* sbb, int x0, int x1, int y, SCR_ENTRY se);
void se_vline (SCR_ENTRY* sbb, int x, int y0, int y1, SCR_ENTRY se);

// --- Prototypes -----------------------------------------------------

// --- affine ---
void bg_aff_set (BG_AFFINE* bgaff, FIXED pa, FIXED pb, FIXED pc, FIXED pd);
void bg_aff_identity (BG_AFFINE* bgaff);
void bg_aff_scale (BG_AFFINE* bgaff, FIXED sx, FIXED sy);
void bg_aff_shearx (BG_AFFINE* bgaff, FIXED hx);
void bg_aff_sheary (BG_AFFINE* bgaff, FIXED hy);

void bg_aff_rotate (BG_AFFINE* bgaff, ushort alpha);
void bg_aff_rotscale (BG_AFFINE* bgaff, int sx, int sy, ushort alpha);
void bg_aff_premul (BG_AFFINE* dst, const(BG_AFFINE)* src);
void bg_aff_postmul (BG_AFFINE* dst, const(BG_AFFINE)* src);
void bg_aff_rotscale2 (BG_AFFINE* bgaff, const(AFF_SRC)* as);
void bg_rotscale_ex (BG_AFFINE* bgaff, const(AFF_SRC_EX)* asx);

/*!	\}	*/

// --------------------------------------------------------------------
// BITMAPS
// --------------------------------------------------------------------

//! \addtogroup grpVideoBmp
/*!	\{	*/

//! \name mode 3
//\{

extern (D) auto M3_CLEAR()
{
    return memset32(vid_mem, 0, M3_SIZE / 4);
}

void m3_fill (COLOR clr);
void m3_plot (int x, int y, COLOR clr);

void m3_hline (int x1, int y, int x2, COLOR clr);
void m3_vline (int x, int y1, int y2, COLOR clr);
void m3_line (int x1, int y1, int x2, int y2, COLOR clr);

void m3_rect (int left, int top, int right, int bottom, COLOR clr);
void m3_frame (int left, int top, int right, int bottom, COLOR clr);

//\}

//! \name mode 4
//\{

extern (D) auto M4_CLEAR()
{
    return memset32(vid_page, 0, M4_SIZE / 4);
}

void m4_fill (ubyte clrid);
void m4_plot (int x, int y, ubyte clrid);

void m4_hline (int x1, int y, int x2, ubyte clrid);
void m4_vline (int x, int y1, int y2, ubyte clrid);
void m4_line (int x1, int y1, int x2, int y2, ubyte clrid);

void m4_rect (int left, int top, int right, int bottom, ubyte clrid);
void m4_frame (int left, int top, int right, int bottom, ubyte clrid);

//\}

//! \name mode 5
//\{

extern (D) auto M5_CLEAR()
{
    return memset32(vid_page, 0, M5_SIZE / 4);
}

void m5_fill (COLOR clr);
void m5_plot (int x, int y, COLOR clr);

void m5_hline (int x1, int y, int x2, COLOR clr);
void m5_vline (int x, int y1, int y2, COLOR clr);
void m5_line (int x1, int y1, int x2, int y2, COLOR clr);

void m5_rect (int left, int top, int right, int bottom, COLOR clr);
void m5_frame (int left, int top, int right, int bottom, COLOR clr);

//\}

/*!	\}	*/

// --------------------------------------------------------------------
// INLINES
// --------------------------------------------------------------------

// --- General --------------------------------------------------------

// wait till VDraw
// wait till VBlank
void vid_vsync ();

// --- Colors ---------------------------------------------------------

//! Create a 15bit BGR color.
COLOR RGB15 (int red, int green, int blue);

//! Create a 15bit BGR color, with proper masking of R,G,B components.
COLOR RGB15_SAFE (int red, int green, int blue);

//! Create a 15bit BGR color, using 8bit components
COLOR RGB8 (ubyte red, ubyte green, ubyte blue);

// --- Backgrounds ----------------------------------------------------

//! Fill screenblock \a sbb with \a se
void se_fill (SCR_ENTRY* sbb, SCR_ENTRY se);

//! Plot a screen entry at (\a x,\a y) of screenblock \a sbb.
void se_plot (SCR_ENTRY* sbb, int x, int y, SCR_ENTRY se);

//! Fill a rectangle on \a sbb with \a se.
void se_rect (
    SCR_ENTRY* sbb,
    int left,
    int top,
    int right,
    int bottom,
    SCR_ENTRY se);

//! Create a border on \a sbb with \a se.
void se_frame (
    SCR_ENTRY* sbb,
    int left,
    int top,
    int right,
    int bottom,
    SCR_ENTRY se);

// --- Affine ---

//! Copy bg affine aprameters
void bg_aff_copy (BG_AFFINE* dst, const(BG_AFFINE)* src);

//! Set the elements of an \a bg affine matrix.
void bg_aff_set (BG_AFFINE* bgaff, FIXED pa, FIXED pb, FIXED pc, FIXED pd);

//! Set an bg affine matrix to the identity matrix
void bg_aff_identity (BG_AFFINE* bgaff);

//! Set an bg affine matrix for scaling.
void bg_aff_scale (BG_AFFINE* bgaff, FIXED sx, FIXED sy);

void bg_aff_shearx (BG_AFFINE* bgaff, FIXED hx);

void bg_aff_sheary (BG_AFFINE* bgaff, FIXED hy);

// --- Bitmaps --------------------------------------------------------

// --- mode 3 interface ---

//! Fill the mode 3 background with color \a clr.
void m3_fill (COLOR clr);

//! Plot a single \a clr colored pixel in mode 3 at (\a x, \a y).
void m3_plot (int x, int y, COLOR clr);

//! Draw a \a clr colored horizontal line in mode 3.
void m3_hline (int x1, int y, int x2, COLOR clr);

//! Draw a \a clr colored vertical line in mode 3.
void m3_vline (int x, int y1, int y2, COLOR clr);

//! Draw a \a clr colored line in mode 3.
void m3_line (int x1, int y1, int x2, int y2, COLOR clr);

//! Draw a \a clr colored rectangle in mode 3.
/*! \param left	Left side, inclusive.
*	\param top	Top size, inclusive.
*	\param right	Right size, exclusive.
*	\param bottom	Bottom size, exclusive.
*	\param clr	Color.
*	\note Normalized, but not clipped.
*/
void m3_rect (int left, int top, int right, int bottom, COLOR clr);

//! Draw a \a clr colored frame in mode 3.
/*! \param left	Left side, inclusive.
*	\param top	Top size, inclusive.
*	\param right	Right size, exclusive.
*	\param bottom	Bottom size, exclusive.
*	\param clr	Color.
*	\note Normalized, but not clipped.
*/
void m3_frame (int left, int top, int right, int bottom, COLOR clr);

// --- mode 4 interface ---

//! Fill the current mode 4 backbuffer with \a clrid
void m4_fill (ubyte clrid);

//! Plot a \a clrid pixel on the current mode 4 backbuffer
void m4_plot (int x, int y, ubyte clrid);

//! Draw a \a clrid colored horizontal line in mode 4.
void m4_hline (int x1, int y, int x2, ubyte clrid);

//! Draw a \a clrid colored vertical line in mode 4.
void m4_vline (int x, int y1, int y2, ubyte clrid);

//! Draw a \a clrid colored line in mode 4.
void m4_line (int x1, int y1, int x2, int y2, ubyte clrid);

//! Draw a \a clrid colored rectangle in mode 4.
/*! \param left	Left side, inclusive.
*	\param top	Top size, inclusive.
*	\param right	Right size, exclusive.
*	\param bottom	Bottom size, exclusive.
*	\param clrid	color index.
*	\note Normalized, but not clipped.
*/
void m4_rect (int left, int top, int right, int bottom, ubyte clrid);

//! Draw a \a clrid colored frame in mode 4.
/*! \param left	Left side, inclusive.
*	\param top	Top size, inclusive.
*	\param right	Right size, exclusive.
*	\param bottom	Bottom size, exclusive.
*	\param clrid	color index.
*	\note Normalized, but not clipped.
*/
void m4_frame (int left, int top, int right, int bottom, ubyte clrid);

// --- mode 5 interface ---

//! Fill the current mode 5 backbuffer with \a clr
void m5_fill (COLOR clr);

//! Plot a \a clrid pixel on the current mode 5 backbuffer
void m5_plot (int x, int y, COLOR clr);

//! Draw a \a clr colored horizontal line in mode 5.
void m5_hline (int x1, int y, int x2, COLOR clr);

//! Draw a \a clr colored vertical line in mode 5.
void m5_vline (int x, int y1, int y2, COLOR clr);

//! Draw a \a clr colored line in mode 5.
void m5_line (int x1, int y1, int x2, int y2, COLOR clr);

//! Draw a \a clr colored rectangle in mode 5.
/*! \param left	Left side, inclusive.
*	\param top	Top size, inclusive.
*	\param right	Right size, exclusive.
*	\param bottom	Bottom size, exclusive.
*	\param clr	Color.
*	\note Normalized, but not clipped.
*/
void m5_rect (int left, int top, int right, int bottom, COLOR clr);

//! Draw a \a clr colored frame in mode 5.
/*! \param left	Left side, inclusive.
*	\param top	Top size, inclusive.
*	\param right	Right size, exclusive.
*	\param bottom	Bottom size, exclusive.
*	\param clr	Color.
*	\note Normalized, but not clipped.
*/
void m5_frame (int left, int top, int right, int bottom, COLOR clr);

// TONC_VIDEO

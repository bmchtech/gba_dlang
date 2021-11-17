//
// Tonc Text Engine main header
//
//! \file tonc_tte.h
//! \author J Vijn
//! \date 20070517 - 20080503
//
/* === NOTES ===
  * 20080503: WARNING : added the 'heights' field to TFont. All
    older fonts should be updated for the change.
  * 20080225: tte_get_context() calls are optimized out. I checked.
	After a function call all bets are off, of course.
  * 20070723: PONDER: Make positional items signed?
*/


module tonc.tonc_tte;

import core.stdc.stdio;

import tonc.tonc_surface;
import tonc.tonc_types;

extern (C):

/*! \addtogroup grpTTE
	\brief	A generalized raster text system.

	As of v1.3, Tonc has a completely new way of handling text. It can
	handle (practically) all modes, VRAM types and font sizes and brings
	them together under a unified interface. It uses function pointers to
	store \e drawg and \e erase functions of each rendering family. The
	families currently supported are:

	- <b>ase</b>:	Affine screen entries (Affine tiled BG)
	- <b>bmp8</b>:	8bpp bitmaps (Mode 4)
	- <b>bmp16</b>	16bpp bitmaps (Mode 3/5)
	- <b>chr4c</b>	4bpp characters, column-major (Regular tiled BG)
	- <b>chr4r</b>	4bpp characters, row-major (Regular tiled BG)
	- <b>obj</b>	Objects
	- <b>se</b>		Regular screen entries (Regular tiled BG)

	Each of these consists of an initializer, \c tte_init_foo, and
	one or more glyph rendering functions, \c foo_puts_bar, The \c bar
	part of the renderer denotes the style of the particular renderer,
	which can indicate:

		- Expected bitdepth of font data (\c b1 for 1bpp, etc)
		- Expected sizes of the character (\c w8 and h8, for example).
		- Application of system colors (\c c ).
		- Transparent or opaque background pixels (\c t or \c o ).
		- Whether the font-data is in 'strip' layout (\c s )

	The included renderers here are usually transparent,
	recolored, using 1bpp strip glyphs (\c _b1cts ). The initializer
	takes a bunch of options specific to each family, as well as font
	and renderer pointers. You can provide your own font and renderers,
	provided they're formatted correcty. For the default font/renderers,
	use \c NULL.<br>

	After the calling the initializer, you can write utf-8 encoded text
	with tte_write() or tte_write_ex(). You can also enable stdio-related
	functions by calling tte_init_con().<br>

	The system also supposed rudimentary scripting for positions, colors,
	margins and erases. See tte_cmd_default() and con_cmd_parse() for
	details.
	\sa	grpSurface
*/

/*!	\defgroup grpTTEOps Operations
	\ingroup grpTTE
	\brief	Basic operations.

	This covers most of the things you can actually use TTE for,
	like writing the text, getting information about a glyph and setting
	color attributes.
*/

/*!	\defgroup grpTTEAttr Attributes
	\ingroup grpTTE
	\brief	Basic getters and setters.
*/

/*! \defgroup grpTTEConio Console IO
	\ingroup grpTTE
	\brief	Stdio functionality.

	These functions allow you to use stdio routines for writing, like
	printf, puts and such. Note that tte_printf is just iprintf ...
	at least for now.
*/

/*! \defgroup grpTTEMap Tilemap text
	\ingroup grpTTE
	\brief	Text for regular and affine tilemaps.

	The tilemap sub-system loads the tiles into memory first, then
	writes to the map to show the letters. For this to work properly,
	the glyph sizes should be 8-pixel aligned.
	\note	At present, the regular tilemap text ignores screenblock
		boundaries, so 512px wide maps may not work properly.
*/

/*! \defgroup grpTTEChr4c Character text, column-major
	\ingroup grpTTE
	\brief	Text on surface composed of 4bpp tiles, mapped in column-major order.

	There are actually two \e chr4 systems. The difference
	between the two is the ordering of the tiles: column-major
	versus row-major. Since column-major is 'better', this is
	considered the primary sub-system for tiled text.
	\sa grpSchr4c
*/

/*! \defgroup grpTTEChr4r Character text, row-major
	\ingroup grpTTE
	\brief	Text on surface composed of 4bpp tiles, mapped in row-major order.

	There are actually two \e chr4 systems, with row-major and
	column-major tile indexing. The column-major version is more
	advanced, so use that when possible.
	\sa grpSchr4r
*/

/*! \defgroup grpTTEBmp Bitmap text
	\ingroup grpTTE
	\brief	Text for 16bpp and 8bpp bitmap surfaces: modes 3, 4 and 5.

	Note that TTE does not update the pointer of the surface for
	page-flipping. You'll have to do that yourself.
*/

/*! \defgroup grpTTEObj Object text
	\ingroup grpTTE
	\brief	Text using objects.

	This is similar to tilemaps, in that the glyphs are loaded into
	object VRAM first and pointed to by the objects. Unlike tilemaps,
	though, variable-width fonts are possible here. The members of
	the surface member are used a little differently here, though.
	the <code>pitch</code> is used as an index to the current
	object, and <code>width</code> is the number of objects allowed
	to be used for text.
*/

// --------------------------------------------------------------------
// CONSTANTS
// --------------------------------------------------------------------

/*! \addtogroup grpTTE	*/
/*!	\{	*/

enum TTE_TAB_WIDTH = 24;

//! \name Color lut indices
//\{
enum TTE_INK = 0;
enum TTE_SHADOW = 1;
enum TTE_PAPER = 2;
enum TTE_SPECIAL = 3;
//\}

// --------------------------------------------------------------------
// MACROS
// --------------------------------------------------------------------

//! \name drawg helper macros
/*! Each \c drawg renderer usually starts with the same thing:
	- Get the system and font pointers.
	- Translate from ascii-character to glyph offset.
	- Get the glyph (and glyph-cell) dimensions.
	- Get the source and destination pointers and positions.
	These macros will make declarint and defining that easier.
*/
//\{

//! Declare and define base drawg variables

//! Declare and define basic source drawg variables

//! Declare and define basic destination drawg variables

//\}

//! \name Default fonts
//\{
alias fwf_default = sys8Font; //!< Default fixed-width font
alias vwf_default = verdana9Font; //!< Default vairable-width font
//\}

//! \name Default glyph renderers
//\{
// // enum ase_drawg_default = cast(fnDrawg) ase_drawg_s;
// ref fnDrawg ase_drawg_default() { return cast(fnDrawg) ase_drawg_s;}
// // enum bmp8_drawg_default = cast(fnDrawg) bmp8_drawg_b1cts;
// ref fnDrawg bmp8_drawg_default() { return cast(fnDrawg) bmp8_drawg_b1cts;}
// // enum bmp16_drawg_default = cast(fnDrawg) bmp16_drawg_b1cts;
// ref fnDrawg bmp16_drawg_default() { return cast(fnDrawg) bmp16_drawg_b1cts;}
// // enum chr4c_drawg_default = cast(fnDrawg) chr4c_drawg_b1cts;
// ref fnDrawg chr4c_drawg_default() { return cast(fnDrawg) chr4c_drawg_b1cts;}
// // enum chr4r_drawg_default = cast(fnDrawg) chr4r_drawg_b1cts;
// ref fnDrawg chr4r_drawg_default() { return cast(fnDrawg) chr4r_drawg_b1cts;}
// // enum obj_drawg_default = cast(fnDrawg) obj_drawg;
// ref fnDrawg obj_drawg_default() { return cast(fnDrawg) obj_drawg;}
// // enum se_drawg_default = cast(fnDrawg) se_drawg_s;
// ref fnDrawg se_drawg_default() { return cast(fnDrawg) se_drawg_s;}
//\}

//! \name Default initializers
//\{

extern (D) auto tte_init_se_default(T0, T1)(auto ref T0 bgnr, auto ref T1 bgcnt)
{
    return tte_init_se(bgnr, bgcnt, 0xF000, CLR_YELLOW, 0, &fwf_default, NULL);
}

extern (D) auto tte_init_ase_default(T0, T1)(auto ref T0 bgnr, auto ref T1 bgcnt)
{
    return tte_init_ase(bgnr, bgcnt, 0x0000, CLR_YELLOW, 0, &fwf_default, NULL);
}

extern (D) auto tte_init_bmp_default(T)(auto ref T mode)
{
    return tte_init_bmp(mode, &vwf_default, NULL);
}

extern (D) auto tte_init_obj_default(T)(auto ref T pObj)
{
    return tte_init_obj(pObj, 0, 0, 0xF000, CLR_YELLOW, 0, &fwf_default, NULL);
}

//\}

// --------------------------------------------------------------------
// CLASSES
// --------------------------------------------------------------------

//! Glyph render function format.
alias fnDrawg = void function (uint gid);

//! Erase rectangle function format.
alias fnErase = void function (int left, int top, int right, int bottom);

//! Font description struct.
/*!	The \c TFont contains a description of the font, including pointers
	to the glyph data and width data (for VWF fonts), an ascii-offset
	for when the first glyph isn't for ascii-null (which is likely.
	Usually it starts at ' ' (32)).<br>
	The font-bitmap is a stack of cells, each containing one glyph
	each. The cells and characters need not be the same size, but
	the character glyph must fit within the cell.<br>

	The formatting of the glyphs themselves should fit the rendering
	procedure. The default renderers use 1bpp 8x8 tiled graphics,
	where for multi-tiled cells the tiles are in a <b>vertical</b>
	'strip' format. In an 16x16 cell, the 4 tiles would be arranged as:

	<table border=1 cellpadding=2 cellspacing=0>
	<tr> <td>0</td> <td>2</td></tr>
	<tr> <td>1</td> <td>3</td></tr>
	</table>
*/
struct TFont
{
    const(void)* data; //!< Character data.
    const(ubyte)* widths; //!< Width table for variable width font.
    const(ubyte)* heights; //!< Height table for variable height font.
    ushort charOffset; //!< Character offset
    ushort charCount; //!< Number of characters in font.
    ubyte charW; //!< Character width (fwf).
    ubyte charH; //!< Character height.
    ubyte cellW; //!< Glyph cell width.
    ubyte cellH; //!< Glyph cell height.
    ushort cellSize; //!< Cell-size (bytes).
    ubyte bpp; //!< Font bitdepth;
    ubyte extra; //!< Padding. Free to use.	
}

//! TTE context struct.
struct TTC
{
    // Members for renderers
    TSurface dst; //!< Destination surface.
    short cursorX; //!< Cursor X-coord.
    short cursorY; //!< Cursor Y-coord.
    TFont* font; //!< Current font.
    ubyte* charLut; //!< Character mapping lut. (if any).
    ushort[4] cattr; //!< ink, shadow, paper and special color attributes.
    // Higher-up members
    ushort flags0;
    ushort ctrl; //!< BG control flags.	(PONDER: remove?)
    ushort marginLeft;
    ushort marginTop;
    ushort marginRight;
    ushort marginBottom;
    short savedX;
    short savedY;
    // Callbacks and table pointers
    fnDrawg drawgProc; //!< Glyph render procedure.
    fnErase eraseProc; //!< Text eraser procedure.
    const(TFont*)* fontTable; //!< Pointer to font table for \{f}.
    const(char*)* stringTable; //!< Pointer to string table for \{s}.
}

// --------------------------------------------------------------------
// GLOBALS
// --------------------------------------------------------------------

//extern TTC __tte_main_context;
extern __gshared TTC* gp_tte_context;

//! \name Internal fonts
//\{

// --- Main Font data ---
extern __gshared const TFont sys8Font; //!< System font ' '-127. FWF  8x 8\@1.

extern __gshared const TFont verdana9Font; //!< Verdana 9 ' '-'�'. VWF  8x12\@1.
extern __gshared const TFont verdana9bFont; //!< Verdana 9 bold ' '-'�'. VWF  8x12\@1.
extern __gshared const TFont verdana9iFont; //!< Verdana 9 italic ' '-'�'. VWF  8x12\@1.

extern __gshared const TFont verdana10Font; //!< Verdana 10 ' '-'�'. VWF 16x14\@1.

extern __gshared const TFont verdana9_b4Font; //!< Verdana 9 ' '-'�'. VWF  8x12\@4.

// --- Extra font data ---

extern __gshared const(uint)[192] sys8Glyphs;

extern __gshared const(uint)[896] verdana9Glyphs;
extern __gshared const(ubyte)[224] verdana9Widths;

extern __gshared const(uint)[896] verdana9bGlyphs;
extern __gshared const(ubyte)[224] verdana9bWidths;

extern __gshared const(uint)[896] verdana9iGlyphs;
extern __gshared const(ubyte)[224] verdana9iWidths;

extern __gshared const(uint)[1792] verdana10Glyphs;
extern __gshared const(ubyte)[224] verdana10Widths;

extern __gshared const(uint)[3584] verdana9_b4Glyphs;
extern __gshared const(ubyte)[224] verdana9_b4Widths;

//\}

/*!	\} */ // grpTTE

// --------------------------------------------------------------------
// PROTOTYPES
// --------------------------------------------------------------------

// === Operations =====================================================

/*! \addtogroup grpTTEOps		*/
/*!	\{	*/

void tte_set_context (TTC* tc);
TTC* tte_get_context ();

uint tte_get_glyph_id (int ch);
int tte_get_glyph_width (uint gid);
int tte_get_glyph_height (uint gid);
const(void)* tte_get_glyph_data (uint gid);

void tte_set_color (eint type, ushort clr);
void tte_set_colors (const(ushort)* colors);

void tte_set_color_attr (eint type, ushort cattr);
void tte_set_color_attrs (const(ushort)* cattrs);

char* tte_cmd_default (const(char)* str);

int tte_putc (int ch);
int tte_write (const(char)* text);
int tte_write_ex (int x, int y, const(char)* text, const(ushort)* clrlut);

void tte_erase_rect (int left, int top, int right, int bottom);
void tte_erase_screen ();
void tte_erase_line ();

POINT16 tte_get_text_size (const(char)* str);

void tte_init_base (const(TFont)* font, fnDrawg drawProc, fnErase eraseProc);

/*! \}	*/ // grpTTEOps

// === Attributes functions ===========================================

/*! \addtogroup grpTTEAttr		*/
/*!	\{	*/

// --- getters ---

void tte_get_pos (int* x, int* y);
ushort tte_get_ink ();
ushort tte_get_shadow ();
ushort tte_get_paper ();
ushort tte_get_special ();

TSurface* tte_get_surface ();
TFont* tte_get_font ();
fnDrawg tte_get_drawg ();
fnErase tte_get_erase ();

char** tte_get_string_table ();
TFont** tte_get_font_table ();

// --- setters ---
void tte_set_pos (int x, int y);
void tte_set_ink (ushort cattr);
void tte_set_shadow (ushort cattr);
void tte_set_paper (ushort cattr);
void tte_set_special (ushort cattr);

void tte_set_surface (const(TSurface)* srf);
void tte_set_font (const(TFont)* font);
void tte_set_drawg (fnDrawg proc);
void tte_set_erase (fnErase proc);

void tte_set_string_table (const(char)** table);
void tte_set_font_table (const(TFont)** table);

void tte_set_margins (int left, int top, int right, int bottom);

/*! \}	*/ // grpTTEAttr

// === Console functions ==============================================

/*! \addtogroup grpTTEConio	*/
/*!	\{	*/

void tte_init_con ();
int tte_cmd_vt100 (const(char)* text);

ssize_t tte_con_write (_reent* r, void* fd, const(char)* text, size_t len);
ssize_t tte_con_nocash (_reent* r, void* fd, const(char)* text, size_t len);

/*! Wrapper 'function' to hide that we're making iprintf do
	things it doesn't usually do.
*/
alias tte_printf = iprintf;

/*!	\}	*/

// === Render families ================================================

/*! \addtogroup grpTTEMap	*/
/*!	\{	*/

//! \name Regular tilemaps
//\{
void tte_init_se (
    int bgnr,
    ushort bgcnt,
    SCR_ENTRY se0,
    uint clrs,
    uint bupofs,
    const(TFont)* font,
    fnDrawg proc);

void se_erase (int left, int top, int right, int bottom);

void se_drawg_w8h8 (uint gid);
void se_drawg_w8h16 (uint gid);
void se_drawg (uint gid);
void se_drawg_s (uint gid);
//\}

//! \name Affine tilemaps
//\{
void tte_init_ase (
    int bgnr,
    ushort bgcnt,
    ubyte ase0,
    uint clrs,
    uint bupofs,
    const(TFont)* font,
    fnDrawg proc);

void ase_erase (int left, int top, int right, int bottom);

void ase_drawg_w8h8 (uint gid);
void ase_drawg_w8h16 (uint gid);
void ase_drawg (uint gid);
void ase_drawg_s (uint gid);
//\}

/*!	\}	*/

/*! \addtogroup grpTTEChr4c	*/
/*!	\{	*/

//! \name 4bpp tiles
//\{
void tte_init_chr4c (
    int bgnr,
    ushort bgcnt,
    ushort se0,
    uint cattrs,
    uint clrs,
    const(TFont)* font,
    fnDrawg proc);

void chr4c_erase (int left, int top, int right, int bottom);

void chr4c_drawg_b1cts (uint gid);
void chr4c_drawg_b1cts_fast (uint gid);

void chr4c_drawg_b4cts (uint gid);
void chr4c_drawg_b4cts_fast (uint gid);

//void chr4c_drawg_b4cos(uint gid);
//IWRAM_CODE int chr4c_drawg_co_fast(uint gid);
//\}

/*!	\}	*/

/*! \addtogroup grpTTEChr4r	*/
/*!	\{	*/

//! \name 4bpp tiles
//\{
void tte_init_chr4r (
    int bgnr,
    ushort bgcnt,
    ushort se0,
    uint cattrs,
    uint clrs,
    const(TFont)* font,
    fnDrawg proc);

void chr4r_erase (int left, int top, int right, int bottom);

void chr4r_drawg_b1cts (uint gid);
void chr4r_drawg_b1cts_fast (uint gid);

//\}

/*!	\}	*/

/*! \addtogroup grpTTEBmp	*/
/*!	\{	*/

void tte_init_bmp (int vmode, const(TFont)* font, fnDrawg proc);

//! \name 8bpp bitmaps
//\(
void bmp8_erase (int left, int top, int right, int bottom);

void bmp8_drawg (uint gid);
void bmp8_drawg_t (uint gid);

void bmp8_drawg_b1cts (uint gid);
void bmp8_drawg_b1cts_fast (uint gid);
void bmp8_drawg_b1cos (uint gid);
//\}

//! \name 16bpp bitmaps
//\{
void bmp16_erase (int left, int top, int right, int bottom);

void bmp16_drawg (uint gid);
void bmp16_drawg_t (uint gid);

void bmp16_drawg_b1cts (uint gid);
void bmp16_drawg_b1cos (uint gid);
//\}

/*!	\}	*/

/*! \addtogroup grpTTEObj		*/
/*	\{	*/

void tte_init_obj (
    OBJ_ATTR* dst,
    uint attr0,
    uint attr1,
    uint attr2,
    uint clrs,
    uint bupofs,
    const(TFont)* font,
    fnDrawg proc);

void obj_erase (int left, int top, int right, int bottom);

void obj_drawg (uint gid);

/*!	\}	*/

// --------------------------------------------------------------------
// INLINES
// --------------------------------------------------------------------

//! Get the master text-system
TTC* tte_get_context ();

// --- Font-specific functions ---

//! Get the glyph index of character \a ch.
uint tte_get_glyph_id (int ch);

//! Get the glyph data of glyph \a id.
const(void)* tte_get_glyph_data (uint gid);

//! Get the width of glyph \a id.
int tte_get_glyph_width (uint gid);

//! Get the height of glyph \a id.
int tte_get_glyph_height (uint gid);

// === Attributes ===

//! Set the text  surface.
void tte_set_surface (const(TSurface)* srf);

//! Get a pointer to the text surface.
TSurface* tte_get_surface ();

//! Set cursor position
void tte_set_pos (int x, int y);

//! Get cursor position
void tte_get_pos (int* x, int* y);

//! Set the font
void tte_set_font (const(TFont)* font);

//! Get the active font
TFont* tte_get_font ();

//! Set ink color attribute.
void tte_set_ink (ushort cattr);

//! Set shadow color attribute.
void tte_set_shadow (ushort cattr);

//! Set paper color attribute.
void tte_set_paper (ushort cattr);

//! Set special color attribute.
void tte_set_special (ushort cattr);

//! Get ink color attribute.
ushort tte_get_ink ();

//! Get shadow color attribute.
ushort tte_get_shadow ();

//! Get paper color attribute.
ushort tte_get_paper ();

//! Get special color attribute.
ushort tte_get_special ();

//! Set the character plotter
void tte_set_drawg (fnDrawg proc);

//! Get the active character plotter
fnDrawg tte_get_drawg ();

//! Set the character plotter
void tte_set_erase (fnErase proc);

//! Get the character plotter
fnErase tte_get_erase ();

//! Set string table
void tte_set_string_table (const(char)** table);

//! Get string table
char** tte_get_string_table ();

//! Set font table
void tte_set_font_table (const(TFont)** table);

//! Get font table
TFont** tte_get_font_table ();

// TONC_TTE

// EOF

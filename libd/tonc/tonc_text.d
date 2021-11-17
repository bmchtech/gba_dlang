//
//  Text system header file
//
//! \file tonc_text.h
//! \author J Vijn
//! \date 20060605 - 20060605
//
// === NOTES ===
//
/* === NOTES ===
	* 20070822: These routines have been superceded by TTE.
	* This file is NOT meant to contain the Mother Of All Text Systems.
	  Rather, this contains the bases to build text-systems on,
	  whether they are map-based, bitmap-based or sprite-based.
	* Text systems tend to be a little fickle, I'll probably add things
	  over time.
	* On use. There are 'standard' initialisers, the txt_init_xxx
	  things, that set up default conditions: using toncfont, 8x8 chars,
	  palettes, that sort of thing. For the rest, just use xxx_puts to
	  write a string and xxx_clrs to clear it again. If you want other
	  fonts or an other charmap you can change it, within limits.
*/

module tonc.tonc_text;

import tonc.tonc_types;
import tonc.tonc_memmap;
import tonc.tonc_memdef;
import tonc.tonc_core;

extern (C):

/*!	\addtogroup module tonc.tonc_text;

import tonc.tonc_types;

grpText
	\deprecated While potentially still useful, TTE is considerably
	more advanced. Use that instead.
*/

/*! \defgroup grpTextTile Tilemap text
*	\ingroup grpText
*/

/*! \defgroup grpTextBm Bitmap text
*	\ingroup grpText
*/

/*! \defgroup grpTextObj Object text
*	\ingroup grpText
*/

// --------------------------------------------------------------------
// CONSTANTS
// --------------------------------------------------------------------

enum toncfontTilesLen = 768;

// --------------------------------------------------------------------
// CLASSES 
// --------------------------------------------------------------------

//!
struct tagTXT_BASE
{
    ushort* dst0; //!< writing buffer starting point
    uint* font; // pointer to font used
    ubyte* chars; // character map (chars as in letters, not tiles)
    ubyte* cws; // char widths (for VWF)
    ubyte dx;
    ubyte dy; // letter distances
    ushort flags; // for later
    ubyte[12] extra; // ditto
}

alias TXT_BASE = tagTXT_BASE;

// --------------------------------------------------------------------
// GLOBALS 
// --------------------------------------------------------------------

extern __gshared const(uint)[192] toncfontTiles;

extern __gshared TXT_BASE __txt_base;
extern __gshared TXT_BASE* gptxt;
extern __gshared ubyte[256] txt_lut;

extern __gshared ushort* vid_page;

// --------------------------------------------------------------------
// PROTOTYPES 
// --------------------------------------------------------------------

// --- overall (tonc_text.c) ---

/*! \addtogroup grpText
	\brief	Text writers for all modes and objects.

	There are three types of text writers here:
	<ul>
	  <li>Tilemap (<code>se_</code> routines)
	  <li>Bitmap (<code>bm_</code> and <code>m<i>x</i>_</code> routines)
	  <li>Object (<code>obj_</code> routines)
	</ul>
	Each of these has an initializer, a char writer, and string writer
	and a string clearer. The general interface for all of these is
	<code>foo(x, y, string/char, special)</code>, Where x and y are the
	positions <b>in pixels</b>, and special depends on the mode-type:
	it can be a color, base screenentry or whatever.<br>
	The clearing routines also use a string parameter, which is used to
	indicate the exact area to clear. You're free to clear the whole
	buffer if you like.
*/
/*!	\{	*/

void txt_init_std ();
void txt_bup_1toX (void* dstv, const(void)* srcv, uint len, int bpp, uint base);

/*!	\}	*/

//! \addtogroup grpTextTile
/*!	\{	*/

// --- Tilemap text (tonc_text_map.c) ---
void txt_init_se (int bgnr, ushort bgcnt, SCR_ENTRY se0, uint clrs, uint base);
void se_putc (int x, int y, int c, SCR_ENTRY se0);
void se_puts (int x, int y, const(char)* str, SCR_ENTRY se0);
void se_clrs (int x, int y, const(char)* str, SCR_ENTRY se0);

/*!	\}	*/

// --- Bitmap text (tonc_text_bm.c) ---

//! \addtogroup grpTextBm
/*!	\{	*/

//! \name Mode-independent functions
//\{
void bm_putc (int x, int y, int c, COLOR clr);
void bm_puts (int x, int y, const(char)* str, COLOR clr);
void bm_clrs (int x, int y, const(char)* str, COLOR clr);
//\}

//! \name Mode 3 functions
//\{
void m3_putc (int x, int y, int c, COLOR clr);
void m3_puts (int x, int y, const(char)* str, COLOR clr);
void m3_clrs (int x, int y, const(char)* str, COLOR clr);
//\}

//! \name Mode 4 functions
//\{
void m4_putc (int x, int y, int c, ubyte clrid);
void m4_puts (int x, int y, const(char)* str, ubyte clrid);
void m4_clrs (int x, int y, const(char)* str, ubyte clrid);
//\}

//! \name Mode 5 functions
//\{
void m5_putc (int x, int y, int c, COLOR clr);
void m5_puts (int x, int y, const(char)* str, COLOR clr);
void m5_clrs (int x, int y, const(char)* str, COLOR clr);
//\}

// \name Internal routines
//\{
void bm16_putc (ushort* dst, int c, COLOR clr, int pitch);
void bm16_puts (ushort* dst, const(char)* str, COLOR clr, int pitch);
void bm16_clrs (ushort* dst, const(char)* str, COLOR clr, int pitch);

void bm8_putc (ushort* dst, int c, ubyte clrid);
void bm8_puts (ushort* dst, const(char)* str, ubyte clrid);
//\}

/*!	\}	*/

// --- Object text (tonc_text_oam.c) ---

//! \addtogroup grpTextObj
/*!	\{	*/

void obj_putc2 (int x, int y, int c, ushort attr2, OBJ_ATTR* obj0);
void obj_puts2 (int x, int y, const(char)* str, ushort attr2, OBJ_ATTR* obj0);

void txt_init_obj (OBJ_ATTR* obj0, ushort attr2, uint clrs, uint base);
void obj_putc (int x, int y, int c, ushort attr2);
void obj_puts (int x, int y, const(char)* str, ushort attr2);
void obj_clrs (int x, int y, const(char)* str);

/*!	\}	*/

// --------------------------------------------------------------------
// MACROS 
// --------------------------------------------------------------------

// === INLINES=========================================================

// --- Bitmap text ---

//! Write character \a c to (x, y) in color \a clr in mode 3
void m3_putc (int x, int y, int c, COLOR clr);

//! Write string \a str to (x, y) in color \a clr in mode 3
void m3_puts (int x, int y, const(char)* str, COLOR clr);

//! Clear the space used by string \a str at (x, y) in color \a clr in mode 3
void m3_clrs (int x, int y, const(char)* str, COLOR clr);

//! Write character \a c to (x, y) in color-index \a clrid in mode 4
void m4_putc (int x, int y, int c, ubyte clrid);

//! Write string \a str to (x, y) in color-index \a clrid in mode 4
void m4_puts (int x, int y, const(char)* str, ubyte clrid);

//! Clear the space used by string \a str at (x, y) in color-index \a clrid in mode 4
void m4_clrs (int x, int y, const(char)* str, ubyte clrid);

//! Write character \a c to (x, y) in color \a clr in mode 5
void m5_putc (int x, int y, int c, COLOR clr);

//! Write string \a str to (x, y) in color \a clr in mode 5
void m5_puts (int x, int y, const(char)* str, COLOR clr);

//! Clear the space used by string \a str at (x, y) in color \a clr in mode 5
void m5_clrs (int x, int y, const(char)* str, COLOR clr);

// --- Object text ---

//! Write character \a c to (x, y) in color \a clr using objects \a obj0 and on
void obj_putc2 (int x, int y, int c, ushort attr2, OBJ_ATTR* obj0);

//! Write string \a str to (x, y) in color \a clr using objects \a obj0 and on
void obj_puts2 (int x, int y, const(char)* str, ushort attr2, OBJ_ATTR* obj0);

// TONC_TEXT

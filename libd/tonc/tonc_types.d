//
//  Basic structs and typedefs
//
//! \file tonc_types.h
//! \author J Vijn
//! \date 20060508 - 20080111
//
// === NOTES ===
// * When doing anything,  always, ALWAYS!!! check the type. 
//   Especially when you're combining things from different sources.
//   Look around on the forum and count the number of times people
//   have copied, say, from a u32 source to a u16 destination.

module tonc.tonc_types;

import ldc.attributes;

extern (C):

/*!	\defgroup grpTypes	Types and attributes	*/

// --------------------------------------------------------------------
// GCC ATTRIBUTES
// --------------------------------------------------------------------

/*!	\defgroup grpTypeAttr	Type attributes
*	\ingroup grpTypes
*/
/*!	\{	*/

// If you want your data in specific sections, add this 
// to your variables or functions.
// Example:
//
// //Declaration
// IWRAM_CODE void function(int x, int y, etc);
//
// //Definition
// IWRAM_CODE void function(int x, int y, etc)
// {
//     // code 
// }

// //! Put variable in IWRAM (default).
// #define IWRAM_DATA __attribute__((section(".iwram")))
template IWRAM_DATA(string T, string var) {
    const char[] IWRAM_DATA = "@(ldc.attributes.section(\".iwram\")) " ~ T ~ var ~ ";";
}

// //! Put variable in EWRAM.
// #define EWRAM_DATA __attribute__((section(".ewram")))
template EWRAM_DATA(string T, string var) {
    const char[] EWRAM_DATA = "@(ldc.attributes.section(\".ewram\")) " ~ T ~ var ~ ";";
}

// //! Put <b>non</b>-initialized variable in EWRAM.
// #define  EWRAM_BSS __attribute__((section(".sbss")))

// //! Put function in IWRAM.
// #define IWRAM_CODE __attribute__((section(".iwram"), long_call))

// //! Put function in EWRAM.
// #define EWRAM_CODE __attribute__((section(".ewram"), long_call))

// //! Force a variable to an \a n-byte boundary
// #define ALIGN(n)	__attribute__((aligned(n)))

//! Force word alignment.
/*! \note	In the old days, GCC aggregates were always word aligned.
	  In the EABI environment (devkitPro r19 and higher), they are
	  aligned to their widest member. While technically a good thing,
	  it may cause problems for struct-copies. If you have aggregates
	  that can multiples of 4 in size but don't have word members,
	  consider using this attribute to make struct-copies possible again.
*/

//! Pack aggregate members
/*! By default, members in aggregates are aligned to their native
	  boundaries. Adding this prevents that. It will slow access though.
*/

//! Deprecated notice.
/*! Indicates that this function/type/variable should not be used anymore.
	Replacements are (usually) present somewhere as well.
*/

//! Inline function declarator
/*!	`inline' inlines the function when -O > 0 when called,
	  but also creates a body for the function itself
	`static' removes the body as well
*/

/*	\}	*/

// --------------------------------------------------------------------
// TYPES
// --------------------------------------------------------------------

// === primary typedefs ===============================================

/*!	\defgroup grpTypePrim	Primary types
	\ingroup grpTypes
*/
/*!	\{	*/

/*! \name Base types
	Basic signed and unsigned types for 8, 16, 32 and 64-bit integers.
	<ul>
	   <li>s# : signed #-bit integer. </li>
	   <li>u#/u{type} : unsigned #-bit integer.</li>
	   <li>e{type} : enum'ed #-bit integer.</li>

	</ul>
*/
//\{
alias u8 = ubyte;
alias u16 = ushort;
alias u32 = uint;
alias u64 = ulong;

alias echar = u8;
alias eshort = u16;
alias eint = u32;

alias s8 = byte;
alias s16 = short;
alias s32 = int;
alias s64 = long;

//\}

/*! \name Volatile types
*	Volatile types for registers
*/
//\{
alias vu8 = ubyte;
alias vu16 = ushort;
alias vu32 = uint;
alias vu64 = ulong;

alias vs8 = byte;
alias vs16 = short;
alias vs32 = int;
alias vs64 = long;
//\}

/*! \name Const types
*	Const types for const function aprameters
*/
//\{
alias cu8 = const ubyte;
alias cu16 = const ushort;
alias cu32 = const uint;
alias cu64 = const ulong;

alias cs8 = const byte;
alias cs16 = const short;
alias cs32 = const int;
alias cs64 = const long;
//\}

//! 8-word type for fast struct-copies
struct BLOCK
{
    uint[8] data;
}

//! Type for consting a string as well as the pointer than points to it.
alias CSTR = const char*;

/*	\}	*/

// === secondary typedefs =============================================

/*!	\defgroup grpTypeSec	Secondary types
*	\ingroup grpTypes
*/
/*!	\{	*/

alias FIXED = int; //!< Fixed point type
alias COLOR = ushort; //!< Type for colors
alias SCR_ENTRY = ushort;
alias SE = ushort; //!< Type for screen entries
alias SCR_AFF_ENTRY = ubyte;
alias SAE = ubyte; //!< Type for affine screen entries

//! 4bpp tile type, for easy indexing and copying of 4-bit tiles
struct TILE
{
    uint[8] data;
}

alias TILE4 = TILE;

//! 8bpp tile type, for easy indexing and 8-bit tiles
struct TILE8
{
    uint[16] data;
}

alias BOOL = ubyte; // C++ bool == u8 too, that's why
enum TRUE = 1;
enum FALSE = 0;

// --- function pointer ---

alias fnptr = void function (); //!< void foo() function pointer
alias fn_v_i = void function (int); //!< void foo(int x) function pointer
alias fn_i_i = int function (int); //!< int foo(int x) function pointer

//! \name affine structs
//\{
//! Simple scale-rotation source struct.
/*! This can be used with ObjAffineSet, and several of tonc's
*	  affine functions
*/
struct AFF_SRC
{
    short sx; //!< Horizontal zoom	(8.8f)
    short sy; //!< Vertical zoom		(8.8f)
    ushort alpha; //!< Counter-clockwise angle ( range [0, 0xFFFF] )
}

alias ObjAffineSource = AFF_SRC;

//! Extended scale-rotate source struct
/*! This is used to scale/rotate around an arbitrary point. See
*	  tonc's main text for all the details.
*/
struct AFF_SRC_EX
{
    int tex_x; //!< Texture-space anchor, x coordinate	(.8f)
    int tex_y; //!< Texture-space anchor, y coordinate	(.8f)
    short scr_x; //!< Screen-space anchor, x coordinate	(.0f)
    short scr_y; //!< Screen-space anchor, y coordinate	(.0f)
    short sx; //!< Horizontal zoom	(8.8f)
    short sy; //!< Vertical zoom		(8.8f)
    ushort alpha; //!< Counter-clockwise angle ( range [0, 0xFFFF] )
}

alias BgAffineSource = AFF_SRC_EX;

//! Simple scale-rotation destination struct, BG version.
/*! This is a P-matrix with continuous elements, like the BG matrix.
*	  It can be used with ObjAffineSet.
*/
struct AFF_DST
{
    short pa;
    short pb;
    short pc;
    short pd;
}

alias ObjAffineDest = AFF_DST;

//! Extended scale-rotate destination struct
/*! This contains the P-matrix and a fixed-point offset , the
*	  combination can be used to rotate around an arbitrary point.
*	  Mainly intended for BgAffineSet, but the struct cna be used
*	  for object transforms too.
*/
struct AFF_DST_EX
{
    short pa;
    short pb;
    short pc;
    short pd;
    int dx;
    int dy;
}

alias BgAffineDest = AFF_DST_EX;

//\}

/*	\}	*/

// === memory map structs  ============================================

/*!	\defgroup grpTypeTert	Tertiary types
*	These types are used for memory mapping of VRAM, affine registers
*	  and other areas that would benefit from logical memory mapping.
*	\ingroup grpTypes
*/
/*!	\{	*/

//! \name IO register types
//\{

//! Regular bg points; range: :0010 - :001F
struct POINT16
{
    short x;
    short y;
}

alias BG_POINT = POINT16;

//! Affine parameters for backgrounds; range : 0400:0020 - 0400:003F
alias BG_AFFINE = AFF_DST_EX;

//!	DMA struct; range: 0400:00B0 - 0400:00DF
struct DMA_REC
{
    const(void)* src;
    void* dst;
    uint cnt;
}

//! Timer struct, range: 0400:0100 - 0400:010F
/*! \note The attribute is required, because union's counted as u32 otherwise.
*/
struct TMR_REC
{
    union
    {
        align (1):

        ushort start;
        ushort count;
    }

    ushort cnt;
}

//\}

//! \name PAL types 
//\{

//! Palette bank type, for 16-color palette banks 
alias PALBANK = ushort[16];

//\}

/*! \name VRAM array types
*	These types allow VRAM access as arrays or matrices in their
*	  most natural types.
*/
//\{
alias SCREENLINE = ushort[32];
alias SCREENMAT = ushort[32][32];
alias SCREENBLOCK = ushort[1024];

alias M3LINE = ushort[240];
alias M4LINE = ubyte[240]; // NOTE: u8, not u16!!
alias M5LINE = ushort[160];

alias CHARBLOCK = TILE[512];
alias CHARBLOCK8 = TILE8[256];

//\}

/*! \name OAM structs
*	\note These OBJ_ATTR and OBJ_AFFINE structs are interlaced in OAM.
*	  When using affine objs, struct/DMA/mem copies will give bad results.
*/
//\{

//! Object attributes.
/*!	\note attribute 3 is padding for the interlace with OBJ_AFFINE. If
*	not using affine objects, it can be used as a free field
*/
struct OBJ_ATTR
{
    ushort attr0;
    ushort attr1;
    ushort attr2;
    short fill;
}

//! Object affine parameters.
/*!	\note most fields are padding for the interlace with OBJ_ATTR.
*/
struct OBJ_AFFINE
{
    ushort[3] fill0;
    short pa;
    ushort[3] fill1;
    short pb;
    ushort[3] fill2;
    short pc;
    ushort[3] fill3;
    short pd;
}

//\}

/*!	\}	*/

// --------------------------------------------------------------------
// DEFINES 
// --------------------------------------------------------------------

enum NULL = cast(void*) 0;

// TONC_TYPES

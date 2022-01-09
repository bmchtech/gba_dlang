//
//  Core functionality
//
//! \file tonc_core.h
//! \author J Vijn
//! \date 20060508 - 20080128
//
/* === NOTES ===
  * Contents: bits, random, dma, timer
  * 20080129,jv: added tonccpy/set routines.
*/

module tonc.tonc_core;

import tonc.tonc_types;
import tonc.tonc_memdef;
import tonc.tonc_memmap;

extern (C):

// --------------------------------------------------------------------
// BITS and BITFIELDS
// --------------------------------------------------------------------

/*! \defgroup grpCoreBit	Bit(field) macros
	\ingroup grpCore
*/
/*!	\{	*/

//! \name Simple bit macros
//\{

//! Create value with bit \a n set
extern (D) auto BIT(T)(auto ref T n)
{
    return 1 << n;
}

//! Shift \a a by \a n
extern (D) auto BIT_SHIFT(T0, T1)(auto ref T0 a, auto ref T1 n)
{
    return a << n;
}

//! Create a bitmask \a len bits long
extern (D) auto BIT_MASK(T)(auto ref T len)
{
    return BIT(len) - 1;
}

//! Set the \a flag bits in \a word

//! Clear the \a flag bits in \a word

//! Flip the \a flag bits in \a word

//! Test whether all the \a flag bits in \a word are set
extern (D) auto BIT_EQ(T0, T1)(auto ref T0 y, auto ref T1 flag)
{
    return (y & flag) == flag;
}

//! Create a bitmask of length \a len starting at bit \a shift.
extern (D) auto BF_MASK(T0, T1)(auto ref T0 shift, auto ref T1 len)
{
    return BIT_MASK(len) << shift;
}

//! Retrieve a bitfield mask of length \a starting at bit \a shift from \a y.
extern (D) auto _BF_GET(T0, T1, T2)(auto ref T0 y, auto ref T1 shift, auto ref T2 len)
{
    return (y >> shift) & BIT_MASK(len);
}

//! Prepare a bitmask for insertion or combining.
extern (D) auto _BF_PREP(T0, T1, T2)(auto ref T0 x, auto ref T1 shift, auto ref T2 len)
{
    return (x & BIT_MASK(len)) << shift;
}

//! Insert a new bitfield value \a x into \a y.

//\}

/*! \name some EVIL bit-field operations, >:)
*	These allow you to mimic bitfields with macros. Most of the
*	bitfields in the registers have <i>foo</i>_SHIFT and
*	<i>foo</i>_SHIFT macros indicating the mask and shift values
*	of the bitfield named <i>foo</i> in a variable.
*	These macros let you prepare, get and set the bitfields.
*/
//\{

//! Prepare a named bit-field for for insterion or combination.
// #define BFN_PREP(x, name)	( ((x)<<name##_SHIFT) & name##_MASK )
template BFN_PREP(string x, string name) {
    const char[] BFN_PREP = "( (("~x~")<<" ~ (name ~ "_SHIFT") ~ ") & " ~ (name ~ "_MASK") ~ ")";
}

//! Get the value of a named bitfield from \a y. Equivalent to (var=) y.name
// #define BFN_GET(y, name)	( ((y) & name##_MASK)>>name##_SHIFT )
template BFN_GET(string y, string name) {
	const char[] BFN_GET = "( (("~y~") & " ~ (name ~ "_MASK") ~ ")>>" ~ (name ~ "_SHIFT") ~ ")";
}

//! Set a named bitfield in \a y to \a x. Equivalent to y.name= x.
// #define BFN_SET(y, x, name)	(y = ((y)&~name##_MASK) | BFN_PREP(x,name) )
template BFN_SET(string y, string x, string name) {
	const char[] BFN_SET = "("~y~" = (("~y~")&~" ~ (name ~ "_MASK") ~ ") | " ~ BFN_PREP!(x,name) ~ ")";
}

//! Compare a named bitfield to named literal \a x.
// #define BFN_CMP(y, x, name)	( ((y)&name##_MASK) == (x) )

//! Massage \a x for use in bitfield \a name with pre-shifted \a x
// #define BFN_PREP2(x, name)	( (x) & name##_MASK )
template BFN_PREP2(string x, string name) {
	const char[] BFN_PREP2 = "( ("~x~") & " ~ (name ~ "_MASK") ~ ")";
}

//! Get the value of bitfield \a name from \a y, but don't down-shift
// #define BFN_GET2(y, name)	( (y) & name##_MASK )
template BFN_GET2(string y, string name) {
	const char[] BFN_GET2 = "( ("~y~") & " ~ (name ~ "_MASK") ~ ")";
}

//! Set bitfield \a name from \a y to \a x with pre-shifted \a x
// #define BFN_SET2(y,x,name)	( y = ((y)&~name##_MASK) | BFN_PREP2(x,name) )
template BFN_SET2(string y, string x, string name) {
	const char[] BFN_SET2 = "("~y~" = (("~y~")&~" ~ (name ~ "_MASK") ~ ") | " ~ BFN_PREP2!(x,name) ~ ")";
}

//\}

uint bf_get (uint y, uint shift, uint len);
uint bf_merge (uint y, uint x, uint shift, uint len);
uint bf_clamp (int x, uint len);

int bit_tribool (uint x, uint plus, uint minus);
uint ROR (uint x, uint ror);

/*!	\}	*/

// --------------------------------------------------------------------
// DATA
// --------------------------------------------------------------------

/*! \defgroup grpData	Data routines
	\ingroup grpCore
*/
/*!	\{	*/

//! Get the number of elements in an array
extern (D) size_t countof(T)(auto ref T _array)
{
    return _array.sizeof / (_array[0]).sizeof;
}

//! Align \a x to the next multiple of \a width.
uint align_ (uint x, uint width);

//! \name Copying and filling routines
//\{

//! Simplified copier for GRIT-exported data.

// Base memcpy/set replacements.
void* tonccpy (void* dst, const(void)* src, uint size);

void* __toncset (void* dst, uint fill, uint size);
void* toncset (void* dst, ubyte src, uint count);
void* toncset16 (void* dst, ushort src, uint count);
void* toncset32 (void* dst, uint src, uint count);

// Fast memcpy/set
void memset16 (void* dst, ushort hw, uint hwcount);
void memcpy16 (void* dst, const(void)* src, uint hwcount);

void memset32 (void* dst, uint wd, uint wcount);
void memcpy32 (void* dst, const(void)* src, uint wcount);

//!	Fastfill for halfwords, analogous to memset()
/*!	Uses <code>memset32()</code> if \a hwcount>5
*	\param dst	Destination address.
*	\param hw	Source halfword (not address).
*	\param hwcount	Number of halfwords to fill.
*	\note	\a dst <b>must</b> be halfword aligned.
*	\note \a r0 returns as \a dst + \a hwcount*2.
*/
void memset16 (void* dst, ushort hw, uint hwcount);

//!	\brief Copy for halfwords.
/*!	Uses <code>memcpy32()</code> if \a hwn>6 and
	  \a src and \a dst are aligned equally.
	\param dst	Destination address.
	\param src	Source address.
	\param hwcount	 Number of halfwords to fill.
	\note \a dst and \a src <b>must</b> be halfword aligned.
	\note \a r0 and \a r1 return as
	  \a dst + \a hwcount*2 and \a src + \a hwcount*2.
*/
void memcpy16 (void* dst, const(void)* src, uint hwcount);

//!	Fast-fill by words, analogous to memset()
/*! Like CpuFastSet(), only without the requirement of
	  32byte chunks and no awkward store-value-in-memory-first issue.
	\param dst	Destination address.
	\param wd	Fill word (not address).
	\param wdcount	Number of words to fill.
	\note	\a dst <b>must</b> be word aligned.
	\note \a r0 returns as \a dst + \a wdcount*4.
*/
void memset32 (void* dst, uint wd, uint wdcount);

//!	\brief Fast-copy by words.
/*! Like CpuFastFill(), only without the requirement of 32byte chunks
	\param dst	Destination address.
	\param src	Source address.
	\param wdcount	Number of words.
	\note	\a src and \a dst <b>must</b> be word aligned.
	\note	\a r0 and \a r1 return as
	  \a dst + \a wdcount*4 and \a src + \a wdcount*4.
*/
void memcpy32 (void* dst, const(void)* src, uint wdcount);

//\}

/*! \name Repeated-value creators
	These function take a hex-value and duplicate it to all fields,
	like 0x88 -> 0x88888888.
*/
//\{
ushort dup8 (ubyte x);
uint dup16 (ushort x);
uint quad8 (ubyte x);
uint octup (ubyte x);
//\}

//!	\name Packing routines.
//\{
ushort bytes2hword (ubyte b0, ubyte b1);
uint bytes2word (ubyte b0, ubyte b1, ubyte b2, ubyte b3);
uint hword2word (ushort h0, ushort h1);
//\}

/*!	\}	*/

// --------------------------------------------------------------------
// DMA
// --------------------------------------------------------------------

/*!	\addtogroup grpDma	*/
/*!	\{	*/

//! General purpose DMA transfer macro
/*!	\param _dst	Destination address.
	\param _src	Source address.
	\param count	Number of transfers.
	\param ch	DMA channel.
	\param mode	DMA mode.
*/

void dma_cpy (void* dst, const(void)* src, uint count, uint ch, uint mode);
void dma_fill (void* dst, uint src, uint count, uint ch, uint mode);

void dma3_cpy (void* dst, const(void)* src, uint size);
void dma3_fill (void* dst, uint src, uint size);

/*! \}	*/

// --------------------------------------------------------------------
// TIMER
// --------------------------------------------------------------------

void profile_start ();
uint profile_stop ();

// --------------------------------------------------------------------
// TONE GENERATOR
// --------------------------------------------------------------------

enum eSndNoteId
{
    NOTE_C = 0,
    NOTE_CIS = 1,
    NOTE_D = 2,
    NOTE_DIS = 3,
    NOTE_E = 4,
    NOTE_F = 5,
    NOTE_FIS = 6,
    NOTE_G = 7,
    NOTE_GIS = 8,
    NOTE_A = 9,
    NOTE_BES = 10,
    NOTE_B = 11
}

extern __gshared const(uint)[12] __snd_rates;

//! Gives the period of a note for the tone-gen registers.
/*! GBA sound range: 8 octaves: [-2, 5]; 8*12= 96 notes (kinda).
*	\param note	ID (range: [0,11>). See eSndNoteId.
*	\param oct	octave (range [-2,4)>).
*/
extern (D) auto SND_RATE(T0, T1)(auto ref T0 note, auto ref T1 oct)
{
    return 2048 - (__snd_rates[note] >> (4 + oct));
}

// --------------------------------------------------------------------
// MISC
// --------------------------------------------------------------------

/*! \defgroup grpCoreMisc	Miscellaneous routines
*	\ingroup grpCore
*/
/*!	\{	*/

extern (D) string STR(T)(auto ref T x)
{
    import std.conv : to;

    return to!string(x);
}

//! Create text string from a literal
alias XSTR = STR;

//! \name Inline assembly
//\{

//! Assembly comment

//! No$gba breakpoint

//! No-op; wait a bit.

//\}

//! \name Sector checking
//\{

uint octant (int x, int y);
uint octant_rot (int x0, int y0);

//\}

//! \name Random numbers
//\{

enum QRAN_SHIFT = 15;
enum QRAN_MASK = (1 << QRAN_SHIFT) - 1;
enum QRAN_MAX = QRAN_MASK;

int sqran (int seed);
int qran ();
int qran_range (int min, int max);

//\}

/*!	\}	*/

// --------------------------------------------------------------------
// GLOBALS
// --------------------------------------------------------------------

extern __gshared const(ubyte)[2][4][3] oam_sizes;
extern __gshared const BG_AFFINE bg_aff_default;
extern __gshared COLOR* vid_page;

extern __gshared int __qran_seed;

// --------------------------------------------------------------------
// INLINES
// --------------------------------------------------------------------

// --- Bit and bitfields -----------------------------------------------

//! Get \a len long bitfield from \a y, starting at \a shift.
/*!	\param y	Value containing bitfield.
	\param shift	Bitfield Start;
	\param len	Length of bitfield.
	\return Bitfield between bits \a shift and \a shift + \a length.
*/
uint bf_get (uint y, uint shift, uint len);

//! Merge \a x into an \a len long bitfield from \a y, starting at \a shift.
/*!	\param y	Value containing bitfield.
	\param x	Value to merge (will be masked to fit).
	\param shift	Bitfield Start;
	\param len	Length of bitfield.
	\return	Result of merger: (y&~M) | (x<<s & M)
	\note	Does \e not write the result back into \a y (Because pure C
		does't have references, that's why)
*/
uint bf_merge (uint y, uint x, uint shift, uint len);

//! Clamp \a to within the range allowed by \a len bits
uint bf_clamp (int x, uint len);

//! Gives a tribool (-1, 0, or +1) depending on the state of some bits.
/*! Looks at the \a plus and \a minus bits of \a flags, and subtracts
	  their status to give a +1, -1 or 0 result. Useful for direction flags.
	\param flags	Value with bit-flags.
	\param plus		Bit number for positive result.
	\param minus	Bit number for negative result.
	\return	<b>+1</b> if \a plus bit is set but \a minus bit isn't<br>
	  <b>-1</b> if \a minus bit is set and \a plus bit isn't<br>
	  <b>0</b> if neither or both are set.
*/
int bit_tribool (uint flags, uint plus, uint minus)
{	return ((flags>>plus)&1) - ((flags>>minus)&1);	}

//! Rotate bits right. Yes, this does lead to a ror instruction.
uint ROR (uint x, uint ror);

// --- Data -----------------------------------------------------------

uint align_ (uint x, uint width);

//! VRAM-safe memset, byte  version. Size in bytes.
void* toncset (void* dst, ubyte src, uint count);

//! VRAM-safe memset, halfword version. Size in hwords.
void* toncset16 (void* dst, ushort src, uint count);

//! VRAM-safe memset, word version. Size in words.
void* toncset32 (void* dst, uint src, uint count);

//! Duplicate a byte to form a halfword: 0x12 -> 0x1212.
ushort dup8 (ubyte x);

//! Duplicate a halfword to form a word: 0x1234 -> 0x12341234.
uint dup16 (ushort x);

//! Quadruple a byte to form a word: 0x12 -> 0x12121212.
uint quad8 (ubyte x);

//! Octuple a nybble to form a word: 0x1 -> 0x11111111
uint octup (ubyte x);

//! Pack 2 bytes into a word. Little-endian order.
ushort bytes2hword (ubyte b0, ubyte b1);

//! Pack 4 bytes into a word. Little-endian order.
uint bytes2word (ubyte b0, ubyte b1, ubyte b2, ubyte b3);

uint hword2word (ushort h0, ushort h1);

// --- DMA ------------------------------------------------------------

/*!	\addtogroup grpDma	*/
/*!	\{	*/

// //! Generic DMA copy routine.
// /*!	\param dst	Destination address.
// *	\param src	Source address.
// *	\param count	Number of copies to perform.
// *	\param ch	DMA channel.
// *	\param mode	DMA transfer mode.
// *	\note	\a count is the number of copies, not the size in bytes.
// */
// void dma_cpy (void* dst, const(void)* src, uint count, uint ch, uint mode)
// {
// 	REG_DMA[ch].cnt= 0;
// 	REG_DMA[ch].src= src;
// 	REG_DMA[ch].dst= dst;
// 	REG_DMA[ch].cnt= mode | count;
// }

// //! Generic DMA fill routine.
// /*!	\param dst	Destination address.
// *	\param src	Source value.
// *	\param count	Number of copies to perform.
// *	\param ch	DMA channel.
// *	\param mode	DMA transfer mode.
// *	\note	\a count is the number of copies, not the size in bytes.
// */
// void dma_fill (void* dst, uint src, uint count, uint ch, uint mode)
// {
// 	REG_DMA[ch].cnt= 0;
// 	REG_DMA[ch].src= cast(const(void*))&src;
// 	REG_DMA[ch].dst= dst;
// 	REG_DMA[ch].cnt= count | mode | DMA_SRC_FIXED;
// }

//! Specific DMA copier, using channel 3, word transfers.
/*!	\param dst	Destination address.
*	\param src	Source address.
*	\param size	Number of bytes to copy
*	\note	\a size is the number of bytes
*/
void dma3_cpy (void* dst, const(void)* src, uint size)
// {	dma_cpy(dst, src, size/4, 3, DMA_CPY32);	}
{
	*REG_DMA3CNT = 0;
	*REG_DMA3SAD = cast(vu32) src;
	*REG_DMA3DAD = cast(vu32) dst;
	*REG_DMA3CNT = (size/4) | DMA_CPY32 | DMA_SRC_FIXED;
}

//! Specific DMA filler, using channel 3, word transfers.
/*!	\param dst	Destination address.
*	\param src	Source value.
*	\param size	Number of bytes to copy
*	\note	\a size is the number of bytes
*/
void dma3_fill (void* dst, uint src, uint size)
{	dma_fill(dst, src, size/4, 3, DMA_FILL32);	}

/*! \}	*/

// --- Random ---------------------------------------------------------

//! Quick (and very dirty) pseudo-random number generator 
/*! \return random in range [0,8000h>
*/
int qran ()
{	
	__qran_seed= 1664525*__qran_seed+1013904223;
	return (__qran_seed>>16) & QRAN_MAX;
}

//! Ranged random number
/*! \return random in range [\a min, \a max>
*	\note (max-min) must be lower than 8000h
*/
int qran_range (int min, int max)
{	return (qran()*(max-min)>>QRAN_SHIFT)+min;		}

// --- Timer ----------------------------------------------------------

/*!	\addtogroup grpTimer	*/
/*!	\{	*/

//! Start a profiling run
/*!	\note Routine uses timers 3 and 3; if you're already using these
*	  somewhere, chaos is going to ensue.
*/
void profile_start ();

//! Stop a profiling run and return the time since its start.
/*!	\return 32bit cycle count
*/
uint profile_stop ();

/*!	\}	/addtogroup	*/

// TONC_CORE

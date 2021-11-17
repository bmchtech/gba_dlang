//
//  BIOS call functions
//
//! \file tonc_bios.h
//! \author J Vijn
//! \date 20060508 - 20070208
//
// === NOTES ===
//
// Pretty much copied verbatim from Pern and dkARM's libgba
// (which in turn is copied from CowBite Spec (which got its info from 
//  GBATek))
// 
//
// === NOTES ===
// * Make SURE your data is aligned to 32bit boundaries. Defining data
//   as u32 (and I do mean define; not merely cast) ensures this. Either 
//   that or use __attribute__(( aligned(4) ))
// * There is a large (70 cycle in and out) overhead for SWIs. If you 
//   know what they do, consider creating replacement code
// * div by 0 locks up GBA. 
// * Cpu(Fast)Set's count is in chunks, not bytes. CpuFastSet REQUIRES
//   n*32 byte data
// * SoftReset is funky with interrupts on.
// * VBlankIntrWait is your friend. If you have a VBlank isr that clears 
//   REG_IFBIOS as well. Use this instead of REG_VCOUNT polling for
//   VSync.
// * I haven't tested many of these functions. The ones that are have a 
//   plus (+) behind their numbers.
// * I've switched to the standard BIOS names. 

module tonc.tonc_bios;

import tonc.tonc_types;

extern (C):

/*!
	\addtogroup


 grpBios
	\brief	Interfaces and constants for the GBA BIOS routines.

	For details, see
	<a href="http://www.coranac.com/tonc/text/keys.htm">tonc:keys</a>
	and especially
	<a href="http://nocash.emubase.de/gbatek.htm#biosfunctions">gbatek:bios</a>.

	\note	While the speeds of the routines are fair, there
	is a large overhead in calling the functions.
*/

/*!	\defgroup grpBiosDef	BIOS informalities
	\ingroup grpBios
*/
/*!	\{	*/

// --------------------------------------------------------------------
// CONSTANTS
// --------------------------------------------------------------------

//! \name SoftReset flags
//\{
enum ROM_RESTART = 0x00; //!< Restart from ROM entry point.
enum RAM_RESTART = 0x01; //!< Restart from RAM entry point.
//\}

//! \name RegisterRamReset flags
//\{
enum RESET_EWRAM = 0x0001; //!< Clear 256K on-board WRAM
enum RESET_IWRAM = 0x0002; //!< Clear 32K in-chip WRAM
enum RESET_PALETTE = 0x0004; //!< Clear Palette
enum RESET_VRAM = 0x0008; //!< Clear VRAM
enum RESET_OAM = 0x0010; //!< Clear OAM. does NOT disable OBJs!
enum RESET_REG_SIO = 0x0020; //!< Switches to general purpose mode
enum RESET_REG_SOUND = 0x0040; //!< Reset Sound registers
enum RESET_REG = 0x0080; //!< All other registers

//#define RESET_REG_VIDEO	0x0100	//!< video regs, 00h-60h (non standard!)
//#define RESET_REG_DMA	0x0200	//!< DMA regs, B0h-100h (non standard!)
//#define	RESET_REG_TIMER	0x0400	//!< Timer regs (100h-110h) (non standard!)

enum RESET_MEM_MASK = 0x001F;
enum RESET_REG_MASK = 0x00E0;

enum RESET_GFX = 0x001C; //!< Clear all gfx-related memory

//\}

//! \name Cpu(Fast)Set flags
//\{
enum CS_CPY = 0; //!< Copy mode
enum CS_FILL = 1 << 24; //!< Fill mode
enum CS_CPY16 = 0; //!< Copy in halfwords
enum CS_CPY32 = 1 << 26; //!< Copy words
enum CS_FILL32 = 5 << 24; //!< Fill words

enum CFS_CPY = CS_CPY; //!< Copy words
enum CFS_FILL = CS_FILL; //!< Fill words
//\}

//! \name ObjAffineSet P-element offsets
//\{
enum BG_AFF_OFS = 2; //!< BgAffineDest offsets
enum OBJ_AFF_OFS = 8; //!< ObjAffineDest offsets
//\}

//! \name Decompression routines
enum BUP_ALL_OFS = 1 << 31;

enum LZ_TYPE = 0x00000010;
enum LZ_SIZE_MASK = 0xFFFFFF00;
enum LZ_SIZE_SHIFT = 8;

enum HUF_BPP_MASK = 0x0000000F;
enum HUF_TYPE = 0x00000020;
enum HUF_SIZE_MASK = 0xFFFFFF00;
enum HUF_SIZE_SHIFT = 8;

enum RL_TYPE = 0x00000030;
enum RL_SIZE_MASK = 0xFFFFFF00;
enum RL_SIZE_SHIFT = 8;

enum DIF_8 = 0x00000001;
enum DIF_16 = 0x00000002;
enum DIF_TYPE = 0x00000080;
enum DIF_SIZE_MASK = 0xFFFFFF00;
enum DIF_SIZE_SHIFT = 8;
//\}

//! \name Multiboot modes
//\{
enum MBOOT_NORMAL = 0x00;
enum MBOOT_MULTI = 0x01;
enum MBOOT_FAST = 0x02;
//\}

// --------------------------------------------------------------------
// MACROS
// --------------------------------------------------------------------

//! BIOS calls from C
/*!	You can use this macro in a C BIOS-call wrapper. The wrapper
*	  should declare the flags, then this call will do the rest.
*	\param x	Number of swi call (THUMB number)
*	\note	It checks the __thumb__ \#define to see whether we're
*	  in ARM or THUMB mode and fixes the swi number accordingly.
*	  Huzzah for the C proprocessor!
*	\deprecated	This macro will not work properly for functions that have IO.
*/

// --------------------------------------------------------------------
// CLASSES
// --------------------------------------------------------------------

// --- affine function 0x0E and 0x0F ---

/*
*  Notational convention: postfix underscore is 2d vector
*
*	p_ = (px, py)		= texture coordinates
*	q_ = (qx, qy)		= screen coordinates
*	P  = | pa pb |		= affine matrix
*	     | pc pd |
*	d_ = (dx, dy)		= background displacement
*
*  Then:
*
* (1)	p_ = P*q_ + d_
*
*  For transformation around a different point
*  (texture point p0_ and screen point q0_), do
*
* (2)	p_ - p0_ = P*(q_-q0_)
*
*  Subtracting eq 2 from eq1 we immediately find:
*
* (3)	_d = p0_ - P*q0_
*
*  For the special case of a texture->screen scale-then-rotate
*  transformation with
*	s_ = (sx, sy)	= inverse scales (s>1 shrinks)
*	a = alpha		= Counter ClockWise (CCW) angle
*
* (4)	P  = | sx*cos(a) -sx*sin(a) |
*            | sy*sin(a)  sy*cos(a) |
*
*
*  ObjAffineSet takes a and s_ as input and gives P
*  BgAffineSet does that and fills in d_ as well
*
*/

// affine types in tonc_types.h

//! BitUpPack ( for swi 10h)
struct BUP
{
    ushort src_len; //!< source length (bytes)	
    ubyte src_bpp; //!< source bitdepth (1,2,4,8)
    ubyte dst_bpp; //!< destination bitdepth (1,2,4,8,16,32)
    uint dst_ofs; //!< {0-30}: added offset {31}: zero-data offset flag
}

//! Multiboot struct
struct MultiBootParam
{
    uint[5] reserved1;
    ubyte handshake_data;
    ubyte padding;
    ushort handshake_timeout;
    ubyte probe_count;
    ubyte[3] client_data;
    ubyte palette_data;
    ubyte response_bit;
    ubyte client_bit;
    ubyte reserved2;
    ubyte* boot_srcp;
    ubyte* boot_endp;
    ubyte* masterp;
    ubyte*[3] reserved3;
    uint[4] system_work2;
    ubyte sendflag;
    ubyte probe_target_bit;
    ubyte check_wait;
    ubyte server_type;
}

/*!	\}	*/

// --------------------------------------------------------------------
// BASIC BIOS ROUTINES
// --------------------------------------------------------------------

/*!	\defgroup grpBiosMain	BIOS functions
*	\ingroup grpBios
*/
/*! \{	*/

//! \name Reset functions
//\{
void SoftReset ();
void RegisterRamReset (uint flags);
//\}

//! \name Halt functions
//\{
void Halt ();
void Stop ();
void IntrWait (uint flagClear, uint irq);
void VBlankIntrWait ();
//\}

//! \name Math functions
//\{
int Div (int num, int den);
int DivArm (int den, int num);
uint Sqrt (uint num);
short ArcTan (short dydx);
short ArcTan2 (short x, short y);
//\}

//! \name Memory copiers/fillers
//\{
// Technically, these are misnomers. The convention is that 
// xxxset is used for fills (comp memset, strset). Or perhaps
// the C library functions are misnomers, since set can be applied 
// to both copies and fills. 
void CpuSet (const(void)* src, void* dst, uint mode);
void CpuFastSet (const(void)* src, void* dst, uint mode);
//\}

uint BiosCheckSum ();

//! \name Rot/scale functions
//\{
// These functions are misnomers, because ObjAffineSet is merely
// a special case of/precursor to BgAffineSet. Results from either
// can be used for both objs and bgs. Oh well.
void ObjAffineSet (const(ObjAffineSource)* src, void* dst, int num, int offset);
void BgAffineSet (const(BgAffineSource)* src, BgAffineDest* dst, int num);
//\}

//! \name Decompression (see GBATek for format details) 
//\{
void BitUnPack (const(void)* src, void* dst, const(BUP)* bup);
void LZ77UnCompWram (const(void)* src, void* dst);
void LZ77UnCompVram (const(void)* src, void* dst);
void HuffUnComp (const(void)* src, void* dst);
void RLUnCompWram (const(void)* src, void* dst);
void RLUnCompVram (const(void)* src, void* dst);
void Diff8bitUnFilterWram (const(void)* src, void* dst);
void Diff8bitUnFilterVram (const(void)* src, void* dst);
void Diff16bitUnFilter (const(void)* src, void* dst);
//\}

//! \name Sound Functions
//\{
// (I have even less of a clue what these do than for the others ---
void SoundBias (uint bias);
void SoundDriverInit (void* src);
void SoundDriverMode (uint mode);
void SoundDriverMain ();
void SoundDriverVSync ();
void SoundChannelClear ();
uint MidiKey2Freq (void* wa, ubyte mk, ubyte fp);
void SoundDriverVSyncOff ();
void SoundDriverVSyncOn ();
//\}

//! \name Multiboot handshake
//\{
int MultiBoot (MultiBootParam* mb, uint mode);
//\}

/*!	\}	*/

/*!	\defgroup grpBiosEx	More BIOS functions
*	\ingroup grpBios
*/
/*! \{	*/

//\{

// You can find these in swi_ex.s
void VBlankIntrDelay (uint count);
int DivSafe (int num, int den);
int Mod (int num, int den);
uint DivAbs (int num, int den);
int DivArmMod (int den, int num);
uint DivArmAbs (int den, int num);
void CpuFastFill (uint wd, void* dst, uint count);

alias DivMod = Mod;
//\}

/*!	\}	*/

// === ONCE MORE, WITH DOXYGEN! =======================================

// --- Reset ---

void SoftReset (); // swi 00h
void RegisterRamReset (uint flags); // swi 01h

// --- Halt ---

void Halt (); // swi 02h
void Stop (); // swi 03h
void IntrWait (uint flagClear, uint irq); // swi 04h

//! Wait for the next VBlank (swi 05h).
/*! \note Requires clearing of REG_IFBIOS bit 0 at the interrupt
*	  tonc's master interrupt handler does this for you.
*/
void VBlankIntrWait ();

// --- Arithmetic ---

//! Basic integer division (swi 06h).
/*! \param num	Numerator.
*	\param den	Denominator.
*	\return \a num / \a den
*	\note	div/0 results in an infinite loop. Try \c DivSafe instead
*/
int Div (int num, int den);

//! Basic integer division, but with switched arguments (swi 07h).
/*! \param num	Numerator.
*	\param den	Denominator.
*	\return \a num / \a den
*	\note	div/0 results in an infinite loop.
*/
int DivArm (int den, int num);

//! Integer Square root (swi 08h).
uint Sqrt (uint num);

//! Arctangent of \a dydx (swi 08h)
/*! \param dydx	Slope to get the arctangent of.
*	\return	Arctangent of \a dydx in the range &lt;-4000h, 4000h&gt;,
*	  corresponding to
*	  \htmlonly &lt;-&frac12;&pi;, &frac12;&pi;&gt; \endhtmlonly.
*	\note Said to be inaccurate near the range's limits.
*/
short ArcTan (short dydx);

//! Arctangent of a coordinate pair (swi 09h).
/*! This is the full-circle arctan, with an angle range of [0,FFFFh].
*/
short ArcTan2 (short x, short y);

// --- Memory fills ---
// Technically, these are misnomers. The convention is that 
// xxxset is used for fills (comp memset, strset). Or perhaps
// the C library functions are misnomers, since set can be applied 
// to both copies and fills.

//! Transfer via CPU in (half)word chunks.
/*!	The default mode is 16bit copies. With bit 24 set, it copies
*	  words; with bit 26 set it will keep the source address constant,
*	  effectively performing fills instead of copies.
*	\param src	Source address.
*	\param dst	Destination address.
*	\param mode	Number of transfers, and mode bits.
*	\note	This basically does a straightforward loop-copy, and is
*	  not particularly fast.
*	\note	In fill-mode (bit 26), the source is \e still an address,
*	  not a value.
*/
void CpuSet (const(void)* src, void* dst, uint mode);

//! A fast transfer via CPU in 32 byte chunks.
/*!	This uses ARM's ldmia/stmia instructions to copy 8 words at a time,
*	  making it rival DMA transfers in speed. With bit 26 set it will
*	  keep the source address constant, effectively performing fills
*	  instead of copies.
*	\param src	Source address.
*	\param dst	Destination address.
*	\param mode	Number of words to transfer, and mode bits.
*	\note	Both source and destination must be word aligned; the
*		number of copies must be a multiple of 8.
*	\note	In fill-mode (bit 26), the source is \e still an address,
*	  not a value.
*	\note	memcpy32/16 and memset32/16 basically do the same things, but
*	  safer. Use those instead.
*/
void CpuFastSet (const(void)* src, void* dst, uint mode);

uint BiosCheckSum ();

// --- Rot/scale (0Eh (+) & 0Fh (+) ) ---
// These functions are misnomers, because ObjAffineSet is merely
// a special case of / precursor to BgAffineSet. Results from either
// can be used for both objs and bgs. Oh well.

//! Sets up a simple scale-then-rotate affine transformation (swi 0Eh).
/*!	Uses a single \a ObjAffineSource struct to set up an array of affine
*	matrices (either BG or Object) with a certain transformation. The
*	matrix created is
\htmlonly
<table border=0 cellpadding=4 cellspacing=0>
<tr>
  <td> s<sub>x</sub>&middot;cos(&alpha;)</td>
  <td>-s<sub>x</sub>&middot;sin(&alpha;)</td>
</tr>
<tr>
  <td> s<sub>y</sub>&middot;sin(&alpha;)</td>
  <td> s<sub>y</sub>&middot;cos(&alpha;)</td>
</tr>
</table>
\endhtmlonly
*
*	\param src	Array with scale and angle information.
*	\param dst	Array of affine matrices, starting at a \a pa element.
*	\param num	Number of matrices to set.
*	\param offset	Offset between affine elements. Use 2 for BG and
*	  8 for object matrices.
*	\note	Each element in \a src needs to be word aligned, which
*	  devkitPro doesn't do anymore by itself.
*/
void ObjAffineSet (const(ObjAffineSource)* src, void* dst, int num, int offset);
void BgAffineSet (const(BgAffineSource)* src, BgAffineDest* dst, int num);

// --- Decompression (see GBATek for format details) --- 
void BitUnPack (const(void)* src, void* dst, const(BUP)* bup); // swi 10h +
void LZ77UnCompWram (const(void)* src, void* dst); // swi 11h +
void LZ77UnCompVram (const(void)* src, void* dst); // swi 12h +
void HuffUnComp (const(void)* src, void* dst); // swi 13h +
void RLUnCompWram (const(void)* src, void* dst); // swi 14h
void RLUnCompVram (const(void)* src, void* dst); // swi 15h +
void Diff8bitUnFilterWram (const(void)* src, void* dst); // swi 16h
void Diff8bitUnFilterVram (const(void)* src, void* dst); // swi 17h
void Diff16bitUnFilter (const(void)* src, void* dst); // swi 18h

// --- Sound (I have even less of a clue what these do than for the others ---
void SoundBias (uint bias); // swi 19h
void SoundDriverInit (void* src); // swi 1Ah
void SoundDriverMode (uint mode); // swi 1Bh
void SoundDriverMain (); // swi 1Ch
void SoundDriverVSync (); // swi 1Dh
void SoundChannelClear (); // swi 1Eh
uint MidiKey2Freq (void* wa, ubyte mk, ubyte fp); // swi 1Fh
void SoundDriverVSyncOff (); // swi 28h
void SoundDriverVSyncOn (); // swi 29h

// --- Multiboot handshake ---
int MultiBoot (MultiBootParam* mb, uint mode); // swi 25h

// --------------------------------------------------------------------
// EXTRA BIOS ROUTINES
// --------------------------------------------------------------------

//! Wait for \a count frames
void VBlankIntrDelay (uint count);

//! Div/0-safe division
/*! The standard Div hangs if \a den = 0. This version will return
*	INT_MAX/MIN in that case, depending on the sign of \a num,
*	or just \a num / \a den if \a den is not 0.
*	\param num	Numerator.
*	\param den	Denominator.
*/
int DivSafe (int num, int den);

//! Modulo: \a num % \a den.
int Mod (int num, int den);

//! Absolute value of \a num / \a den
uint DivAbs (int num, int den);

//! Modulo: \a num % \a den.
int DivArmMod (int den, int num);

//! Absolute value of \a num / \a den
uint DivArmAbs (int den, int num);

//! A fast word fill
/*! While you can perform fills with CpuFastSet(), the fact that
*	  swi 12 requires a source address makes it awkward to use.
*	  This function is more like the traditional memset formulation.
*	\param wd	Fill word.
*	\param dst	Destination address.
*	\param mode	Number of words to transfer
*/
void CpuFastFill (uint wd, void* dst, uint mode);

// TONC_BIOS

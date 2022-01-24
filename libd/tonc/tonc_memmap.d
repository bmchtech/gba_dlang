//
//  GBA Memory map 
//
//! \file tonc_memmap.h
//! \author J Vijn
//! \date 20060508 - 20060508
//
// 
// === NOTES ===
//
// * The REG_BGxy registers for affine backgrounds
//   should be _signed_ (vs16 / vs32), not unsigned (vu16 / vu32)
// * I have removed several REG_x_L, REG_x_H pairs because all they 
//   do is clutter up the file
// * C++ doesn't seem to like struct copies if the type specifiers 
//   don't match (e.g., volatile, non-volatile). Most registers 
//   don't really need the volatile specifier anyway, so if this 
//   presents a problem consider removing it.
// * I'm using defines for the memory map here, but GCC cannot optimize 
//   these properly and they will often appear inside a loop, potentially
//   slowing it down to up 50% or so, depending on how much you do 
//   in the loop. Possible remedy: use a set of global pointers for the 
//   memory map instead of defines. It'll only be 4 or so pointers, so 
//   it should be ok. (PONDER: system with void pointers?)
module tonc.tonc_memmap;

import rt.mmio;
import tonc.tonc_types;

@system:
extern (C):

/*!	\defgroup grpReg	IO Registers	*/
/*!	\defgroup grpRegAlt	IO Alternates	*/

// === MEMORY SECTIONS ================================================

/*! \addtogroup grpMemmap
	\brief Basic memory map
*/
/*!	\{	*/

//! \name Main sections
//\{
enum MEM_EWRAM = 0x02000000; //!< External work RAM
enum MEM_IWRAM = 0x03000000; //!< Internal work RAM
enum MEM_IO = 0x04000000; //!< I/O registers
enum MEM_PAL = 0x05000000; //!< Palette. Note: no 8bit write !!
enum MEM_VRAM = 0x06000000; //!< Video RAM. Note: no 8bit write !!
enum MEM_OAM = 0x07000000; //!< Object Attribute Memory (OAM) Note: no 8bit write !!
enum MEM_ROM = 0x08000000; //!< ROM. No write at all (duh)
enum MEM_SRAM = 0x0E000000; //!< Static RAM. 8bit write only
//\}

//! \name Main section sizes
//\{
enum EWRAM_SIZE = 0x40000;
enum IWRAM_SIZE = 0x08000;
enum PAL_SIZE = 0x00400;
enum VRAM_SIZE = 0x18000;
enum OAM_SIZE = 0x00400;
enum SRAM_SIZE = 0x10000;
//\}

//! \name Sub section sizes
//\{
enum PAL_BG_SIZE = 0x00200; //!< BG palette size
enum PAL_OBJ_SIZE = 0x00200; //!< Object palette size
enum CBB_SIZE = 0x04000; //!< Charblock size
enum SBB_SIZE = 0x00800; //!< Screenblock size
enum VRAM_BG_SIZE = 0x10000; //!< BG VRAM size
enum VRAM_OBJ_SIZE = 0x08000; //!< Object VRAM size
enum M3_SIZE = 0x12C00; //!< Mode 3 buffer size
enum M4_SIZE = 0x09600; //!< Mode 4 buffer size
enum M5_SIZE = 0x0A000; //!< Mode 5 buffer size
enum VRAM_PAGE_SIZE = 0x0A000; //!< Bitmap page size
//\}

//! \name Sub sections
//\{
enum REG_BASE = MEM_IO;

enum MEM_PAL_BG = MEM_PAL; //!< Background palette address
enum MEM_PAL_OBJ = MEM_PAL + PAL_BG_SIZE; //!< Object palette address
enum MEM_VRAM_FRONT = MEM_VRAM; //!< Front page address
enum MEM_VRAM_BACK = MEM_VRAM + VRAM_PAGE_SIZE; //!< Back page address
enum MEM_VRAM_OBJ = MEM_VRAM + VRAM_BG_SIZE; //!< Object VRAM address
//\}

/*!	\}	*/

// --------------------------------------------------------------------
//  STRUCTURED MEMORY MAP 
// --------------------------------------------------------------------

/*! \defgroup grpMemArray Memory mapped arrays
	\ingroup grpMemmap
	\brief	These are some macros for easier access of various
	  memory sections. They're all arrays or matrices, using the
	  types that would be the most natural for that concept.
*/
/*	\{	*/

//! \name Palette
//\{

//! Background palette.
/*! pal_bg_mem[i]	= color i					( COLOR )
*/
enum pal_bg_mem = cast(COLOR*) MEM_PAL;

//! Object palette. 
/*! pal_obj_mem[i]	= color i					( COLOR )
*/
enum pal_obj_mem = cast(COLOR*) MEM_PAL_OBJ;

//! Background palette matrix. 
/*! pal_bg_bank[y]		= bank y				( COLOR[ ] )<br>
	pal_bg_bank[y][x]	= color color y*16+x	( COLOR )
*/
enum pal_bg_bank = cast(PALBANK*) MEM_PAL;

//! Object palette matrix. 
/*!	pal_obj_bank[y]		= bank y				( COLOR[ ] )<br>
	pal_obj_bank[y][x]	= color y*16+x			( COLOR )
*/
enum pal_obj_bank = cast(PALBANK*) MEM_PAL_OBJ;

//\}	// End Palette

//! \name VRAM
//\{

//!	Charblocks, 4bpp tiles.
/*!	tile_mem[y]		= charblock y				( TILE[ ] )<br>
	tile_mem[y][x]	= block y, tile x			( TILE )
*/
enum tile_mem = cast(CHARBLOCK*) MEM_VRAM;

//!	Charblocks, 8bpp tiles.
/*!	tile_mem[y]		= charblock y				( TILE[ ] )<br>
	tile_mem[y][x]	= block y, tile x			( TILE )
*/
enum tile8_mem = cast(CHARBLOCK8*) MEM_VRAM;

//!	Object charblocks, 4bpp tiles.
/*!	tile_mem[y]		= charblock y				( TILE[ ] )<br>
	tile_mem[y][x]	= block y, tile x			( TILE )
*/
enum tile_mem_obj = cast(CHARBLOCK*) MEM_VRAM_OBJ;

//!	Object charblocks, 4bpp tiles.
/*!	tile_mem[y]		= charblock y				( TILE[ ] )<br>
	tile_mem[y][x]	= block y, tile x			( TILE )
*/
enum tile8_mem_obj = cast(CHARBLOCK8*) MEM_VRAM_OBJ;

//! Screenblocks as arrays
/*!	se_mem[y]		= screenblock y				( SCR_ENTRY[ ] )<br>
*	se_mem[y][x]	= screenblock y, entry x	( SCR_ENTRY )
*/
enum se_mem = cast(SCREENBLOCK*) MEM_VRAM;

//! Screenblock as matrices
/*!	se_mat[s]		= screenblock s					( SCR_ENTRY[ ][ ] )<br>
	se_mat[s][y][x]	= screenblock s, entry (x,y)	( SCR_ENTRY )
*/
enum se_mat = cast(SCREENMAT*) MEM_VRAM;

//! Main mode 3/5 frame as an array
/*!	vid_mem[i]		= pixel i						( COLOR )
*/
enum vid_mem = cast(COLOR*) MEM_VRAM;

//! Mode 3 frame as a matrix
/*!	m3_mem[y][x]	= pixel (x, y)					( COLOR )
*/
enum m3_mem = cast(M3LINE*) MEM_VRAM;

//! Mode 4 first page as a matrix
/*!	m4_mem[y][x]	= pixel (x, y)					( u8 )
*	\note	This is a byte-buffer. Not to be used for writing.
*/
enum m4_mem = cast(M4LINE*) MEM_VRAM;

//! Mode 5 first page as a matrix
/*!	m5_mem[y][x]	= pixel (x, y)					( COLOR )
*/
enum m5_mem = cast(M5LINE*) MEM_VRAM;

//! First page array
enum vid_mem_front = cast(COLOR*) MEM_VRAM;

//! Second page array
enum vid_mem_back = cast(COLOR*) MEM_VRAM_BACK;

//! Mode 4 second page as a matrix
/*!	m4_mem[y][x]	= pixel (x, y)					( u8 )
*	\note	This is a byte-buffer. Not to be used for writing.
*/
enum m4_mem_back = cast(M4LINE*) MEM_VRAM_BACK;

//! Mode 5 second page as a matrix
/*!	m5_mem[y][x]	= pixel (x, y)					( COLOR )
*/
enum m5_mem_back = cast(M5LINE*) MEM_VRAM_BACK;

//\}	// End VRAM

//! \name OAM
//\{

//! Object attribute memory
/*!	oam_mem[i]		= object i						( OBJ_ATTR )
*/
enum oam_mem = cast(OBJ_ATTR*) MEM_OAM;
enum obj_mem = cast(OBJ_ATTR*) MEM_OAM;

//! Object affine memory
/*!	obj_aff_mem[i]		= object matrix i			( OBJ_AFFINE )
*/
enum obj_aff_mem = cast(OBJ_AFFINE*) MEM_OAM;

//\}		// End OAM

//!	\name ROM
//\{

//! ROM pointer
enum rom_mem = cast(ushort*) MEM_ROM;

//\}

//!	\name SRAM
//\{

//! SRAM pointer
enum sram_mem = cast(ubyte*) MEM_SRAM;

//\}

/*!	\}	*/

// --------------------------------------------------------------------
// REGISTER LIST
// --------------------------------------------------------------------

/*!	\addtogroup grpReg
	\ingroup grpMemmap
*/
/*!	\{	*/

//! \name IWRAM 'registers'
//\{

// 0300:7ff[y] is mirrored at 03ff:fff[y], which is why this works out:
// enum REG_IFBIOS = *(cast(vu16*) REG_BASE - 0x0008); //!< IRQ ack for IntrWait functions

enum REG_RESET_DST = cast(vu16*)(REG_BASE - 0x0006); //!< Destination for after SoftReset

// enum REG_ISR_MAIN = *(cast(fnptr*) REG_BASE - 0x0004); //!< IRQ handler address
fnptr* REG_ISR_MAIN() {
	return cast(fnptr*)(REG_BASE - 0x0004);
}
//\}

//! \name Display registers
//\{
enum REG_DISPCNT = cast(vu16*)(REG_BASE + 0x0000); //!< Display control
enum REG_DISPSTAT = cast(vu16*)(REG_BASE + 0x0004); //!< Display status

enum REG_VCOUNT = cast(vu16*)(REG_BASE + 0x0006); //!< Scanline count

//\}

//! \name Background control registers
//\{
enum REG_BGCNT = cast(vu16*)(REG_BASE + 0x0008); //!< Bg control array

enum REG_BG0CNT = cast(vu16*)(REG_BASE + 0x0008); //!< Bg0 control

enum REG_BG1CNT = cast(vu16*)(REG_BASE + 0x000A); //!< Bg1 control

enum REG_BG2CNT = cast(vu16*)(REG_BASE + 0x000C); //!< Bg2 control

enum REG_BG3CNT = cast(vu16*)(REG_BASE + 0x000E); //!< Bg3 control

//\}

//! \name Regular background scroll registers. (write only!)
//\{
// enum REG_BG_OFS = cast(BG_POINT*) REG_BASE + 0x0010; //!< Bg scroll array
BG_POINT* REG_BG_OFS() {
	return (cast(BG_POINT*) REG_BASE + 0x0010);
}

enum REG_BG0HOFS = cast(vu16*)(REG_BASE + 0x0010); //!< Bg0 horizontal scroll

enum REG_BG0VOFS = cast(vu16*)(REG_BASE + 0x0012); //!< Bg0 vertical scroll

enum REG_BG1HOFS = cast(vu16*)(REG_BASE + 0x0014); //!< Bg1 horizontal scroll

enum REG_BG1VOFS = cast(vu16*)(REG_BASE + 0x0016); //!< Bg1 vertical scroll

enum REG_BG2HOFS = cast(vu16*)(REG_BASE + 0x0018); //!< Bg2 horizontal scroll

enum REG_BG2VOFS = cast(vu16*)(REG_BASE + 0x001A); //!< Bg2 vertical scroll

enum REG_BG3HOFS = cast(vu16*)(REG_BASE + 0x001C); //!< Bg3 horizontal scroll

enum REG_BG3VOFS = cast(vu16*)(REG_BASE + 0x001E); //!< Bg3 vertical scroll

//\}

//! \name Affine background parameters. (write only!)
//\{
// enum REG_BG_AFFINE = cast(BG_AFFINE*) REG_BASE + 0x0000; //!< Bg affine array
ref BG_AFFINE REG_BG_AFFINE() {
	return *cast(BG_AFFINE*)(REG_BASE + 0x0000);
}

enum REG_BG2PA = cast(vs16*)(REG_BASE + 0x0020); //!< Bg2 matrix.pa

enum REG_BG2PB = cast(vs16*)(REG_BASE + 0x0022); //!< Bg2 matrix.pb

enum REG_BG2PC = cast(vs16*)(REG_BASE + 0x0024); //!< Bg2 matrix.pc

enum REG_BG2PD = cast(vs16*)(REG_BASE + 0x0026); //!< Bg2 matrix.pd

enum REG_BG2X = cast(vs32*)(REG_BASE + 0x0028); //!< Bg2 x scroll

enum REG_BG2Y = cast(vs32*)(REG_BASE + 0x002C); //!< Bg2 y scroll

enum REG_BG3PA = cast(vs16*)(REG_BASE + 0x0030); //!< Bg3 matrix.pa.

enum REG_BG3PB = cast(vs16*)(REG_BASE + 0x0032); //!< Bg3 matrix.pb

enum REG_BG3PC = cast(vs16*)(REG_BASE + 0x0034); //!< Bg3 matrix.pc

enum REG_BG3PD = cast(vs16*)(REG_BASE + 0x0036); //!< Bg3 matrix.pd

enum REG_BG3X = cast(vs32*)(REG_BASE + 0x0038); //!< Bg3 x scroll

enum REG_BG3Y = cast(vs32*)(REG_BASE + 0x003C); //!< Bg3 y scroll

//\}

//! \name Windowing registers
//\{
enum REG_WIN0H = cast(vu16*)(REG_BASE + 0x0040); //!< win0 right, left (0xLLRR)

enum REG_WIN1H = cast(vu16*)(REG_BASE + 0x0042); //!< win1 right, left (0xLLRR)

enum REG_WIN0V = cast(vu16*)(REG_BASE + 0x0044); //!< win0 bottom, top (0xTTBB)

enum REG_WIN1V = cast(vu16*)(REG_BASE + 0x0046); //!< win1 bottom, top (0xTTBB)

enum REG_WININ = cast(vu16*)(REG_BASE + 0x0048); //!< win0, win1 control

enum REG_WINOUT = cast(vu16*)(REG_BASE + 0x004A); //!< winOut, winObj control

//\}

//! \name Alternate Windowing registers
//\{
enum REG_WIN0R = cast(vu8*)(REG_BASE + 0x0040); //!< Win 0 right

enum REG_WIN0L = cast(vu8*)(REG_BASE + 0x0041); //!< Win 0 left

enum REG_WIN1R = cast(vu8*)(REG_BASE + 0x0042); //!< Win 1 right

enum REG_WIN1L = cast(vu8*)(REG_BASE + 0x0043); //!< Win 1 left

enum REG_WIN0B = cast(vu8*)(REG_BASE + 0x0044); //!< Win 0 bottom

enum REG_WIN0T = cast(vu8*)(REG_BASE + 0x0045); //!< Win 0 top

enum REG_WIN1B = cast(vu8*)(REG_BASE + 0x0046); //!< Win 1 bottom

enum REG_WIN1T = cast(vu8*)(REG_BASE + 0x0047); //!< Win 1 top

enum REG_WIN0CNT = cast(vu8*)(REG_BASE + 0x0048); //!< window 0 control

enum REG_WIN1CNT = cast(vu8*)(REG_BASE + 0x0049); //!< window 1 control

enum REG_WINOUTCNT = cast(vu8*)(REG_BASE + 0x004A); //!< Out window control

enum REG_WINOBJCNT = cast(vu8*)(REG_BASE + 0x004B); //!< Obj window control

//\}

//! \name Graphic effects
//\{
enum REG_MOSAIC = cast(vu32*)(REG_BASE + 0x004C); //!< Mosaic control

enum REG_BLDCNT = cast(vu16*)(REG_BASE + 0x0050); //!< Alpha control

enum REG_BLDALPHA = cast(vu16*)(REG_BASE + 0x0052); //!< Fade level

enum REG_BLDY = cast(vu16*)(REG_BASE + 0x0054); //!< Blend levels

//\}

// === SOUND REGISTERS ===
// sound regs, partially following pin8gba's nomenclature

//! \name Channel 1: Square wave with sweep
//\{
enum REG_SND1SWEEP = cast(vu16*)(REG_BASE + 0x0060); //!< Channel 1 Sweep

enum REG_SND1CNT = cast(vu16*)(REG_BASE + 0x0062); //!< Channel 1 Control

enum REG_SND1FREQ = cast(vu16*)(REG_BASE + 0x0064); //!< Channel 1 frequency

//\}

//! \name Channel 2: Simple square wave
//\{
enum REG_SND2CNT = cast(vu16*)(REG_BASE + 0x0068); //!< Channel 2 control

enum REG_SND2FREQ = cast(vu16*)(REG_BASE + 0x006C); //!< Channel 2 frequency

//\}

//! \name Channel 3: Wave player
//\{
enum REG_SND3SEL = cast(vu16*)(REG_BASE + 0x0070); //!< Channel 3 wave select

enum REG_SND3CNT = cast(vu16*)(REG_BASE + 0x0072); //!< Channel 3 control

enum REG_SND3FREQ = cast(vu16*)(REG_BASE + 0x0074); //!< Channel 3 frequency

//\}

//! \name Channel 4: Noise generator
//\{
enum REG_SND4CNT = cast(vu16*)(REG_BASE + 0x0078); //!< Channel 4 control

enum REG_SND4FREQ = cast(vu16*)(REG_BASE + 0x007C); //!< Channel 4 frequency

//\}

//! \name Sound control
//\{
enum REG_SNDCNT = cast(vu32*)(REG_BASE + 0x0080); //!< Main sound control

enum REG_SNDDMGCNT = cast(vu16*)(REG_BASE + 0x0080); //!< DMG channel control

enum REG_SNDDSCNT = cast(vu16*)(REG_BASE + 0x0082); //!< Direct Sound control

enum REG_SNDSTAT = cast(vu16*)(REG_BASE + 0x0084); //!< Sound status

enum REG_SNDBIAS = cast(vu16*)(REG_BASE + 0x0088); //!< Sound bias

//\}

//! \name Sound buffers
//\{
enum REG_WAVE_RAM = cast(vu32*)(REG_BASE + 0x0090); //!< Channel 3 wave buffer

enum REG_WAVE_RAM0 = cast(vu32*)(REG_BASE + 0x0090);

enum REG_WAVE_RAM1 = cast(vu32*)(REG_BASE + 0x0094);

enum REG_WAVE_RAM2 = cast(vu32*)(REG_BASE + 0x0098);

enum REG_WAVE_RAM3 = cast(vu32*)(REG_BASE + 0x009C);

enum REG_FIFO_A = cast(vu32*)(REG_BASE + 0x00A0); //!< DSound A FIFO

enum REG_FIFO_B = cast(vu32*)(REG_BASE + 0x00A4); //!< DSound B FIFO

//\}

//! \name DMA registers
//\{
enum REG_DMA = cast(DMA_REC*)(REG_BASE + 0x00B0); //!< DMA as DMA_REC array

enum REG_DMA0SAD = cast(vu32*)(REG_BASE + 0x00B0); //!< DMA 0 Source address

enum REG_DMA0DAD = cast(vu32*)(REG_BASE + 0x00B4); //!< DMA 0 Destination address

enum REG_DMA0CNT = cast(vu32*)(REG_BASE + 0x00B8); //!< DMA 0 Control

enum REG_DMA1SAD = cast(vu32*)(REG_BASE + 0x00BC); //!< DMA 1 Source address

enum REG_DMA1DAD = cast(vu32*)(REG_BASE + 0x00C0); //!< DMA 1 Destination address

enum REG_DMA1CNT = cast(vu32*)(REG_BASE + 0x00C4); //!< DMA 1 Control

enum REG_DMA2SAD = cast(vu32*)(REG_BASE + 0x00C8); //!< DMA 2 Source address

enum REG_DMA2DAD = cast(vu32*)(REG_BASE + 0x00CC); //!< DMA 2 Destination address

enum REG_DMA2CNT = cast(vu32*)(REG_BASE + 0x00D0); //!< DMA 2 Control

enum REG_DMA3SAD = cast(vu32*)(REG_BASE + 0x00D4); //!< DMA 3 Source address

enum REG_DMA3DAD = cast(vu32*)(REG_BASE + 0x00D8); //!< DMA 3 Destination address

enum REG_DMA3CNT = cast(vu32*)(REG_BASE + 0x00DC); //!< DMA 3 Control

//\}

//! \name Timer registers
//\{
// enum REG_TM = cast(TMR_REC*) REG_BASE + 0x0100; //!< Timers as TMR_REC array
TMR_REC* REG_TM() {
	return cast(TMR_REC*) REG_BASE + 0x0100;
}

enum REG_TM0D = cast(vu16*)(REG_BASE + 0x0100); //!< Timer 0 data

enum REG_TM0CNT = cast(vu16*)(REG_BASE + 0x0102); //!< Timer 0 control

enum REG_TM1D = cast(vu16*)(REG_BASE + 0x0104); //!< Timer 1 data

enum REG_TM1CNT = cast(vu16*)(REG_BASE + 0x0106); //!< Timer 1 control

enum REG_TM2D = cast(vu16*)(REG_BASE + 0x0108); //!< Timer 2 data

enum REG_TM2CNT = cast(vu16*)(REG_BASE + 0x010A); //!< Timer 2 control

enum REG_TM3D = cast(vu16*)(REG_BASE + 0x010C); //!< Timer 3 data

enum REG_TM3CNT = cast(vu16*)(REG_BASE + 0x010E); //!< Timer 3 control

//\}

//! \name Serial communication
//{
enum REG_SIOCNT = cast(vu16*)(REG_BASE + 0x0128); //!< Serial IO control (Normal/MP/UART)

enum REG_SIODATA = cast(vu32*)(REG_BASE + 0x0120);

enum REG_SIODATA32 = cast(vu32*)(REG_BASE + 0x0120); //!< Normal/UART 32bit data

enum REG_SIODATA8 = cast(vu16*)(REG_BASE + 0x012A); //!< Normal/UART 8bit data

enum REG_SIOMULTI = cast(vu16*)(REG_BASE + 0x0120); //!< Multiplayer data array

enum REG_SIOMULTI0 = cast(vu16*)(REG_BASE + 0x0120); //!< MP master data

enum REG_SIOMULTI1 = cast(vu16*)(REG_BASE + 0x0122); //!< MP Slave 1 data

enum REG_SIOMULTI2 = cast(vu16*)(REG_BASE + 0x0124); //!< MP Slave 2 data 

enum REG_SIOMULTI3 = cast(vu16*)(REG_BASE + 0x0126); //!< MP Slave 3 data

enum REG_SIOMLT_RECV = cast(vu16*)(REG_BASE + 0x0120); //!< MP data receiver

enum REG_SIOMLT_SEND = cast(vu16*)(REG_BASE + 0x012A); //!< MP data sender

//\}

//! \name Keypad registers
//\{
enum REG_KEYINPUT = cast(vu16*)(REG_BASE + 0x0130); //!< Key status (read only??)

enum REG_KEYCNT = cast(vu16*)(REG_BASE + 0x0132); //!< Key IRQ control

//\}

//! \name Joybus communication
//\{
enum REG_RCNT = cast(vu16*)(REG_BASE + 0x0134); //!< SIO Mode Select/General Purpose Data

enum REG_JOYCNT = cast(vu16*)(REG_BASE + 0x0140); //!< JOY bus control

enum REG_JOY_RECV = cast(vu32*)(REG_BASE + 0x0150); //!< JOY bus receiever

enum REG_JOY_TRS = cast(vu32*)(REG_BASE + 0x0154); //!< JOY bus transmitter

enum REG_JOYSTAT = cast(vu16*)(REG_BASE + 0x0158); //!< JOY bus status

//\}

//! \name Interrupt / System registers
//\{
enum REG_IE = cast(vu16*)(REG_BASE + 0x0200); //!< IRQ enable

enum REG_IF = cast(vu16*)(REG_BASE + 0x0202); //!< IRQ status/acknowledge

enum REG_WAITCNT = cast(vu16*)(REG_BASE + 0x0204); //!< Waitstate control

enum REG_IME = cast(vu16*)(REG_BASE + 0x0208); //!< IRQ master enable

enum REG_PAUSE = cast(vu16*)(REG_BASE + 0x0300); //!< Pause system (?)

//\}

/*!	\}	*/

// --------------------------------------------------------------------
// ALT REGISTERS
// --------------------------------------------------------------------

/*!	\addtogroup grpRegAlt
	\ingroup grpMemmap
	\brief	Alternate names for some of the registers
*/
/*!	\{	*/

enum REG_BLDMOD = cast(vu16*)(REG_BASE + 0x0050); // alpha control

enum REG_COLEV = cast(vu16*)(REG_BASE + 0x0052); // fade level

enum REG_COLEY = cast(vu16*)(REG_BASE + 0x0054); // blend levels

// sound regs as in belogic and GBATek (mostly for compatability)
enum REG_SOUND1CNT = cast(vu32*)(REG_BASE + 0x0060);

enum REG_SOUND1CNT_L = cast(vu16*)(REG_BASE + 0x0060);

enum REG_SOUND1CNT_H = cast(vu16*)(REG_BASE + 0x0062);

enum REG_SOUND1CNT_X = cast(vu16*)(REG_BASE + 0x0064);

enum REG_SOUND2CNT_L = cast(vu16*)(REG_BASE + 0x0068);

enum REG_SOUND2CNT_H = cast(vu16*)(REG_BASE + 0x006C);

enum REG_SOUND3CNT = cast(vu32*)(REG_BASE + 0x0070);

enum REG_SOUND3CNT_L = cast(vu16*)(REG_BASE + 0x0070);

enum REG_SOUND3CNT_H = cast(vu16*)(REG_BASE + 0x0072);

enum REG_SOUND3CNT_X = cast(vu16*)(REG_BASE + 0x0074);

enum REG_SOUND4CNT_L = cast(vu16*)(REG_BASE + 0x0078);

enum REG_SOUND4CNT_H = cast(vu16*)(REG_BASE + 0x007C);

enum REG_SOUNDCNT = cast(vu32*)(REG_BASE + 0x0080);

enum REG_SOUNDCNT_L = cast(vu16*)(REG_BASE + 0x0080);

enum REG_SOUNDCNT_H = cast(vu16*)(REG_BASE + 0x0082);

enum REG_SOUNDCNT_X = cast(vu16*)(REG_BASE + 0x0084);

enum REG_SOUNDBIAS = cast(vu16*)(REG_BASE + 0x0088);

enum REG_WAVE = cast(vu32*)(REG_BASE + 0x0090);

enum REG_FIFOA = cast(vu32*)(REG_BASE + 0x00A0);

enum REG_FIFOB = cast(vu32*)(REG_BASE + 0x00A4);

enum REG_DMA0CNT_L = cast(vu16*)(REG_BASE + 0x00B8); // count

enum REG_DMA0CNT_H = cast(vu16*)(REG_BASE + 0x00BA); // flags

enum REG_DMA1CNT_L = cast(vu16*)(REG_BASE + 0x00C4);

enum REG_DMA1CNT_H = cast(vu16*)(REG_BASE + 0x00C6);

enum REG_DMA2CNT_L = cast(vu16*)(REG_BASE + 0x00D0);

enum REG_DMA2CNT_H = cast(vu16*)(REG_BASE + 0x00D2);

enum REG_DMA3CNT_L = cast(vu16*)(REG_BASE + 0x00DC);

enum REG_DMA3CNT_H = cast(vu16*)(REG_BASE + 0x00DE);

enum REG_TM0CNT_L = cast(vu16*)(REG_BASE + 0x0100);

enum REG_TM0CNT_H = cast(vu16*)(REG_BASE + 0x0102);

enum REG_TM1CNT_L = cast(vu16*)(REG_BASE + 0x0104);

enum REG_TM1CNT_H = cast(vu16*)(REG_BASE + 0x0106);

enum REG_TM2CNT_L = cast(vu16*)(REG_BASE + 0x0108);

enum REG_TM2CNT_H = cast(vu16*)(REG_BASE + 0x010a);

enum REG_TM3CNT_L = cast(vu16*)(REG_BASE + 0x010c);

enum REG_TM3CNT_H = cast(vu16*)(REG_BASE + 0x010e);

enum REG_KEYS = cast(vu16*)(REG_BASE + 0x0130); // Key status

enum REG_P1 = cast(vu16*)(REG_BASE + 0x0130); // for backward combatibility

enum REG_P1CNT = cast(vu16*)(REG_BASE + 0x0132); // ditto

enum REG_SCD0 = cast(vu16*)(REG_BASE + 0x0120);

enum REG_SCD1 = cast(vu16*)(REG_BASE + 0x0122);

enum REG_SCD2 = cast(vu16*)(REG_BASE + 0x0124);

enum REG_SCD3 = cast(vu16*)(REG_BASE + 0x0126);

enum REG_SCCNT = cast(vu32*)(REG_BASE + 0x0128);

enum REG_SCCNT_L = cast(vu16*)(REG_BASE + 0x0128);

enum REG_SCCNT_H = cast(vu16*)(REG_BASE + 0x012A);

enum REG_R = cast(vu16*)(REG_BASE + 0x0134);

enum REG_HS_CTRL = cast(vu16*)(REG_BASE + 0x0140);

enum REG_JOYRE = cast(vu32*)(REG_BASE + 0x0150);

enum REG_JOYRE_L = cast(vu16*)(REG_BASE + 0x0150);

enum REG_JOYRE_H = cast(vu16*)(REG_BASE + 0x0152);

enum REG_JOYTR = cast(vu32*)(REG_BASE + 0x0154);

enum REG_JOYTR_L = cast(vu16*)(REG_BASE + 0x0154);

enum REG_JOYTR_H = cast(vu16*)(REG_BASE + 0x0156);

enum REG_JSTAT = cast(vu16*)(REG_BASE + 0x0158);

enum REG_WSCNT = cast(vu16*)(REG_BASE + 0x0204);

// /*!	\}	*/

// // TONC_MEMMAP

// // EOF

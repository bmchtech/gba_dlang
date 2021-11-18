//
//  Memory map defines. All of them
//
//! \file tonc_memdef.h
//! \author J Vijn
//! \date 20060508 - 20080521
//
/* === NOTES ===
  * 20080521 : comms items taken from libgba
*/

module tonc.tonc_memdef;

import tonc.tonc_types;

extern (C):

/*! \defgroup grpMemBits	Memory map bit(fields)
	\ingroup grpMemmap
	\brief List of all bit(field) definitions of memory mapped items.
*/

// --- Prefixes ---
// REG_DISPCNT		: DCNT
// REG_DISPSTAT		: DSTAT
// REG_BGxCNT		: BG
// REG_WIN_x		: WIN
// REG_MOSAIC		: MOS
// REG_BLDCNT		: BLD
// REG_SND1SWEEP	: SSW
// REG_SNDxCNT,		: SSQR
// REG_SNDxFREQ,	: SFREQ
// REG_SNDDMGCNT	: SDMG
// REG_SNDDSCNT		: SDS
// REG_SNDSTAT		: SSTAT
// REG_DMAxCNT		: DMA
// REG_TMxCNT		: TM
// REG_SIOCNT		: SIO(N/M/U)
// REG_RCNT			: R / GPIO
// REG_KEYINPUT		: KEY
// REG_KEYCNT		: KCNT
// REG_IE, REG_IF	: IRQ
// REG_WSCNT		: WS
// Regular SE		: SE
// OAM attr 0		: ATTR0
// OAM attr 1		: ATTR1
// OAM attr 2		: ATTR2

// --- REG_DISPCNT -----------------------------------------------------

/*!	\defgroup grpVideoDCNT	Display Control Flags
	\ingroup grpMemBits
	\brief	Bits for REG_DISPCNT
*/
/*!	\{	*/

enum DCNT_MODE0 = 0; //!< Mode 0; bg 0-4: reg
enum DCNT_MODE1 = 0x0001; //!< Mode 1; bg 0-1: reg; bg 2: affine
enum DCNT_MODE2 = 0x0002; //!< Mode 2; bg 2-3: affine
enum DCNT_MODE3 = 0x0003; //!< Mode 3; bg2: 240x160\@16 bitmap
enum DCNT_MODE4 = 0x0004; //!< Mode 4; bg2: 240x160\@8 bitmap
enum DCNT_MODE5 = 0x0005; //!< Mode 5; bg2: 160x128\@16 bitmap
enum DCNT_GB = 0x0008; //!< (R) GBC indicator
enum DCNT_PAGE = 0x0010; //!< Page indicator
enum DCNT_OAM_HBL = 0x0020; //!< Allow OAM updates in HBlank
enum DCNT_OBJ_2D = 0; //!< OBJ-VRAM as matrix
enum DCNT_OBJ_1D = 0x0040; //!< OBJ-VRAM as array
enum DCNT_BLANK = 0x0080; //!< Force screen blank
enum DCNT_BG0 = 0x0100; //!< Enable bg 0
enum DCNT_BG1 = 0x0200; //!< Enable bg 1
enum DCNT_BG2 = 0x0400; //!< Enable bg 2
enum DCNT_BG3 = 0x0800; //!< Enable bg 3
enum DCNT_OBJ = 0x1000; //!< Enable objects
enum DCNT_WIN0 = 0x2000; //!< Enable window 0
enum DCNT_WIN1 = 0x4000; //!< Enable window 1
enum DCNT_WINOBJ = 0x8000; //!< Enable object window

enum DCNT_MODE_MASK = 0x0007;
enum DCNT_MODE_SHIFT = 0;

extern (D) auto DCNT_MODE(T)(auto ref T n)
{
    return n << DCNT_MODE_SHIFT;
}

enum DCNT_LAYER_MASK = 0x1F00;
enum DCNT_LAYER_SHIFT = 8;

extern (D) auto DCNT_LAYER(T)(auto ref T n)
{
    return n << DCNT_LAYER_SHIFT;
}

enum DCNT_WIN_MASK = 0xE000;
enum DCNT_WIN_SHIFT = 13;

extern (D) auto DCNT_WIN(T)(auto ref T n)
{
    return n << DCNT_WIN_SHIFT;
}

/*!	\}	/defgroup	*/

// --- REG_DISPSTAT ----------------------------------------------------

/*!	\defgroup grpVideoDSTAT	Display Status Flags
	\ingroup grpMemBits
	\brief	Bits for REG_DISPSTAT
*/
/*!	\{	*/

enum DSTAT_IN_VBL = 0x0001; //!< Now in VBlank
enum DSTAT_IN_HBL = 0x0002; //!< Now in HBlank
enum DSTAT_IN_VCT = 0x0004; //!< Now in set VCount
enum DSTAT_VBL_IRQ = 0x0008; //!< Enable VBlank irq
enum DSTAT_HBL_IRQ = 0x0010; //!< Enable HBlank irq
enum DSTAT_VCT_IRQ = 0x0020; //!< Enable VCount irq

enum DSTAT_VCT_MASK = 0xFF00;
enum DSTAT_VCT_SHIFT = 8;

extern (D) auto DSTAT_VCT(T)(auto ref T n)
{
    return n << DSTAT_VCT_SHIFT;
}

/*!	\}	/defgroup	*/

// --- REG_BGxCNT ------------------------------------------------------

/*!	\defgroup grpVideoBGCNT	Background Control Flags
	\ingroup grpMemBits
	\brief	Bits for REG_BGxCNT
*/
/*!	\{	*/

enum BG_MOSAIC = 0x0040; //!< Enable Mosaic
enum BG_4BPP = 0; //!< 4bpp (16 color) bg (no effect on affine bg)
enum BG_8BPP = 0x0080; //!< 8bpp (256 color) bg (no effect on affine bg)
enum BG_WRAP = 0x2000; //!< Wrap around edges of affine bgs
enum BG_SIZE0 = 0;
enum BG_SIZE1 = 0x4000;
enum BG_SIZE2 = 0x8000;
enum BG_SIZE3 = 0xC000;
enum BG_REG_32x32 = 0; //!< reg bg, 32x32 (256x256 px)
enum BG_REG_64x32 = 0x4000; //!< reg bg, 64x32 (512x256 px)
enum BG_REG_32x64 = 0x8000; //!< reg bg, 32x64 (256x512 px)
enum BG_REG_64x64 = 0xC000; //!< reg bg, 64x64 (512x512 px)
enum BG_AFF_16x16 = 0; //!< affine bg, 16x16 (128x128 px)
enum BG_AFF_32x32 = 0x4000; //!< affine bg, 32x32 (256x256 px)
enum BG_AFF_64x64 = 0x8000; //!< affine bg, 64x64 (512x512 px)
enum BG_AFF_128x128 = 0xC000; //!< affine bg, 128x128 (1024x1024 px)

enum BG_PRIO_MASK = 0x0003;
enum BG_PRIO_SHIFT = 0;

extern (D) auto BG_PRIO(T)(auto ref T n)
{
    return n << BG_PRIO_SHIFT;
}

enum BG_CBB_MASK = 0x000C;
enum BG_CBB_SHIFT = 2;

extern (D) auto BG_CBB(T)(auto ref T n)
{
    return cast(T) n << BG_CBB_SHIFT;
}

enum BG_SBB_MASK = 0x1F00;
enum BG_SBB_SHIFT = 8;

extern (D) auto BG_SBB(T)(auto ref T n)
{
    return cast(T) n << BG_SBB_SHIFT;
}

enum BG_SIZE_MASK = 0xC000;
enum BG_SIZE_SHIFT = 14;

extern (D) auto BG_SIZE(T)(auto ref T n)
{
    return n << BG_SIZE_SHIFT;
}

/*!	\}	*/

/*! \defgroup grpVideoGfx Graphic effects
	\ingroup grpMemBits
*/
/*!	\{	*/

// --- REG_WIN_x ------------------------------------------------------

//! \name Window macros
//\{

enum WIN_BG0 = 0x0001; //!< Windowed bg 0
enum WIN_BG1 = 0x0002; //!< Windowed bg 1
enum WIN_BG2 = 0x0004; //!< Windowed bg 2
enum WIN_BG3 = 0x0008; //!< Windowed bg 3
enum WIN_OBJ = 0x0010; //!< Windowed objects
enum WIN_ALL = 0x001F; //!< All layers in window.
enum WIN_BLD = 0x0020; //!< Windowed blending

enum WIN_LAYER_MASK = 0x003F;
enum WIN_LAYER_SHIFT = 0;

extern (D) auto WIN_LAYER(T)(auto ref T n)
{
    return n << WIN_LAYER_SHIFT;
}

extern (D) auto WIN_BUILD(T0, T1)(auto ref T0 low, auto ref T1 high)
{
    return (high << 8) | low;
}

alias WININ_BUILD = WIN_BUILD;

alias WINOUT_BUILD = WIN_BUILD;

//\}

// --- REG_MOSAIC ------------------------------------------------------

//! \name Mosaic macros
//\{

enum MOS_BH_MASK = 0x000F;
enum MOS_BH_SHIFT = 0;

extern (D) auto MOS_BH(T)(auto ref T n)
{
    return n << MOS_BH_SHIFT;
}

enum MOS_BV_MASK = 0x00F0;
enum MOS_BV_SHIFT = 4;

extern (D) auto MOS_BV(T)(auto ref T n)
{
    return n << MOS_BV_SHIFT;
}

enum MOS_OH_MASK = 0x0F00;
enum MOS_OH_SHIFT = 8;

extern (D) auto MOS_OH(T)(auto ref T n)
{
    return n << MOS_OH_SHIFT;
}

enum MOS_OV_MASK = 0xF000;
enum MOS_OV_SHIFT = 12;

extern (D) auto MOS_OV(T)(auto ref T n)
{
    return n << MOS_OV_SHIFT;
}

extern (D) auto MOS_BUILD(T0, T1, T2, T3)(auto ref T0 bh, auto ref T1 bv, auto ref T2 oh, auto ref T3 ov)
{
    return ((ov & 15) << 12) | ((oh & 15) << 8) | ((bv & 15) << 4) | (bh & 15);
}

//\}

/*	\}	*/

// --- REG_BLDCNT ------------------------------------------------------

/*!	\defgroup grpVideoBLD	Blend Flags
	\ingroup grpMemBits
	\brief	Macros for REG_BLDCNT, REG_BLDY and REG_BLDALPHA
*/
/*!	\{	*/

//!\ name Blend control
//\{

enum BLD_BG0 = 0x0001; //!< Blend bg 0
enum BLD_BG1 = 0x0002; //!< Blend bg 1
enum BLD_BG2 = 0x0004; //!< Blend bg 2
enum BLD_BG3 = 0x0008; //!< Blend bg 3
enum BLD_OBJ = 0x0010; //!< Blend objects
enum BLD_ALL = 0x001F; //!< All layers (except backdrop)
enum BLD_BACKDROP = 0x0020; //!< Blend backdrop
enum BLD_OFF = 0; //!< Blend mode is off
enum BLD_STD = 0x0040; //!< Normal alpha blend (with REG_EV)
enum BLD_WHITE = 0x0080; //!< Fade to white (with REG_Y)
enum BLD_BLACK = 0x00C0; //!< Fade to black (with REG_Y)

enum BLD_TOP_MASK = 0x003F;
enum BLD_TOP_SHIFT = 0;

extern (D) auto BLD_TOP(T)(auto ref T n)
{
    return n << BLD_TOP_SHIFT;
}

enum BLD_MODE_MASK = 0x00C0;
enum BLD_MODE_SHIFT = 6;

extern (D) auto BLD_MODE(T)(auto ref T n)
{
    return n << BLD_MODE_SHIFT;
}

enum BLD_BOT_MASK = 0x3F00;
enum BLD_BOT_SHIFT = 8;

extern (D) auto BLD_BOT(T)(auto ref T n)
{
    return n << BLD_BOT_SHIFT;
}

extern (D) u16 BLD_BUILD(T0, T1, T2)(auto ref T0 top, auto ref T1 bot, auto ref T2 mode)
{
    return cast(u16) ((bot & 63) << 8) | ((mode & 3) << 6) | (top & 63);
}

//\}

// --- REG_BLDALPHA ---

//! \name Blend weights

enum BLD_EVA_MASK = 0x001F;
enum BLD_EVA_SHIFT = 0;

extern (D) auto BLD_EVA(T)(auto ref T n)
{
    return n << BLD_EVA_SHIFT;
}

enum BLD_EVB_MASK = 0x1F00;
enum BLD_EVB_SHIFT = 8;

extern (D) auto BLD_EVB(T)(auto ref T n)
{
    return n << BLD_EVB_SHIFT;
}

extern (D) u16 BLDA_BUILD(T0, T1)(auto ref T0 eva, auto ref T1 evb)
{
    return cast(u16) ((eva & 31) | ((evb & 31) << 8));
}

//\}

// --- REG_BLDY ---

//! \name Fade levels

enum BLDY_MASK = 0x001F;
enum BLDY_SHIFT = 0;

extern (D) auto BLDY(T)(auto ref T n)
{
    return n << BLD_EY_SHIFT;
}

extern (D) u16 BLDY_BUILD(u16 ey)
{
    return ey & 31;
}

//\}

/*!	\}	*/

// --- REG_SND1SWEEP ---------------------------------------------------

/*!	\defgroup grpAudioSSW	Tone Generator, Sweep Flags
	\ingroup grpMemBits
	\brief	Bits for REG_SND1SWEEP (aka REG_SOUND1CNT_L)
*/
/*!	\{	*/

enum SSW_INC = 0; //!< Increasing sweep rate
enum SSW_DEC = 0x0008; //!< Decreasing sweep rate
enum SSW_OFF = 0x0008; //!< Disable sweep altogether

enum SSW_SHIFT_MASK = 0x0007;
enum SSW_SHIFT_SHIFT = 0;

extern (D) auto SSW_SHIFT(T)(auto ref T n)
{
    return n << SSW_SHIFT_SHIFT;
}

enum SSW_TIME_MASK = 0x0070;
enum SSW_TIME_SHIFT = 4;

extern (D) auto SSW_TIME(T)(auto ref T n)
{
    return n << SSW_TIME_SHIFT;
}

extern (D) auto SSW_BUILD(T0, T1, T2)(auto ref T0 shift, auto ref T1 dir, auto ref T2 time)
{
    return ((time & 7) << 4) | (dir << 3) | (shift & 7);
}

/*!	\}	/defgroup	*/

// --- REG_SND1CNT, REG_SND2CNT, REG_SND4CNT ---------------------------

/*!	\defgroup grpAudioSSQR	Tone Generator, Square Flags
	\ingroup grpMemBits
	\brief	Bits for REG_SND{1,2,4}CNT
	(aka REG_SOUND1CNT_H, REG_SOUND2CNT_L, REG_SOUND4CNT_L, respectively)
*/
/*!	\{	*/

enum SSQR_DUTY1_8 = 0; //!< 12.5% duty cycle (#-------)
enum SSQR_DUTY1_4 = 0x0040; //!< 25% duty cycle (##------)
enum SSQR_DUTY1_2 = 0x0080; //!< 50% duty cycle (####----)
enum SSQR_DUTY3_4 = 0x00C0; //!< 75% duty cycle (######--) Equivalent to 25%
enum SSQR_INC = 0; //!< Increasing volume
enum SSQR_DEC = 0x0800; //!< Decreasing volume

enum SSQR_LEN_MASK = 0x003F;
enum SSQR_LEN_SHIFT = 0;

extern (D) auto SSQR_LEN(T)(auto ref T n)
{
    return n << SSQR_LEN_SHIFT;
}

enum SSQR_DUTY_MASK = 0x00C0;
enum SSQR_DUTY_SHIFT = 6;

extern (D) auto SSQR_DUTY(T)(auto ref T n)
{
    return n << SSQR_DUTY_SHIFT;
}

enum SSQR_TIME_MASK = 0x0700;
enum SSQR_TIME_SHIFT = 8;

extern (D) auto SSQR_TIME(T)(auto ref T n)
{
    return n << SSQR_TIME_SHIFT;
}

enum SSQR_IVOL_MASK = 0xF000;
enum SSQR_IVOL_SHIFT = 12;

extern (D) auto SSQR_IVOL(T)(auto ref T n)
{
    return n << SSQR_IVOL_SHIFT;
}

extern (D) auto SSQR_ENV_BUILD(T0, T1, T2)(auto ref T0 ivol, auto ref T1 dir, auto ref T2 time)
{
    return (ivol << 12) | (dir << 11) | ((time & 7) << 8);
}

extern (D) auto SSQR_BUILD(T0, T1, T2, T3, T4)(auto ref T0 _ivol, auto ref T1 dir, auto ref T2 step, auto ref T3 duty, auto ref T4 len)
{
    return SSQR_ENV_BUILD(ivol, dir, step) | ((duty & 3) << 6) | (len & 63);
}

/*!	\}	/defgroup	*/

// --- REG_SND1FREQ, REG_SND2FREQ, REG_SND3FREQ ------------------------

/*!	\defgroup grpAudioSFREQ	Tone Generator, Frequency Flags
	\ingroup grpMemBits
	\brief	Bits for REG_SND{1-3}FREQ
	(aka REG_SOUND1CNT_X, REG_SOUND2CNT_H, REG_SOUND3CNT_X)
*/
/*!	\{	*/

enum SFREQ_HOLD = 0; //!< Continuous play
enum SFREQ_TIMED = 0x4000; //!< Timed play
enum SFREQ_RESET = 0x8000; //!< Reset sound

enum SFREQ_RATE_MASK = 0x07FF;
enum SFREQ_RATE_SHIFT = 0;

extern (D) auto SFREQ_RATE(T)(auto ref T n)
{
    return n << SFREQ_RATE_SHIFT;
}

extern (D) auto SFREQ_BUILD(T0, T1, T2)(auto ref T0 rate, auto ref T1 timed, auto ref T2 reset)
{
    return (rate & 0x7FF) | (timed << 14) | (reset << 15);
}

/*!	\}	/defgroup	*/

// --- REG_SNDDMGCNT ---------------------------------------------------

/*!	\defgroup grpAudioSDMG	Tone Generator, Control Flags
	\ingroup grpMemBits
	\brief	Bits for REG_SNDDMGCNT (aka REG_SOUNDCNT_L)
*/
/*!	\{	*/

enum SDMG_LSQR1 = 0x0100; //!< Enable channel 1 on left 
enum SDMG_LSQR2 = 0x0200; //!< Enable channel 2 on left
enum SDMG_LWAVE = 0x0400; //!< Enable channel 3 on left
enum SDMG_LNOISE = 0x0800; //!< Enable channel 4 on left	
enum SDMG_RSQR1 = 0x1000; //!< Enable channel 1 on right
enum SDMG_RSQR2 = 0x2000; //!< Enable channel 2 on right
enum SDMG_RWAVE = 0x4000; //!< Enable channel 3 on right
enum SDMG_RNOISE = 0x8000; //!< Enable channel 4 on right

enum SDMG_LVOL_MASK = 0x0007;
enum SDMG_LVOL_SHIFT = 0;

extern (D) auto SDMG_LVOL(T)(auto ref T n)
{
    return n << SDMG_LVOL_SHIFT;
}

enum SDMG_RVOL_MASK = 0x0070;
enum SDMG_RVOL_SHIFT = 4;

extern (D) auto SDMG_RVOL(T)(auto ref T n)
{
    return n << SDMG_RVOL_SHIFT;
}

// Unshifted values
enum SDMG_SQR1 = 0x01;
enum SDMG_SQR2 = 0x02;
enum SDMG_WAVE = 0x04;
enum SDMG_NOISE = 0x08;

extern (D) auto SDMG_BUILD(T0, T1, T2, T3)(auto ref T0 _lmode, auto ref T1 _rmode, auto ref T2 _lvol, auto ref T3 _rvol)
{
    return (_rmode << 12) | (_lmode << 8) | ((_rvol & 7) << 4) | (_lvol & 7);
}

extern (D) auto SDMG_BUILD_LR(T0, T1)(auto ref T0 _mode, auto ref T1 _vol)
{
    return SDMG_BUILD(_mode, _mode, _vol, _vol);
}

/*!	\}	/defgroup	*/

// --- REG_SNDDSCNT ----------------------------------------------------

/*!	\defgroup grpAudioSDS	Direct Sound Flags
	\ingroup grpMemBits
	\brief	Bits for REG_SNDDSCNT (aka REG_SOUNDCNT_H)
*/
/*!	\{	*/

enum SDS_DMG25 = 0; //!< Tone generators at 25% volume
enum SDS_DMG50 = 0x0001; //!< Tone generators at 50% volume
enum SDS_DMG100 = 0x0002; //!< Tone generators at 100% volume
enum SDS_A50 = 0; //!< Direct Sound A at 50% volume
enum SDS_A100 = 0x0004; //!< Direct Sound A at 100% volume
enum SDS_B50 = 0; //!< Direct Sound B at 50% volume
enum SDS_B100 = 0x0008; //!< Direct Sound B at 100% volume
enum SDS_AR = 0x0100; //!< Enable Direct Sound A on right
enum SDS_AL = 0x0200; //!< Enable Direct Sound A on left
enum SDS_ATMR0 = 0; //!< Direct Sound A to use timer 0
enum SDS_ATMR1 = 0x0400; //!< Direct Sound A to use timer 1
enum SDS_ARESET = 0x0800; //!< Reset FIFO of Direct Sound A
enum SDS_BR = 0x1000; //!< Enable Direct Sound B on right
enum SDS_BL = 0x2000; //!< Enable Direct Sound B on left
enum SDS_BTMR0 = 0; //!< Direct Sound B to use timer 0
enum SDS_BTMR1 = 0x4000; //!< Direct Sound B to use timer 1
enum SDS_BRESET = 0x8000; //!< Reset FIFO of Direct Sound B

/*!	\}	/defgroup	*/

// --- REG_SNDSTAT -----------------------------------------------------

/*!	\defgroup grpAudioSSTAT	Sound Status Flags
	\ingroup grpMemBits
	\brief	Bits for REG_SNDSTAT (and REG_SOUNDCNT_X)
*/
/*!	\{	*/

enum SSTAT_SQR1 = 0x0001; //!< (R) Channel 1 status
enum SSTAT_SQR2 = 0x0002; //!< (R) Channel 2 status
enum SSTAT_WAVE = 0x0004; //!< (R) Channel 3 status
enum SSTAT_NOISE = 0x0008; //!< (R) Channel 4 status
enum SSTAT_DISABLE = 0; //!< Disable sound
enum SSTAT_ENABLE = 0x0080; //!< Enable sound. NOTE: enable before using any other sound regs

/*!	\}	/defgroup	*/

// --- REG_DMAxCNT -----------------------------------------------------

/*!	\defgroup grpAudioDMA	DMA Control Flags
	\ingroup grpMemBits
	\brief	Bits for REG_DMAxCNT
*/
/*!	\{	*/

enum DMA_DST_INC = 0; //!< Incrementing destination address
enum DMA_DST_DEC = 0x00200000; //!< Decrementing destination
enum DMA_DST_FIXED = 0x00400000; //!< Fixed destination 
enum DMA_DST_RELOAD = 0x00600000; //!< Increment destination, reset after full run
enum DMA_SRC_INC = 0; //!< Incrementing source address
enum DMA_SRC_DEC = 0x00800000; //!< Decrementing source address
enum DMA_SRC_FIXED = 0x01000000; //!< Fixed source address
enum DMA_REPEAT = 0x02000000; //!< Repeat transfer at next start condition 
enum DMA_16 = 0; //!< Transfer by halfword
enum DMA_32 = 0x04000000; //!< Transfer by word
enum DMA_AT_NOW = 0; //!< Start transfer now
enum DMA_GAMEPAK = 0x08000000; //!< Gamepak DRQ
enum DMA_AT_VBLANK = 0x10000000; //!< Start transfer at VBlank
enum DMA_AT_HBLANK = 0x20000000; //!< Start transfer at HBlank
enum DMA_AT_SPECIAL = 0x30000000; //!< Start copy at 'special' condition. Channel dependent
enum DMA_AT_FIFO = 0x30000000; //!< Start at FIFO empty (DMA0/DMA1)
enum DMA_AT_REFRESH = 0x30000000; //!< VRAM special; start at VCount=2 (DMA3)
enum DMA_IRQ = 0x40000000; //!< Enable DMA irq
enum DMA_ENABLE = 0x80000000; //!< Enable DMA

enum DMA_COUNT_MASK = 0x0000FFFF;
enum DMA_COUNT_SHIFT = 0;

extern (D) auto DMA_COUNT(T)(auto ref T n)
{
    return n << DMA_COUNT_SHIFT;
}

// \name Extra 
//\{

enum DMA_NOW = DMA_ENABLE | DMA_AT_NOW;
enum DMA_16NOW = DMA_NOW | DMA_16;
enum DMA_32NOW = DMA_NOW | DMA_32;

// copies
enum DMA_CPY16 = DMA_NOW | DMA_16;
enum DMA_CPY32 = DMA_NOW | DMA_32;

// fills
enum DMA_FILL16 = DMA_NOW | DMA_SRC_FIXED | DMA_16;
enum DMA_FILL32 = DMA_NOW | DMA_SRC_FIXED | DMA_32;

enum DMA_HDMA = DMA_ENABLE | DMA_REPEAT | DMA_AT_HBLANK | DMA_DST_RELOAD;

//\}

/*!	\}	/defgroup	*/

// --- REG_TMxCNT ------------------------------------------------------

/*!	\defgroup grpTimerTM	Timer Control Flags
	\ingroup grpMemBits
	\brief	Bits for REG_TMxCNT
*/
/*!	\{	*/

enum TM_FREQ_SYS = 0; //!< System clock timer (16.7 Mhz)
enum TM_FREQ_1 = 0; //!< 1 cycle/tick (16.7 Mhz)
enum TM_FREQ_64 = 0x0001; //!< 64 cycles/tick (262 kHz)
enum TM_FREQ_256 = 0x0002; //!< 256 cycles/tick (66 kHz)
enum TM_FREQ_1024 = 0x0003; //!< 1024 cycles/tick (16 kHz)
enum TM_CASCADE = 0x0004; //!< Increment when preceding timer overflows
enum TM_IRQ = 0x0040; //!< Enable timer irq
enum TM_ENABLE = 0x0080; //!< Enable timer

enum TM_FREQ_MASK = 0x0003;
enum TM_FREQ_SHIFT = 0;

extern (D) auto TM_FREQ(T)(auto ref T n)
{
    return n << TM_FREQ_SHIFT;
}

/*!	\}	/defgroup	*/

// --- REG_SIOCNT ----------------------------------------------------------

/*!	\defgroup grpSioCnt	Serial I/O Control
	\ingroup grpMemBits
	\brief	Bits for REG_TMxCNT
*/
/*!	\{	*/

//!	\name General SIO bits.
//\{
enum SIO_MODE_8BIT = 0x0000; //!< Normal comm mode, 8-bit.
enum SIO_MODE_32BIT = 0x1000; //!< Normal comm mode, 32-bit.
enum SIO_MODE_MULTI = 0x2000; //!< Multi-play comm mode.
enum SIO_MODE_UART = 0x3000; //!< UART comm mode.

enum SIO_SI_HIGH = 0x0004;
enum SIO_IRQ = 0x4000; //!< Enable serial irq.

enum SIO_MODE_MASK = 0x3000;
enum SIO_MODE_SHIFT = 12;

extern (D) auto SIO_MODE(T)(auto ref T n)
{
    return n << SIO_MODE_SHIFT;
}

//\}

//!	\name Normal mode bits. UNTESTED.
//\{
enum SION_CLK_EXT = 0x0000; //!< Slave unit; use external clock (default).
enum SION_CLK_INT = 0x0001; //!< Master unit; use internal clock.

enum SION_256KHZ = 0x0000; //!< 256 kHz clockspeed (default).
enum SION_2MHZ = 0x0002; //!< 2 MHz clockspeed.

enum SION_RECV_HIGH = 0x0004; //!< SI high; opponent ready to receive (R).
enum SION_SEND_HIGH = 0x0008; //!< SO high; ready to transfer.

enum SION_ENABLE = 0x0080; //!< Start transfer/transfer enabled.
//\}

//!	\name Multiplayer mode bits. UNTESTED.
//\{
enum SIOM_9600 = 0x0000; //!< Baud rate,   9.6 kbps.
enum SIOM_38400 = 0x0001; //!< Baud rate,  38.4 kbps.
enum SIOM_57600 = 0x0002; //!< Baud rate,  57.6 kbps.
enum SIOM_115200 = 0x0003; //!< Baud rate, 115.2 kbps.

enum SIOM_SI = 0x0004; //!< SI port (R).
enum SIOM_SLAVE = 0x0004; //!< Not the master (R).
enum SIOM_SD = 0x0008; //!< SD port (R).
enum SIOM_CONNECTED = 0x0008; //!< All GBAs connected (R)

enum SIOM_ERROR = 0x0040; //!< Error in transfer (R).
enum SIOM_ENABLE = 0x0080; //!< Start transfer/transfer enabled.

enum SIOM_BAUD_MASK = 0x0003;
enum SIOM_BAUD_SHIFT = 0;

extern (D) auto SIOM_BAUD(T)(auto ref T n)
{
    return n << SIOM_BAUD_SHIFT;
}

enum SIOM_ID_MASK = 0x0030; //!< Multi-player ID mask (R)
enum SIOM_ID_SHIFT = 4;

extern (D) auto SIOM_ID(T)(auto ref T n)
{
    return n << SIOM_ID_SHIFT;
}

//\}

//!	\name UART mode bits. UNTESTED.
//!\{
enum SIOU_9600 = 0x0000; //!< Baud rate,   9.6 kbps.
enum SIOU_38400 = 0x0001; //!< Baud rate,  38.4 kbps.
enum SIOU_57600 = 0x0002; //!< Baud rate,  57.6 kbps.
enum SIOU_115200 = 0x0003; //!< Baud rate, 115.2 kbps.

enum SIOU_CTS = 0x0004; //!< CTS enable.
enum SIOU_PARITY_EVEN = 0x0000; //!< Use even parity.
enum SIOU_PARITY_ODD = 0x0008; //!< Use odd parity.
enum SIOU_SEND_FULL = 0x0010; //!< Send data is full (R).
enum SIOU_RECV_EMPTY = 0x0020; //!< Receive data is empty (R).
enum SIOU_ERROR = 0x0040; //!< Error in transfer (R).
enum SIOU_7BIT = 0x0000; //!< Data is 7bits long.
enum SIOU_8BIT = 0x0080; //!< Data is 8bits long.
enum SIOU_SEND = 0x0100; //!< Start sending data.
enum SIOU_RECV = 0x0200; //!< Start receiving data.

enum SIOU_BAUD_MASK = 0x0003;
enum SIOU_BAUD_SHIFT = 0;

extern (D) auto SIOU_BAUD(T)(auto ref T n)
{
    return n << SIOU_BAUD_SHIFT;
}

//\}

/*!	\}	*/

/*!	\defgroup grpCommR		Comm control.
	\ingroup grpMemBits
	\brief	Communication mode select and general purpose I/O (REG_RCNT).
*/
/*!	\{	*/

//!	\name Communication mode select.
//\{
enum R_MODE_NORMAL = 0x0000; //!< Normal mode.
enum R_MODE_MULTI = 0x0000; //!< Multiplayer mode.
enum R_MODE_UART = 0x0000; //!< UART mode.
enum R_MODE_GPIO = 0x8000; //!< General purpose mode.
enum R_MODE_JOYBUS = 0xC000; //!< JOY mode.

enum R_MODE_MASK = 0xC000;
enum R_MODE_SHIFT = 14;

extern (D) auto R_MODE(T)(auto ref T n)
{
    return n << R_MODE_SHIFT;
}

//\}

//!	\name General purpose I/O data
//\{
enum GPIO_SC = 0x0001; // Data
enum GPIO_SD = 0x0002;
enum GPIO_SI = 0x0004;
enum GPIO_SO = 0x0008;
enum GPIO_SC_IO = 0x0010; // Select I/O
enum GPIO_SD_IO = 0x0020;
enum GPIO_SI_IO = 0x0040;
enum GPIO_SO_IO = 0x0080;
enum GPIO_SC_INPUT = 0x0000; // Input setting
enum GPIO_SD_INPUT = 0x0000;
enum GPIO_SI_INPUT = 0x0000;
enum GPIO_SO_INPUT = 0x0000;
enum GPIO_SC_OUTPUT = 0x0010; // Output setting
enum GPIO_SD_OUTPUT = 0x0020;
enum GPIO_SI_OUTPUT = 0x0040;
enum GPIO_SO_OUTPUT = 0x0080;

enum GPIO_IRQ = 0x0100; //! Interrupt on SI.
//\}

/*!	\}	*/

// --- REG_KEYINPUT --------------------------------------------------------

/*!	\defgroup grpInputKEY	Key Flags
	\ingroup grpMemBits
	\brief	Bits for REG_KEYINPUT and REG_KEYCNT
*/
/*!	\{	*/

enum KEY_A = 0x0001; //!< Button A
enum KEY_B = 0x0002; //!< Button B
enum KEY_SELECT = 0x0004; //!< Select button
enum KEY_START = 0x0008; //!< Start button
enum KEY_RIGHT = 0x0010; //!< Right D-pad
enum KEY_LEFT = 0x0020; //!< Left D-pad
enum KEY_UP = 0x0040; //!< Up D-pad
enum KEY_DOWN = 0x0080; //!< Down D-pad
enum KEY_R = 0x0100; //!< Shoulder R
enum KEY_L = 0x0200; //!< Shoulder L

enum KEY_ACCEPT = 0x0009; //!< Accept buttons: A or start
enum KEY_CANCEL = 0x0002; //!< Cancel button: B (well, it usually is)
enum KEY_RESET = 0x030C; //!< St+Se+L+R

enum KEY_FIRE = 0x0003; //!< Fire buttons: A or B
enum KEY_SPECIAL = 0x000C; //!< Special buttons: Select or Start
enum KEY_DIR = 0x00F0; //!< Directions: left, right, up down
enum KEY_SHOULDER = 0x0300; //!< L or R

enum KEY_ANY = 0x03FF; //!< Here's the Any key :)

enum KEY_MASK = 0x03FF;

/*!	\}	/defgroup	*/

// --- REG_KEYCNT ------------------------------------------------------

/*!	\defgroup grpInputKCNT	Key Control Flags
	\ingroup grpMemBits
	\brief	Bits for REG_KEYCNT
*/

/*!	\{	*/

enum KCNT_IRQ = 0x4000; //!< Enable key irq
enum KCNT_OR = 0; //!< Interrupt on any of selected keys
enum KCNT_AND = 0x8000; //!< Interrupt on all of selected keys

/*!	\}	/defgroup	*/

// --- REG_IE, REG_IF, REG_IF_BIOS -------------------------------------

/*!	\defgroup grpIrqIRQ	Interrupt Flags
	\ingroup grpMemBits
	\brief	Bits for REG_IE, REG_IF and REG_IFBIOS
*/
/*!	\{	*/

enum IRQ_VBLANK = 0x0001; //!< Catch VBlank irq
enum IRQ_HBLANK = 0x0002; //!< Catch HBlank irq
enum IRQ_VCOUNT = 0x0004; //!< Catch VCount irq
enum IRQ_TIMER0 = 0x0008; //!< Catch timer 0 irq
enum IRQ_TIMER1 = 0x0010; //!< Catch timer 1 irq
enum IRQ_TIMER2 = 0x0020; //!< Catch timer 2 irq
enum IRQ_TIMER3 = 0x0040; //!< Catch timer 3 irq
enum IRQ_SERIAL = 0x0080; //!< Catch serial comm irq
enum IRQ_DMA0 = 0x0100; //!< Catch DMA 0 irq
enum IRQ_DMA1 = 0x0200; //!< Catch DMA 1 irq
enum IRQ_DMA2 = 0x0400; //!< Catch DMA 2 irq
enum IRQ_DMA3 = 0x0800; //!< Catch DMA 3 irq
enum IRQ_KEYPAD = 0x1000; //!< Catch key irq
enum IRQ_GAMEPAK = 0x2000; //!< Catch cart irq

/*!	\}	/defgroup	*/

// --- REG_WSCNT -------------------------------------------------------

/*!	\defgroup grpMiscWS	Waitstate Control Flags
	\ingroup grpMemBits
	\brief	Bits for REG_WAITCNT
*/
/*!	\{	*/

enum WS_SRAM_4 = 0;
enum WS_SRAM_3 = 0x0001;
enum WS_SRAM_2 = 0x0002;
enum WS_SRAM_8 = 0x0003;
enum WS_ROM0_N4 = 0;
enum WS_ROM0_N3 = 0x0004;
enum WS_ROM0_N2 = 0x0008;
enum WS_ROM0_N8 = 0x000C;
enum WS_ROM0_S2 = 0;
enum WS_ROM0_S1 = 0x0010;
enum WS_ROM1_N4 = 0;
enum WS_ROM1_N3 = 0x0020;
enum WS_ROM1_N2 = 0x0040;
enum WS_ROM1_N8 = 0x0060;
enum WS_ROM1_S4 = 0;
enum WS_ROM1_S1 = 0x0080;
enum WS_ROM2_N4 = 0;
enum WS_ROM2_N3 = 0x0100;
enum WS_ROM2_N2 = 0x0200;
enum WS_ROM2_N8 = 0x0300;
enum WS_ROM2_S8 = 0;
enum WS_ROM2_S1 = 0x0400;
enum WS_PHI_OFF = 0;
enum WS_PHI_4 = 0x0800;
enum WS_PHI_2 = 0x1000;
enum WS_PHI_1 = 0x1800;
enum WS_PREFETCH = 0x4000;
enum WS_GBA = 0;
enum WS_CGB = 0x8000;

enum WS_STANDARD = 0x4317;

/*!	\}	/defgroup	*/

// --- Reg screen entries ----------------------------------------------

/*!	\defgroup grpVideoSE	Screen-entry Flags
	\ingroup grpMemBits
*/
/*!	\{	*/

enum SE_HFLIP = 0x0400; //!< Horizontal flip
enum SE_VFLIP = 0x0800; //!< Vertical flip

enum SE_ID_MASK = 0x03FF;
enum SE_ID_SHIFT = 0;

extern (D) auto SE_ID(T)(auto ref T n)
{
    return n << SE_ID_SHIFT;
}

enum SE_FLIP_MASK = 0x0C00;
enum SE_FLIP_SHIFT = 10;

extern (D) auto SE_FLIP(T)(auto ref T n)
{
    return n << SE_FLIP_SHIFT;
}

enum SE_PALBANK_MASK = 0xF000;
enum SE_PALBANK_SHIFT = 12;

extern (D) auto SE_PALBANK(T)(auto ref T n)
{
    return n << SE_PALBANK_SHIFT;
}

/*!	\}	/defgroup	*/

// --- OAM attribute 0 -------------------------------------------------

/*!	\defgroup grpVideoAttr0	Object Attribute 0 Flags
	\ingroup grpMemBits
*/
/*!	\{	*/

enum ATTR0_REG = 0; //!< Regular object
enum ATTR0_AFF = 0x0100; //!< Affine object
enum ATTR0_HIDE = 0x0200; //!< Inactive object
enum ATTR0_AFF_DBL = 0x0300; //!< Double-size affine object
enum ATTR0_AFF_DBL_BIT = 0x0200;
enum ATTR0_BLEND = 0x0400; //!< Enable blend
enum ATTR0_WINDOW = 0x0800; //!< Use for object window
enum ATTR0_MOSAIC = 0x1000; //!< Enable mosaic
enum ATTR0_4BPP = 0; //!< Use 4bpp (16 color) tiles
enum ATTR0_8BPP = 0x2000; //!< Use 8bpp (256 color) tiles
enum ATTR0_SQUARE = 0; //!< Square shape
enum ATTR0_WIDE = 0x4000; //!< Tall shape (height &gt; width)
enum ATTR0_TALL = 0x8000; //!< Wide shape (height &lt; width)

enum ATTR0_Y_MASK = 0x00FF;
enum ATTR0_Y_SHIFT = 0;

extern (D) auto ATTR0_Y(T)(auto ref T n)
{
    return n << ATTR0_Y_SHIFT;
}

enum ATTR0_MODE_MASK = 0x0300;
enum ATTR0_MODE_SHIFT = 8;

extern (D) auto ATTR0_MODE(T)(auto ref T n)
{
    return n << ATTR0_MODE_SHIFT;
}

enum ATTR0_SHAPE_MASK = 0xC000;
enum ATTR0_SHAPE_SHIFT = 14;

extern (D) auto ATTR0_SHAPE(T)(auto ref T n)
{
    return n << ATTR0_SHAPE_SHIFT;
}

/*!	\}	/defgroup	*/

// --- OAM attribute 1 -------------------------------------------------

/*!	\defgroup grpVideoAttr1	Object Attribute 1 Flags
	\ingroup grpMemBits
*/
/*!	\{	*/

enum ATTR1_HFLIP = 0x1000; //!< Horizontal flip (reg obj only)
enum ATTR1_VFLIP = 0x2000; //!< Vertical flip (reg obj only)
// Base sizes
enum ATTR1_SIZE_8 = 0;
enum ATTR1_SIZE_16 = 0x4000;
enum ATTR1_SIZE_32 = 0x8000;
enum ATTR1_SIZE_64 = 0xC000;
// Square sizes
enum ATTR1_SIZE_8x8 = 0; //!< Size flag for  8x8 px object
enum ATTR1_SIZE_16x16 = 0x4000; //!< Size flag for 16x16 px object
enum ATTR1_SIZE_32x32 = 0x8000; //!< Size flag for 32x32 px object
enum ATTR1_SIZE_64x64 = 0xC000; //!< Size flag for 64x64 px object
// Tall sizes
enum ATTR1_SIZE_8x16 = 0; //!< Size flag for  8x16 px object
enum ATTR1_SIZE_8x32 = 0x4000; //!< Size flag for  8x32 px object
enum ATTR1_SIZE_16x32 = 0x8000; //!< Size flag for 16x32 px object
enum ATTR1_SIZE_32x64 = 0xC000; //!< Size flag for 32x64 px object
// Wide sizes
enum ATTR1_SIZE_16x8 = 0; //!< Size flag for 16x8 px object
enum ATTR1_SIZE_32x8 = 0x4000; //!< Size flag for 32x8 px object
enum ATTR1_SIZE_32x16 = 0x8000; //!< Size flag for 32x16 px object
enum ATTR1_SIZE_64x32 = 0xC000; //!< Size flag for 64x64 px object

enum ATTR1_X_MASK = 0x01FF;
enum ATTR1_X_SHIFT = 0;

extern (D) auto ATTR1_X(T)(auto ref T n)
{
    return n << ATTR1_X_SHIFT;
}

enum ATTR1_AFF_ID_MASK = 0x3E00;
enum ATTR1_AFF_ID_SHIFT = 9;

extern (D) auto ATTR1_AFF_ID(T)(auto ref T n)
{
    return n << ATTR1_AFF_ID_SHIFT;
}

enum ATTR1_FLIP_MASK = 0x3000;
enum ATTR1_FLIP_SHIFT = 12;

extern (D) auto ATTR1_FLIP(T)(auto ref T n)
{
    return n << ATTR1_FLIP_SHIFT;
}

enum ATTR1_SIZE_MASK = 0xC000;
enum ATTR1_SIZE_SHIFT = 14;

extern (D) auto ATTR1_SIZE(T)(auto ref T n)
{
    return n << ATTR1_SIZE_SHIFT;
}

/*!	\}	/defgroup	*/

// --- OAM attribute 2 -------------------------------------------------

/*!	\defgroup grpVideoAttr2	Object Attribute 2 Flags
	\ingroup grpMemBits
*/
/*!	\{	*/

enum ATTR2_ID_MASK = 0x03FF;
enum ATTR2_ID_SHIFT = 0;

extern (D) auto ATTR2_ID(T)(auto ref T n)
{
    return n << ATTR2_ID_SHIFT;
}

enum ATTR2_PRIO_MASK = 0x0C00;
enum ATTR2_PRIO_SHIFT = 10;

extern (D) auto ATTR2_PRIO(T)(auto ref T n)
{
    return n << ATTR2_PRIO_SHIFT;
}

enum ATTR2_PALBANK_MASK = 0xF000;
enum ATTR2_PALBANK_SHIFT = 12;

extern (D) auto ATTR2_PALBANK(T)(auto ref T n)
{
    return n << ATTR2_PALBANK_SHIFT;
}

/*!	\}	//defgroup	*/

// TONC_MEMDEF

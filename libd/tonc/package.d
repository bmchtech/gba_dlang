//
//  Main tonc header
//
//! \file tonc.h
//! \author J Vijn
//! \date 20060508 - 20080825
//
// === NOTES ===

module tonc;

public {
	import tonc.tonc_types;
	import tonc.tonc_memmap;
	import tonc.tonc_memdef;

	import tonc.tonc_bios;
	import tonc.tonc_core;
	import tonc.tonc_input;
	import tonc.tonc_irq;
	import tonc.tonc_math;
	import tonc.tonc_oam;
	import tonc.tonc_tte;
	import tonc.tonc_video;
	import tonc.tonc_surface;

	import tonc.tonc_nocash;

	import tonc.tonc_text;
}

extern (C):

// For old times' sake

// --- Doxygen modules: ---

/*!	\defgroup grpBios	Bios Calls			*/
/*!	\defgroup grpCore	Core				*/
/*! \defgroup grpDma	DMA					*/
/*! \defgroup grpInput	Input				*/
/*! \defgroup grpIrq	Interrupt			*/
/*! \defgroup grpMath	Math				*/
/*!	\defgroup grpMemmap Memory Map			*/
/*! \defgroup grpAudio	Sound				*/
/*! \defgroup grpTTE	Tonc Text Engine	*/
/*! \defgroup grpText	Old Text			*/
/*! \defgroup grpTimer	Timer				*/
/*! \defgroup grpVideo	Video				*/

/*!	\mainpage	Tonclib 1.4 (20080825)
	<p>
	Tonclib is the library accompanying the set of GBA tutorials known
	as <a href="http://www.coranac.com/tonc/">Tonc</a>  Initially, it
	was just a handful of macros and functions for dealing with the
	GBA hardware: the memory map and its bits, affine transformation
	code and things like that. More recently, more general items
	have been added like tonccpy() and toncset(), the TSurface system
	and TTE. All these items should provide a firm basis on which to
	build GBA software.
	</p>
*/

// TONC_MAIN

//
//  no$gba messaging functionality
//
//! \file tonc_nocash.h
//! \author J Vijn
//! \date 20080422 - 20080422
//
/* === NOTES ===
*/
module tonc.tonc_nocash;


extern (C):

/*!	\defgroup grpNocash no$gba debugging
	\ingroup grpCore
	The non-freeware versions of no$gba have window to which you
	can output messages for debugging purposes. These functions allow
	you to work with that.
*/

/*! \addtogroup grpNocash	*/
/*!	\{	*/

// --------------------------------------------------------------------
// GLOBALS 
// --------------------------------------------------------------------

extern __gshared char[80] nocash_buffer;

// --------------------------------------------------------------------
// PROTOTYPES 
// --------------------------------------------------------------------

//!	Output a string to no$gba debugger.
/*!
	\param str	Text to print.
	\return		Number of characters printed.
*/
int nocash_puts (const(char)* str);

//! Print the current \a nocash_buffer to the no$gba debugger.
void nocash_message ();

/*!	\}	*/

// TONC_NOCASH

// EOF

//
//  Input header
//
//! \file tonc_input.h
//! \author J Vijn
//! \date 20060508 - 20070406
//
// === NOTES ===
// * 20070406: Changed KEY_RESET to Se+St+L+R, like it should be.
// * 20070406: added key-repeat functionality.

module tonc.tonc_input;

import tonc.tonc_types;


extern (C):

/*!	\addtogroup grpInput
	\brief	Routines for synchronous and asynchronous button states.

	For details, see
	<a href="http://www.coranac.com/tonc/text/keys.htm">tonc:keys</a>.
*/

/*! \{	*/

// --------------------------------------------------------------------
// CONSTANTS
// --------------------------------------------------------------------

enum eKeyIndex
{
    KI_A = 0,
    KI_B = 1,
    KI_SELECT = 2,
    KI_START = 3,
    KI_RIGHT = 4,
    KI_LEFT = 5,
    KI_UP = 6,
    KI_DOWN = 7,
    KI_R = 8,
    KI_L = 9,
    KI_MAX = 10
}

enum KEY_FULL = 0xFFFFFFFF; //!< Define for checking all keys.

// --------------------------------------------------------------------
// MACROS 
// --------------------------------------------------------------------

// Check which of the specified keys are down or up right now

extern (D) auto KEY_DOWN_NOW(T)(auto ref T key)
{
    return ~REG_KEYINPUT & key;
}

extern (D) auto KEY_UP_NOW(T)(auto ref T key)
{
    return REG_KEYINPUT & key;
}

// test whether all keys are pressed, released, whatever.
// Example use:
//   KEY_EQ(key_hit, KEY_L | KEY_R)
// will be true if and only if KEY_L and KEY_R are _both_ being pressed
extern (D) auto KEY_EQ(T0, T1)(auto ref T0 key_fun, auto ref T1 keys)
{
    return key_fun(keys) == keys;
}

extern (D) auto KEY_TRIBOOL(T0, T1, T2)(auto ref T0 fnKey, auto ref T1 plus, auto ref T2 minus)
{
    return bit_tribool(fnKey(KEY_FULL), plus, minus);
}

// --------------------------------------------------------------------
// GLOBALS 
// --------------------------------------------------------------------

extern __gshared ushort __key_curr;
extern __gshared ushort __key_prev;

// --------------------------------------------------------------------
// PROTOTYPES 
// --------------------------------------------------------------------

void key_wait_for_clear (uint key); // wait for keys to be up

//! \name Basic synchonous keystates
//\{
void key_poll ();
uint key_curr_state ();
uint key_prev_state ();

uint key_is_down (uint key);
uint key_is_up (uint key);

uint key_was_down (uint key);
uint key_was_up (uint key);
//\}

//! \name Transitional keystates
//\{
uint key_transit (uint key);
uint key_held (uint key);
uint key_hit (uint key);
uint key_released (uint key);
//\}

//! \name Tribools
//\{
int key_tri_horz ();
int key_tri_vert ();
int key_tri_shoulder ();
int key_tri_fire ();
//\}

//! \name Key repeats
//\{
uint key_repeat (uint keys);

void key_repeat_mask (uint mask);
void key_repeat_limits (uint delay, uint repeat);
//\}

void key_wait_till_hit (ushort key);

// --------------------------------------------------------------------
// INLINES
// --------------------------------------------------------------------

//! Get current keystate
uint key_curr_state ();

//! Get previous key state
uint key_prev_state ();

//! Gives the keys of \a key that are currently down
uint key_is_down (uint key);

//! Gives the keys of \a key that are currently up
uint key_is_up (uint key);

//! Gives the keys of \a key that were previously down
uint key_was_down (uint key);

//! Gives the keys of \a key that were previously down
uint key_was_up (uint key);

//! Gives the keys of \a key that are different from before
uint key_transit (uint key);

//! Gives the keys of \a key that are being held down
uint key_held (uint key);

//! Gives the keys of \a key that are pressed (down now but not before)
uint key_hit (uint key);

//! Gives the keys of \a key that are being released
uint key_released (uint key);

//! Horizontal tribool (right,left)=(+,-)
int key_tri_horz ();

//! Vertical tribool (down,up)=(+,-)
int key_tri_vert ();

//! Shoulder-button tribool (R,L)=(+,-)
int key_tri_shoulder ();

//! Fire-button tribool (A,B)=(+,-)
int key_tri_fire ();

/*	\}	*/

// TONC_INPUT

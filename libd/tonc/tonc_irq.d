//
//  Interrupt header
//
//! \file tonc_irq.h
//! \author J Vijn
//! \date 20060508 - 20080326
//
// === NOTES ===
module tonc.tonc_irq;

import tonc.tonc_types;


extern (C):

// --------------------------------------------------------------------
// CONSTANTS
// --------------------------------------------------------------------

/*! \addtogroup grpIrq
	\brief	Hardware interrupt management.


	For details, see
	<a href="http://www.coranac.com/tonc/text/interrupts.htm">tonc:irq</a>
	*/
/*! \{	*/

//! IRQ indices, to be used in most functions.
enum IrqIndex
{
    VBLANK = 0,
    HBLANK = 1,
    VCOUNT = 2,
    TIMER0 = 3,
    TIMER1 = 4,
    TIMER2 = 5,
    TIMER3 = 6,
    SERIAL = 7,
    DMA0 = 8,
    DMA1 = 9,
    DMA2 = 10,
    DMA3 = 11,
    KEYPAD = 12,
    GAMEPAK = 13,
    MAX = 14
}

//! \name Options for irq_set
//\{

enum ISR_LAST = 0x0040; //!< Last isr in line (Lowest priority)
enum ISR_REPLACE = 0x0080; //!< Replace old isr if existing (prio ignored)

enum ISR_PRIO_MASK = 0x003F; //!< 
enum ISR_PRIO_SHIFT = 0;

extern (D) auto ISR_PRIO(T)(auto ref T n)
{
    return n << ISR_PRIO_SHIFT;
}

enum ISR_DEF = ISR_LAST | ISR_REPLACE;

//\}

// --------------------------------------------------------------------
// MACROS 
// --------------------------------------------------------------------

//! Default irq_init() call: use irq_master_nest() for switchboard.
extern (D) auto IRQ_INIT()
{
    return irq_init(null);
}

//! Default irq_set() call: no isr, add to back of priority stack

// Default irq_add() call: no isr

// --------------------------------------------------------------------
// CLASSES 
// --------------------------------------------------------------------

//! Struct for prioritized irq table
struct IRQ_REC
{
    uint flag; //!< Flag for interrupt in REG_IF, etc
    fnptr isr; //!< Pointer to interrupt routine
}

// --------------------------------------------------------------------
// GLOBALS 
// --------------------------------------------------------------------

extern __gshared IRQ_REC[15] __isr_table;

// --------------------------------------------------------------------
// PROTOTYPES 
// --------------------------------------------------------------------

void isr_master ();
void isr_master_nest ();

void irq_init (fnptr isr);
fnptr irq_set_master (fnptr isr);

fnptr irq_add (IrqIndex irq_id, fnptr isr);
fnptr irq_delete (IrqIndex irq_id);

fnptr irq_set (IrqIndex irq_id, fnptr isr, uint opts);

void irq_enable (IrqIndex irq_id);
void irq_disable (IrqIndex irq_id);

// --------------------------------------------------------------------
// INLINES 
// --------------------------------------------------------------------

/*! \}	*/

// TONC_IRQ

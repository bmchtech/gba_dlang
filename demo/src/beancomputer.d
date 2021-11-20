module beancomputer;

import tonc.tonc_types;
import core.volatile;

extern (C):

/*
BEANCOMPUTER STANDARD v0.1
An extension to the GBA, adding a few IO registers to allow for general purpose computing!
*/

enum REG_BEANCOMPUTER_SUPPORT = cast(shared u32*) 0x4FFF104;
enum REG_BEANCOMPUTER_KEYBOARD1 = cast(shared u32*) 0x4FFF108;
enum REG_BEANCOMPUTER_KEYBOARD2 = cast(shared u32*) 0x4FFF10c;
enum REG_BEANCOMPUTER_MOUSE = cast(shared u32*) 0x4FFF110;

enum BEANCOMPUTER_SUPPORT_MAGIC = 0xBEA7;

/*
SUPPORT bits (little endian):
    bits 0-15: version
    bits 16-31: magic number (0xBEA7)
KEYBOARD1 bits (little-endian):
    bits 0-25: a-z
    bit 26: shift
    bit 27: ctrl
    bit 28: alt
    bit 29: super
    bit 30: fn
    bit 31: esc
KEYBOARD2 bits (little-endian):
    bits 0-9: 0-9
    bit 10: ,
    bit 11: .
    bit 12: /
    bit 13: ;
    bit 14: '
    bit 15: [
    bit 16: ]
    bit 17: \
    bit 18: -
    bit 19: +
    bit 20: `
    bit 21: tab
    bit 22: return
    bit 23: backspace
    bit 24: left arrow
    bit 25: right arrow
    bit 26: up arrow
    bit 27: down arrow
MOUSE bits (little-endian):
    bit 0-7: mouse x
    bit 8-15: mouse y
    bit 16: left button
    bit 17: right button
    bit 18: middle button
*/

enum BeanComputerSupport {
    NOT_SUPPORTED = -1,
    VERSION_01 = 0x01,
    VERSION_02 = 0x02,
    UNKNOWN_VERSION = 0xFFFF,
}

BeanComputerSupport beancomputer_check_support() {
    // check upper 16 bits of the support register are the magic number
    bool magic_match = ((*REG_BEANCOMPUTER_SUPPORT & 0xFFFF0000) >> 16) == BEANCOMPUTER_SUPPORT_MAGIC;
    if (!magic_match) {
        return BeanComputerSupport.NOT_SUPPORTED;
    }
    // magic does match, check the version and return appropriate value
    ushort bc_version = (*REG_BEANCOMPUTER_SUPPORT) & 0xFFFF;
    switch (bc_version) {
    case BeanComputerSupport.VERSION_01:
        return BeanComputerSupport.VERSION_01;
    case BeanComputerSupport.VERSION_02:
        return BeanComputerSupport.VERSION_02;
    default:
        return BeanComputerSupport.UNKNOWN_VERSION;
    }
}

struct BeanComputerInputState {
    u32 keyboard1 = 0xFFFFFFFF;
    u32 keyboard2 = 0xFFFFFFFF;
    u32 mouse = 0x0 | (0x1L << 16) | (0x1L << 17) | (0x1L << 18);
}

struct BeanComputerMouseState {
    u8 x = 0;
    u8 y = 0;
    bool left = false;
    bool right = false;
    bool middle = false;
}

enum BeanComputerKeyboardKey : ulong {
    A = (0x1L << 0),
    B = (0x1L << 1),
    C = (0x1L << 2),
    D = (0x1L << 3),
    E = (0x1L << 4),
    F = (0x1L << 5),
    G = (0x1L << 6),
    H = (0x1L << 7),
    I = (0x1L << 8),
    J = (0x1L << 9),
    K = (0x1L << 10),
    L = (0x1L << 11),
    M = (0x1L << 12),
    N = (0x1L << 13),
    O = (0x1L << 14),
    P = (0x1L << 15),
    Q = (0x1L << 16),
    R = (0x1L << 17),
    S = (0x1L << 18),
    T = (0x1L << 19),
    U = (0x1L << 20),
    V = (0x1L << 21),
    W = (0x1L << 22),
    X = (0x1L << 23),
    Y = (0x1L << 24),
    Z = (0x1L << 25),
    SHIFT = (0x1L << 26),
    CTRL = (0x1L << 27),
    ALT = (0x1L << 28),
    SUPER = (0x1L << 29),
    FN = (0x1L << 30),
    ESC = (0x1L << 31),
    D0 = (0x1L << 32),
    D1 = (0x1L << 33),
    D2 = (0x1L << 34),
    D3 = (0x1L << 35),
    D4 = (0x1L << 36),
    D5 = (0x1L << 37),
    D6 = (0x1L << 38),
    D7 = (0x1L << 39),
    D8 = (0x1L << 40),
    D9 = (0x1L << 41),
    COMMA = (0x1L << 42),
    PERIOD = (0x1L << 43),
    SLASH = (0x1L << 44),
    SEMICOLON = (0x1L << 45),
    QUOTE = (0x1L << 46),
    BRACKET_OPEN = (0x1L << 47),
    BRACKET_CLOSE = (0x1L << 48),
    BACKSLASH = (0x1L << 49),
    MINUS = (0x1L << 50),
    PLUS = (0x1L << 51),
    TAB = (0x1L << 52),
    RETURN = (0x1L << 53),
    BACKSPACE = (0x1L << 54),
    LEFT_ARROW = (0x1L << 55),
    RIGHT_ARROW = (0x1L << 56),
    UP_ARROW = (0x1L << 57),
    DOWN_ARROW = (0x1L << 58),
}

enum BeanComputerMouseButton : ulong {
    LEFT = (0x1L << 16),
    RIGHT = (0x1L << 17),
    MIDDLE = (0x1L << 18),
}

__gshared BeanComputerInputState beancomputer_input_state;
__gshared BeanComputerInputState beancomputer_prev_input_state;

/*
enum REG_BEANCOMPUTER_KEYBOARD1 = cast(shared u32*) 0x4FFF108;
enum REG_BEANCOMPUTER_KEYBOARD2 = cast(shared u32*) 0x4FFF10c;
enum REG_BEANCOMPUTER_MOUSE = cast(shared u32*) 0x4FFF110;

MOUSE bits (little-endian):
    bit 0-7: mouse x
    bit 8-15: mouse y
    bit 16: left button
    bit 17: right button
    bit 18: middle button
*/

/** check whether a key is down in a state */
bool beancomputer_key_down(BeanComputerInputState state, BeanComputerKeyboardKey key) {
    // check whether key is in keyboard1 or keyboard2
    bool is_keyboard2 = (key & 0xFFFFFFFF) == 0;

    u32 check_reg = is_keyboard2 ? state.keyboard2 : state.keyboard1;

    // check whether key bit is set to 0 (down)
    return (check_reg & key) == 0;
}

/** get the mouse state from the cached input state */
BeanComputerMouseState beancomputer_mouse_read_state(BeanComputerInputState state) {
    BeanComputerMouseState mouse_state;
    mouse_state.x = (state.mouse >> 0) & 0xFF;
    mouse_state.y = (state.mouse >> 8) & 0xFF;
    mouse_state.left = (state.mouse >> 16) & 0x1;
    mouse_state.right = (state.mouse >> 17) & 0x1;
    mouse_state.middle = (state.mouse >> 18) & 0x1;
    return mouse_state;
}

/** get the mouse state from the cached input state */
BeanComputerMouseState beancomputer_mouse_get_state() {
    return beancomputer_mouse_read_state(beancomputer_input_state);
}

/** check if key wasn't previously pressed but is now */
bool beancomputer_key_just_pressed(BeanComputerKeyboardKey key) {
    return !beancomputer_key_down(beancomputer_prev_input_state, key)
        && beancomputer_key_down(beancomputer_input_state, key);
}

/** check if key was previously pressed but is up now */
bool beancomputer_key_just_released(BeanComputerKeyboardKey key) {
    return beancomputer_key_down(beancomputer_prev_input_state, key)
        && !beancomputer_key_down(beancomputer_input_state, key);
}

/** read input registers and update cached states */
void beancomputer_input_poll() {
    // update prev state
    beancomputer_prev_input_state = beancomputer_input_state;
    // read new state
    volatileBarrier();
    beancomputer_input_state.keyboard1 = *REG_BEANCOMPUTER_KEYBOARD1;
    beancomputer_input_state.keyboard2 = *REG_BEANCOMPUTER_KEYBOARD2;
    beancomputer_input_state.mouse = *REG_BEANCOMPUTER_MOUSE;
}

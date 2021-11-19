module beancomputer;

/*
BEANCOMPUTER STANDARD v0.1
An extension to the GBA, adding a few IO registers to allow for general purpose computing!
*/

enum REG_BEANCOMPUTER_SUPPORT = cast(shared char*) 0x4FFF104;
enum REG_BEANCOMPUTER_KEYBOARD1 = cast(shared char*) 0x4FFF108;
enum REG_BEANCOMPUTER_KEYBOARD2 = cast(shared char*) 0x4FFF10c;
enum REG_BEANCOMPUTER_MOUSE = cast(shared char*) 0x4FFF110;

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

import core.stdc.stdio;
import tonc;
import mgba;

extern(C) int main() {
	// nothing
	printf("Hello, world!\n");
    
    *REG_DISPCNT = DCNT_MODE0 | DCNT_BG0;
    pal_bg_mem[0] = 0x6B9D; // background color

    // write some text to screen
    *REG_DISPCNT |= DCNT_BG1;
	tte_init_chr4c(1, cast(u16) (BG_CBB!u16(0)|BG_SBB!u16(31)), 0, 0x0201, CLR_WHITE, null, null);
	tte_init_con();

    // set text colors
    pal_bg_mem[1] = 0x39BB;
    pal_bg_mem[2] = 0x5AAE;
    pal_bg_mem[3] = 0x2D09;
    pal_bg_mem[4] = 0x4F54;

    tte_printf("#{P:12,12}#{ci:1}bean #{ci:2}machine");
    tte_printf("#{P:20,26}#{ci:3}dlang on gba");
    tte_printf("#{P:76,26}#{ci:4}success");

    bool mgba_opened = mgba_open();
    if (mgba_opened) {
        mgba_printf(MGBA_LOG_LEVEL.MGBA_LOG_ERROR, "Hello, from %s!\n", cast(const char*)"Bean Machine");
        tte_printf("#{P:20,40}#{ci:4}mgba opened");
    }

    while (TRUE) {
        key_poll();
    }

	return 0;
}

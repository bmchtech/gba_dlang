import core.stdc.stdio;
import tonc;
import mgba;

extern(C) int main() {
	// nothing
	printf("Hello, world!\n");
    
    *REG_DISPCNT = DCNT_MODE0 | DCNT_BG0;
    pal_bg_mem[0] = 0x0C02; // background color

	if (mgba_open()) {
		mgba_printf(MGBA_LOG_LEVEL.MGBA_LOG_ERROR, "Hello, world, %s!\n", cast(const char*)"Bean Machine");
	} else {
        // failed to open mgba
        pal_bg_mem[0] = CLR_RED;
    }

    while (TRUE) {
        key_poll();
    }

	return 0;
}

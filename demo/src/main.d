import core.stdc.stdio;
import tonc;
import mgba;
import beancomputer;

extern (C):

__gshared bool beancomputer_log = false;
__gshared int frame_count = 0;

void init_show_info() {
    // nothing
    printf("Hello, world!\n");

    *REG_DISPCNT = DCNT_MODE0 | DCNT_BG0;
    pal_bg_mem[0] = 0x6B9D; // background color

    // write some text to screen
    *REG_DISPCNT |= DCNT_BG1;
    tte_init_chr4c(1, cast(u16)(BG_CBB!u16(0) | BG_SBB!u16(31)), 0, 0x0201,
            CLR_WHITE, null, null);
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
        mgba_printf(MGBA_LOG_LEVEL.MGBA_LOG_ERROR, "Hello, from %s!\n",
                cast(const char*) "Bean Machine");
        tte_printf("#{P:20,40}#{ci:4}mgba opened");
    }
}

int main() {
    init_show_info();

    auto bc_support = beancomputer_check_support();
    bool bc_enabled = false;
    if (bc_support == BeanComputerSupport.NOT_SUPPORTED) {
        tte_printf("#{P:20,54}#{ci:1}bc not supported (use gamebean emulator)");
    } else {
        tte_printf("#{P:20,54}#{ci:4}bc ver: 0x%02x", cast(int) bc_support);
        tte_printf("#{P:20,64}#{ci:4}press [shift] to enter bc view");
        bc_enabled = true;
    }

    while (true) {
        frame_count++;

        if (bc_enabled) {
            beancomputer_input_poll();

            // when RETURN is pressed, write info about beancomputer version
            if (beancomputer_key_just_pressed(BeanComputerKeyboardKey.SHIFT)) {
                beancomputer_log = true;
                tte_erase_screen();
            }

            if (beancomputer_log && frame_count % 8 == 0) {
                // tte_erase_rect(12, 12, 80, 12);
                tte_erase_rect(20, 26, 60, 12);

                // write info about beancomputer
                tte_printf("#{P:12,12}#{ci:4}beancomputer #{ci:3}ver: 0x%02x", cast(int) bc_support);
                // get mouse pos
                BeanComputerMouseState mouse_state = beancomputer_mouse_get_state();
                tte_printf("#{P:20,26}#{ci:4}mouse: %d, %d", mouse_state.x, mouse_state.y);
            }
        }
    }

    return 0;
}

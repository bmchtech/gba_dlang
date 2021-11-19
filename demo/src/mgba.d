module mgba;

import core.stdc.stdarg;
import core.stdc.stdio;
import core.stdc.string;
import tonc.tonc_types;
import core.volatile;

extern (C):

enum REG_DEBUG_ENABLE = cast(shared vu16*) 0x4FFF780;
enum REG_DEBUG_FLAGS = cast(shared vu16*) 0x4FFF700;
enum REG_DEBUG_STRING = cast(shared char*) 0x4FFF600;

enum MGBA_LOG_LEVEL {
    MGBA_LOG_FATAL = 0,
    MGBA_LOG_ERROR = 1,
    MGBA_LOG_WARN = 2,
    MGBA_LOG_INFO = 3,
    MGBA_LOG_DEBUG = 4
}

void mgba_printf(int level, const char* ptr, ...) {
    va_list args;
    level &= 0x7;
    va_start(args, ptr);
    vsprintf(REG_DEBUG_STRING, ptr, args);
    va_end(args);
    *REG_DEBUG_FLAGS = cast(u16)(level | 0x100);
}

bool mgba_open() {
    volatileBarrier();
    *REG_DEBUG_ENABLE = 0xC0DE;
    // volatileStore(REG_DEBUG_ENABLE, 0xC0DE);
    volatileBarrier();
    return *REG_DEBUG_ENABLE == 0x1DEA;
    // return volatileLoad(REG_DEBUG_ENABLE) == 0x1DEA;
}

void mgba_close() {
    volatileBarrier();
    *REG_DEBUG_ENABLE = 0;
    volatileBarrier();
    // volatileStore(REG_DEBUG_ENABLE, 0);
}

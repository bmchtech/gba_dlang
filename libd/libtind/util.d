module libtind.util;

import core.stdc.string;
import core.stdc.stdio;
import core.stdc.stdlib;

T* tind_alloc(T)() {
    T* t = cast(T*) malloc(T.sizeof);
    if (!t) {
        assert(0, "tind_alloc: out of memory");
    }
    return t;
}

void tind_free(T)(T* t) {
    if (!t) {
        assert(0, "tind_free: null pointer");
    }
    free(t);
    t = null;
}

/**
 * This module declares intrinsics for volatile operations.
 *
 * Copyright: Copyright © 2019, The D Language Foundation
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Authors:   Walter Bright, Ernesto Castellotti
 * Source:    $(DRUNTIMESRC core/volatile.d)
 */

module core.volatile;

import ldc.llvmasm;

nothrow:
@system:
@nogc:

/*************************************
 * Read/write value from/to the memory location indicated by ptr.
 *
 * These functions are recognized by the compiler, and calls to them are guaranteed
 * to not be removed (as dead assignment elimination or presumed to have no effect)
 * or reordered in the same thread.
 *
 * These reordering guarantees are only made with regards to other
 * operations done through these functions; the compiler is free to reorder regular
 * loads/stores with regards to loads/stores done through these functions.
 *
 * This is useful when dealing with memory-mapped I/O (MMIO) where a store can
 * have an effect other than just writing a value, or where sequential loads
 * with no intervening stores can retrieve
 * different values from the same location due to external stores to the location.
 *
 * These functions will, when possible, do the load/store as a single operation. In
 * general, this is possible when the size of the operation is less than or equal to
 * $(D (void*).sizeof), although some targets may support larger operations. If the
 * load/store cannot be done as a single operation, multiple smaller operations will be used.
 *
 * These are not to be conflated with atomic operations. They do not guarantee any
 * atomicity. This may be provided by coincidence as a result of the instructions
 * used on the target, but this should not be relied on for portable programs.
 * Further, no memory fences are implied by these functions.
 * They should not be used for communication between threads.
 * They may be used to guarantee a write or read cycle occurs at a specified address.
 */

ubyte  volatileLoad(ubyte * ptr);
ushort volatileLoad(ushort* ptr);
uint   volatileLoad(uint  * ptr);
ulong  volatileLoad(ulong * ptr);

void volatileStore(ubyte * ptr, ubyte  value);
void volatileStore(ushort* ptr, ushort value);
void volatileStore(uint  * ptr, uint   value);
void volatileStore(ulong * ptr, ulong  value);

pragma(inline, true) void volatileBarrier() {
    // ARMv5 asm to mark memory as clobbered, as a barrier
    return __asm("", "~{memory}");
}

@system unittest
{
    alias TT(T...) = T;

    foreach (T; TT!(ubyte, ushort, uint, ulong))
    {
        T u;
        T* p = &u;
        volatileStore(p, 1);
        T r = volatileLoad(p);
        assert(r == u);
    }
}

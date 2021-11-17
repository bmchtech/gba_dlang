// Based on https://github.com/JinShil/stm32f42_discovery_demo/blob/master/source/stm32f42/mmio.d
module rt.mmio;

// Copyright © 2017 Michael V. Franklin
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/***************************************************************************
 Implementation of memory-mapped I/O registers in D.  The idea for this
 came from a paper by Ken Smith titled "C++ Hardware Register Access Redux".
 At the time of this writing, a link to the could be found here:
 http://yogiken.files.wordpress.com/2010/02/c-register-access.pdf

 The idea, is that all of this logic will actually be evaluated at compile
 time and each BitField access will only cost a few instructions of assembly.

 Right now, this will probably only work for 32-bit platforms. I'd like to
 modify this so it is portable to even 16, and 8 bit platforms, but one step
 at a time.

 * It enforces word, half-word, and byte access policy at compile time.
   See Access.
 * It enforces mutability constraints such as read, write, readwrite, etc...
   at compile time. See Mutability.
 * It optimizes byte-aligned and half-word aligned bitfields generating atomic
   read/write operations resulting in smaller code size and faster performance.
 * It optimizes bitfieds of a single bit, via bit-banding, generating atomic
   read/write operations resulting in smaller code size and faster performance.
 * It can combine multiple bitfield accesses within a single register into one
   read-modify-write operation resulting in smaller code size and faster
   performance.
 * It enables intuitive and obvious register modeling that directly cross-references
   back to register specifications.

 Example:
 --------------------
 // A peripherals's register specification can be modeled as follows
 // TODO: make a more meaningful example
final abstract class MyPeripheral : Peripheral!(0x2000_1000)
{
    final abstract class MyRegister0 : Register!(0x0000, Access.Word)
    {
        alias EntireRegister = BitField!(31, 0, Mutability.rw);
        alias Bits31To17     = BitField!(17, 2, Mutability.rw);
        alias Bits15to8      = BitField!(15, 8, Mutability.rw);
        alias Bits1to0       = BitField!( 1, 0, Mutability.rw);
        alias Bit1           = Bit!(1, Mutability.rw);
        alias Bit0           = Bit!(0, Mutability.rw);
    }

    final abstract class MyRegister1 : Register!(0x0004, Access.Word)
    {
        alias EntireRegister = BitField!(31, 0, Mutability.rw);
        alias Bits31To17     = BitField!(17, 2, Mutability.rw);
        alias Bits15to8      = BitField!(15, 8, Mutability.rw);
        alias Bits1to0       = BitField!( 1, 0, Mutability.rw);
        alias Bit1           = Bit!(1, Mutability.rw);
        alias Bit0           = Bit!(0, Mutability.rw);
    }
}
 --------------------
*/

nothrow:

/****************************************************************************
   Template wrapping volatileLoad intrinsic casting to basic type based on
   size.
*/
private T volatileLoad(T)(T* a) @trusted
{
    static import core.bitop;
    static if (T.sizeof == 1)
    {
        return cast(T)core.bitop.volatileLoad(cast(ubyte*)a);
    }
    else static if (T.sizeof == 2)
    {
        return cast(T)core.bitop.volatileLoad(cast(ushort*)a);
    }
    else static if (T.sizeof == 4)
    {
        return cast(T)core.bitop.volatileLoad(cast(uint*)a);
    }
    else
    {
        static assert(false, "Size not supported.");
    }
}

/****************************************************************************
   Template wrapping volatileStore intrinsic casting to basic type based on
   size.
*/
private void volatileStore(T)(T* a, in T v) @trusted
{
    static import core.bitop;
    static if (T.sizeof == 1)
    {
        core.bitop.volatileStore(cast(ubyte*)a, cast(ubyte)v);
    }
    else static if (T.sizeof == 2)
    {
        core.bitop.volatileStore(cast(ushort*)a, cast(ushort)v);
    }
    else static if (T.sizeof == 4)
    {
        core.bitop.volatileStore(cast(uint*)a, cast(uint)v);
    }
    else
    {
        static assert(false, "Size not supported");
    }
}
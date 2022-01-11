module libtind.ds.set;

import core.stdc.string;
import core.stdc.stdio;

import libtind.util;
import libtind.ds.dict;

extern (C) @nogc {
    struct Set(T) {
        Dict!(T, bool) dict;

        void clear() {
            dict.clear();
        }

        bool contains(T val) {
            return val in this;
        }

        void add(T val) {
            dict.set(val, true);
        }

        bool remove(T val) {
            return dict.remove(val);
        }

        bool opBinaryRight(string op)(scope const T key) @nogc nothrow 
                if (op == "in") {
            return (key in dict) != null;
        }

        @property size_t count() {
            return dict.length;
        }
    }
}

@("set-test-1")
unittest {
    Set!int s1;

    // try adding
    s1.add(1);
    s1.add(2);
    s1.add(3);

    // check if values in set
    assert(s1.contains(1));
    assert(s1.contains(2));
    assert(s1.contains(3));
    assert(s1.contains(4) == false);

    // try with "in" syntax
    assert(2 in s1);
    assert(4 !in s1);

    // try removing one
    assert(s1.remove(2));

    // verify count
    assert(s1.count == 2);

    // now clear
    s1.clear();

    // ensure empty
    assert(s1.count == 0);

    // try a new set
    Set!int s2;

    // insert some values with duplicates
    s2.add(1);
    s2.add(2);
    s2.add(2);
    s2.add(3);
    s2.add(4);
    s2.add(5);
    s2.add(5);
    s2.add(5);
    s2.add(5);
    s2.add(6);

    // check count
    assert(s2.count == 6);

    // try removing
    assert(s2.remove(5));

    // check count
    assert(s2.count == 5);

    // try removing again
    assert(s2.remove(5) == false);

    // check count
    assert(s2.count == 5);
}

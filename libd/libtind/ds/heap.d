module libtind.ds.heap;

import core.stdc.string;
import core.stdc.stdio;

import libtind.util;
import libtind.ds.vector;

extern (C) @nogc {
    bool less_than(T)(T a, T b) {
        return a < b;
    }

    bool greater_than(T)(T a, T b) {
        return a > b;
    }

    struct Heap(T) {
        Vector!T vec;
        bool initialized = false;
        // bool function(T, T) compare = &less_than;

        void initialize() {
            vec.clear();
            // insert the [0] into the heap
            vec.push_front(0);
            initialized = true;
        }

        void clear() {
            initialize();
        }

        void add(T val) {
            // init if needed
            if (vec.length == 0)
                initialize();

            vec.push_back(val);
            sift_up(vec.length - 1);
        }

        T remove_at(size_t index) {
            auto min = vec[index];
            vec[index] = vec[vec.length - 1]; // swap with last

            vec.pop_back(); // remove the last (this is our removed el)
            sift_down(index); // percolate down from our swapped
            return min;
        }

        T peek_min() {
            if (vec.length <= 1) { // heap doesn't have a min
                return T.init;
            }
            return vec[1];
        }

        T remove_min() {
            if (vec.length <= 1) { // heap doesn't have a min
                return T.init;
            }
            return remove_at(1);
        }

        void sift_up(size_t index) {
            while (index / 2 > 0) { // while index points to a heap node
                if (vec[index] < vec[index / 2]) { // check if node is less than parent
                    // swap
                    auto tmp = vec[index / 2];
                    vec[index / 2] = vec[index];
                    vec[index] = tmp;
                }
                index /= 2; // move upward
            }
        }

        void sift_down(size_t index) {
            while ((index * 2) < vec.length) {
                auto min_child = compare_child(index);
                if (vec[index] > vec[min_child]) { // check if node is greater than child
                    // swap
                    auto tmp = vec[index];
                    vec[index] = vec[min_child];
                    vec[min_child] = tmp;
                }
                index = min_child;
            }
        }

        size_t compare_child(size_t index) {
            if ((index * 2 + 1) > vec.length - 1) { // check if right child is outside vector bounds
                return index * 2;
            } else {
                if (vec[index * 2] < vec[index * 2 + 1]) { // check if left child is less than right child
                    return index * 2;
                } else {
                    return index * 2 + 1;
                }
            }
        }

        @property size_t count() {
            if (!initialized)
                return 0;

            return vec.length - 1;
        }

        void free() {
            vec.free();
        }
    }
}

@("heap-test-1") unittest {
    import std.stdio;

    Heap!int h1;
    // writefln("%s", h1.vec[]);

    // insert some values
    h1.add(4);
    h1.add(2);
    h1.add(1);
    h1.add(3);

    // check if the heap is valid
    // writefln("%s", h1.vec[]);
    // writefln("%s", h1.peek_min());
    assert(h1.peek_min() == 1);
    assert(h1.remove_min() == 1);
    assert(h1.peek_min() == 2);
    assert(h1.remove_min() == 2);
    assert(h1.peek_min() == 3);
    assert(h1.remove_min() == 3);
    assert(h1.peek_min() == 4);
    assert(h1.remove_min() == 4);

    // check count
    assert(h1.count == 0);
    h1.free();

    // try new heap
    Heap!int h2;

    // insert some random values
    h2.add(13);
    h2.add(14);
    h2.add(21);
    h2.add(7);
    h2.add(3);
    h2.add(11);
    h2.add(15);

    // check if the heap is valid
    assert(h2.peek_min() == 3);
    assert(h2.remove_min() == 3);
    assert(h2.peek_min() == 7);
    assert(h2.remove_min() == 7);
    assert(h2.peek_min() == 11);
    assert(h2.remove_min() == 11);
    assert(h2.peek_min() == 13);
    assert(h2.remove_min() == 13);
    assert(h2.peek_min() == 14);
    assert(h2.remove_min() == 14);
    assert(h2.peek_min() == 15);
    assert(h2.remove_min() == 15);
    assert(h2.peek_min() == 21);
    assert(h2.remove_min() == 21);

    // check count
    assert(h2.count == 0);
    h2.free();

    // try a new heap, this time test dupes
    Heap!int h3;

    // insert some random values
    h3.add(79);
    h3.add(81);
    h3.add(23);
    h3.add(40);
    h3.add(32);
    h3.add(79);
    h3.add(79);
    h3.add(81);

    // check if the heap is valid
    assert(h3.peek_min() == 23);
    assert(h3.remove_min() == 23);
    assert(h3.peek_min() == 32);
    assert(h3.remove_min() == 32);
    assert(h3.peek_min() == 40);
    assert(h3.remove_min() == 40);
    assert(h3.peek_min() == 79);
    assert(h3.remove_min() == 79);
    assert(h3.peek_min() == 79);
    assert(h3.remove_min() == 79);
    assert(h3.peek_min() == 79);
    assert(h3.remove_min() == 79);
    assert(h3.peek_min() == 81);
    assert(h3.remove_min() == 81);
    assert(h3.peek_min() == 81);
    assert(h3.remove_min() == 81);

    // check count
    assert(h3.count == 0);
    h3.free();
}

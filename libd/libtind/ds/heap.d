module libtind.ds.heap;

import core.stdc.string;
import core.stdc.stdio;

import libtind.util;
import libtind.ds.vector;

extern (C) @nogc {
    // bool less_than(T)(T a, T b) {
    //     return a < b;
    // }

    // bool greater_than(T)(T a, T b) {
    //     return a > b;
    // }

    struct Heap(T) {
        Vector!Node vec;
        bool initialized = false;
        // bool function(T, T) compare = &less_than;

        public struct Node {
            int priority; // lower value is higher priority
            T value;
        }

        bool compare(Node a, Node b) {
            return a.priority < b.priority;
        }

        void initialize() {
            vec.clear();
            // insert the [0] into the heap
            vec.push_front(Node.init);
            initialized = true;
        }

        void clear() {
            initialize();
        }

        void add(Node val) {
            // init if needed
            if (vec.length == 0)
                initialize();

            vec.push_back(val);
            sift_up(vec.length - 1);
        }

        Node remove_at(size_t index) {
            auto min = vec[index];
            vec[index] = vec[vec.length - 1]; // swap with last

            vec.pop_back(); // remove the last (this is our removed el)
            sift_down(index); // percolate down from our swapped
            return min;
        }

        Node peek_min() {
            if (!initialized) { // heap doesn't have a min
                return Node.init;
            }
            return vec[1];
        }

        Node remove_min() {
            if (!initialized) { // heap doesn't have a min
                return Node.init;
            }
            return remove_at(1);
        }

        void sift_up(size_t index) {
            while (index / 2 > 0) { // while index points to a heap node
                // if (vec[index] < vec[index / 2]) { // check if node is less than parent
                if (compare(vec[index], vec[index / 2])) { // check if node is less than parent
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
                auto min_child = min_child(index);
                // if (vec[index] > vec[min_child]) { // check if node is greater than child
                if (compare(vec[min_child], vec[index])) { // check if node is greater than child
                    // swap
                    auto tmp = vec[index];
                    vec[index] = vec[min_child];
                    vec[min_child] = tmp;
                }
                index = min_child;
            }
        }

        size_t min_child(size_t index) {
            if ((index * 2 + 1) > vec.length - 1) { // check if right child is outside vector bounds
                return index * 2;
            } else {
                // if (vec[index * 2] < vec[index * 2 + 1]) { // check if left child is less than right child
                if (compare(vec[index * 2], vec[index * 2 + 1])) { // check if left child is less than right child
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
    }
}

alias IntHeap = Heap!int;

@("heap-test-1") unittest {
    import std.stdio;

    IntHeap h1;
    // writefln("%s", h1.vec[]);

    // insert some values
    h1.add(IntHeap.Node(4));
    h1.add(IntHeap.Node(2));
    h1.add(IntHeap.Node(1));
    h1.add(IntHeap.Node(3));

    // check if the heap is valid
    // writefln("%s", h1.vec[]);
    // writefln("%s", h1.peek_min().priority);
    assert(h1.peek_min().priority == 1);
    assert(h1.remove_min().priority == 1);
    assert(h1.peek_min().priority == 2);
    assert(h1.remove_min().priority == 2);
    assert(h1.peek_min().priority == 3);
    assert(h1.remove_min().priority == 3);
    assert(h1.peek_min().priority == 4);
    assert(h1.remove_min().priority == 4);

    // check count
    assert(h1.count == 0);

    // try new heap
    IntHeap h2;

    // insert some random values
    h2.add(IntHeap.Node(13));
    h2.add(IntHeap.Node(14));
    h2.add(IntHeap.Node(21));
    h2.add(IntHeap.Node(7));
    h2.add(IntHeap.Node(3));
    h2.add(IntHeap.Node(11));
    h2.add(IntHeap.Node(15));

    // check if the heap is valid
    assert(h2.peek_min().priority == 3);
    assert(h2.remove_min().priority == 3);
    assert(h2.peek_min().priority == 7);
    assert(h2.remove_min().priority == 7);
    assert(h2.peek_min().priority == 11);
    assert(h2.remove_min().priority == 11);
    assert(h2.peek_min().priority == 13);
    assert(h2.remove_min().priority == 13);
    assert(h2.peek_min().priority == 14);
    assert(h2.remove_min().priority == 14);
    assert(h2.peek_min().priority == 15);
    assert(h2.remove_min().priority == 15);
    assert(h2.peek_min().priority == 21);
    assert(h2.remove_min().priority == 21);

    // check count
    assert(h2.count == 0);

    // try a new heap, this time test dupes
    IntHeap h3;

    // insert some random values
    h3.add(IntHeap.Node(79));
    h3.add(IntHeap.Node(81));
    h3.add(IntHeap.Node(23));
    h3.add(IntHeap.Node(40));
    h3.add(IntHeap.Node(32));
    h3.add(IntHeap.Node(79));
    h3.add(IntHeap.Node(79));
    h3.add(IntHeap.Node(81));

    // check if the heap is valid
    assert(h3.peek_min().priority == 23);
    assert(h3.remove_min().priority == 23);
    assert(h3.peek_min().priority == 32);
    assert(h3.remove_min().priority == 32);
    assert(h3.peek_min().priority == 40);
    assert(h3.remove_min().priority == 40);
    assert(h3.peek_min().priority == 79);
    assert(h3.remove_min().priority == 79);
    assert(h3.peek_min().priority == 79);
    assert(h3.remove_min().priority == 79);
    assert(h3.peek_min().priority == 79);
    assert(h3.remove_min().priority == 79);
    assert(h3.peek_min().priority == 81);
    assert(h3.remove_min().priority == 81);
    assert(h3.peek_min().priority == 81);
    assert(h3.remove_min().priority == 81);

    // check count
    assert(h3.count == 0);
}

@("heap-test-2") unittest {
    // now test with values inside the nodes
    import std.stdio;

    alias StringHeap = Heap!string;
    StringHeap h1;

    // insert some values
    h1.add(StringHeap.Node(4, "four"));
    h1.add(StringHeap.Node(2, "two"));
    h1.add(StringHeap.Node(1, "one"));
    h1.add(StringHeap.Node(3, "three"));

    // check if the heap is valid
    // writefln("%s", h1.vec[]);
    // writefln("%s", h1.peek_min().priority);
    auto peek1 = h1.peek_min();
    assert(peek1.priority == 1);
    assert(peek1.value == "one");
    auto remove1 = h1.remove_min();
    assert(remove1.priority == 1);
    assert(remove1.value == "one");
    auto peek2 = h1.peek_min();
    assert(peek2.priority == 2);
    assert(peek2.value == "two");
}

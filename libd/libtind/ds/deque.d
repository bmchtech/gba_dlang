module libtind.ds.deque;

// import std.stdio;
import core.stdc.string;
import core.stdc.stdio;

import libtind.util;

extern (C) @nogc {
    struct Deque(T) {
        alias NodePtr = Node!T*;
        struct Node(T) {
            T data;
            NodePtr link_fw;
            NodePtr link_bk;
        }

        NodePtr head = null;
        NodePtr tail = null;
        int count = 0;

        NodePtr create_node(T item) {
            NodePtr node = tind_alloc!(Node!T)();

            node.data = item;
            node.link_fw = null;
            node.link_bk = null;
            count++;

            return node;
        }

        void push_front(T item) {
            auto node = create_node(item);

            // insert the node and initialize forward and backward links
            if (!head) {
                head = node;
            } else {
                node.link_fw = head;
                node.link_bk = null;
                head.link_bk = node;
                head = node;
            }
            if (!tail) {
                tail = node;
            }
        }

        void push_back(T item) {
            auto node = create_node(item);
            // writefln("push_back: %d", count);

            // insert the node and initialize forward and backward links
            if (!tail) {
                tail = node;
            } else {
                node.link_fw = null;
                node.link_bk = tail;
                tail.link_fw = node;
                tail = node;
            }
            if (!head) {
                head = node;
            }
        }

        void delete_node(NodePtr node) {
            // insert the node and fix forward and backward links
            // handle fixing the ends if necessary

            if (node == head) {
                head = node.link_fw;
            } else if (node == tail) {
                tail = node.link_bk;
            } else {
                node.link_bk.link_fw = node.link_fw; // fix prev node
                node.link_fw.link_bk = node.link_bk; // fix next node
            }

            // free node
            tind_free(node);
            count--;

            if (count == 0) {
                head = null;
                tail = null;
            }

            // writefln("delete count: %d", count);
        }

        T pop_front() {
            if (!head) {
                return T.init;
            }

            auto node = head;
            auto item = node.data;

            delete_node(node);

            return item;
        }

        T pop_back() {
            if (!tail) {
                return T.init;
            }

            auto node = tail;
            auto item = node.data;

            delete_node(node);

            return item;
        }

        void clear() {
            // writefln("clear: %d", count);
            // writefln("head: %s", head);
            // writefln("tail: %s", tail);

            while (head) {
                delete_node(head);
            }
            tail = null;
        }

        void free() {
            clear();
        }

        ~this() {
            free();
        }
    }
}

@("deque-test-1")
unittest {
    Deque!int d1;

    d1.push_back(1);
    d1.push_back(2);
    d1.push_back(4);
    d1.push_back(8);

    assert(d1.count == 4);

    // try removing one by one

    // clear it
    d1.clear();

    // ensure it's empty
    assert(d1.head == null, "d1.head != null");
    assert(d1.tail == null, "d1.tail != null");
    assert(d1.count == 0, "d1.count != 0");

    d1.free();

    // make a new one
    Deque!int d2;

    // insert some items
    d2.push_back(3);
    d2.push_back(5);
    d2.push_back(7);

    // ensure they're there
    assert(d2.count == 3);

    // try clearing
    d2.clear();

    // ensure it's empty
    assert(d2.head == null);
    assert(d2.count == 0);

    // see if we can insert again
    d2.push_back(9);
    d2.push_back(10);

    // ensure they're there
    assert(d2.count == 2);

    // try pushing front and back
    d2.push_front(1);
    d2.push_back(11);

    // ensure they're there
    assert(d2.count == 4);

    // try popping some
    auto d2p1 = d2.pop_front();
    auto d2p2 = d2.pop_front();
    auto d2p3 = d2.pop_back();

    assert(d2p1 == 1);
    assert(d2p2 == 9);
    assert(d2p3 == 11);

    // clean up
    d2.clear();

    // ensure it's empty
    assert(d2.count == 0);
    assert(d2.head == null);
    assert(d2.tail == null);

    // now try another one
    Deque!int d3;

    // insert some items
    d3.push_back(12);
    d3.push_back(14);
    d3.push_back(16);

    // try removing one by one
    auto d3p1 = d3.pop_front();
    auto d3p3 = d3.pop_back();
    auto d3p2 = d3.pop_front();

    // check values
    assert(d3p1 == 12);
    assert(d3p2 == 14);
    assert(d3p3 == 16);

    // check count
    assert(d3.count == 0);
    assert(d3.head == null);
    assert(d3.tail == null);

    // try popping from empty
    auto d3p4 = d3.pop_front();

    // check values
    assert(d3p4 == int.init);

    // try clearing again
    d3.clear();

    // check count
    assert(d3.count == 0);
    assert(d3.head == null);
    assert(d3.tail == null);
}

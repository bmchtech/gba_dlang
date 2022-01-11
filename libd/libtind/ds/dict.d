/** Simple associative array implementation for D (-betterC)

The author of the original implementation: Martin Nowak

Copyright:
 Copyright (c) 2020, Ferhat Kurtulmuş.

 License:
   $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).

Simplified betterC port of druntime/blob/master/src/rt/aaA.d
*/

module libtind.ds.dict;

version (LDC) {
    version (D_BetterC) {
        pragma(LDC_no_moduleinfo);
    }
}

//import std.experimental.allocator.common : stateSize;

import core.stdc.string;

private enum {
    // grow threshold
    GROW_NUM = 4,
    GROW_DEN = 5,
    // shrink threshold
    SHRINK_NUM = 1,
    SHRINK_DEN = 8,
    // grow factor
    GROW_FAC = 4
}
// growing the AA doubles it's size, so the shrink threshold must be
// smaller than half the grow threshold to have a hysteresis
static assert(GROW_FAC * SHRINK_NUM * GROW_DEN < GROW_NUM * SHRINK_DEN);

private enum {
    // initial load factor (for literals), mean of both thresholds
    INIT_NUM = (GROW_DEN * SHRINK_NUM + GROW_NUM * SHRINK_DEN) / 2,
    INIT_DEN = SHRINK_DEN * GROW_DEN,

    INIT_NUM_BUCKETS = 8,
    // magic hash constants to distinguish empty, deleted, and filled buckets
    HASH_EMPTY = 0,
    HASH_DELETED = 0x1,
    HASH_FILLED_MARK = size_t(1) << 8 * size_t.sizeof - 1
}

private {
    alias hash_t = size_t;

    enum isSomeString(T) = is(immutable T == immutable C[], C) && (is(C == char) || is(C == wchar) || is(
                C == dchar));

    template KeyType(K) {
        alias Key = K;

    @nogc nothrow pure:
        hash_t getHash(scope const Key key) @safe {
            return key.hashOf;
        }

        bool equals(scope const Key k1, scope const Key k2) {
            static if (is(K == const(char)*)) {
                return strlen(k1) == strlen(k2) &&
                    strcmp(k1, k2) == 0;
            } else static if (isSomeString!K) {
                const len = k1.length;
                return len == k2.length && strncmp(k1.ptr, k2.ptr, len) == 0;
            } else {
                return k1 == k2;
            }
        }
    }
}

private {
    /// mallocator code BEGINS

    // based on std.experimental.allocator.mallocator and
    // https://github.com/submada/basic_string/blob/main/src/basic_string/package.d:

    struct Mallocator {
        //import std.experimental.allocator.common : platformAlignment;
        import core.stdc.stdlib : malloc, realloc, free;

        //enum uint alignment = platformAlignment;

        static void[] allocate(size_t bytes) @trusted @nogc nothrow {
            if (!bytes)
                return null;
            auto p = malloc(bytes);
            return p ? p[0 .. bytes] : null;
        }

        static void deallocate(void[] b) @system @nogc nothrow {
            free(b.ptr);
        }

        static bool reallocate(ref void[] b, size_t s) @system @nogc nothrow {
            if (!s) {
                // fuzzy area in the C standard, see http://goo.gl/ZpWeSE
                // so just deallocate and nullify the pointer
                deallocate(b);
                b = null;
                return true;
            }

            auto p = cast(ubyte*) realloc(b.ptr, s);
            if (!p)
                return false;
            b = p[0 .. s];
            return true;
        }

        __gshared static Mallocator instance;
    }

    T[] makeArray(T, Allocator)(auto ref Allocator alloc, size_t length) {
        return cast(T[]) alloc.allocate(length * T.sizeof);
    }

    T* make(T, Allocator)(auto ref Allocator alloc) {
        return cast(T*) alloc.allocate(T.sizeof).ptr;
    }

    void dispose(A, T)(auto ref A alloc, auto ref T[] array) {
        alloc.deallocate(cast(void[]) array);
    }

    void dispose(A, T)(auto ref A alloc, auto ref T* p) {
        alloc.deallocate(p[0 .. 1]);
    }
}

/// mallocator code ENDS

struct Dict(K, V, Allocator = Mallocator) {

    struct Node {
        K key;
        V val;

        alias value = val;
    }

    struct Bucket {
    private pure nothrow @nogc:
        size_t hash;
        Node* entry;
        @property bool empty() const {
            return hash == HASH_EMPTY;
        }

        @property bool deleted() const {
            return hash == HASH_DELETED;
        }

        @property bool filled() const {
            return cast(ptrdiff_t) hash < 0;
        }
    }

    private Bucket[] buckets;

    uint firstUsed;
    uint used;
    uint deleted;

    alias TKey = KeyType!K;

    alias allocator = Allocator.instance;

    @property size_t length() const {
        //assert(used >= deleted);
        return used - deleted;
    }

    private void allocHtable(size_t sz) @nogc nothrow {
        Bucket[] _htable = allocator.makeArray!Bucket(sz);
        _htable[] = Bucket.init;
        buckets = _htable;
    }

    private void initTableIfNeeded() @nogc nothrow {
        if (buckets is null) {
            allocHtable(INIT_NUM_BUCKETS);
            firstUsed = INIT_NUM_BUCKETS;
        }
    }

    @property size_t dim() const {
        return buckets.length;
    }

    @property size_t mask() const {
        return dim - 1;
    }

    inout(Bucket)* findSlotInsert(size_t hash) inout pure nothrow @nogc {
        for (size_t i = hash & mask, j = 1;; ++j) {
            if (!buckets[i].filled)
                return &buckets[i];
            i = (i + j) & mask;
        }
    }

    inout(Bucket)* findSlotLookup(size_t hash, scope const K key) inout nothrow @nogc {
        for (size_t i = hash & mask, j = 1;; ++j) {

            if (buckets[i].hash == hash && TKey.equals(key, buckets[i].entry.key))
                return &buckets[i];

            if (buckets[i].empty)
                return null;
            i = (i + j) & mask;
        }
    }

    void set(scope const K key, scope const V val) @nogc nothrow {
        initTableIfNeeded();

        const keyHash = calcHash(key);

        if (auto p = findSlotLookup(keyHash, key)) {
            p.entry.val = cast(V) val;
            return;
        }

        auto p = findSlotInsert(keyHash);

        if (p.deleted)
            --deleted;

        // check load factor and possibly grow
        else if (++used * GROW_DEN > dim * GROW_NUM) {
            grow();
            p = findSlotInsert(keyHash);
            //assert(p.empty);
        }

        // update search cache and allocate entry
        uint m = cast(uint)(p - buckets.ptr);
        if (m < firstUsed) {
            firstUsed = m;
        }

        p.hash = keyHash;

        if (!p.deleted) {
            Node* newNode = allocator.make!Node();
            newNode.key = key;
            newNode.val = cast(V) val;

            p.entry = newNode;
        } else {
            p.entry.key = key;
            p.entry.val = cast(V) val;
        }
    }

    private size_t calcHash(scope const K pkey) pure @nogc nothrow {
        // highest bit is set to distinguish empty/deleted from filled buckets
        const hash = TKey.getHash(pkey);
        return mix(hash) | HASH_FILLED_MARK;
    }

    void resize(size_t sz) @nogc nothrow {
        auto obuckets = buckets;
        allocHtable(sz);

        foreach (ref b; obuckets[firstUsed .. $]) {
            if (b.filled)
                *findSlotInsert(b.hash) = b;
            if (b.empty || b.deleted) {
                allocator.dispose(b.entry);

                b.entry = null;
            }

        }

        firstUsed = 0;
        used -= deleted;
        deleted = 0;

        allocator.dispose(obuckets.ptr);
    }

    void rehash() @nogc nothrow {
        if (length)
            resize(nextpow2(INIT_DEN * length / INIT_NUM));
    }

    void grow() @nogc nothrow {
        resize(length * SHRINK_DEN < GROW_FAC * dim * SHRINK_NUM ? dim : GROW_FAC * dim);
    }

    void shrink() @nogc nothrow {
        if (dim > INIT_NUM_BUCKETS)
            resize(dim / GROW_FAC);
    }

    bool remove(scope const K key) @nogc nothrow {
        if (!length)
            return false;

        const hash = calcHash(key);
        if (auto p = findSlotLookup(hash, key)) {
            // clear entry
            p.hash = HASH_DELETED;
            // just mark it to be disposed

            ++deleted;
            if (length * SHRINK_DEN < dim * SHRINK_NUM)
                shrink();

            return true;
        }
        return false;
    }

    V get(scope const K key) @nogc nothrow {
        if (auto ret = key in this)
            return *ret;
        return V.init;
    }

    alias opIndex = get;

    void opIndexAssign(scope const V value, scope const K key) @nogc nothrow {
        set(key, value);
    }

    static if (isSomeString!K) {
        @property auto opDispatch(K key)() {
            return opIndex(key);
        }

        @property auto opDispatch(K key)(scope const V value) {
            return opIndexAssign(value, key);
        }
    }

    V* opBinaryRight(string op)(scope const K key) @nogc nothrow if (op == "in") {
        if (!length)
            return null;

        const keyHash = calcHash(key);
        if (auto buck = findSlotLookup(keyHash, key))
            return &buck.entry.val;
        return null;
    }

    /// returning slice must be deallocated like Allocator.dispose(keys);
    // use byKeyValue to avoid extra allocations
    K[] keys() @nogc nothrow {
        K[] ks = allocator.makeArray!K(length);
        size_t j;
        foreach (ref b; buckets[firstUsed .. $]) {
            if (b.filled) {
                ks[j++] = b.entry.key;
            }
        }

        return ks;
    }

    /// returning slice must be deallocated like Allocator.dispose(values);
    // use byKeyValue to avoid extra allocations
    V[] values() @nogc nothrow {
        V[] vals = allocator.makeArray!V(length);
        size_t j;
        foreach (ref b; buckets[firstUsed .. $]) {
            if (b.filled) {
                vals[j++] = b.entry.val;
            }
        }

        return vals;
    }

    void clear() @nogc nothrow { // WIP
        /+ not sure if this works with this port
        import core.stdc.string : memset;
        // clear all data, but don't change bucket array length
        memset(&buckets[firstUsed], 0, (buckets.length - firstUsed) * Bucket.sizeof);
        +/
        // just loop over entire slice
        foreach (ref b; buckets)
            if (b.entry !is null) {
                //core.stdc.stdlib.free(b.entry);
                allocator.dispose(b.entry);
                b.entry = null;
            }
        deleted = used = 0;
        firstUsed = cast(uint) dim;
        buckets[] = Bucket.init;
    }

    private void free() @nogc nothrow {
        foreach (ref b; buckets)
            if (b.entry !is null) {
                //core.stdc.stdlib.free(b.entry);
                allocator.dispose(b.entry);
                b.entry = null;
            }

        //core.stdc.stdlib.free(buckets.ptr);
        allocator.dispose(buckets);
        deleted = used = 0;
        buckets = null;
    }

    ~this() @nogc nothrow {
        free();
    }

    auto copy() @nogc nothrow {
        auto new_buckets = allocator.makeArray!Bucket(buckets.length);
        //cast(Bucket*)malloc(buckets.length * Bucket.sizeof);
        memcpy(new_buckets.ptr, buckets.ptr, buckets.length * Bucket.sizeof);
        typeof(this) newAA;
        newAA.buckets = new_buckets[0 .. buckets.length];
        newAA.firstUsed = firstUsed;
        newAA.used = used;
        newAA.deleted = deleted;
        return newAA;
    }

    // opApply will be deprecated. Use byKeyValue instead
    int opApply(int delegate(DictPair!(K, V)) @nogc nothrow dg) nothrow @nogc {
        if (buckets is null || buckets.length == 0)
            return 0;
        int result = 0;
        foreach (ref b; buckets[firstUsed .. $]) {
            if (!b.filled)
                continue;
            result = dg(DictPair!(K, V)(&b.entry.key, &b.entry.val));
            if (result) {
                break;
            }
        }
        return 0;
    }

    // for GC usages
    // opApply will be deprecated. Use byKeyValue instead
    int opApply(int delegate(DictPair!(K, V)) dg) {
        if (buckets is null || buckets.length == 0)
            return 0;
        int result = 0;
        foreach (ref b; buckets[firstUsed .. $]) {
            if (!b.filled)
                continue;
            result = dg(DictPair!(K, V)(&b.entry.key, &b.entry.val));
            if (result) {
                break;
            }
        }
        return 0;
    }

    private enum RangeType {
        KEYS,
        VALUES,
        BOTH
    }

    struct DictRange(B, alias rangeType) {
        B* bucks;
        size_t len;
        size_t current;

    nothrow @nogc:

        bool empty() {
            if (len == 0)
                return true;
            return false;
        }

        // front must be called first before popFront
        auto front() {
            next();
            static if (rangeType == RangeType.BOTH) {
                auto ret = Node((*bucks)[current].entry.key, (*bucks)[current].entry.val);
            } else static if (rangeType == RangeType.KEYS) {
                auto ret = (*bucks)[current].entry.key;
            } else static if (rangeType == RangeType.VALUES) {
                auto ret = (*bucks)[current].entry.val;
            }

            return ret;
        }

        void popFront() {
            foreach (i, ref b; (*bucks)[current .. $]) {
                if (!b.empty) {
                    --len;
                    ++current;
                    break;
                }
            }
        }

        private void next() {
            while (!(*bucks)[current].filled || (*bucks)[current].empty) {
                current++;
            }
        }
    }

    // The following functions return an InputRange

    auto byKeyValue() nothrow @nogc {
        size_t current = firstUsed;
        auto len = length;

        typeof(buckets)* bucks = &buckets;

        return DictRange!(typeof(buckets), RangeType.BOTH)(bucks, len, current);
    }

    auto byKey() nothrow @nogc {
        size_t current = firstUsed;
        auto len = length;

        typeof(buckets)* bucks = &buckets;

        return DictRange!(typeof(buckets), RangeType.KEYS)(bucks, len, current);
    }

    auto byValue() nothrow @nogc {
        size_t current = firstUsed;
        auto len = length;

        typeof(buckets)* bucks = &buckets;

        return DictRange!(typeof(buckets), RangeType.VALUES)(bucks, len, current);
    }
}

struct DictPair(K, V) {
    K* keyp;
    V* valp;
}

private size_t nextpow2(size_t n) pure nothrow @nogc {
    import core.bitop : bsr;

    if (!n)
        return 1;

    const isPowerOf2 = !((n - 1) & n);
    return 1 << (bsr(n) + !isPowerOf2);
}

private size_t mix(size_t h) @safe pure nothrow @nogc {
    enum m = 0x5bd1e995;
    h ^= h >> 13;
    h *= m;
    h ^= h >> 15;
    return h;
}

@("dict-test-1")
unittest {
    Dict!(string, string) aa;
    scope (exit)
        aa.free;
    aa["foo".idup] = "bar";
    assert(aa.foo == "bar");
}

@nogc:

@("dict-test-2")
unittest {
    import core.stdc.stdio;
    import core.stdc.time;

    clock_t begin = clock();
    {
        Dict!(int, int) aa0;
        scope (exit)
            aa0.free;

        foreach (i; 0 .. 1000_000) {
            aa0[i] = i;
        }

        foreach (i; 2000 .. 1000_000) {
            aa0.remove(i);
        }

        // printf("%d\n", aa0[1000]);
    }
    clock_t end = clock();
    // printf("Elapsed time: %f \n", double(end - begin) / CLOCKS_PER_SEC);

    {
        Dict!(string, string) aa1;
        scope (exit)
            aa1.free;

        aa1["Stevie"] = "Ray Vaughan";
        aa1["Asım Can"] = "Gündüz";
        aa1["Dan"] = "Patlansky";
        aa1["İlter"] = "Kurcala";
        aa1.Ferhat = "Kurtulmuş";

        foreach (pair; aa1) {
            // printf("%s -> %s", (*pair.keyp).ptr, (*pair.valp).ptr);
        }

        assert("Dan" in aa1);
        // if (auto valptr = "Dan" in aa1)
        //     printf("%s exists!!!!\n", (*valptr).ptr);
        // else
        //     printf("does not exist!!!!\n");

        assert(aa1.remove("Ferhat") == true);
        assert(aa1.Ferhat == null);
        assert(aa1.remove("Foe") == false);
        assert(aa1["İlter"] == "Kurcala");

        aa1.rehash();

        // printf("%s\n", aa1["Stevie"].ptr);
        // printf("%s\n", aa1["Asım Can"].ptr);
        // printf("%s\n", aa1.Dan.ptr);
        // printf("%s\n", aa1["Ferhat"].ptr);

        auto keys = aa1.keys;
        scope (exit)
            aa1.allocator.dispose(keys);
        foreach (key; keys)
            // printf("%s -> %s\n", key.ptr, aa1[key].ptr);

        // byKey, byValue, and byKeyValue do not allocate
        // They use the range magic of D
        foreach (pp; aa1.byKeyValue()) {
            // printf("%s: %s\n", pp.key.ptr, pp.value.ptr);

        }

        struct Guitar {
            string brand;
        }

        Dict!(int, Guitar) guitars;
        scope (exit)
            guitars.free;

        guitars[0] = Guitar("Fender");
        guitars[3] = Guitar("Gibson");
        guitars[356] = Guitar("Stagg");

        assert(guitars[3].brand == "Gibson");

        // printf("%s\n", guitars[356].brand.ptr);

        assert(3 in guitars);
        // if (auto valPtr = 3 in guitars)
        //     printf("%s\n", (*valPtr).brand.ptr);
    }
}

@("dict-test-3")
unittest {
    Dict!(string, int) aa;
    scope (exit)
        aa.free;
    aa.foo = 1;
    aa.bar = 0;
    assert("foo" in aa);
    assert(aa.foo == 1);

    aa.clear;
    assert("foo" !in aa);

    aa.bar = 2;
    assert("bar" in aa);
    assert(aa.bar == 2);
}

@("dict-test-4")
// Test "in" works for AA without allocated storage.
unittest {
    Dict!(int, int) emptyMap;
    assert(0 !in emptyMap);
}

@("dict-test-5")
// Try to force a memory leak - issue #5
unittest {
    struct S {
        int x, y;
        string txt;
    }

    Dict!(int, S) aas;
    scope (exit)
        aas.free;

    for (int i = 1024; i < 2048; i++) {
        aas[i] = S(i, i * 2, "caca\0");
    }
    aas[100] = S(10, 20, "caca\0");

    import core.stdc.stdio;

    // printf(".x=%d .y%d %s\n", aas[100].x, aas[100].y, aas[100].txt.ptr);

    for (int i = 1024; i < 2048; i++) {
        aas.remove(i);
    }
}

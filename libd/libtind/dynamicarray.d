module libtind.dynamicarray;

@nogc nothrow @safe:

struct DynamicArray(T) {
	import core.stdc.stdlib : realloc, free;

	T* ptr;
	size_t length;
	private size_t _capacity;

	struct Range {
		DynamicArray!(T)* ptr;

		size_t low;
		size_t high;

		@property bool empty() const {
			return this.low == this.high;
		}

		@property size_t length() const {
			return this.high - this.low;
		}

		@property ref T front() {
			return (*ptr)[this.low];
		}

		@property ref T back() {
			return (*ptr)[this.high - 1];
		}

		ref T opIndex(size_t idx) {
			return (*ptr)[this.low + idx];
		}
	}

	@disable this(this) {
	}

	~this() {
		if(this.ptr) {
			() @trusted { free(cast(void*)ptr); }();
			this.length = 0;
			this._capacity = 0;
		}
	}

	@property bool empty() const {
		return this.length == 0;
	}

	@property size_t opDollar() const {
		return this.length;
	}

	@property size_t capacity() const {
		return this._capacity;
	}

	void assureCapacity(size_t cap) {
		if(cap > this.length) {
			this._capacity = cap;
			() @trusted {
				this.ptr = cast(T*)realloc(this.ptr, T.sizeof * this._capacity);
			}();
			assert(this.ptr);
		}
	}

	private void assureCapacity() {
		if(this.length == this._capacity) {
			this._capacity = this._capacity == 0 ? 10 : this._capacity * 2;
			this.assureCapacity(this._capacity);
		}
	}

	void insertBack(T t) {
		this.assureCapacity();
		() @trusted { *(this.ptr + this.length) = t; }();
		++this.length;
	}

	void removeBack() {
		--this.length;
	}

	void insert(const size_t idx, T t) @trusted {
		assert(idx < this.length);
		this.assureCapacity();
		for(size_t i = this.length; i > idx; --i) {
			*(this.ptr + i) = *(this.ptr + i - 1);
		}
		*(this.ptr + idx) = t;
		this.length++;
	}

	ref T opIndex(size_t idx) @trusted {
		assert(idx < this.length);
		return *(this.ptr + idx);
	}

	@property ref T front() {
		return *(this.ptr);
	}

	@property ref T back() @trusted {
		return *(this.ptr + (this.length - 1));
	}

	auto opSlice() {
		return Range(&this, 0, this.length);
	}

	auto opSlice(size_t low, size_t high) {
		return Range(&this, low, high);
	}
}

unittest {
	DynamicArray!int a;
	assert(a.empty);
	assert(a.length == 0);
}

unittest {
	DynamicArray!int a;
	auto r = a[];
	assert(r.empty);
	assert(r.length == 0);
}

unittest {
	DynamicArray!int a;
	a.insertBack(1);
	assert(a.capacity == 10);
	assert(a.length == 1);
	assert(a[0] == 1);
	assert(a.front == 1);
	assert(a.back == 1);

	a.removeBack();
	assert(a.capacity == 10);
	assert(a.length == 0);
}

unittest {
	const upTo = 100;
	DynamicArray!int a;
	foreach(it; 0 .. upTo) {
		a.insertBack(it);
		assert(a.front == 0);
		assert(a.back == it);
		foreach(jdx; 0 .. it) {
			assert(a[jdx] == jdx);
		}

		auto r = a[];
		assert(r.front == 0);
		assert(r.back == it);
		assert(r.length == it + 1);

		foreach(idx; 0 .. it) {
			assert(r[idx] == idx);
		}

		auto s = a[0 .. $];
		assert(s.front == 0);
		assert(s.back == it);
		assert(s.length == it + 1);

		foreach(idx; 0 .. it) {
			assert(s[idx] == idx);
		}
	}

	foreach(it; 0 .. upTo) {
		long oldSize = a.length;
		a.removeBack();
		long newSize = a.length;
		--oldSize;
		assert(newSize == oldSize);
	}
}

unittest {
	DynamicArray!int a;
	foreach(it; [0, 1, 2, 4, 5, 6, 7, 8, 9]) {
		a.insertBack(it);
	}
	a.insert(3, 3);
	foreach(it; [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]) {
		assert(a[it] == it);
	}
	a.insert(0, -1);
	foreach(it; [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) {
		assert(a[it] == it - 1);
	}
}

unittest {
	DynamicArray!int a;
	DynamicArray!int b;
	static assert(!__traits(compiles, b = a));
}

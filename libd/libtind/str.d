module libtind.str;

version(WASM) {
	void* realloc(void*, size_t) nothrow @safe pure;
	void free(void*) nothrow @safe pure;
} else {
	import core.stdc.stdlib : realloc, free;
}

@safe:
struct String {
	struct Payload {
		char* ptr;
		long refCnt;
		size_t capacity;
	}

	struct StringPayloadHandler {
		static Payload* make() @trusted {
			Payload* pl;
			pl = cast(Payload*)realloc(pl, Payload.sizeof);
			pl.ptr = null;
			pl.capacity = 0;
			pl.refCnt = 1;

			return pl;
		}

		static void allocate(Payload* pl, in size_t s) @trusted {
			assert(s != 0);
			if(s >= pl.capacity) {
				pl.ptr = cast(char*)realloc(pl.ptr, s * char.sizeof);
				pl.capacity = s;
			}
		}

		static void deallocate(Payload* pl) @trusted {
			realloc(pl.ptr, 0);
			pl.capacity = 0;
			realloc(pl, 0);
		}

		static void incrementRefCnt(Payload* pl) {
			if(pl !is null) {
				++(pl.refCnt);
			}
		}

		static void decrementRefCnt(Payload* pl) {
			if(pl !is null) {
				--(pl.refCnt);
				if(pl.refCnt == 0) {
					StringPayloadHandler.deallocate(pl);
				}
			}
		}
	}

	this(string s) {
		this.assign(s);
	}

	this(String n) {
		this.assign(n);
	}

	this(const String n) @trusted {
		this.assign(cast(string)n.storePtr()[0 .. n.length]);
	}

	this(this) {
		if(this.large !is null) {
			StringPayloadHandler.incrementRefCnt(this.large);
		}
	}

	~this() @trusted {
		if(this.large !is null) {
			StringPayloadHandler.decrementRefCnt(cast(Payload*)this.large);
		}
	}


	private void assign(string input) @trusted {
		if(input.length > SmallSize) {
			this.allocate(input.length);
		}

		this.storePtr()[0 .. input.length] = input;
		this.len = input.length;
	}

	private void assign(String n) @trusted {
		if(this.large !is null) {
			StringPayloadHandler.decrementRefCnt(this.large);
		}

		if(n.large !is null) {
			this.large = n.large;
			StringPayloadHandler.incrementRefCnt(this.large);
		} else {
			this.small = n.small;
		}

		this.offset = n.offset;
		this.len = n.length;
	}

	private void allocate(const size_t newLen) @trusted {
		if(newLen > SmallSize) {
			if(this.large is null) {
				this.large = StringPayloadHandler.make();
			}
			StringPayloadHandler.allocate(this.large, newLen);
		}
	}

	private bool isSmall() const nothrow {
		return this.large is null;
	}

	private char* storePtr() return @trusted {
		if(this.isSmall()) {
			return this.small.ptr;
		} else {
			return this.large.ptr;
		}
	}

	private const(char)* storePtr() return const @trusted {
		if(this.isSmall()) {
			return this.small.ptr;
		} else {
			return this.large.ptr;
		}
	}

	private void moveToFront() {
 		if(this.offset > 0) {
			immutable len = this.length;
			if(this.isSmall()) {
				for(int i = 0; i < len; ++i) {
					this.small[i] = this.small[this.offset + i];
				}
			} else {
				for(int i = 0; i < len; ++i) {
					(() @trusted =>
					this.large.ptr[i] = this.large.ptr[this.offset + i]
					)();
				}
			}
			this.offset = 0;
			this.len = len;
		}
	}

	private char[] largePtr(in size_t low, in size_t high) @trusted {
		return this.large.ptr[low .. high];
	}

	void opAssign(inout(char)[] n) {
		if(this.isSmall() && n.length < SmallSize) {
			this.small[0 .. n.length] = n;
		} else {
			if(this.large is null || this.large.refCnt > 1) {
				this.large = StringPayloadHandler.make();
			}

			StringPayloadHandler.allocate(this.large, n.length);
			this.largePtr(0, n.length)[] = n;
		}

		this.len = n.length;
		this.offset = 0;
	}

	void opAssign(typeof(this) n) {
		this.assign(n);
	}

	// properties

	@property bool empty() const nothrow {
		return this.offset == this.len;
	}

	@property size_t length() const nothrow {
		return cast(size_t)(this.len - this.offset);
	}

	bool opEquals(T)(T other) const
			if(is(T == string) || is(T == String) || is(T == const(String)))
	{
		if(this.length == other.length) {
			for(size_t i = 0; i < this.length; ++i) {
				if(this[i] != other[i]) {
					return false;
				}
			}

			return true;
		} else {
			return false;
		}
	}

	@property char front() const @trusted {
		assert(!this.empty);
		return this.storePtr()[this.offset .. this.len][0];
	}

	@property char back() const @trusted {
		assert(!this.empty);
		return this.storePtr()[this.offset .. this.len][$ - 1];
	}

	@property char opIndex(const size_t idx) const @trusted {
		assert(!this.empty);
		assert(idx < this.len - this.offset);

		return this.storePtr()[this.offset .. this.len][idx];
	}

	typeof(this) opSlice() {
		return this;
	}

	typeof(this) opSlice(in size_t low, in size_t high) @trusted {
		//assert(low <= high);
		//assert(high < this.length);

		if(this.isSmall()) {
			return String(
				cast(immutable(char)[])this.small[
					this.offset + low ..  this.offset + high
				]
			);
		} else {
			auto ret = String(this);
			ret.offset += low;
			ret.len = this.offset + high;
			return ret;
		}
	}

	void popFront() {
		const auto l = stride(this.isSmall()
			? this.small[this.offset .. this.len]
			: this.largePtr(this.offset, this.len));

		assert(!l.isNull);
		this.offset += l.get(0U);
	}

	void popBack() {
		const auto l = strideBack(this.isSmall()
			? this.small[this.offset .. this.len]
			: this.largePtr(this.offset, this.len));

		assert(!l.isNull);
		this.len -= l.get(0U);
	}

	@property String dup() const {
		return String(this);
	}

	/// This will malloc the string and leak in betterC
	@property string idup() const @trusted {
		char* p;
		p = cast(char*)realloc(p, (this.length + 1) * char.sizeof);
		foreach(idx; 0 .. this.length) {
			p[idx] = this[idx];
		}
		p[this.length] = '\0';
		return cast(string)p[0 .. this.length];
	}

	int opCmp(ref const(String) other) const {
    	immutable len = this.length <= other.length
			? this.length
			: other.length;

		foreach (const u; 0 .. len) {
			if(this[u] != other[u]) {
				return this[u] > other[u] ? 1 : -1;
			}
		}
    	return this.length < other.length
			? -1
			: (this.length > other.length);
	}

	enum SmallSize = 16;
	ptrdiff_t offset;
	ptrdiff_t len;
	Payload* large;
	char[SmallSize] small;
}

import libtind.nullable;

Nullable!uint stride(inout(char)[] str) {
	return stride(str, 0);
}

Nullable!uint stride(inout(char)[] str, size_t index) {
	assert(index < str.length, "Past the end of the UTF-8 sequence");
	immutable c = str[index];

	if (c < 0x80)
		return Nullable!uint(1);
	else
		return strideImpl(c, index);
}

private Nullable!uint strideImpl(char c, size_t index) @safe pure nothrow
in { assert(c & 0x80); }
do
{
	import core.bitop : bsr;
	immutable msbs = 7 - bsr((~uint(c)) & 0xFF);
	if (c == 0xFF || msbs < 2 || msbs > 4) {
		return Nullable!(uint).init;
	}
	return Nullable!uint(msbs);
}

Nullable!uint strideBack(inout(char)[] str) {
	return strideBack(str, str.length - 1);
}

Nullable!uint strideBack(inout(char)[] str , size_t index) {
	assert(index <= str.length, "Past the end of the UTF-8 sequence");
	assert(index > 0, "Not the end of the UTF-8 sequence");

	if ((str[index-1] & 0b1100_0000) != 0b1000_0000)
		return typeof(return)(1);

	if (index >= 4) { //single verification for most common case
		foreach (i; 2 .. 5) {
			if((str[index-i] & 0b1100_0000) != 0b1000_0000) {
				return typeof(return)(i);
			}
		}
	} else {
		foreach(i; 2 .. 4) {
			if(index >= i && (str[index-i] & 0b1100_0000) != 0b1000_0000) {
				return typeof(return)(i);
			}
		}
	}
	return Nullable!(uint).init;
}

unittest {
	string hw = "Hello World";
	auto s = String(hw);
	assert(s.length == hw.length);
}

private @property bool empty(string s) {
	return s.length == 0;
}

private @property char front(string s) {
	assert(!s.empty);
	return s[0];
}

private @property char back(string s) {
	assert(!s.empty);
	return s[$ - 1];
}

private void popFront(ref string s) {
	Nullable!uint l = stride(s);
	s = s[l.get(0U) .. $];
}

private void popBack(ref string s) {
	Nullable!uint l = strideBack(s);
	s = s[0 .. $ - l.get(0U)];
}

unittest {
	auto s = String("Hello World");
}

unittest {
	const a = String("Hello World");
	const b = String("hello World");
	assert(a.opCmp(b) == -1);
	assert(b.opCmp(a) == 1);
	assert(a.opCmp(a) == 0);
	assert(b.opCmp(b) == 0);
}

unittest {
	const a = String("Hello Worl");
	const b = String("hello World");
	assert(a.opCmp(b) == -1);
	assert(b.opCmp(a) == 1);
	assert(a.opCmp(a) == 0);
	assert(b.opCmp(b) == 0);
}

unittest {
	const a = String("Hello Worl");
	const b = String("hello World");

	assert(a == a);
	assert(a != b);
	assert(b != a);
}

unittest {
	const a = String("Hello World");
	const b = String("Hello Worlz");

	assert(a == a);
	assert(b == b);
	assert(a != b);
	assert(b != a);
	assert(a.opCmp(b) == -1);
	assert(b.opCmp(a) == 1);
	assert(a.opCmp(a) == 0);
	assert(b.opCmp(b) == 0);
}

unittest {
	import core.stdc.stdio;
	enum string[] strs = ["","ABC", "HellWorld", "", "Foobar",
		"HellWorldHellWorldHellWorldHellWorldHellWorldHellWorldHellWorldHellWorld",
		"ABCD", "Hello", "HellWorldHellWorld", "ölleä",
		"hello\U00010143\u0100\U00010143", "£$€¥", "öhelloöö"
	];

	foreach(idx, strL; strs) {
		auto str = strL;
		auto s = String(str);

		assert(s.length == str.length);
		assert(s.empty == str.empty);
		assert(s == str);

		auto istr = s.idup();
		assert(str == istr);
		() @trusted {
			free(cast(void*)istr.ptr);
		}();

		foreach(it; strs) {
			auto cmpS = cast(string)(it);
			auto itStr = String(cmpS);

			if(cmpS == str) {
				assert(s == cmpS);
				assert(s == itStr);
			} else {
				assert(s != cmpS);
				assert(s != itStr);
			}
		}

		if(s.empty) { // if str is empty we do not need to test access
			continue; //methods
		}

		assert(s.front == str.front);
		assert(s.back == str.back);
		assert(s[0] == str[0]);
		for(size_t i = 0; i < str.length; ++i) {
			assert(str[i] == s[i]);
		}

		for(size_t it = 0; it < str.length; ++it) {
			for(size_t jt = it; jt < str.length; ++jt) {
				auto ss = s[it .. jt];
				auto strc = str[it .. jt];

				assert(ss.length == strc.length);
				assert(ss.empty == strc.empty);

				for(size_t k = 0; k < ss.length; ++k) {
					assert(ss[k] == strc[k]);
				}
			}
		}

		String t;
		assert(t.empty);

		t = str;
		assert(s == t);
		assert(!t.empty);
		assert(t.front == str.front);
		assert(t.back == str.back);
		assert(t[0] == str[0]);
		assert(t.length == str.length);

		auto tdup = t.dup;
		assert(!tdup.empty);
		assert(tdup.front == str.front);
		assert(tdup.back == str.back);
		assert(tdup[0] == str[0]);
		assert(tdup.length == str.length);

		istr = t.idup();
		assert(str == istr);
		() @trusted {
			free(cast(void*)istr.ptr);
		}();

		if(tdup.large !is null) {
			assert(tdup.large.refCnt == 1);
		}

		s = t;
		assert(!s.empty);
		assert(s.front == str.front);
		assert(s.back == str.back);
		assert(s[0] == str[0]);
		assert(s.length == str.length);

		auto r = String(s);
		assert(!r.empty);
		assert(r.front == str.front);
		assert(r.back == str.back);
		assert(r[0] == str[0]);
		assert(r.length == str.length);

		auto g = r[];
		assert(!g.empty);
		assert(g.front == str.front);
		assert(g.back == str.back);
		assert(g[0] == str[0]);
		assert(g.length == str.length);

		auto strC = str;
		auto strC2 = str;
		assert(!strC.empty);
		assert(!strC2.empty);

		r.popFront();
		str.popFront();
		assert(str.front == r.front);
		assert(s != r);

		r.popBack();
		str.popBack();
		assert(str.back == r.back);
		assert(str.front == r.front);

		assert(!strC.empty);
		assert(!s.empty);
		while(!strC.empty && !s.empty) {
			assert(strC.front == s.front);
			assert(strC.back == s.back);
			assert(strC.length == s.length);
			for(size_t i = 0; i < strC.length; ++i) {
				assert(strC[i] == s[i]);
			}

			strC.popFront();
			s.popFront();
		}

		assert(strC.empty);
		assert(s.empty);

		assert(!strC2.empty);
		assert(!t.empty);
		while(!strC2.empty && !t.empty) {
			assert(strC2.front == t.front);
			assert(strC2.back == t.back);
			assert(strC2.length == t.length);
			for(size_t i = 0; i < strC2.length; ++i) {
				assert(strC2[i] == t[i]);
			}

			strC2.popFront();
			t.popFront();
			string idup2 = t.idup;
			assert(t == idup2);
			assert(t == strC2, t.idup);
			() @trusted {
				free(cast(void*)idup2.ptr);
			}();

			t.moveToFront();
			idup2 = t.idup;
			assert(t == idup2);
			assert(t == strC2, t.idup);

			() @trusted {
				free(cast(void*)idup2.ptr);
			}();
		}

		assert(strC2.empty);
		assert(t.empty);
	}
}

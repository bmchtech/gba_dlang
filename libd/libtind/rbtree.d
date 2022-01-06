module libtind.rbtree;

import libtind.functional : less, equal;
version(WASM) {
} else {
	import core.stdc.stdio;
}

@nogc nothrow @safe:

struct Iterator(T) {
@nogc nothrow @safe:
	private Node!(T)* current;

	this(Node!(T)* current) {
		this.current = current;
	}

	void opUnary(string s)() if(s == "++") { increment(); }
	void opUnary(string s)() if(s == "--") { decrement(); }
	ref T opUnary(string s)() if(s == "*") { return getData(); }

	void increment() {
		Node!(T)* y;
		if(null !is (y = this.current.link[true])) {
			while(y.link[false] !is null) {
				y = y.link[false];
			}
			this.current = y;
		} else {
			y = this.current.parent;
			while(y !is null && this.current is y.link[true]) {
				this.current = y;
				y = y.parent;
			}
			this.current = y;
		}
	}

	ref T getData() {
		return this.current.getData();
	}

	void decrement() {
		Node!(T)* y;
		if(null !is (y = this.current.link[false])) {
			while(y.link[true] !is null) {
				y = y.link[true];
			}
			this.current = y;
		} else {
			y = this.current.parent;
			while(y !is null && this.current is y.link[false]) {
				this.current = y;
				y = y.parent;
			}
			this.current = y;
		}
	}

	bool isValid() const {
		return this.current !is null;
	}
}

struct Node(T) {
@nogc nothrow @safe:
	T data;
	bool red;

	Node!(T)*[2] link;
	Node!(T)* parent;

	alias getData this;

	ref T getData() {
		return this.data;
	}

	bool validate(bool root, const Node!(T)* par = null) const {
		if(!root) {
			if(this.parent is null) {
				/*() @trusted {
				printf("%s %d %lu\n", __FILE__.ptr,__LINE__,
						cast(ulong)": parent is null".ptr);
				}();
				*/
				return false;
			}
			if(this.parent !is par) {
				/*() @trusted {
				printf("%s %d %lu\n", __FILE__.ptr,__LINE__,
						cast(ulong)": parent is wrong".ptr);
				}();
				*/
				return false;
			}
		}
		bool left = true;
		bool right = true;
		if(this.link[0] !is null) {
			assert(this.link[0].parent is &this);
			left = this.link[0].validate(false, &this);
		}
		if(this.link[1] !is null) {
			assert(this.link[1].parent is &this);
			right = this.link[1].validate(false, &this);
		}
		return left && right;
	}

	void print(int i) {
		version(WASM) {
		} else {
		foreach(it; 0 .. i) {
			() @trusted {
			printf("  ");
			}();
		}
		() @trusted {
		printf("%lx %d %lx\n", cast(size_t)&this, this.red,
				cast(size_t)this.parent);
		}();
		if(this.link[0] !is null) {
			this.link[0].print(i + 1);
		}
		if(this.link[1] !is null) {
			this.link[1].print(i + 1);
		}
		}
	}
}

struct RBTree(T, alias ls = less, alias eq = equal) {
@nogc nothrow @safe:
	version(WASM) {
		void* malloc(size_t);
		void free(void*);
	} else {
		import core.stdc.stdlib : malloc, free;
	}

	Node!(T)* newNode(T data) {
		Node!(T)* ret = newNode();
		ret.data = data;
		return ret;
	}

	Node!(T)* newNode() {
		Node!T* ret =
			() @trusted { return cast(Node!T*)malloc(Node!(T).sizeof); }();
		ret.red = true;
		ret.parent = null;
		ret.link[0] = null;
		ret.link[1] = null;
		return ret;
	}

	void freeNode(Node!(T)* node) {
		if(node !is null) {
			() @trusted { free(cast(void*)node); }();
		}
	}

	private static bool isRed(const Node!(T)* n) {
		return n !is null && n.red;
	}

	private static Node!(T)* singleRotate(Node!(T)* node, bool dir) {
		Node!(T)* save = node.link[!dir];
		node.link[!dir] = save.link[dir];
		if(node.link[!dir] !is null) {
			node.link[!dir].parent = node;
		}
		save.link[dir] = node;
		if(save.link[dir] !is null) {
			save.link[dir].parent = save;
		}
		node.red = true;
		save.red = false;
		return save;
	}

	private static Node!(T)* doubleRotate(Node!(T)* node, bool dir) {
		node.link[!dir] = singleRotate(node.link[!dir], !dir);
		if(node.link[!dir] !is null) {
			node.link[!dir].parent = node;
		}
		return singleRotate(node, dir);
	}

	private static int validate(Node!(T)* node, Node!(T)* parent) {
		version(WASM) {
			return 0;
		} else {
		if(node is null) {
			return 1;
		} else {
			if(node.parent !is parent) {
				() @trusted {
				printf("parent violation %d %d\n", node.parent is null,
					parent is null);
				}();
			}
			if(node.link[0] !is null) {
				() @trusted {
				if(node.link[0].parent !is node) {
					printf("parent violation link wrong\n");
				}
				}();
			}
			if(node.link[1] !is null) {
				() @trusted {
				if(node.link[1].parent !is node) {
					printf("parent violation link wrong\n");
				}
				}();
			}

			Node!(T)* ln = node.link[0];
			Node!(T)* rn = node.link[1];

			if(isRed(node)) {
				if(isRed(ln) || isRed(rn)) {
					() @trusted {
						printf("Red violation\n");
					}();
					return 0;
				}
			}
			int lh = validate(ln, node);
			int rh = validate(rn, node);

			if((ln !is null && ln.data >= node.data)
					|| (rn !is null && rn.data <= node.data))
			{
				() @trusted {
				printf("Binary tree violation\n");
				}();
				return 0;
			}

			if(lh != 0 && rh != 0 && lh != rh) {
				() @trusted {
				printf("Black violation %d %d\n", lh, rh);
				}();
				return 0;
			}

			if(lh != 0 && rh != 0) {
				return isRed(node) ? lh : lh +1;
			} else {
				return 0;
			}
		}
		}
	}

	bool validate() {
		return validate(this.root, null) != 0
			&& this.root ? this.root.validate(true) : true;
	}

	Node!(T)* search(T data) {
		return search(this.root, data);
	}

	private Node!(T)* search(Node!(T)* node ,T data) {
		if(node is null) {
			return null;
		} else if(eq(node.data, data)) {
			return node;
		} else {
			bool dir = ls(node.data, data);
			return this.search(node.link[dir], data);
		}
	}

	bool remove(ref Iterator!(T) it, bool dir = true) {
		if(it.isValid()) {
			T value = *it;
			if(dir)
				it++;
			else
				it--;
			return this.remove(value);
		} else {
			return false;
		}
	}

	bool remove(T data) {
		bool done = false;
		bool succes = false;
		this.root = removeR(this.root, data, done, succes);
		if(this.root !is null) {
			this.root.red = false;
			this.root.parent = null;
		}
		if(succes) {
			this.size--;
		}
		return succes;
	}

	private Node!(T)* removeR(Node!(T)* node, T data, ref bool done,
			ref bool succes) {
		if(node is null) {
			done = true;
		} else {
			bool dir;
			if(eq(node.data, data)) {
				succes = true;
				if(node.link[0] is null || node.link[1] is null) {
					Node!(T)* save = node.link[node.link[0] is null];

					if(isRed(node)) {
						done = true;
					} else if(isRed(save)) {
						save.red = false;
						done = true;
					}
					freeNode(node);
					return save;
				} else {
					Node!(T)* heir = node.link[0];
					while(heir.link[1] !is null) {
						heir = heir.link[1];
					}

					node.data = heir.data;
					data = heir.data;
				}
			}
			dir = ls(node.data, data);
			node.link[dir] = removeR(node.link[dir], data, done, succes);
			if(node.link[dir] !is null) {
				node.link[dir].parent = node;
			}

			if(!done) {
				node = removeBalance(node, dir, done);
			}
		}
		return node;
	}

	private Node!(T)* removeBalance(Node!(T)* node, bool dir, ref bool done) {
		Node!(T)* p = node;
		Node!(T)* s = node.link[!dir];
		if(isRed(s)) {
			node = singleRotate(node, dir);
			s = p.link[!dir];
		}

		if(s !is null) {
			if(!isRed(s.link[0]) && !isRed(s.link[1])) {
				if(isRed(p)) {
					done = true;
				}
				p.red = false;
				s.red = true;
			} else {
				bool save = p.red;
				bool newRoot = eq(node, p);

				if(isRed(s.link[!dir])) {
					p = singleRotate(p, dir);
				} else {
					p = doubleRotate(p, dir);
				}

				p.red = save;
				p.link[0].red = false;
				p.link[1].red = false;

				if(newRoot) {
					node = p;
				} else {
					node.link[dir] = p;
					if(node.link[dir] !is null) {
						node.link[dir].parent = node;
					}
				}

				done = true;
			}
		}
		return node;
	}

	bool insert(T data) {
		bool success;
		this.root = insertImpl(this.root, data, success);
		this.root.parent = null;
		this.root.red = false;
		return success;
	}

	private Node!(T)* insertImpl(Node!(T)* root, T data, ref bool success) {
		if(root is null) {
			root = newNode(data);
			this.size++;
			success = true;
		} else if(data != root.data) {
			bool dir = ls(root.data, data);

			root.link[dir] = insertImpl(root.link[dir], data, success);
			root.link[dir].parent = root;

			if(isRed(root.link[dir])) {
				if(isRed(root.link[!dir])) {
					/* Case 1 */
					root.red = true;
					root.link[0].red = false;
					root.link[1].red = false;
				} else {
					/* Cases 2 & 3 */
					if(isRed(root.link[dir].link[dir])) {
						root = singleRotate( root, !dir );
					} else if(isRed(root.link[dir].link[!dir])) {
						root = doubleRotate (root, !dir);
					}
				}
			}
		}

		return root;
	}

	@property size_t length() const {
		return this.size;
	}

	Iterator!(T) begin() {
		Node!(T)* be = this.root;
		if(be is null)
			return Iterator!(T)(null);
		int count = 0;
		while(be.link[0] !is null) {
			be = be.link[0];
			count++;
		}
		auto it = Iterator!(T)(be);
		return it;
	}

	Iterator!(T) end() {
		Node!(T)* end = this.root;
		if(end is null)
			return Iterator!(T)(null);
		while(end.link[1] !is null)
			end = end.link[1];
		return Iterator!(T)(end);
	}

	Iterator!(T) searchIt(T data) {
		return Iterator!(T)(cast(Node!(T)*)search(data));
	}

	bool isEmpty() const {
	    return this.root is null;
	}

	void print() {
		if(this.root !is null) {
			this.root.print(0);
		}
	}

	private size_t size;
	private Node!(T)* root;
}


bool compare(T)(RBTree!(T) t, T[T] s) {
	foreach(it; s.values) {
		if(t.search(it) is null) {
			printf("%d %s\n", __LINE__, " size wrong".ptr);
			return false;
		}
	}
	return true;
}

unittest {
	immutable int[41] a = [2811, 1089, 3909, 3593, 1980, 2863, 676, 258, 2499, 3147,
	3321, 3532, 3009, 1526, 2474, 1609, 518, 1451, 796, 2147, 56, 414, 3740,
	2476, 3297, 487, 1397, 973, 2287, 2516, 543, 3784, 916, 2642, 312, 1130,
	756, 210, 170, 3510, 987];
	immutable int[11] b = [0,1,2,3,4,5,6,7,8,9,10];
	immutable int[11] c = [10,9,8,7,6,5,4,3,2,1,0];
	immutable int[12] d = [10,9,8,7,6,5,4,3,2,1,0,11];
	immutable int[12] e = [0,1,2,3,4,5,6,7,8,9,10,-1];
	immutable int[10] f = [11,1,2,3,4,5,6,7,8,0];
	test1(a[]);
	test1(b[]);
	test1(c[]);
	test1(d[]);
	test1(e[]);
	test1(f[]);
	test2(a[]);
}

private void test1(scope immutable int[] lots) {
	RBTree!(int) a;
	foreach(idx, it; lots) {
		assert(a.insert(it));
		auto iter = a.searchIt(it);
		assert(iter.isValid());
		assert(iter.getData() == it);
		assert(a.length == idx+1);
		foreach(jt; lots[0..idx+1]) {
			assert(a.search(jt));
		}
		assert(a.validate());
		foreach(jt; lots[0 .. idx]) {
			assert(a.search(jt) !is null);
		}

		Iterator!(int) ait = a.begin();
		size_t cnt = 0;
		while(ait.isValid()) {
			assert(a.search(*ait));
			ait++;
			cnt++;
		}
		assert(cnt == a.length);

		ait = a.end();
		cnt = 0;
		while(ait.isValid()) {
			assert(a.search(*ait));
			ait--;
			cnt++;
		}
		assert(cnt == a.length);

	}
	//writeln(__LINE__);
	foreach(idx, it; lots) {
		assert(a.remove(it));
		assert(a.validate());
		foreach(jt; lots[0..idx+1]) {
			assert(!a.search(jt));
		}
		foreach(jt; lots[idx+1..$]) {
			assert(a.search(jt));
		}
		Iterator!(int) ait = a.begin();
		size_t cnt = 0;
		while(ait.isValid()) {
			assert(a.search(*ait));
			ait++;
			cnt++;
		}
		assert(cnt == a.length);

		ait = a.end();
		cnt = 0;
		while(ait.isValid()) {
			assert(a.search(*ait));
			ait--;
			cnt++;
		}
		assert(cnt == a.length);
	}
	assert(a.length == 0);
	//writeln(__LINE__);
}

private void test2(scope immutable int[] lot) {
	for(int i = 0; i < lot.length; i++) {
		RBTree!(int) itT;
		foreach(it; lot) {
			itT.insert(it);
		}
		assert(itT.length == lot.length);
		Iterator!(int) be = itT.begin();
		while(be.isValid()) {
			assert(itT.remove(be, true));
		}
		assert(itT.length == 0);
	}

	for(int i = 0; i < lot.length; i++) {
		RBTree!(int) itT;
		foreach(it; lot) {
			itT.insert(it);
		}
		assert(itT.length == lot.length);
		Iterator!(int) be = itT.end();
		while(be.isValid()) {
			assert(itT.remove(be, false));
		}
		assert(itT.length == 0);
	}
}

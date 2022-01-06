module libtind.map;

import libtind.functional : less, equal;

@nogc nothrow @safe:

struct Map(K,V,alias lessThan = less, alias equalTo = equal) {
	import libtind.rbtree;

	struct KeyValue(Key, Value) {
		Key key;
		Value value;

		int opCmp(ref const typeof(this) other) const {
			return less(this.key, other.key);
		}

		bool opEquals()(auto ref const typeof(this) other) const {
			return equalTo(this.key, other.key);
		}
	}

	bool insert(K key, V value) {
		return this.tree.insert(MapNode(key, value));
	}

	Node!(MapNode)* opIndex(this T)(K key) {
		MapNode s;
		s.key = key;
		return this.tree.search(s);
	}

	bool remove(K key) {
		MapNode s;
		s.key = key;
		return this.tree.remove(s);
	}

	@property size_t length() const pure nothrow {
		return this.tree.length;
	}

	@property bool empty() const pure nothrow {
		return this.tree.length == 0;
	}

	alias MapNode = KeyValue!(K,V);

	RBTree!(MapNode) tree;
}

unittest {
	Map!(int,int) map;
	assert(map.empty);
	assert(map[10] is null);
	assert(map.insert(1, 1000));
	assert(!map.empty);
	assert(map.length == 1);
	assert(map[10] is null);
	assert(map[1] !is null);
	assert(map[1].value == 1000);
	assert(map.remove(1));
	assert(map.empty);
	assert(map.length == 0);
}

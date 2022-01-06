module libtind.nullable;

@safe pure:

struct Nullable(T) {
	T value;
	bool isNull = true;

	this(T nv) {
		this.value = nv;
		this.isNull = false;
	}

	T get(G)(G ifNull) {
		return this.isNull
			? ifNull
			: this.value;
	}

	const(T) get(G)(G ifNull) const {
		return this.isNull
			? ifNull
			: this.value;
	}
}

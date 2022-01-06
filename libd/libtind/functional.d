module libtind.functional;

bool less(T)(T a, T b) {
	return a < b;
}

bool equal(T)(T a, T b) {
	return a == b;
}

int cmp(T)(T a, T b) {
	if(a < b) {
		return -1;
	} else if(a > b) {
		return 1;
	} else {
		return 0;
	}
}

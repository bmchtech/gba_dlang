module bclib.error;

import bclib.io : print;

@trusted
void panic(Values...)(Values values)
{
	import core.stdc.stdlib : exit;
	print(values);
	assert(0);
}
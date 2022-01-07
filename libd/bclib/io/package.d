module bclib.io;

public:
	import bclib.io.print;


import core.stdc.stdlib : exit;

void stdoutFlush(){
	import core.stdc.stdio;
	stdout.fflush();
}
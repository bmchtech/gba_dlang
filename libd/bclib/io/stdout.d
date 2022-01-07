module bclib.io.stdout;

struct Stdout
{
    void put( Values... )(auto ref Values values)
    {
    	import core.stdc.stdio : 
    	fwrite, 
    	stdout,
    	fputc;

        static foreach(value ; values)
        {
            static if( is( typeof(value) == char) )
            {
            	fputc(value, stdout);
            }
            else
            {
            	import core.stdc.stdio : printf;
            	printf("%.*s", value.length, value.ptr);
            	//TODO: stdout bug
                //fwrite( value.ptr, 1 , 9, stdout );	
            }
        }
    }
}

static Stdout stdout;
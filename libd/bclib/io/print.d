module bclib.io.print;

import bclib.io.stdout : stdout;

@trusted
void format( alias IO = stdout, Values... )( auto ref Values values )
{
	static foreach(value ; values)
	{{
		import bclib.traits : isAny;
		import bclib.string : String;
		import std.traits : isPointer, Unqual, isArray;

		alias Type = Unqual!(typeof(value));

		static if( is(typeof(Type.toString)) )
		{
			value.toString!IO;
		}
		else static if( isAny!( Type, string, String, char[] ) )
		{
			IO.put( value[0 .. $] );
		}
		else static if( is(Type == struct) )
		{
			format!IO( "{ \"__type\": \"", Type.stringof, "\", ");
			static if( Type.tupleof.length )
			{
				static foreach( index ; 0 .. Type.tupleof.length-1 )
				{{
	    			alias FieldType = typeof(Type.tupleof[index]);

	    			format!IO('"', Type.tupleof[index].stringof ,"\": ");

	    			static if( is( FieldType == string ) )
	    				format!IO('"', value.tupleof[index], "\", " );	
	    			else
	    				format!IO(value.tupleof[index], ", " );	
	    			
				}}

				alias FieldType = typeof(Type.tupleof[$-1]);

    			format!IO('"', Type.tupleof[$-1].stringof ,"\": ");

    			static if( is( FieldType == string ) )
    				format!IO('"', value.tupleof[$-1], "\"" );	
    			else
    				format!IO(value.tupleof[$-1] );	
			}
			format!IO('}');
			
		}
		else static if(is(Type == bool))
	    {
			IO.put( value ? "true" : "false" );
	    }
	    else static if( isArray!Type )
	    {
	    	IO.put("[");
	    	if( value.length )
	    	{
	    		foreach( i ; 0 .. value.length - 1 )
	    			format!IO( value[i] , ", " );
	    		format!IO( value[$-1] );
	    	}
	    	IO.put("]");
	    }
	    else
	    {
	        static if( isAny!(Type, size_t, ulong ) )
	            enum format = "%Iu";
	        else static if( is( Type == long ) )
	            enum format = "%Id";
	        else static if( is( Type == uint ) )
	            enum format = "%u";
	        else static if( is( Type == int ) )
	            enum format = "%d";
	        else static if( is( Type == float ) )
	            enum format = "%f";
	        else static if( is( Type == double ) )
	            enum format = "%lf";
	        else static if( is( Type == char ) )
	            enum format = "%c";
			else static if( is( Type == byte ) || is( Type == ubyte ) )
	            enum format = "%x";
	        else static if( isPointer!Type )
	            enum format = "#%llx";
			else
				pragma(msg, "Type ", Type.stringof, " is not implemented!");

	        import core.stdc.stdio : sprintf;  
	        //316, maybe the max char possible (double.max)
	        char[512] tmp;
	        
	        size_t length = sprintf(tmp.ptr, format , value );
			IO.put( tmp[0 .. length] );
	    }
	}}
}

@trusted
void print( Values... )( auto ref Values values )
{
	import std.functional : forward;
	format!(stdout)(forward!values);
	format!(stdout)('\n');
}

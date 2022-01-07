module bclib.util;

import bclib.traits : isAny;

size_t hashof(T)( auto ref T value )
{
	static if ( isAny!( T, byte, ubyte, char , char, short, ushort, int, uint, long, ulong, size_t ) )
	{
		return cast(size_t) value;
	}
	else static if( is( T == struct ))
	{
		static if( is( typeof( T.hashof ) ) )	
		{
			return value.hashof();
		}
		else
		{
			pragma(msg, "struct Hashing NOT IMPLEMENTED!");
			return 0;
		}
	}
	else
	{
		pragma(msg, "hashof!(", T.stringof ,") NOT IMPLEMENTED!");
		return 0;
	}

}
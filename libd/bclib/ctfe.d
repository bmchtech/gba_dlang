module bclib.ctfe;

struct StringBuilder(alias int SIZE)
{
	char[SIZE] ptr;
	size_t length;

	void opCall(Values...)( Values values )
	{
		static foreach( i, value ; values )
		{
			static if(is(Values[i] == string))
			{
				foreach(c ; value)
				{
					ptr[length++] = c;
				}			
			}
			else static if( is( Values[i] == size_t ) )
			{
				length += size_t2str( value, ptr[length .. SIZE] );
			}
		}
	}

	auto opSlice(){ return ptr[0 .. length]; }
}

size_t size_t2str( size_t from, char[] buffer )
{
	size_t strlen = 0;
	do{
		size_t value = from % 10;
		from = cast(size_t)(from / 10);
		buffer[ strlen++ ] = cast(char) (48 + value);
	}
	while(from);

	size_t head = 0;
	size_t tail = strlen-1;
	import bclib.io;
	while(head < tail)
	{
		auto c       = buffer[head];
		buffer[head] = buffer[tail];
		buffer[tail] = c;
		++head;
		--tail;
	}

	return strlen;
}

//To to( To, From )(auto ref From from)
//{
//	static if( is( From == string ) && is( To == int ) )
//	{
//		size_t str_len = from.length;
//		size_t multiplier = 1;
//		int result = 0;
//		while(str_len--)
//		{
//			result += (To(from[ str_len ]) - 48) * multiplier;
//			multiplier *= 10;
//		}
//		return result;
//	}
//}

T find( Haystack, Needle )( Haystack haystack, const Needle needle )
{
	import bclib.traits : isArray;
	static if( isArray!Needle ) 
	{
		immutable needle_len = needle.length;
		size_t index = 0;
		size_t limit = haystack.length - needle_len;
		while( index != limit )
		{
			if( haystack[ index .. needle_len ] == needle )
			{
				return haystack[ index .. $ ];
			}
			++index;
		}	
	}
	
	return [];
}

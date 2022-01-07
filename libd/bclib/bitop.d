module bclib.bitop;

import bclib.string;

String bit2str( T )( auto ref T value )
{
	import std.traits : isStaticArray;
	import std.range : ElementType;

	static if( isStaticArray!T )
		enum BitSize = ElementType!(T).sizeof * 8;
	else
		enum BitSize = T.sizeof * 8;
	char[ BitSize ] data;

	auto limit = BitSize;
	auto pos = 0;
	while(limit--)
	{
		data[pos++] = value.bitcheck(limit) ? '1' : '0';
	}
	return String(data[0 .. BitSize]);
}

//{
//	import std.conv:   text;
//	import std.format: format;
//	import std.range:  ElementType;
//	import std.traits: isStaticArray;

//	static if( isStaticArray!T )
//		enum BitSize = ElementType!(T).sizeof * 8;
//	else
//		enum BitSize = T.sizeof * 8;

//	string r;

//	static if( isStaticArray!T )
//	{
//		static foreach( index ; 0 .. value.length )
//		{
//			r ~= format( text("%0", BitSize ,"b\n"), value[index] );		
//		}
//	}
//	else
//	{
//		r = format( text("%0", BitSize ,"b\n"), value );
//	}
//	return r;
//}

void bitset( T, U )(ref T value, ref U index)
{
	import std.range : ElementType;
	import std.traits : isStaticArray;

	static if( isStaticArray!T )
		enum BitSize = ElementType!(T).sizeof * 8;
	else
		enum BitSize = T.sizeof * 8;

	static if( isStaticArray!T )
	{
		value[ index / BitSize ] |= 1UL << index % BitSize;

	}
	else
	{
		value |= 1UL << index;
	}
}

void bitclear( T, U )(ref T value, ref U index)
{
	import std.range : ElementType;
	import std.traits : isStaticArray;

	static if( isStaticArray!T )
		enum BitSize = ElementType!(T).sizeof * 8;
	else
		enum BitSize = T.sizeof * 8;

	static if( isStaticArray!T )
	{
		value[ index / BitSize ] &= ~(1UL << index % BitSize);

	}
	else
	{
		value &= ~(1UL << index);
	}
}

bool bitcheck( T, U )(ref T value, ref U index)
{
	import std.range : ElementType;
	import std.traits : isStaticArray;

	static if( isStaticArray!T )
		enum BitSize = ElementType!(T).sizeof * 8;
	else
		enum BitSize = T.sizeof * 8;

	static if( isStaticArray!T )
	{
		return (value[ index / BitSize ] >> index) & 1U;
	}
	else
	{
		return (value >> index) & 1UL;
	}
}

bool bitmaskcheck( T, U )(auto ref T value, auto ref U other)
{

	import std.range : ElementType;
	import std.traits : isStaticArray;

	static if( isStaticArray!T )
	{
		static gen()
		{
			import std.conv : text;
			import std.array : join;
			string[] code;
			static foreach(i ; 0 .. value.length)
			{
				code ~= text( "( (value[",i,"] & other[",i,"] ) == other[",i,"] )" );
			}

			return  "return " ~ code.join(" && ") ~";";

		}
		mixin(gen());
	}
	else
	{
		return (value & other) == other;
	}	
}
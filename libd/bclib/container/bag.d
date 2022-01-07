module bclib.container.bag;

struct Bag(Type, alias Size)
{
	Type[ Size ] data;
	size_t len;
	Type* ptr(){ return data.ptr; }
	size_t length(){ return len; }
	alias capacity = Size;

	this(ref Bag other)
	{
		import bclib.memory : memcpy;
		immutable other_len = other.length;
		memcpy( data.ptr, other.ptr, other_len * Type.sizeof );
		len = other.len;
	}

	this( Values... )( auto ref Values values )
	{
		import bclib.traits:  isRValue;
		import std.math : nextPow2;
		import bclib.memory : assign;
		import bclib.io : print;

		static if( Values.length > capacity )
		{
			print(Bag.stringof, " cannot assign " , Values.length, " elements.");
			assert(0);
		}

		static foreach(value ; values)
		{{
			assign!( isRValue!value )( data[len] , value );
			++len;
		}}
	}

	void push( Values... )( auto ref Values values )
	{
		import bclib.traits:  isRValue;
		import std.math : nextPow2;
		import bclib.memory : assign;

		size_t new_len = len + Values.length;

		if( new_len > capacity )
		{
			import bclib.io : print;
			print(Bag.stringof, " cannot push more elements");
			assert(0);
		}

		static foreach(value ; values)
		{{
			assign!( isRValue!value )( data[len], value );
			++len;
		}}
	}

	void pop()
	{
		--len;
	}

	ref pop_return()
	{
		return data[ --len  ];
	}

	ref front(){ return data[0]; }  
	ref back() { return data[len-1]; }  

	ref opIndex( size_t index )
	{
		return data[ index ];
	}

	auto opSlice()
	{
		return data[0 .. len];
	}

	auto opSlice( size_t start, size_t end )
	{
		return data[start .. end];
	}

	void toIO(alias IO)()
	{
		import bclib.io : printl;

		printl!IO("[");
		if( len )
		{
			foreach(ref val ; data[0 .. len - 1])
			{
				printl!IO(val , ", ");
			}
			printl!IO(data[len-1] );	
		}
		printl!IO("]");
	}

	auto opDollar(){ return len; }

}

auto bag( T... )( auto ref T t )
{
	return Bag!(T[0],T.length)(t);
}

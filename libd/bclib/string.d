module bclib.string;

import bclib.memory : default_allocator;

//TODO: want to make \0 ended strings also
//TODO: dont have code to shrink strings (do i need?)

struct TString(alias Allocator = default_allocator)
{
	//import bclib.memory : Box, box;

	//Box!(string, default_allocator) ptr;

	//size_t length(){ return ptr.capacity; }

	//this(Type)(Type str){
	//	ptr = box(str[]);
	//}

	//String dup()
	//{
	//	String tmp;
	//	tmp.ptr = ptr.dup;
	//	return tmp;
	//}

	//String opBinary(alias op = "~", T)( auto ref T other )
	//	if( is(T == String) || is(T == string) )
	//{
	//	import bclib.memory : copyTo;

	//	String new_string;
	//	new_string.resize( length + other.length );
	//	ptr[].copyTo( new_string[] );
	//	other[].copyTo( new_string[length .. $] );
	//	return new_string;
	//}

	//void opOpAssign( string op = "~", T )( auto ref T other )
	//	if( is(T == String) || is(T == string) )
	//{
	//	import bclib.memory : copyTo;
		
	//	auto start = length;
	//	ptr.resize( length + other.length );
	//	other[].copyTo( ptr[start .. $] );
	//}

	//void resize(size_t size){ ptr.reserve(size); }

	//auto opSlice(){ return ptr.opSlice(); }
	//auto opSlice( size_t start, size_t end ){ return ptr.opSlice(start , end); }
	//auto opDollar(){ return ptr.opDollar(); }

	////void toString( alias IO )()
	////{	
	////	IO.put( ptr[] );
	////}	

}

alias String = TString!(default_allocator);


//struct TString(alias allocator = default_allocator)
//{
//	import bclib.memory : Box;

//	Box!(char[]) __data;

//	this( immutable(char[]) str )
//	{
		
//		//__data = 
//	}	
//}

//alias String = TString!();




//import bclib.memory : alloc, alloc_zero, release , sys_alloc;

//import bclib.io : printf;

//struct String
//{
//	alias allocator = sys_alloc;
//	alias Type      = char;
//	alias SelfType  = String;

//	Type[] data;
//	size_t len;


//	char* ptr(){ return data.ptr; }
//	size_t length(){ return len; }
//	size_t capacity(){ return data.length; }

//	this(ref SelfType other)
//	{
//		import std.traits : hasIndirections;
//		import bclib.memory : memcpy;

//		static if( hasIndirections!Type )  
//			alias _alloc = alloc_zero;
//		else
//			alias _alloc = alloc;

//		immutable other_len = other.length;

//		/*
//		need to cast because of bug
//		https://issues.dlang.org/show_bug.cgi?id=19960
//		*/
//		data = cast(Type[])_alloc!(Type[], allocator)( other.length + 1 );	
//		memcpy( data.ptr, other.ptr, other_len * Type.sizeof );
//		len = other.len;
//		data[len] = 0;
//	}

//	this( Values... )( auto ref Values values )
//	{
//		import bclib.traits:  isRValue;
//		import std.math : nextPow2;
//		import bclib.memory : assign;

//		size_t new_cap = 0;
//		foreach( ref val ; values ) new_cap+= val.length;
//		reserve( new_cap );
	
//		static foreach(value ; values)
//		{{
//			assign!(isRValue!value)( data[len .. $] , value );
//			len += value.length;
//		}}
//	}

//	~this()
//	{
//		if( data ) 
//			release!(allocator)(data);

//		data = null;
//	}

//	void push( Values... )( auto ref Values values )
//	{
//		import bclib.traits:  isRValue;
//		import std.math : nextPow2;
//		import bclib.memory : assign;

//		size_t new_len = len;

//		static foreach(value ; values)
//		{
//			new_len += value.length;
//		}

//		if( new_len > capacity )
//			reserve( new_len );

//		static foreach(value ; values)
//		{{
//			assign!(isRValue!value)( data[len .. $] , value );
//			len += value.length;
//		}}
//	}

//	void pop()
//	{
//		import std.traits : hasElaborateDestructor;
//		import bclib.memory : dtor;
//		--len;
//		data[ len ].dtor;
//	}

//	void reserve( size_t new_cap )
//	{
//		import std.traits : hasIndirections;
//		import bclib.memory : memcpy;

//		//TODO:
//		//this should be decided by alloc .. or not ?
//		static if( hasIndirections!Type )  
//			alias _alloc = alloc_zero;
//		else
//			alias _alloc = alloc;

//		if( capacity() == 0 )
//		{
//			//look bug above
//			data = cast(Type[])_alloc!(Type[], allocator)( new_cap + 1 );	
//			data[new_cap] = 0;
//		}
//		else
//		{
//			//look bug above
//			auto new_data = cast(Type[])_alloc!(Type[], allocator)( new_cap + 1 );	
//			memcpy( new_data.ptr, data.ptr, Type.sizeof * len );
//			release!(allocator)(data);
//			data = new_data;
//			data[ new_cap ] = 0;
//		}
//	}

//	ref front(){ return data[0]; }  
//	ref back() { return data[len-1]; }  

//	ref opIndex( size_t index )
//	{
//		return data[ index ];
//	}

//	auto opSlice()
//	{
//		return data[0 .. len];
//	}

//	auto opSlice( size_t start, size_t end )
//	{
//		return data[start .. end];
//	}

//	String opBinary(alias op = "~", T)( auto ref T other )
//	{
//		return String( this, other );
//	}

//	void opOpAssign( string op = "~", T )( auto ref T other )
//	{
//		push( other );
//	}

//	auto opDollar(){ return len; }

	
//	void toIO(alias IO)()
//	{
//		import bclib.io : printl;

//		printl!IO( cast(string)data );
//	}

	

//}

//auto str(T... )( auto ref T t )
//{
//	return String(t);
//}


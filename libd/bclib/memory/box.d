module bclib.memory.box;

import bclib.memory : default_allocator;
import bclib.error : panic;

struct Box(Type, alias TAllocator = default_allocator)
{
	import std.traits : isArray, Select, Unqual;
	import std.range : ElementType;

	alias IsArray   = isArray!Type;
	alias DataType  = Select!( IsArray , Type, Type* );
	alias Allocator = TAllocator;

	private DataType __ptr;

	/*
		Constructors, Destructors, Assign, and Free Boxes
	*/
	this(Type value)
	{
		import std.algorithm : moveEmplace, moveEmplaceAll;
		import bclib.memory : alloc, moveTo;

		import std.traits : ReturnType;

		static if( IsArray )
		{
			__ptr = alloc!(Type, Allocator)( value.length );
			value.copyTo( __ptr );
		}
		else
		{
			__ptr = alloc!(Type, Allocator);
			value.moveTo( *__ptr );			
		}
	}

	this(ref Box other)
	{
		import bclib.memory : alloc, copyTo;

		if( other )
		{
			static if( IsArray )
			{
				import bclib.io;
				print(other);
				__ptr = alloc!( Type, Allocator )( other.capacity );
				//other.__ptr.copyTo( __ptr );
			}
			else
			{
				__ptr = alloc!( Type, Allocator )();
				other.__ptr.copyTo( __ptr );
			}	
		}
	}

	void opAssign( Self : Box )( auto ref Self other )
	{
		import bclib.memory : alloc, copyTo;

		free();

		if( other )
		{
			static if( IsArray )
			{
				__ptr = alloc!( Type, Allocator )( other.capacity );
				other.__ptr.copyTo( __ptr );
			}
			else
			{
				__ptr = alloc!( Type, Allocator )();
				other.__ptr.copyTo( __ptr );
			}	
		}
	}

	void fromPtr( ref DataType ptr )
	{
		__ptr = ptr;
		ptr = null;
	}

	~this()
	{
		free();
	}

	void free()
	{
		import bclib.memory : dealloc, destructor;
		if ( this )
		{
			static if(IsArray)
				destructor(__ptr);
			else
				destructor(*__ptr);

			dealloc!(Allocator)(__ptr);
		}
	}

	static if( IsArray )
	{
		import bclib.memory : allocInit,dealloc, copyTo;
		void reserve( size_t size )
		{
			if( size > __ptr.length )
			{
			//	//TODO: every calloc call can be replaced with alloc call if the type don´t have indirections

				auto tmp = allocInit!(Type, Allocator)( size );
				__ptr.copyTo( tmp );
				free();
				__ptr = tmp;
			}
		}

		void reserveInit( size_t size )
		{
			if( size > __ptr.length )
			{
				auto tmp = allocInit!(Type, Allocator)( size );
				__ptr.copyTo( tmp );
				free();
				__ptr = tmp;
			}
		}
		
		size_t opDollar(){ return __ptr.length; }
		alias capacity = opDollar;

		@safe
		ref  opIndex( size_t index ) { 
			import bclib.error : panic;

			if( index >= capacity ) panic("Box[index] is out of bounds!");
			if( !this ) panic("Box[index] indexing an empty box!");
			return __ptr[ index ]; 
		}

		@safe
		auto opSlice() { 
			import bclib.error : panic;

			if( !this ) panic("Box[] slicing an empty box!");
			return __ptr[0 .. $];
		}

		@safe
		auto opSlice(size_t start, size_t end) {
			if( !this ) panic("Box[start .. end] slicing an empty box!");
			if( start >= capacity || end > capacity) panic("Box[",start," .. ",end,"] is out of bounds!");

			return __ptr[start .. end]; 
		}

	}

	@safe
	ref opUnary( string op: "*")(string file = __FILE__, int line = __LINE__)
	{
		import bclib.error : panic;
		static if( IsArray ){
			if( this ) return __ptr;
			panic( "Dereferencing an empty box in ",file, ": ", line);
		} 
		else{
			if( this ) return *__ptr;
			panic( "Dereferencing an empty box in ",file, ": ", line);
		}
		assert(0);
	}

	/*
		Internal data access functions
	*/
	@safe
	bool opCast()
	{
		return __ptr !is null;
	}


	@system
	auto ptr()
	{
		static if(IsArray) return __ptr.ptr;
		else return __ptr;
	}
	/*
		Change box ownership
	*/

	@trusted
	auto move()
	{
		import std.algorithm : move_ = move;
		return move_(this);
	}

	@system
	auto releasePtr()
	{
		auto tmp = __ptr;
		__ptr = null;
		return tmp;
	}

	@trusted
	auto match( alias SomeFunction, alias NoneFunction )()
	{
		import bclib.traits : ReturnType;

		if( this ) 
		{
			static if( IsArray )
				return SomeFunction( __ptr );
			else
				return SomeFunction( *__ptr );
		}
		else
		{
			return NoneFunction();
		}
	}

}

struct box(alias Allocator = default_allocator)
{
	static opCall( Type )(auto ref Type value)
	{
		import std.functional : forward;
		return Box!(Type, Allocator)(forward!value);	
	}

	static fromPtr( Type )(ref Type* value)
	{
		Box!(Type, Allocator) box;
		box.fromPtr( value );
		return box;
	}

	static fromPtr( Type )(ref Type[] value)
	{
		Box!(Type[], Allocator) box;
		box.fromPtr( value );
		return box;
	}
}

unittest{

	import bclib.io;
	import core.stdc.stdio;
	import core.stdc.stdlib;

	import bclib.memory : CounterAllocator;
	import bclib.io : print;

	static CounterAllocator!() counter_allocator;

	alias _Box(T) = Box!(T, counter_allocator);

		
	{ _Box!int box_int = _Box!int(123); }
	{ _Box!int _box_int = box!counter_allocator(123); }
	{ auto _box_int = box!counter_allocator(123); } 

	import std.array : staticArray;

	auto array_ptr   = [1,2,3].staticArray;
	auto array_slice = array_ptr[];

	{ _Box!(int[]) _box_int = _Box!(int[])( array_slice ); }
	{ _Box!(int[]) _box_int = box!counter_allocator( array_slice ); }
	{ auto _box_int = box!counter_allocator( array_slice ); } 

	{
		auto a = box!counter_allocator(123);
		auto b = a;
		*a = 100;

		assert(cast(bool)a, "b = a, is a copy, not move.");
		assert(cast(bool)b, "b = a, is a copy, not move.");

		assert( *a != *b, "a and b _boxes are have different values" );
		assert( a.ptr != b.ptr, "a and b have different pointers" );
	}

	{
		auto a = box!counter_allocator(100);
		auto b = box!counter_allocator(200);

		a = b;

		assert(cast(bool)a, "a and b have values");
		assert(cast(bool)b, "a and b have values");

		assert( *a == *b, "a and b have the same value" );
		assert( a.ptr != b.ptr, "a and b have different pointers" );
	}
	{
		auto ptr = cast(int*) counter_allocator.malloc(4);
		*ptr = 100;
		auto a = box!counter_allocator.fromPtr( ptr );

		assert(ptr is null, "box.fromPtr must move the pointer to gain ownership");
		assert(*a == 100, "box value must be from the pointer");
	}
	{
		auto x = box!counter_allocator(100);
		x.free();
		assert(x.ptr is null, "free() testing");
	}
	{
		auto a = box!counter_allocator(100);
		auto b = a.move();

		assert( cast(bool)a == false, "a was moved" );
		assert( cast(bool)b , "b have the value" );
		assert( *b == 100 , "b have the value" );
	}
	{
		auto a = box!counter_allocator(100);
		auto ptr = a.releasePtr();
		assert( cast(bool)a == false, "a must be empty" );
		assert( *ptr == 100);

		typeof(a).Allocator.free(ptr);
	}
	{
		auto x = box!counter_allocator(123);

		auto right_value = x.match!(
			v => v,
			() => 0,
		);
		assert(right_value == 123, "box.match some value" );

		x.free();

		right_value = x.match!(
			v => v,
			() => 0,
		);
		assert(right_value == 0, "box.match none value" );

	}

	//slices

	auto buffer1 = [1,2,3].staticArray;
	auto arr1 = buffer1[];

	auto buffer2 = [1,2,3,4].staticArray;
	auto arr2 = buffer2[];

	{
		auto a = box!counter_allocator(arr1);
		auto b = a;
		a[0] = 100;

		assert(cast(bool)a, "b = a, is a copy, not move.");
		assert(cast(bool)b, "b = a, is a copy, not move.");

		assert( a[0] != b[0], "a and b _boxes are have different values" );
		assert( a.ptr != b.ptr, "a and b have different pointers" );
	}

	{
		auto a = box!counter_allocator(arr1);
		auto b = box!counter_allocator(arr2);

		a = b;

		assert(cast(bool)a, "a and b have values");
		assert(cast(bool)b, "a and b have values");

		assert( *a == *b, "a and b have the same value" );
		assert( a.ptr != b.ptr, "a and b have different pointers" );
	}
	{
		auto ptr = (cast(int*) counter_allocator.malloc(int.sizeof * 3))[0 .. 3];
		ptr[0] = 100;
		ptr[1] = 200;
		ptr[2] = 300;
		auto a = box!counter_allocator.fromPtr( ptr );

		assert(ptr is null, "box.fromPtr must move the pointer to gain ownership");
		assert(a[0] == 100, "box value must be from the pointer");
		assert(a[1] == 200, "box value must be from the pointer");
		assert(a[2] == 300, "box value must be from the pointer");
	}
	{
		auto x = box!counter_allocator(arr1);
		x.free();
		assert(x.ptr is null, "free() testing");
	}
	{
		auto a = box!counter_allocator(arr1);
		auto b = a.move();

		assert( cast(bool)a == false, "a was moved" );
		assert( cast(bool)b , "b have the value" );
		assert( b[0] == 1 , "b have the value" );
	}
	{
		auto a = box!counter_allocator(arr1);
		auto ptr = a.releasePtr();
		assert( cast(bool)a == false, "a must be empty" );
		assert( ptr[0] == 1);

		typeof(a).Allocator.free(ptr.ptr);
	}
	{
		auto x = box!counter_allocator(arr1);

		auto right_value = x.match!(
			v => v,
			(){
				int[] tmp;
				return tmp;
			},
		);
		assert(right_value == arr1, "box.match some value" );

		x.free();

		right_value = x.match!(
			v => v,
			(){
				int[] tmp;
				return tmp;
			},
		);
		assert(right_value.length == 0, "box.match none value" );

	}

	{
		auto a = Box!(int[])();
		a.reserve(10);
		assert( a.capacity == 10, "box.reserve check value" );
		assert( a.ptr !is null , "reserved box must have a valid pointer" );
	}

	{
		auto a = box!counter_allocator(arr1);
		auto slice = a[];
		slice[1] = 123;
		assert( a[1] == 123, "Slice is a pointer to the real value" );

		slice = a[0 ..2];
		assert( slice.length == 2 , "Slice length check" );
	}

    print("Allocation Counter: ", counter_allocator.counter);
	assert( counter_allocator.counter == 0 , "Allocations must be 0 at the end" );


}
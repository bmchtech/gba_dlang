module bclib.container.array;

private import bclib.memory : default_allocator;

//  TODO: check for out of bounds in all methods

struct Array( Type, alias Allocator = default_allocator )
{
    enum float RESERVE_FACTOR = 1.5;

    Type[]  __ptr;
    size_t  __length;

    @trusted 
    size_t  length()    { return __length; }
    @trusted 
    size_t  capacity()  { return __ptr.length; }
    @system 
    Type*  ptr()       { return __ptr.ptr; }

    @trusted
    this( Values... )( Values values )
    {
        import bclib.traits : isArray, isBCArray;
        import std.range : isInputRange, hasLength;
        import bclib.io;


        size_t new_cap = 0;
        static foreach (value; values)
        {{
            alias ValueType = typeof(value);
            static if (is(ValueType == Type))
            {
                ++new_cap;
            }
            else static if (hasLength!ValueType)
            {
                new_cap += value.length;
            }
            else
            {
                enum hasUnpredictableLength;
            }
        }}
        
        reserve( cast(size_t) (new_cap * RESERVE_FACTOR) );

        static if( !is( typeof( hasUnpredictableLength ) ) )
        {
            static foreach (value; values)
            {{
                alias ValueType = typeof(value);

                static if (is(ValueType == Type))
                {
                    import bclib.memory : moveTo;

                    value.moveTo(__ptr[__length++]);
                }
                else static if ( isArray!ValueType || isBCArray!ValueType )
                {
                    import bclib.memory : moveTo;
                    
                    value[0 .. $].moveTo(__ptr[__length .. __length + value.length]);
                    __length += value.length;    
                }
                else static if (isInputRange!ValueType)
                {
                    foreach (ref val; value)
                    {
                        push(val);
                    }
                }
            }}
        }
        else
        {
            static foreach (value; values)
            {
                push(value);
            }
        }
        
    }

    @trusted
    this(ref Array other)
    {
        import bclib.memory : alloc;

        free();
        immutable new_len     = other.length;
        auto new_ptr          = alloc!(Type[], Allocator)( new_len );
        new_ptr[0 .. new_len] = other.ptr[0 .. new_len];
        __ptr                 = new_ptr;
        __length              = new_len;
    }

    @trusted
    void reserve( size_t size )
    {
        import bclib.memory : alloc, copyTo;
        if( size > __length )
        {
            auto new_ptr = alloc!(Type[], Allocator)( size );
            if( __length )
            {
                auto old_len = __length;
                new_ptr[0 .. old_len] = __ptr[0 .. old_len];
                free();
                __length = old_len;
            }
            __ptr = new_ptr;
        }
    }

    @trusted
    void reserveInit( size_t size )
    {
        import bclib.memory : allocInit, copyTo;

        if( size > __length )
        {
            auto new_ptr = allocInit!(Type[], Allocator)( size );
            if( __length )
            {
                new_ptr[0 .. __length] = __ptr[0 .. __length];
            }
            free();
            __ptr = new_ptr;
        }
    }

    @trusted
    void resize(size_t size)
    {
        import bclib.memory : destructor;

        if( size > __length )
        {
            reserveInit( size );
        }
        else if (size < __length)
        {
            __ptr[ size .. __length ].destructor();
        }
        __length = size;
    }

    alias capacity = reserve;
    alias length = resize;

    @trusted
    void push(Values...)( Values values )
    {
        import bclib.traits : isArray, isBCArray;
        import std.range : isInputRange, hasLength;

        size_t new_len = __length;
        static foreach (value; values)
        {{
            alias ValueType = typeof(value);
            static if (is(ValueType == Type))
            {
                ++new_len;
            }
            else static if (hasLength!ValueType)
            {
                new_len += value.length;
            }
            else
            {
                enum hasUnpredictableLength;
            }
        }}

        if (new_len > capacity)
        {
            auto new_cap = cast(size_t) (new_len * RESERVE_FACTOR);
            reserve( new_cap );
        }

        static if( !is( typeof( hasUnpredictableLength ) ) )
        {
            static foreach (value; values)
            {{
                alias ValueType = typeof(value);

                static if (is(ValueType == Type))
                {
                    import bclib.memory : moveTo;

                    value.moveTo(__ptr[__length++]);
                }
                else static if ( isArray!ValueType || isBCArray!ValueType )
                {
                    import bclib.memory : moveTo;
                    
                    value[0 .. $].moveTo(__ptr[__length .. __length + value.length]);
                    __length += value.length;    
                }
                else static if (isInputRange!ValueType)
                {
                    foreach (ref val; value)
                    {
                        push(val);
                    }
                }
            }}
        }
        else
        {
            static foreach (value; values)
            {
                push(value);
            }
        }
    }

    alias opOpAssign(alias op = "~") = push;

    @trusted
    void insert( Type value , size_t index )
    {
        import bclib.memory : destructor, moveTo, MemOverlap;

        if (__length + 1 > capacity)
            reserve(cast(size_t)((capacity ? capacity : 4) * RESERVE_FACTOR));

        //TODO: why should i have to do this? moveTo!(Type, ?
        __ptr[index .. __length].moveTo!(Type,MemOverlap)( __ptr[index + 1 .. __length + 1] );
        value.moveTo( __ptr[index] );
        ++__length;
    }

    @trusted
    void pop()
    {
        import bclib.memory : destructor;
        if( __length )
        {
            --__length;
            __ptr[ __length ].destructor;    
        }
        
    }

    @trusted
    void pop( size_t size )
    {
        import bclib.memory : destructor;
        if( __length - size >= 0 )
        {
            __ptr[ __length - size .. __length ].destructor;
            __length -= size;    
        }
    }

    @trusted
    void remove( size_t index )
    {
        import bclib.memory : swap;
        if( index < __length )
        {
            swap( __ptr[index], __ptr[__length - 1] );
            pop;    
        }
    }

    @trusted
    void removeStable( size_t index )
    {
        import bclib.memory : swap, destructor, moveTo, MemOverlap;
        if( index < __length )
        {
            __ptr[index].destructor();

            if( index != __length - 1 )
            {
                __ptr[index + 1 .. __length ].moveTo!(Type, MemOverlap)( __ptr[index .. __length - 2] );
            }
            --__length;
        }
    }

    @trusted
    void free()
    {
        import bclib.memory : dealloc, destructor;
        if ( this )
        {
            destructor(__ptr);
            dealloc!(Allocator)(__ptr);
            __length = 0;
        }
    }

    alias opDollar = __length;

    @system
    ref opIndex(size_t index)
    {
        return __ptr[index];
    }

    @trusted
    auto opSlice()
    {
        return __ptr[0 .. __length];
    }

    @system
    auto opSlice(size_t start, size_t end)
    {
        return __ptr[start .. end];
    }

    @system
    ref front()
    {
      return __ptr[0];
    }

    @system
    ref back()
    {
      return __ptr[__length - 1];
    }

    @trusted
    bool opCast()
    {
        return __length != 0;
    }

    Type[] opBinaryRight(string op = "in")( Type needle )
    {
        size_t index = 0;
        while(true)
        {
            if( __ptr[index] == needle ) return __ptr[ index .. __length ];
            ++index;
            if( index == __length ) return null;
        }
    }

    @trusted
    void toString(alias IO)()
    {
        import bclib.io.print : format;
        format!IO("[");
        if (__length)
        {
            foreach (ref val; ptr[0 .. __length - 1])
            {
                format!IO(val, ", ");
            }
            format!IO(ptr[__length - 1]);
        }
        format!IO("]");
    }

}

template array(alias Allocator = default_allocator)
{
    auto array(Values...)(auto ref Values values)
    {
        import std.functional : forward;
        return Array!(Values[0], Allocator)(forward!values);
    }
}

unittest{

    import bclib.memory : CounterAllocator;
    import bclib.io : print;

    static CounterAllocator!() counter_allocator;

    alias _Array(T) = Array!(T, counter_allocator);
    alias _array = array!(counter_allocator);

    {
        import std.conv : to;
        import std.range : iota;
        auto arr = array(1,2, [3,4] , iota( 5 , 7 ), array(7,8) );
        assert( arr.length == 8 , "Wrong lenght" );
        assert( arr.capacity == 12 , "Wrong capacity" );
        assert( arr[] == [1,2,3,4,5,6,7,8] , "Wrong values" );
    }

    {
        auto arr = array(1,2,3);
        auto arr2 = arr;

        arr.push(4,5);
        arr2.push(4);

        assert( arr.length == 5 , "Wrong lenght" );
        assert( arr.capacity == 7 , "Wrong capacity" );
        assert( arr[] == [1,2,3,4,5] , "Wrong values" );

        assert( arr2.length == 4 , "Wrong lenght" );
        assert( arr2.capacity == 6 , "Wrong capacity" );
        assert( arr2[] == [1,2,3,4] , "Wrong values" );
    }

    {
        auto arr = array(1,2,3);
        arr.reserve(10);

        assert( arr.length == 3 , "Wrong lenght" );
        assert( arr.capacity == 10 , "Wrong capacity" );
        assert( arr[] == [1,2,3] , "Wrong values" );
    }

    {
        // TODO: this may be wrong here
        //static struct T{ int x = 10; }
        //Array!T arr;
        //arr.reserveInit(10);

        //assert( arr.length == 0 , "Wrong lenght" );
        //assert( arr.capacity == 10 , "Wrong capacity" );
        //assert( arr[0].x == 10 , "Wrong init value" );
        //assert( arr[9].x == 10 , "Wrong init value" );
    }

    {
        auto arr = array(1,2,3);
        arr.resize(10);

        assert( arr.length == 10 , "Wrong lenght" );
        assert( arr.capacity == 10 , "Wrong capacity" );
        assert( arr[] == [1,2,3,0,0,0,0,0,0,0] , "Wrong values" );
    }

    {
        import std.range : iota;
        Array!int arr;
        arr.push(1,2, [3,4] , iota(5,7), array(7,8) );
        assert( arr.length == 8 , "Wrong lenght" );
        assert( arr.capacity == 12 , "Wrong capacity" );
        assert( arr[] == [1,2,3,4,5,6,7,8] , "Wrong values" );
    }

    {
        auto arr = array(1,2,3,5,6,7);
        arr.insert( 4,3 );
        assert( arr.length == 7 , "Wrong lenght" );
        assert( arr.capacity == 9 , "Wrong capacity" );
        assert( arr[] == [1,2,3,4,5,6,7] , "Wrong values" );
    }

    {
        auto arr = array(1,2,3,4,5,6,7,8,9,10);
        arr.pop;
        arr.pop(5);
        arr.remove(0);
        arr.removeStable(0);

        assert( arr.length == 2 , "Wrong lenght" );
        assert( arr.capacity == 15 , "Wrong capacity" );
        assert( arr[] == [2,3] , "Wrong values" );

    }

    {
        auto arr = array(1,2,3,4,5,6);
        arr.free;

        assert( arr.length == 0 , "Wrong lenght" );
        assert( arr.capacity == 0 , "Wrong capacity" );
        assert( arr[] == [] , "Wrong values" );

    }

    {
        auto arr = array(1,2,3,4,5);

        assert( arr[0 .. $] == [1,2,3,4,5], "Wrong opDollar" ) ;
        assert( arr[1 .. 4] == [2,3,4], "Wrong opSlice(start, end)" ) ;
        assert( arr.front == 1 , "Wrong front" ) ;
        assert( arr.back == 5 , "Wrong back" ) ;
        assert( cast(bool)arr == true, "Wrong opCast(bool)");
    }

    {
        //  TODO: test "in" operator? 
        //  not did because dont know if i will keep "in" operator
    }

    print("Allocation Counter: ", counter_allocator.counter);
    assert( counter_allocator.counter == 0 , "Allocations must be 0 at the end" );

}

//struct Array(Type, alias Allocator = default_allocator)
//{
//    import bclib.memory : Array;

//    enum RESERVE_FACTOR = 1.5;

//    Box!(Type[]) ptr;
//    size_t _length;

//    auto length()
//    {
//        return _length;
//    }

//    auto capacity()
//    {
//        return ptr.capacity;
//    }

//    this(Values...)(auto ref Values values)
//    {

//        import bclib.traits : isArray;
//        import std.range : isInputRange;
//        import std.algorithm : move;

//        size_t new_cap = 0;
//        static foreach (value; values)
//        {
//            {
//                alias ValueType = typeof(value);
//                static if (is(ValueType == Type))
//                {
//                    ++new_cap;
//                }
//                else static if (isArray!ValueType)
//                {
//                    new_cap += values.length;
//                }
//            }
//        }

//        reserve(new_cap);

//        static foreach (value; values)
//        {
//            {
//                alias ValueType = typeof(value);
//                static if (is(ValueType == Type))
//                {
//                    import bclib.memory : moveTo;

//                    value.moveTo(ptr[_length++]);
//                }
//                else static if (isArray!ValueType)
//                {
//                    import bclib.memory : moveTo;

//                    value[].moveTo(ptr[_length .. _length + value.length]);
//                    _length += value.length;
//                }
//                else static if (isInputRange!ValueType)
//                {
//                    foreach (ref val; value)
//                    {
//                        push(val);
//                    }
//                }
//            }
//        }
//    }

//    auto dup()
//    {
//        Array!(Type, Allocator) tmp;
//        tmp.ptr = ptr.dup;
//        return tmp;
//    }

//    void reserve(size_t size)
//    {
//        ptr.reserve(size);
//    }

//    void push(Values...)(auto ref Values values)
//    {
//        import bclib.traits : isArray;

//        size_t new_len = length;
//        static foreach (value; values)
//        {
//            {
//                alias ValueType = typeof(value);
//                static if (is(ValueType == Type))
//                {
//                    ++new_len;
//                }
//                else static if (isArray!ValueType)
//                {
//                    new_len += values.length;
//                }
//            }
//        }

//        if (new_len > capacity)
//            reserve(cast(size_t)((capacity ? capacity : 4) * RESERVE_FACTOR));

//        static foreach (value; values)
//        {
//            {
//                alias ValueType = typeof(value);
//                static if (is(ValueType == Type))
//                {
//                    import bclib.memory : moveTo;

//                    value.moveTo(ptr[_length++]);
//                }
//                else static if (isArray!ValueType)
//                {
//                    import bclib.memory : moveTo;

//                    value[].moveTo(ptr[_length .. _length + value.length]);
//                    _length += value.length;
//                }
//                else static if (isInputRange!ValueType)
//                {
//                    foreach (ref val; value)
//                    {
//                        push(val);
//                    }
//                }
//            }
//        }
//    }

//    alias put = push;

//    void insert( Type value , size_t index )
//    {
//    	import bclib.memory : destructor, moveTo, MemOverlap;

//    	if (length + 1 > capacity)
//            reserve(cast(size_t)((capacity ? capacity : 4) * RESERVE_FACTOR));

//    	ptr[index .. _length].moveTo( ptr[index + 1 .. _length + 1] );
//    	value.moveTo( ptr[index] );
//    	++_length;
//    }

//    void insertUnstable( Type value , size_t index )
//    {
//    	import bclib.memory : destructor, moveTo, swap;

//    	if (length + 1 > capacity)
//            reserve(cast(size_t)((capacity ? capacity : 4) * RESERVE_FACTOR));

//        swap( ptr[index], ptr[_length] );
//    	value.moveTo( ptr[index] );
//    	++_length;
//    }

//    void pop()
//    {
//        import bclib.memory : destructor;

//        --_length;
//        destructor(ptr[_length]);
//    }

//    void pop(size_t size)
//    {
//        import bclib.memory : destructor;

//        destructor(ptr[_length - size .. _length]);
//        _length -= size;
//    }

//    void free()
//    {
//        ptr.free();
//    }

//    alias opDollar = capacity;

//    ref opIndex(size_t index)
//    {
//        return ptr[index];
//    }

//    auto opSlice()
//    {
//        return ptr[0 .. $];
//    }

//    auto opSlice(size_t start, size_t end)
//    {
//        return ptr[start .. end];
//    }

//    ref front()
//    {
//    	return ptr[0];
//    }

//    ref back()
//    {
//    	return ptr[_length-1];
//    }

//    Type[] opBinaryRight(string op = "in")( Type needle )
//    {
//    	size_t index = 0;
//    	while(true)
//    	{
//    		if( ptr[index] == needle ) return ptr[ index .. _length ];
//    		++index;
//    		if( index == _length ) return null;
//    	}
//    }


//    void toString(alias IO)()
//    {
//        import bclib.io.print : formatter;

//        formatter!IO("[");
//        if (_length)
//        {
//            foreach (ref val; ptr[0 .. _length - 1])
//            {
//                formatter!IO(val, ", ");
//            }
//            formatter!IO(ptr[_length - 1]);
//        }
//        formatter!IO("]");
//    }
//}

//template array(alias Allocator = default_allocator)
//{
//    auto array(Values...)(auto ref Values values)
//    {
//        return Array!(Values[0], Allocator)(values);
//    }
//}

//import bclib.memory : alloc, alloc_zero, release;
//import bclib.allocator : sys_alloc, IAllocator;
//import bclib.traits : hasInterface;

//struct Array(Type, alias allocator = sys_alloc )
//{
//	static assert( hasInterface!(IAllocator, allocator), "allocator interface don't match" );
//	Type[] data;
//	size_t len;

//	Type* ptr(){ return data.ptr; }
//	size_t length(){ return len; }
//	size_t capacity(){ return data.length; }

//	this(ref Array other)
//	{
//		import std.traits : hasIndirections;
//		import bclib.memory : memcpy;

//		static if( hasIndirections!Type )  
//			alias _alloc = alloc_zero;
//		else
//			alias _alloc = alloc;

//		immutable other_len = other.length;
//		data = _alloc!(Type[], allocator)( other.length );	
//		memcpy( data.ptr, other.ptr, other_len * Type.sizeof );
//		len = other.len;
//	}

//	this( Values... )( auto ref Values values )
//	{
//		import std.math:  nextPow2;
//		import bclib.memory: memcpy;

//		reserve( Values.length );

//		static foreach(value ; values)
//		{{
//			memcpy( &data[len], &value, Type.sizeof );
//			++len;
//		}}
//	}

//	~this()
//	{
//		import bclib.memory : dtor;
//		dtor( data[ 0 .. len ] );

//		if( data ) 
//			release!(allocator)(data);

//		data = null;
//	}

//	void push( Values... )( auto ref Values values )
//	{
//		import bclib.traits:  isRValue;
//		import std.math : nextPow2;
//		import bclib.memory : memcpy, memset;

//		size_t new_len = len + Values.length;

//		if( new_len > capacity )
//			reserve( nextPow2( new_len ) );

//		static foreach(value ; values)
//		{{
//			memcpy( &data[len], &value, Type.sizeof );
//			++len;
//		}}

//		static foreach(value ; values)
//		{{
//			static if(isRValue!value)
//				memset( &value, 0, Type.sizeof );
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
//		//this should be decided by alloc, or not
//		static if( hasIndirections!Type )  
//			alias _alloc = alloc_zero;
//		else
//			alias _alloc = alloc;

//		if( capacity() == 0 )
//		{
//			data = _alloc!(Type[], allocator)( new_cap );	
//		}
//		else
//		{
//			auto new_data = _alloc!(Type[], allocator)( new_cap );	
//			memcpy( new_data.ptr, data.ptr, Type.sizeof * len );
//			release!(allocator)(data);
//			data = new_data;
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

//	auto opDollar(){ return len; }

//	void toIO(alias IO)()
//	{
//		import bclib.io : printl;

//		printl!IO("[");
//		if( len )
//		{
//			foreach(ref val ; data[0 .. len - 1])
//			{
//				printl!IO(val , ", ");
//			}
//			printl!IO(data[len-1] );	
//		}
//		printl!IO("]");
//	}

//}

//auto array( T... )( auto ref T t )
//{
//	return Array!(T[0])(t);
//}

//{	

//	T* ptr;
//	size_t len;
//	size_t cap;

//	/*
//	CTOR/BLIT/DTOR
//	*/

//	/*
//	ctor and put methods uses the same logic.
//	So for now i'm keeping only one code with mixin template tricks
//	*/
//	mixin template __PUT( values... )
//	{
//		bool action = {
//		import bcliblib.memory : memCopy, memMove, blit;
//		import bcliblib.traits : isRValue, isTemplateOf, isDArray;
//		import std.traits : TemplateOf;

//		auto new_cap = cap;
//		static foreach(value ; values)
//		{{

//			alias Type = typeof(value);
//			static if( isDArray!Type || isTemplateOf!( Type, TemplateOf!Array ) )
//			{
//				new_cap += value.length;
//			}
//			else
//			{
//				new_cap++;
//			}

//		}}

//		reserve( new_cap );

//		static foreach(value ; values)
//		{{
//			alias Type = typeof(value);

//			static if( isDArray!Type || isTemplateOf!( Type, TemplateOf!Array ) )
//			{
//				auto next_len = value.length;
//				static if( isRValue!value ){
//					memMove( ptr + len, value.ptr, next_len );	
//				} else {
//					memCopy( ptr + len, value.ptr, next_len );	
//					blit(ptr + len);
//				}
//				len+=next_len;
//			}
//			else
//			{
//				static if( isRValue!value ) {
//					memMove( ptr + len, &value );	
//				} else {
//					memCopy( ptr + len, &value );	
//					blit(ptr + len);
//				}

//				++len;
//			}
//		}}
//		return true;
//		}();
//	}

//	this( Values... )( auto ref Values values )
//	{
//		mixin __PUT!values;
//	}

//	this(this)
//	{
//		import bcliblib.memory : memCopy, blit;
//		auto new_ptr = cast(T*)Alloc.alloc( T.sizeof * len );
//		memCopy( new_ptr, ptr, len );
//		blit( new_ptr, len );
//		ptr = new_ptr;
//		cap = len;
//	}

//	~this()
//    {
//    	import bcliblib.memory : dtor;
//    	if(ptr)
//    	{
//    		dtor(ptr, len);
//    		Alloc.free(ptr);
//    		ptr = null;
//    	}
//    	len = 0;
//    	cap = 0;
//    }

//	/*
//	RETRIEVE
//	*/

//	size_t length(){ return len; }
//	size_t capacity(){ return cap; }

//	ref opIndex(size_t index)
//	{
//		return ptr[index];
//	}

//	int opApply(scope int delegate(ref T) fun ) 
//    {
//        int result;
//        foreach(i ; 0 .. len)
//        {
//        	result = fun( ptr[i] );
//			if( result ) break;
//        }
//        return result;
//    }

//    int opApply(scope int delegate(size_t, ref T) fun ) 
//    {
//        int result;
//        foreach(i ; 0 .. len)
//        {
//        	result = fun( i, ptr[i] );
//			if( result ) break;
//        }
//        return result;
//    }

//    auto opSlice()
//    {
//    	return ptr[0 .. len];
//    }

//    size_t opDollar()
//    {
//    	return len;
//    }

//	/*
//	CHANGE
//	*/

//	void reserve(size_t size)
//	{
//		//TODO: initialize new memory
//		//HOW? ctor method?
//		import bcliblib.memory : memCopy;
//		if( size > cap )
//		{
//			auto new_ptr = cast(T*)Alloc.alloc( T.sizeof * size );
//			if( ptr )
//			{
//				memCopy( new_ptr, ptr, len );
//				Alloc.free( ptr );
//			}
//			ptr = new_ptr;
//			cap = size;
//		}
//	}

//	void resize(size_t size)
//	{
//		import bcliblib.memory : blit, dtor;

//		immutable diff = cast(int)(size - len);
//		import bcliblib.io;
//		if( diff > 0 )
//		{
//			if( size > cap ) reserve( size );
//			blit(ptr + len, diff);
//			len = size;
//		}
//		else if( diff < 0 )
//		{
//			dtor(ptr + diff , -diff );
//			len = size;
//		}
//	}

//	alias length = resize;

//	void put(Values...)(auto ref Values values)
//	{
//		mixin __PUT!values;
//	}

//	alias opOpAssign(string op : "~") = put;
//	alias push                        = put;

//	void removeIndex( string op = "" )(size_t index)
//	{
//		import bcliblib.memory : dtor, memMove;

//		if( index < len ) 
//		{
//			dtor( ptr + index );
//			static if( op == "stable" )
//				memMove( ptr + index , ptr + index + 1, len - index - 1 );
//			else
//				memMove( ptr + index, ptr + len - 1 );

//			--len;		
//		}
//	}

//	void removeIndexStable(size_t index)
//	{
//		import bcliblib.memory : dtor, memMove;

//		dtor( ptr + index );
//		memMove( ptr + index, ptr + len - 1 );

//		--len;	
//	}

//	void removeValue(string op = "", U : T)(auto ref U value)
//	{
//		import bcliblib.memory : dtor, memMove;

//		foreach(index ; 0 .. len)
//		{
//			if( ptr[index] == value )
//			{
//				dtor( ptr + index );
//				static if( op == "stable" )
//					memMove( ptr + index , ptr + index + 1, len - index - 1 );
//				else
//					memMove( ptr + index, ptr + len - 1 );
//				--len;
//				return;
//			}
//		}
//	}

//	/*
//	OTHER
//	*/

//	auto dup()
//	{
//	}

//	auto opBinary(string op : "~", U)( auto ref U other )
//	{
//		return Array!(T, Alloc)( this, other );
//	}

//	void toIO(alias IO)()
//	{
//		import bcliblib.io : printl;

//		printl!IO("[ ");
//    	if( len )
//    	{
//    		foreach( i ; 0 .. len - 1 )
//    			printl!IO( ptr[i] , ", " );
//    	}
//    	printl!IO( ptr[len-1] );
//    	printl!IO(" ]");
//	}
//}

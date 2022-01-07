/++
	This module provides a basic allocator that implements `malloc and free.`

	Also set a global variable called `default_allocator` that is used as the default allocator for 
	all the lib.	

	A basic allocator must have this signature:
	---
	struct IAllocator
	{
		void* malloc(size_t);
		void free(void*);
	}

	To use property Allocator in `bclib` you must set allocator to be static variables. 
	All structures use the allocators as simple `alias`, so if you point to a stack local allocator, it will lost the
	frame pointer and crash. 
	The advantage is that structs don't have to store the allocator.
	---
+/
module bclib.memory.allocator.default_allocator;

///
unittest{
	struct LogAllocator
	{
    	import core.stdc.stdlib : 
    		_malloc = malloc,
    		_calloc = calloc,
    		_free = free;
		import core.stdc.stdio : printf;

		void* malloc(size_t size ){
			printf("Malloc : (%d)\n", size);
			return _malloc( size );
		}
		void* calloc(size_t size){
			printf("Calloc : (%d)\n", size);
			return _calloc( 1, size );
		}
		void free(void* ptr){
			_free(ptr);
			printf("Free : (%p)\n", ptr);
		}
	}

	auto log_allocator = LogAllocator();
	auto buffer        = log_allocator.malloc(100);
	log_allocator.free(buffer);
}

/**
	Basic Default Allocator
*/
struct DefaultAllocator
{
    import core.stdc.stdlib : _malloc = malloc, _calloc = calloc, _free = free;
    enum stdcAllocator = true;
    /**
	Allocate memory
	Params: size = Size in bytes of memory to be allocated
	Returns: Pointer to new allocated memory
	*/
    void* malloc(size_t size)
    {
        return _malloc(size);
    }

    /**
	Free memory
	Params: ptr = Pointer to the memory address to be freed
	*/
    void free(void* ptr)
    {
        _free(ptr);
    }
}

///global variable that are used by default on implementations that require an allocator.
public DefaultAllocator default_allocator;

unittest{

	DefaultAllocator allocator;
	auto ptr = allocator.malloc(100);
	assert( ptr !is null );
	allocator.free(ptr);
}
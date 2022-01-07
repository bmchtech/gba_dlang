module bclib.memory.allocator.counter_allocator;

import bclib.memory : default_allocator;

struct CounterAllocator( alias Allocator = default_allocator )
{
	size_t counter = 0;
	void* malloc(size_t size)
    {
    	++counter;
    	return Allocator.malloc(size);
    }

    void free(void* ptr)
    {
    	--counter;
    	Allocator.free(ptr);
    }
}

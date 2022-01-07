module bclib.allocator.allocator_interface;

public:
	
struct IAllocator
{
	void* malloc(size_t );
	void* calloc(size_t);
	void free( void* ptr );
}
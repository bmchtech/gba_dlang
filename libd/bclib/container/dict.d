module bclib.container.dict;

private import bclib.memory : default_allocator;

struct Dict( Key, Value, alias Allocator = default_allocator )
{
	import bclib.memory : Box;

	enum STARTING_SIZE = 64;
    enum RESERVE_FACTOR = 1.5;

	Box!(Key[],   Allocator) _keys;
	Box!(Value[], Allocator) _values;
	Box!(int[],   Allocator) _distances;
	size_t       			 _limit;

	size_t capacity(){ return _distances.capacity - _limit; }

	void initialize( size_t size = STARTING_SIZE )
	{
		import std.math : log2;

		_keys.reserve( size );
		_values.reserve( size );
		_distances.reserve( size );

		_distances.ptr[] = -1;

		_limit = cast(size_t) log2( size );
	}

	void resize()
	{
		import std.math : log2;
		import bclib.memory : moveTo;

		size_t new_cap = cast(size_t) (capacity * RESERVE_FACTOR);

		Dict!(Key, Value, Allocator) tmp;

		tmp.initialize( new_cap );

		foreach( i ; 0 .. capacity )
		{
			if( _distances[i] != -1 )
			{
				tmp[ _keys[i] ] = _values[i];
			}
		}

		_keys.free();
		_values.free();
		_distances.free();

		tmp._keys.moveTo( _keys );
		tmp._values.moveTo( _values );
		tmp._distances.moveTo( _distances );

		_limit = cast(size_t) log2( new_cap );

	}

	void opIndexAssign( Value value, Key key )
	{	
		import bclib.memory : swap, moveTo, destructor;

		if( capacity() == 0 ) initialize();

		size_t index = key % capacity;
		int    distance = 0;

		while(true)
		{
			auto dict_distance = _distances[index];
			if( dict_distance == -1 )
			{
				key.moveTo( _keys[index] );
				value.moveTo( _values[index] );
				_distances[index] = distance;
				return;
			}
			if( _keys[index] == key )
			{
				destructor( _keys[index] );
				destructor( _values[index] );

				key.moveTo( _keys[index] );
				value.moveTo( _values[index] );
				_distances[index] = distance;
				return;

			}

			if( distance > dict_distance  )
			{
				swap( _values[index], value );
				swap( _keys[index], key );
				swap( _distances[index], distance );
			}
			
			++distance;
			++index;

			if( distance == _limit ) break;

		}
		resize();
		this[ key ] = value;
	}

	auto opIndex( Key key )
	{
		//static Value not_found;
		auto index = key % capacity;
		while(true)
		{
			if( _keys[ index ] == key ) return _values[index];
			if( _distances[index] == -1 ){
				return Value();	
			} 
			++index;
		}
	}

	auto getOr( Key key, Value default_value )
	{
		import std.algorithm : move;
		auto index = key % capacity;
		while(true)
		{
			if( _keys[ index ] == key ) return _values[index];
			if( _distances[index] == -1 ) return default_value;
			++index;
		}
	}

	void free()
	{
		_keys.free();
		_values.free();
		_distances.free();
	}
}
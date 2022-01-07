module bclib.memory.util;

import bclib.memory : default_allocator;

auto alloc(Type, alias Allocator = default_allocator)(const size_t size = 1)
{
    import bclib.traits : isArray, ArrayElement;

    static if (isArray!Type)
    {
        alias Element = ArrayElement!Type;
        return (cast(Element*) Allocator.malloc( Element.sizeof * size))[0 .. size];
    }
    else
    {
        return cast(Type*) Allocator.malloc(Type.sizeof);
    }
}

auto allocInit(Type, alias Allocator = default_allocator)(const size_t size = 1)
{
    import std.traits : isArray;
    import std.range : ElementType;

    // TODO: now i´m setting things to 0. But allocInit must set values to .init values ( zero out with memset if struct is isZeroed)

    static if (isArray!Type)
    {
        alias Element = typeof(Type.init[0]);
        static if( is(typeof( Allocator.stdcAllocator ) ) )
        {
            import core.stdc.stdlib : calloc;
            return (cast(Element*) calloc( size , Element.sizeof ))[0 .. size];
        }
        else
        {
            
            auto ptr = (cast(Element*) Allocator.malloc(Element.sizeof * size) )[0 .. size];
            ptr.memZero;
            return ptr;
        }
    }
    else
    {
        static if( is( typeof( Allocator.stdcAllocator ) ) )
        {
            import core.stdc.stdlib : calloc;
            return cast(Type*) calloc( 1, Type.sizeof );
        }
        else
        {
            auto ptr = cast(Type*) Allocator.malloc(Type.sizeof);
            ptr.memZero;
            return ptr;
        }
    }
}

void dealloc(alias Allocator = default_allocator, Type)(ref Type value)
{
    import std.traits : isArray, isPointer, PointerTarget, Unqual, hasElaborateDestructor;
    import bclib.error : panic;

    static if (isArray!Type)
    {
        alias Element = typeof(Type.init[0]);
        if (value !is null)
        {
            Allocator.free(cast(Unqual!(Type)*) value.ptr);
            value = null;
        }
    }
    else static if (isPointer!Type)
    {
        alias Element = PointerTarget!Type;
        if (value !is null)
        {
            Allocator.free(cast(Unqual!(Type)*) value);
            value = null;
        }
    }
    else
        panic("'free' argument must be a pointers or an array.");
}

void destructor(Type)(auto ref Type value)
{
    import bclib.traits : hasElaborateDestructor, isArray, ArrayElement;

    static if( isArray!Type )
    {
        static if( hasElaborateDestructor!(ArrayElement!Type) )
        {
            foreach(ref val ; value)
                val.__xdtor;
        }        
    }
    else
    {
        static if( hasElaborateDestructor!Type )
        {
            value.__xdtor;
        }    
    }
}

void memZero(Type)(auto ref Type value)
{
    import core.stdc.string : memset;
    import bclib.traits : isArray, ArrayElement;

    static if( isArray!Type )
    {
        memset(value.ptr, 0, ArrayElement!(Type).sizeof * value.length);
    }
    else
    {
        memset(&value, 0, Type.sizeof);
    }
}

void copyTo(Type)(Type source, Type target)
{
    import bclib.traits : isArray, isPointer, ArrayElement, PointerTarget, Unqual;
    import core.stdc.string : memcpy;

    static if( isArray!Type )
    {
        memcpy( target.ptr , source.ptr, ArrayElement!Type.sizeof * source.length);
    }
    else static if( isPointer!Type )
    {
        memcpy(target, source, PointerTarget!(Type).sizeof);
    }
    else
    {
        panic("'copyTo' arguments must be pointers of arrays");
    }
}

enum MemOverlap = true;

void moveTo(Type, alias overlap = false)(ref Type* source, ref Type* target)
{
    import bclib.traits : hasIndirections;
    import core.stdc.string : memcpy, memmove;


    static if( !overlap )
        memcpy(target, source, Type.sizeof);
    else 
        memmove(target, source, Type.sizeof);

    static if (hasIndirections!Type)
        memZero(source);
}

void moveTo(Type,alias overlap = false)(Type[] source, Type[] target)
{
    import bclib.traits : Unqual, hasIndirections;
    import core.stdc.string : memcpy, memmove;

    alias CleanType = Unqual!(Type);

    static if( !overlap )
        memcpy( cast(CleanType*) target.ptr, cast(CleanType*) source.ptr, Type.sizeof * source.length);
    else
        memmove( cast(CleanType*) target.ptr, cast(CleanType*) source.ptr, Type.sizeof * source.length);

    source = null;
}

void moveTo(Type,alias overlap = false)(ref Type source, ref Type target)
{
    import bclib.traits : hasIndirections;
    import core.stdc.string : memcpy, memmove;

    static if( !overlap )
        memcpy(&target, &source, Type.sizeof);
    else
        memmove(&target, &source, Type.sizeof);

    static if (hasIndirections!Type)
        memZero(source);

}

void assignAllTo(Type)(Type[] source, Type[] target)
{
    import bclib.traits : hasIndirections, isCopyable;

    static if (hasIndirections!Type)
    {
        foreach (index; 0 .. source.length)
        {
            static if( isCopyable!Type )
            {
                target[index] = source[index];
            }
            else
            {
                target[index] = source[index].dup;
            }
        }
    }
    else
    {
        source.copyTo(target);
    }
}

void swap(T)( ref T value1, ref T value2 )
{   
    import bclib.memory : moveTo;
    T tmp = void;
    value1.moveTo( tmp );
    value2.moveTo( value1 );
    tmp.moveTo( value2 );
}
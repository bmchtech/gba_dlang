module bclib.adt;

public enum This;

struct ADT(T...)
{
    import std.meta : ReplaceAll;
    //import std.variant : This;

    alias Types = T;

    alias InternalTypes = ReplaceAll!(This*, typeof(this)*, Types);

    //TODO:  is better to choose tag depending on max(Types) lenghts, or just size_t for a better memory layout?

    //private
    size_t tag;
    union
    {
        InternalTypes values;
    }

    //static foreach (index, Type; InternalTypes)
    //{
    //    this(Type value)
    //    {

    //        values[index] = value;
    //        tag = index;
    //    }

    //    void opAssign(Type value)
    //    {
    //        values[index] = value;
    //        tag = index;
    //    }
    //}



    //auto match(Visitors...)()
    //{

    //    enum VisitorIndices = () {
    //        import std.algorithm : canFind, find;
    //        import std.range : iota;
    //        import std.meta : staticIndexOf;
    //        import std.traits : isFunction, isFunctionPointer, isDelegate, Parameters;

    //        int[InternalTypes.length] indices;
    //        indices[] = -1;

    //        static foreach (Index, F; Visitors)
    //        {
    //            static if (isFunction!F || isFunctionPointer!F || isDelegate!F)
    //            {
    //                indices[staticIndexOf!(Parameters!(F)[0], InternalTypes)] = Index;
    //            }
    //        }
    //        static foreach (Index, F; Visitors)
    //        {
    //            static if (!(isFunction!F || isFunctionPointer!F || isDelegate!F))
    //            {
    //                {
    //                    auto f = indices[].find(-1);
    //                    if (f.length)
    //                        f[0] = Index;
    //                }
    //            }
    //        }
    //        //TODO: check if canFind -1; if yes then is not exaustive match
    //        return indices;
    //    }();

    //    final switch (tag)
    //    {
    //        static foreach (TypeIndex; 0 .. InternalTypes.length)
    //        {
    //    		case TypeIndex:
    //            	return Visitors[VisitorIndices[TypeIndex]](values[TypeIndex]);
    //        }
    //    }
    //}

    ////get or exit
    //auto get(Type)()
    //{
    //    import std.meta : staticIndexOf;

    //    enum TypeIndex = staticIndexOf!(Type, InternalTypes);

    //    if (tag == TypeIndex)
    //        return values[TypeIndex];
    //    else
    //        return Type.init;
    //}

    //auto isType(Type)()
    //{
    //    import std.meta : staticIndexOf;

    //    enum TypeIndex = staticIndexOf!(Type, InternalTypes);
    //    return tag == TypeIndex;
    //}
}

//struct TSome(T)
//{
//    private T value;
//    alias value this;
//}

//auto Some(T)(T value)
//{
//    return value;
//}

//struct TNone
//{
//}

//auto None()
//{
//    return TNone();
//}

//struct Maybe(T)
//{
//    ADT!(T, TNone) value;
//    alias value this;

//    this(T)(T value)
//    {
//        this.value = typeof(this.value)(value);
//    }

//    static Some(T value)
//    {
//        return Maybe(value);
//    }

//    static None()
//    {
//        return Maybe(TNone());
//    }
//}

//auto Ok(T)(T value)
//{
//    return value;
//}

//struct TErr(T)
//{
//    private T value;
//    alias value this;

//    @property 
//    auto teste(){return 1;}
//}

//auto Err(T)(T value)
//{
//    return TErr!(T)(value);
//}

//struct Result(OK, E)
//{
//    ADT!(OK, TErr!E) value;
//    alias value this;

//    this(T)(T value)
//    {
//        this.value = typeof(this.value)(value);
//    }

//    static Ok(T)(T value)
//    {
//        return Result(value);
//    }

//    static Err(T)(T value)
//    {
//        return Result(TErr!(T)(value));
//    }

//    bool empty = false;

//    auto front(){
//    	print( value.unsafeGet!(OK) );
//    	return value.unsafeGet!(OK);
//    }
//    auto popFront(){
//    	empty = true;
//    }
//}
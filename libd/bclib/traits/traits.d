module bclib.traits.traits;

public:

import std.traits;

alias getAllMembers( alias T )                      = __traits(allMembers, T);
alias getMember_( alias T, string Func )            = __traits( getMember, T, Func );
alias getFunctionReturnType( alias T )              = ReturnType!( T );
alias getFunctionReturnType( alias T, string Func)  = ReturnType!( getMember_!(T, Func) );
alias getFunctionParamsType( alias Func )           = Parameters!Func;
alias getFunctionParamsType( alias T, string Func ) = Parameters!( getMember_!( T, Func ) );
alias getFunctionParamsName( alias Func )           = ParameterIdentifierTuple!Func;
alias getFunctionParamsName( alias T, string Func ) = ParameterIdentifierTuple!( getMember_!( T, Func ) );

template hasInterface( alias I, alias T )
{
    import std.traits : isFunction;

    enum hasInterface = (){
        bool has_interface = true;
        static foreach( member ; getAllMembers!I )
        {{
            alias I_Member = getMember_!( I, member );
            static if( isFunction!( I_Member ) )
            {{
                alias I_ReturnType = getFunctionReturnType!(I_Member);
                alias I_Params     = getFunctionParamsType!(I_Member);

                static if( is( typeof( getMember_!( T, member ) ) ) )  
                {{
                    alias T_Member     = getMember_!( T, member );
                    alias T_ReturnType = getFunctionReturnType!(T_Member);
                    alias T_Params     = getFunctionParamsType!(T_Member);

                    static if( !is( I_ReturnType == T_ReturnType ) ) has_interface = false;
                    static if( !is( I_Params     == T_Params ) )     has_interface = false;
                }}
                else has_interface = false;
            }}
        }}
        return has_interface;
    }();
}

enum isTemplateOf( T1, alias T2 ) =  __traits(isSame, TemplateOf!(T1), T2) ;

template isAny(Value, Values...)
{
    static if(Values.length)
    {
        static if( is( Value == Values[0] ) )  
        {
            enum isAny = true;
        }
        else
        {
            enum isAny = isAny!(Value, Values[1 .. $]);
        }
    }
    else
    {
        enum isAny = false;
    }
}

template hasMember( T, Members... )
{
    static if( Members.length == 1 )
        enum hasMember = mixin("is( typeof( T.init."~Members[0]~" ) )");
    else
        enum hasMember = hasMember!(T, Members[0]) && hasMember!(T, Members[1 .. $]);
}

enum isDArray( T ) = T.stringof[$-2 .. $] == "[]";

//Work with auto ref Templates
enum isRValue(alias value) = !__traits(isRef, value);

enum hasDtor(T) = hasElaborateDestructor!T;

void callDtor( Type )( ref Type value )
{
    static if( hasElaborateDestructor!( Type ) )
    {
        value.__xdtor;
    }
}

alias ArrayElement( T ) = typeof( T.init[0] );

template isBCArray( T )
{
    import bclib.container.array : Array;
    static if( isTemplateOf!(T, Array) )
        enum isBCArray = true;
    else
        enum isBCArray = false;
}

enum hasSlice( T ) = is( typeof( T.init[] ));


template isArray( T )
{
    import std.traits : _isArray = isArray;
    static if( _isArray!T  )
        enum isArray = true;
    else
        enum isArray = false;
}

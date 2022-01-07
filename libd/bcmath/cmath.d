/**
 * Type generic standard math functions and constants.
 */
module bcmath.cmath;

import cmath = core.stdc.math;
import dmath = std.math;
import std.meta : AliasSeq;

import bcmath.misc : FloatType;

private enum functions = AliasSeq!(
    "acos",
    "asin",
    "atan",
    "atan2",
    "cos",
    "sin",
    "tan",
    "acosh",
    "asinh",
    "atanh",
    "cosh",
    "sinh",
    "tanh",
    "exp",
    "exp2",
    "expm1",
    "frexp",
    "ilogb",
    "ldexp",
    "log",
    "log10",
    "log1p",
    "log2",
    "logb",
    "modf",
    "scalbn",
    "scalbln",
    "cbrt",
    "fabs",
    "hypot",
    "pow",
    "sqrt",
    "erf",
    "erfc",
    "lgamma",
    "tgamma",
    "ceil",
    "floor",
    "nearbyint",
    "rint",
    "lrint",
    "llrint",
    "round",
    "lround",
    "llround",
    "trunc",
    "fmod",
    "remainder",
    "remquo",
    "copysign",
    "nan",
    "nextafter",
    "nexttoward",
    "fdim",
    "fmax",
    "fmin",
    "fma",
);

static foreach (f; functions)
{
    mixin(q{alias } ~ f ~ q{ = MathFunc!} ~ "\"" ~ f ~ "\".opCall;");
}

private enum constants = AliasSeq!(
    "E", 
    "PI", 
    "PI_2", 
    "PI_4", 
    "M_1_PI", 
    "M_2_PI", 
    "M_2_SQRTPI", 
    "LN10", 
    "LN2", 
    "LOG2", 
    "LOG2E", 
    "LOG2T", 
    "LOG10E", 
    "SQRT2", 
    "SQRT1_2",
);

static foreach (c; constants)
{
    mixin(q{alias } ~ c ~ q{ = MathConst!} ~ "\"" ~ c ~ "\";");
}

// Private helpers for templated math function calls
private string cfuncname(T : double, string f)()
{
    return f;
}
private string cfuncname(T : real, string f)()
{
    return f ~ "l";
}
private string cfuncname(T : float, string f)()
{
    return f ~ "f";
}
private string cfuncname(T : long, string f)()
{
    return f ~ "f";
}

/**
 * Template wrapper for standard library math functions.
 * 
 * On CTFE, calls the D runtime math (std.math) functions.
 * On runtime, calls the right variant of the C runtime math (core.stdc.math) functions.
 */
template MathFunc(string f)
{
    template opCall(T, Args...)
    {
        import std.traits : ReturnType;
        private alias dfunc = __traits(getMember, dmath, f);
        private alias cfunc = __traits(getMember, cmath, cfuncname!(T, f)());

        nothrow @nogc ReturnType!cfunc opCall(T arg1, Args args)
        {
            if (__ctfe)
            {
                // Use D functions on CTFE
                return dfunc(cast(FloatType!T) arg1, args);
            }
            else
            {
                // Use the appropriate C function on runtime
                return cfunc(arg1, args);
            }
        }
    }
}

/// Template wrapper for typed versions of the standard library math constants.
private template MathConst(string c)
{
    private alias dconst = __traits(getMember, dmath, c);
    enum MathConst(T = real) = cast(FloatType!T) dconst;
}

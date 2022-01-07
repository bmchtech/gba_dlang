/**
 * Miscelaneous math functions and definitions.
 */
module bcmath.misc;

import std.math : PI;
import std.traits : isFloatingPoint, isNumeric;

/// Templated alias for a floating point type correspondent with `T`.
template FloatType(T)
if (isNumeric!T)
{
    static if (isFloatingPoint!T)
    {
        alias FloatType = T;
    }
    else
    {
        alias FloatType = float;
    }
}

/// Convert angle from degrees to radians.
FloatType!T degreesToRadians(T)(const T degrees)
{
    return degrees * (PI / 180.0);
}
alias deg2rad = degreesToRadians;  /// ditto

/// Convert angle from radias to degrees.
FloatType!T radiansToDegrees(T)(const T radians)
{
    return radians * (180.0 / PI);
}
alias rad2deg = radiansToDegrees;  /// ditto

/// Linearly interpolates values `from` and `to` by `amount`.
T lerp(T, U)(const T from, const T to, const U amount)
{
    enum U one = 1;
    return cast(T) (amount * to + (one - amount) * from);
}
/// Linearly interpolates the values from `fromTo` by `amount`.
T lerp(T, U)(const T[2] fromTo, const U amount)
{
    return lerp(fromTo[0], fromTo[1], amount);
}

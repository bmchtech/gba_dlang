/**
 * Inclusive scalar value ranges for interpolating and remapping values.
 */
module bcmath.valuerange;

/// Remap `value` from the range [inputStart, inputEnd] to [outputStart, outputEnd].
T remap(T)(const T value, const T inputStart, const T inputEnd, const T outputStart, const T outputEnd)
{
    return (value - inputStart) / (inputEnd - inputStart) * (outputEnd - outputStart) + outputStart;
}

/// Remap `value` from the `input` range to `output` range.
T remap(T)(const T value, const ValueRange!T input, const ValueRange!T output)
{
    return remap(value, input.from, input.to, output.from, output.to);
}

/**
 * Range of scalar values, for more easily interpolating and remapping them.
 */
struct ValueRange(T)
{
    /// Alias for ValueRange element type.
    alias ElementType = T;
    /// Value that starts the range.
    T from = 0;
    /// Value that ends the range.
    T to = 1;

    /// Construct from both values.
    this(const T from, const T to)
    {
        this.from = from;
        this.to = to;
    }
    /// Construct from array of values.
    this(const T[2] values)
    {
        from = values[0];
        to = values[1];
    }

    /// Invert ValueRange inplace.
    ref ValueRange invert() return
    {
        import std.algorithm : swap;
        swap(from, to);
        return this;
    }

    /// Returns an inverted copy of ValueRange, the range [to, from].
    ValueRange inverted() const
    {
        typeof(return) r = this;
        return r.invert();
    }

    /// Linearly interpolates range by `amount`.
    T lerp(U)(const U amount) const
    {
        import bcmath.misc : lerp;
        return lerp(from, to, amount);
    }

    /// Remap `value` from this range to `newRange`.
    T remap(const T value, const ValueRange newRange) const
    {
        return .remap(value, this, newRange);
    }

    /// Return `value` normalized by this range, so that 0 represents the start of the range and 1 represents the end of it.
    T normalize(const T value) const
    {
        return (value - from) / (to - from);
    }

    /// Returns the distance between the range start and end.
    T distance() const
    {
        return to - from;
    }
}

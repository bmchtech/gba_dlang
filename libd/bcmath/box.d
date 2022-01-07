/**
 * Type and dimension generic Axis-Aligned Bounding Box (AABB).
 */
module bcmath.box;

@safe @nogc nothrow pure:

version (unittest)
{
    alias Rectangle = BoundingBox!(float, 2, BoundingBoxOptions.storeSize);
}

/// Options for the BoundingBox template.
enum BoundingBoxOptions
{
    /// Default options: store `end` corner information and derive `size`.
    none = 0,
    /// Store `size` information and derive `end` corner.
    storeSize = 1,
}

/**
 * Generic Axis-Aligned Bounding Box.
 *
 * May be stored as the starting and ending corners,
 * or as starting point and size.
 *
 * Params:
 *   T = Element type
 *   N = Box dimension, must be positive
 *   options = Additional options, like storage meaning
 */
struct BoundingBox(T, uint Dim, BoundingBoxOptions options = BoundingBoxOptions.none)
if (Dim > 0)
{
    import bcmath.vector : Vector;

    alias ElementType = T;
    /// Bounding Box dimension.
    enum dimension = Dim;
    /// Point type, a Vector with the same type and dimension.
    alias Point = Vector!(T, Dim);
    private alias PointArg = T[Dim];
    /// Size type, a Vector with the same type and dimension.
    alias Size = Vector!(T, Dim);
    private alias SizeArg = T[Dim];

    private enum storeSize = options & BoundingBoxOptions.storeSize;

    /// Starting BoundingBox corner.
    Point origin = 0;

    static if (storeSize)
    {
        /// Size of a BoundingBox, may be negative.
        Size size = 1;

        /// Get the `end` corner of a BoundingBox.
        @property Point end() const
        {
            return origin + size;
        }
        /// Set the `end` corner of a BoundingBox.
        @property void end(const PointArg value)
        {
            size = value - origin;
        }

        /// Cast BoundingBox to another storage type.
        auto opCast(U : BoundingBox!(T, Dim, options ^ BoundingBoxOptions.storeSize))() const
        {
            typeof(return) box = {
                origin = this.origin,
                end = this.end,
            };
            return box;
        }
    }
    else
    {
        /// Ending BoundingBox corner.
        Point end = 1;

        /// Get the size of a BoundingBox, may be negative.
        @property Size size() const
        {
            return end - origin;
        }
        /// Set the size of a BoundingBox, using `origin` as the pivot.
        @property void size(const SizeArg value)
        {
            end = origin + value;
        }

        /// Cast BoundingBox to another storage type.
        auto opCast(U : BoundingBox!(T, Dim, options ^ BoundingBoxOptions.storeSize))() const
        {
            typeof(return) box = {
                origin = this.origin,
                size = this.size,
            };
            return box;
        }
    }

    /// Get the width of a BoundingBox, may be negative.
    @property T width() const
    {
        return size.width;
    }
    /// Set the width of a BoundingBox, using `origin` as the pivot.
    @property void width(const T value)
    {
        auto s = size;
        s.width = value;
        size = s;
    }

    static if (Dim >= 2)
    {
        /// Get the height of a BoundingBox, may be negative.
        @property T height() const
        {
            return size.height;
        }
        /// Set the height of a BoundingBox, using `origin` as the pivot.
        @property void height(const T value)
        {
            auto s = size;
            s.height = value;
            size = s;
        }
    }
    static if (Dim >= 3)
    {
        /// Get the depth of a BoundingBox, may be negative.
        @property T depth() const
        {
            return size.depth;
        }
        /// Set the depth of a BoundingBox, using `origin` as the pivot.
        @property void depth(const T value)
        {
            auto s = size;
            s.depth = value;
            size = s;
        }
    }

    /// Get the central point of BoundingBox.
    @property Point center() const
    {
        return (origin + end) / 2;
    }
    /// Set the central point of BoundingBox.
    @property void center(const PointArg value)
    {
        immutable delta = value - center;
        origin += delta;
        static if (!storeSize)
        {
            end += delta;
        }
    }
    /// Ditto
    @property void center(const T value)
    {
        center(Point(value));
    }
    ///
    unittest
    {
        Rectangle rect;
        rect.center = 2;
        assert(rect.size == Rectangle.init.size);
        rect.center = [1, 2];
        assert(rect.size == Rectangle.init.size);
    }

    /// Returns whether BoundingBox have any non-positive size values.
    @property bool empty() const
    {
        import std.algorithm : any;
        return size[].any!"a <= 0";
    }

    /// Returns a copy of BoundingBox with sorted corners, so that `size` only presents non-negative values.
    BoundingBox abs() const
    {
        import std.algorithm : swap;
        typeof(return) result = this;
        foreach (i; 0 .. result.dimension)
        {
            if (result.origin[i] < result.end[i])
            {
                swap(result.origin[i], result.end[i]);
            }
        }
        return result;
    }

    /// Get the volume of the BoundingBox.
    @property T volume() const
    {
        import std.algorithm : fold;
        return size.fold!"a * b";
    }

    static if (Dim == 2)
    {
        /// 2D area is the same as generic box volume.
        alias area = volume;
    }

    static if (Dim == 3)
    {
        /// Get the surface area of a 3D BoundingBox.
        @property T surfaceArea() const
        {
            auto s = size;
            return 2 * (s.x * s.y + s.y * s.z + s.x * s.z);
        }
    }

    /// Returns a new BoundingBox by insetting this one by `delta`.
    BoundingBox inset(const SizeArg delta)
    {
        immutable halfDelta = Size(delta) / 2;
        typeof(return) box;
        box.origin = this.origin + halfDelta;
        box.size = this.size - halfDelta;
        return box;
    }
    /// Ditto
    BoundingBox inset(const T delta)
    {
        return inset(Size(delta));
    }

    /// Returns true if Point is contained within BoundingBox.
    bool contains(T, uint N)(const auto ref T[N] point) const
    {
        import std.algorithm : all, map, min;
        import std.range : iota;
        enum minDimension = min(this.dimension, N);
        return iota(minDimension).map!(i => point[i] >= origin[i] && point[i] <= end[i]).all;
    }

    /// Returns true if `box` is completely contained within `this` BoundingBox.
    bool contains(Args...)(const auto ref BoundingBox!(T, Args) box) const
    {
        return contains(box.origin) && contains(box.end);
    }

    /// Returns the intersection between two BoundingBoxes.
    auto intersection(Args...)(const auto ref BoundingBox!(T, Args) box) const
    {
        import std.algorithm : map, min, max;
        import std.range : iota, zip;
        enum minDimension = min(this.dimension, box.dimension);
        BoundingBox!(T, minDimension, options) result;
        result.origin = zip(this.origin[0 .. minDimension], box.origin[0 .. minDimension]).map!(max);
        result.end = zip(this.end[0 .. minDimension], box.end[0 .. minDimension]).map!(min);
        return result;
    }

    /// Returns true if `box` intersects `this`.
    auto intersects(Args...)(const auto ref BoundingBox!(T, Args) box) const
    {
        return !intersection(box).empty;
    }
}

/// Common alias for Bounding Boxes.
alias AABB = BoundingBox;

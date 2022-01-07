/**
 * Type and dimension generic Affine Transformations backed by possibly compacted Matrices.
 */
module bcmath.transform;

/// Options for the Transform template.
enum TransformOptions
{
    /// Default options.
    none = 0,
    /// Use a compact Matrix type, as Affine Transformation matrices always
    /// have the last row [0 ... 0 1]
    compact = 1 << 0,
}

@nogc @safe pure nothrow:

/**
 * Affine Transformation matrix.
 *
 * Params:
 *   T = Value types, should be numeric
 *   Dim = Space dimensions, pass 2 for 2D, 3 for 3D, etc...
 *   options = Additional options
 */
struct Transform(T, uint Dim, TransformOptions options = TransformOptions.none)
if (Dim > 0)
{
    import std.algorithm : min;

    import bcmath.cmath : cos, sin;
    import bcmath.matrix : Matrix;
    import bcmath.misc : FloatType, degreesToRadians;

    alias ElementType = T;
    /// Transform dimension.
    enum dimension = Dim;
    /// Whether Transform is compact.
    enum bool isCompact = options & TransformOptions.compact;
    static if (!isCompact)
    {
        /// The underlying matrix type
        alias MatrixType = Matrix!(T, Dim + 1, Dim + 1);
        private alias CompactTransform = Transform!(T, Dim, TransformOptions.compact);

        private static bool isAffineTransformMatrix(const MatrixType matrix)
        {
            import std.algorithm : equal;
            import std.range : chain, only, repeat;
            return matrix.rows[Dim].equal(repeat(Dim, 0).chain(only(1)));
        }
    }
    else
    {
        /// The underlying matrix type
        alias MatrixType = Matrix!(T, Dim + 1, Dim);
        private alias CompactTransform = typeof(this);

        private static bool isAffineTransformMatrix(const MatrixType _)
        {
            return true;
        }
    }
    private alias FT = FloatType!T;

    /// Cast between Transform types of any dimension.
    U opCast(U : Transform!(T, Args), Args...)() const
    {
        typeof(return) result;
        return copyInto(result);
    }

    /// Copy Transform contents into `target` transform of any dimension and options.
    auto ref copyInto(Args...)(ref return Transform!(T, Args) target) const
    {
        copyInto(target.matrix);
        return target;
    }

    /// Copy Transform contents into a matrix of Transform-like dimensions.
    auto ref copyInto(uint C, uint R)(ref return Matrix!(T, C, R) target) const
    if (C == R || C == R + 1)
    {
        static if (target.rowSize == this.matrix.rowSize)
        {
            matrix.copyInto(target);
        }
        else
        {
            enum minDimension = min(C - 1, this.dimension);
            foreach (i; 0 .. minDimension)
            {
                target[i][0 .. minDimension] = this.matrix[i][0 .. minDimension];
            }
            // translations must be in the last column, so copy them separately
            target[$-1][0 .. minDimension] = this.matrix[$-1][0 .. minDimension];
        }
        return target;
    }


    /// The underlying matrix.
    MatrixType matrix = MatrixType.fromDiagonal(1);
    alias matrix this;

    /// The identity Transform.
    enum identity = Transform.init;

    /// Construct a Transform from matrix.
    this()(const auto ref MatrixType mat)
    in { assert(isAffineTransformMatrix(mat), "Matrix is not suitable for affine transformations"); }
    do
    {
        this.matrix = mat;
    }

    /// Reset a Transform to identity.
    ref Transform setIdentity() return
    {
        this = identity;
        return this;
    }

    /// Transform an array of values of any dimension.
    T[N] transform(uint N)(const auto ref T[N] values) const
    {
        enum minDimension = min(N, Dim + 1);
        typeof(return) result;
        foreach (i; 0 .. Dim)
        {
            T sum = 0;
            foreach (j; 0 .. minDimension)
            {
                sum += matrix[j, i] * values[j];
            }
            static if (N < Dim + 1)
            {
                sum += matrix[$-1, i];
            }
            result[i] = sum;
        }
        return result;
    }
    /// Transform an array of values of any dimension.
    auto opBinary(string op : "*", uint N)(const auto ref T[N] values) const
    {
        return transform(values);
    }

    /// Constructs a new Transform representing a translation.
    static Transform fromTranslation(uint N)(const auto ref T[N] values)
    {
        enum minDimension = min(N, Dim);
        Transform t;
        t[$-1][0 .. minDimension] = values[0 .. minDimension];
        return t;
    }
    /// Apply translation in-place.
    /// Returns: this
    ref Transform translate(uint N)(const auto ref T[N] values) return
    {
        enum minDimension = min(N, Dim);
        this[$-1][0 .. minDimension] += values[0 .. minDimension];
        return this;
    }
    /// Returns a translated copy of Transform.
    Transform translated(uint N)(const auto ref T[N] values) const
    {
        Transform t = this;
        return t.translate(values);
    }

    /// Constructs a new Transform representing a scaling.
    static Transform fromScaling(uint N)(const auto ref T[N] values)
    {
        enum minDimension = min(N, Dim);
        Transform t;
        foreach (i; 0 .. minDimension)
        {
            t[i, i] = values[i];
        }
        return t;
    }
    /// Apply scaling in-place.
    /// Returns: this
    ref Transform scale(uint N)(const auto ref T[N] values) return
    {
        return this.combine(CompactTransform.fromScaling(values));
    }
    /// Returns a scaled copy of Transform.
    Transform scaled(uint N)(const auto ref T[N] values) const
    {
        Transform t = this;
        return t.scale(values);
    }

    // 2D transforms
    static if (Dim >= 2)
    {
        /// Constructs a new Transform representing a shearing.
        static Transform fromShearing(uint N)(const auto ref T[N] values)
        {
            enum minDimension = min(N, Dim);
            Transform t;
            foreach (i; 0 .. minDimension)
            {
                foreach (j; 0 .. Dim)
                {
                    if (j != i)
                    {
                        t[j, i] = values[i];
                    }
                }
            }
            return t;
        }
        /// Apply shearing in-place.
        /// Returns: this
        ref Transform shear(uint N)(const auto ref T[N] values) return
        {
            return this.combine(CompactTransform.fromShearing(values));
        }
        /// Returns a sheared copy of Transform.
        Transform sheared(uint N)(const auto ref T[N] values) const
        {
            Transform t = this;
            return t.shear(values);
        }

        /// Constructs a new Transform representing a 2D rotation.
        /// Params:
        ///   angle = Rotation angle in radians
        static Transform fromRotation(const FT angle)
        {
            Transform t;
            immutable auto c = cos(angle), s = sin(angle);
            t[0, 0] = c; t[0, 1] = -s;
            t[1, 0] = s; t[1, 1] = c;
            return t;
        }
        /// Constructs a new Transform representing a 2D rotation.
        /// Params:
        ///   angle = Rotation angle in degrees
        static auto fromRotationDegrees(const FT degrees)
        {
            return fromRotation(degreesToRadians(degrees));
        }
        /// Apply 2D rotation in-place.
        /// Params:
        ///   angle = Rotation angle in radians
        /// Returns: this
        ref Transform rotate(const FT angle) return
        {
            return this.combine(CompactTransform.fromRotation(angle));
        }
        /// Apply 2D rotation in-place.
        /// Params:
        ///   angle = Rotation angle in degrees
        auto rotateDegrees(const FT degrees)
        {
            return rotate(degreesToRadians(degrees));
        }
        /// Returns a rotated copy of Transform.
        /// Params:
        ///   angle = Rotation angle in radians
        Transform rotated(const FT angle) const
        {
            Transform t = this;
            return t.rotate(angle);
        }
        /// Returns a rotated copy of Transform.
        /// Params:
        ///   angle = Rotation angle in degrees
        auto rotatedDegrees(const FT degrees) const
        {
            return rotated(degreesToRadians(degrees));
        }
    }
    // 3D transforms
    static if (Dim >= 3)
    {
        /// Constructs a new Transform representing a 3D rotation aroud the X axis.
        /// Params:
        ///   angle = Rotation angle in radians
        static Transform fromXRotation(const FT angle)
        {
            Transform t;
            immutable auto c = cos(angle), s = sin(angle);
            t[1, 1] = c; t[2, 1] = -s;
            t[1, 2] = s; t[2, 2] = c;
            return t;
        }
        /// Constructs a new Transform representing a 3D rotation aroud the X axis.
        /// Params:
        ///   angle = Rotation angle in degrees
        static auto fromXRotationDegrees(const FT degrees)
        {
            return fromXRotation(degreesToRadians(degrees));
        }
        /// Apply 3D rotation around the X axis in-place.
        /// Params:
        ///   angle = Rotation angle in radians
        ref Transform rotateX(const FT angle) return
        {
            return this.combine(CompactTransform.fromXRotation(angle));
        }
        /// Apply 3D rotation around the X axis in-place.
        /// Params:
        ///   angle = Rotation angle in degrees
        auto rotateXDegrees(const FT degrees)
        {
            return rotateX(degreesToRadians(degrees));
        }
        /// Returns a copy of Transform rotated around the X axis.
        /// Params:
        ///   angle = Rotation angle in radians
        Transform rotatedX(const FT angle) const
        {
            Transform t = this;
            return t.rotateX(angle);
        }
        /// Returns a copy of Transform rotated around the X axis.
        /// Params:
        ///   angle = Rotation angle in degrees
        auto rotatedXDegrees(const FT degrees)
        {
            return rotatedX(degreesToRadians(degrees));
        }


        /// Constructs a new Transform representing a 3D rotation aroud the Y axis.
        /// Params:
        ///   angle = Rotation angle in radians
        static Transform fromYRotation(const FT angle)
        {
            Transform t;
            immutable auto c = cos(angle), s = sin(angle);
            t[0, 0] = c; t[2, 0] = s;
            t[0, 2] = -s; t[2, 2] = c;
            return t;
        }
        /// Constructs a new Transform representing a 3D rotation aroud the Y axis.
        /// Params:
        ///   angle = Rotation angle in degrees
        static auto fromYRotationDegrees(const FT degrees)
        {
            return fromYRotation(degreesToRadians(degrees));
        }
        /// Apply 3D rotation around the Y axis in-place.
        /// Params:
        ///   angle = Rotation angle in radians
        ref Transform rotateY(const FT angle) return
        {
            return this.combine(CompactTransform.fromYRotation(angle));
        }
        /// Apply 3D rotation around the Y axis in-place.
        /// Params:
        ///   angle = Rotation angle in degrees
        auto rotateYDegrees(const FT degrees)
        {
            return rotateY(degreesToRadians(degrees));
        }
        /// Returns a copy of Transform rotated around the Y axis.
        /// Params:
        ///   angle = Rotation angle in radians
        Transform rotatedY(const FT angle) const
        {
            Transform t = this;
            return t.rotateY(angle);
        }
        /// Returns a copy of Transform rotated around the Y axis.
        /// Params:
        ///   angle = Rotation angle in degrees
        auto rotatedYDegrees(const FT degrees)
        {
            return rotatedY(degreesToRadians(degrees));
        }

        // Rotating in Z is the same as rotating in 2D
        alias fromZRotation = fromRotation;
        alias fromZRotationDegrees = fromRotationDegrees;
        alias rotateZ = rotate;
        alias rotateZDegrees = rotateDegrees;
        alias rotatedZ = rotated;
        alias rotatedZDegrees = rotatedDegrees;
    }
}

/// Pre-multiply `transformation` into `target`, returning a reference to `target`
auto ref combine(T, uint Dim, TransformOptions O1, TransformOptions O2)(
    ref return Transform!(T, Dim, O1) target,
    const auto ref Transform!(T, Dim, O2) transformation
)
{
    target = target.combined(transformation);
    return target;
}
/// Returns the result of pre-multiplying `transformation` and `target`
Transform!(T, Dim, O1) combined(T, uint Dim, TransformOptions O1, TransformOptions O2)(
    const auto ref Transform!(T, Dim, O1) target,
    const auto ref Transform!(T, Dim, O2) transformation
)
{
    // Just about matrix multiplication, but assuming last row is [0...0 1]
    typeof(return) result;
    foreach (i; 0 .. Dim)
    {
        foreach (j; 0 .. Dim + 1)
        {
            T sum = 0;
            foreach (k; 0 .. Dim)
            {
                sum += transformation[k, i] * target[j, k];
            }
            result[j, i] = sum;
        }
        // Last column has to take input's last row's 1
        result[Dim, i] += transformation[Dim, i];
    }
    return result;
}

unittest
{
    alias Transform2D = Transform!(float, 2);
    alias Transform2DCompact = Transform!(float, 2, TransformOptions.compact);
    alias Transform3D = Transform!(float, 3);
    alias Transform3DCompact = Transform!(float, 3, TransformOptions.compact);
}

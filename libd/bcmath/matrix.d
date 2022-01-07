/**
 * Type and dimension generic Matrix type.
 */
module bcmath.matrix;

@safe @nogc pure nothrow:

version (unittest)
{
    import bcmath.vector;
    private alias Vec2 = Vector!(float, 2);
    private alias Vec3 = Vector!(float, 3);
    private alias Mat2 = Matrix!(float, 2);
    private alias Mat23 = Matrix!(float, 2, 3);
    private alias Mat32 = Matrix!(float, 3, 2);
    private alias Mat3 = Matrix!(float, 3);
    private alias Mat34 = Matrix!(float, 3, 4);
    private alias Mat43 = Matrix!(float, 4, 3);
    private alias Mat4 = Matrix!(float, 4);
}

/**
 * Column-major 2D matrix type.
 */
struct Matrix(T, uint numColumns, uint numRows = numColumns)
if (numColumns > 0 && numRows > 0)
{
    import std.algorithm : min;
    /// Alias for Matrix element type.
    alias ElementType = T;
    /// Number of elements in each row, same as the number of columns.
    enum rowSize = numColumns;
    /// Number of elements in each column, same as the number of rows.
    enum columnSize = numRows;
    /// Minimum dimension between number of rows and number of columns.
    enum minDimension = min(rowSize, columnSize);
    /// Total number of elements.
    enum numElements = rowSize * columnSize;
    /// Whether matrix is square or not.
    enum isSquare = rowSize == columnSize;

    /// Matrix underlying elements.
    T[numElements] elements = 0;

    /// Constructs a Matrix specifying all elements.
    this()(const auto ref T[numElements] values)
    {
        this.elements = values;
    }
    /// Constructs a Matrix specifying the diagonal value.
    this(const T diag)
    {
        foreach (i; 0 .. minDimension)
        {
            this[i, i] = diag;
        }
    }

    /// Copy Matrix values into `target` Matrix of any dimensions.
    /// If dimensions are not the same, the values at non-overlapping indices
    /// are ignored.
    auto ref copyInto(uint C, uint R)(ref return Matrix!(T, C, R) target) const
    {
        // If matrices have the same column size, underlying array may be copied at once
        static if (this.columnSize == target.columnSize)
        {
            enum copySize = min(this.numElements, target.numElements);
            target.elements[0 .. copySize] = this.elements[0 .. copySize];
        }
        else
        {
            enum columnCopySize = min(this.columnSize, target.columnSize);
            enum rowCopySize = min(this.rowSize, target.rowSize);
            foreach (i; 0 .. rowCopySize)
            {
                target[i][0 .. columnCopySize] = this[i][0 .. columnCopySize];
            }
        }
        return target;
    }

    /// Returns a copy of Matrix, adjusting dimensions as necessary.
    /// Non-overlapping indices will stay initialized to 0.
    U opCast(U : Matrix!(T, C, R), uint C, uint R)() const
    {
        typeof(return) result;
        return copyInto(result);
    }

    /// Returns a Range of all columns.
    auto columns()
    {
        import std.range : chunks;
        return elements[].chunks(columnSize);
    }
    /// Returns a Range of all columns.
    auto columns() const
    {
        import std.range : chunks;
        return elements[].chunks(columnSize);
    }
    /// Returns a Range of all rows.
    auto rows()
    {
        import std.range : lockstep, StoppingPolicy;
        return columns.lockstep(StoppingPolicy.requireSameLength);
    }
    /// Returns a Range of all rows.
    auto rows() const
    {
        import std.range : lockstep, StoppingPolicy;
        return columns.lockstep(StoppingPolicy.requireSameLength);
    }
    
    /// Index a column.
    inout(T)[] opIndex(size_t i) inout
    in { assert(i < rowSize, "Index out of bounds"); }
    do
    {
        auto initialIndex = i * columnSize;
        return elements[initialIndex .. initialIndex + columnSize];
    }
    /// Index an element directly.
    /// Params:
    ///   i = column index
    ///   j = row index
    ref inout(T) opIndex(size_t i, size_t j) inout
    in { assert(i < rowSize && j < columnSize, "Index out of bounds"); }
    do
    {
        return elements[i*columnSize + j];
    }

    /// Row size
    enum opDollar(size_t pos : 0) = rowSize;
    /// Column size
    enum opDollar(size_t pos : 1) = columnSize;

    /// Constructs a Matrix from all elements in column-major format.
    static Matrix fromColumns(Args...)(const auto ref Args args)
    if (args.length == numElements)
    {
        return Matrix([args]);
    }
    /// Constructs a Matrix from an array of all elements in column-major format.
    static Matrix fromColumns()(const auto ref T[numElements] elements)
    {
        return Matrix(elements);
    }
    /// Constructs a Matrix from a 2D array of columns.
    static Matrix fromColumns()(const auto ref T[rowSize][columnSize] columns)
    {
        return Matrix(cast(T[numElements]) columns);
    }

    /// Constructs a Matrix from row-major format
    static Matrix fromRows(Args...)(const auto ref Args args)
    {
        return Matrix!(T, columnSize, rowSize).fromColumns(args).transposed;
    }

    /// Constructs a Matrix with all diagonal values equal to `diag` and all others equal to 0.
    static Matrix fromDiagonal(const T diag)
    {
        return Matrix(diag);
    }
    /// Constructs a Matrix with diagonal values from `diag` and all others equal to 0.
    static Matrix fromDiagonal(uint N)(const auto ref T[N] diag)
    if (N <= minDimension)
    {
        Matrix mat;
        foreach (i; 0 .. N)
        {
            mat[i, i] = diag[i];
        }
        return mat;
    }

    /// Returns the result of multiplying `vec` by Matrix.
    /// If matrix is not square, the resulting array dimension will be different from input.
    T[columnSize] opBinary(string op : "*")(const auto ref T[rowSize] vec) const
    {
        typeof(return) result;
        foreach (i; 0 .. columnSize)
        {
            T sum = 0;
            foreach (j; 0 .. rowSize)
            {
                sum += this[j, i] * vec[j];
            }
            result[i] = sum;
        }
        return result;
    }
    ///
    unittest
    {
        auto m1 = Mat23.fromRows(1, 2,
                                 3, 4,
                                 5, 6);
        auto v1 = Vec2(1, 2);
        assert(m1 * v1 == Vec3(1*1 + 2*2,
                               1*3 + 2*4,
                               1*5 + 2*6));
    }

    /// Returns the result of Matrix multiplication.
    Matrix!(T, OtherColumns, columnSize) opBinary(string op : "*", uint OtherColumns)(
        const auto ref Matrix!(T, OtherColumns, rowSize) other
    ) const
    {
        typeof(return) result = void;
        foreach (i; 0 .. columnSize)
        {
            foreach (j; 0 .. OtherColumns)
            {
                T sum = 0;
                foreach (k; 0 .. rowSize)
                {
                    sum += this[k, i] * other[j, k];
                }
                result[j, i] = sum;
            }
        }
        return result;
    }
    ///
    unittest
    {
        alias Mat23 = Matrix!(int, 2, 3);
        alias Mat12 = Matrix!(int, 1, 2);

        Mat23 m1 = Mat23.fromRows(1, 1,
                                  2, 2,
                                  3, 3);
        Mat12 m2 = Mat12.fromRows(4,
                                  5);
        auto result = m1 * m2;
        assert(result.elements == [
            1*4 + 1*5,
            2*4 + 2*5,
            3*4 + 3*5,
        ]);
    }

    static if (isSquare)
    {
        /// Constant Identity matrix (diagonal values 1).
        enum identity = fromDiagonal(1);

        /// Inplace matrix multiplication with "*=" operator, only available for square matrices.
        ref Matrix opOpAssign(string op : "*")(const auto ref Matrix other) return
        {
            foreach (i; 0 .. columnSize)
            {
                foreach (j; 0 .. rowSize)
                {
                    T sum = 0;
                    foreach (k; 0 .. rowSize)
                    {
                        sum += this[k, i] * other[j, k];
                    }
                    this[j, i] = sum;
                }
            }
            return this;
        }

        // TODO: determinant, inverse matrix, at least for 2x2, 3x3 and 4x4
    }


    // Matrix 4x4 methods
    static if (rowSize == 4 && columnSize == 4)
    {
        /// Returns an orthographic projection matrix.
        /// See_Also: https://www.khronos.org/registry/OpenGL-Refpages/gl2.1/xhtml/glOrtho.xml
        static Matrix orthographic(T left, T right, T bottom, T top, T near = -1, T far = 1)
        {
            Matrix result;

            result[0, 0] = 2.0 / (right - left);
            result[1, 1] = 2.0 / (top - bottom);
            result[2, 2] = 2.0 / (near - far);
            result[3, 3] = 1.0;

            result[3, 0] = (left + right) / (left - right);
            result[3, 1] = (bottom + top) / (bottom - top);
            result[3, 2] = (far + near) / (near - far);

            return result;
        }
        alias ortho = orthographic;

        /// Calls `perspective` converting angle from degrees to radians.
        /// See_Also: perspective
        static auto perspectiveDegrees(T fovDegrees, T aspectRatio, T near, T far)
        {
            import bcmath.misc : degreesToRadians;
            return perspective(degreesToRadians(fovDegrees), aspectRatio, near, far);
        }
        /// Returns a perspective projection matrix.
        /// See_Also: https://www.khronos.org/registry/OpenGL-Refpages/gl2.1/xhtml/gluPerspective.xml
        static Matrix perspective(T fov, T aspectRatio, T near, T far)
        in { assert(near > 0, "Near clipping pane should be positive"); assert(far > 0, "Far clipping pane should be positive"); }
        do
        {
            Matrix result;

            import bcmath.cmath : tan;
            T cotangent = 1.0 / tan(fov * 0.5);

            result[0, 0] = cotangent / aspectRatio;
            result[1, 1] = cotangent;
            result[2, 3] = -1.0;
            result[2, 2] = (near + far) / (near - far);
            result[3, 2] = (2.0 * near * far) / (near - far);

            return result;
        }
    }
}

/// True if `T` is some kind of Matrix
enum isMatrix(T) = is(T : Matrix!U, U...);

/// Transpose a square matrix inplace.
ref Matrix!(T, C, C) transpose(T, uint C)(ref return Matrix!(T, C, C) mat)
{
    import std.algorithm : swap;
    foreach (i; 0 .. C)
    {
        foreach (j; i+1 .. C)
        {
            swap(mat[j, i], mat[i, j]);
        }
    }
    return mat;
}
///
unittest
{
    auto m1 = Mat2.fromRows(1, 2,
                            3, 4);
    transpose(m1);
    assert(m1 == Mat2.fromRows(1, 3,
                               2, 4));
}

/// Returns a transposed copy of `mat`.
Matrix!(T, R, C) transposed(T, uint C, uint R)(const auto ref Matrix!(T, C, R) mat)
{
    typeof(return) newMat = void;
    foreach (i; 0 .. R)
    {
        foreach (j; 0 .. C)
        {
            newMat[i, j] = mat[j, i];
        }
    }
    return newMat;
}
///
unittest
{
    float[6] elements = [1, 2, 3, 4, 5, 6];
    float[6] transposedElements = [1, 4, 2, 5, 3, 6];
    auto m1 = Mat23.fromColumns(elements);
    auto m2 = transposed(m1);
    assert(m2.elements == transposedElements);
    assert(transposed(m1.transposed) == m1);
}


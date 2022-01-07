/**
 * 2D hexagon grid math.
 *
 * See_Also: https://www.redblobgames.com/grids/hexagons/
 */
module bcmath.hexagrid2d;

import std.algorithm : among;
import std.traits : isFloatingPoint;

import bcmath.cmath;
import bcmath.vector;
import bcmath.matrix;
import bcmath.misc;

@safe @nogc nothrow:

private enum sqrt3 = sqrt(3);

version (unittest)
{
    private alias Hexi = Hex!(int);
    private alias Hexf = Hex!(float);
}

enum Orientation
{
    pointy,
    flat,
}

struct Layout(Orientation orientation, FT = float)
if (isFloatingPoint!FT)
{
pure:
    private alias Mat2 = Matrix!(FT, 2);
    private alias Vec2 = Vector!(FT, 2);
    private alias Vec2i = Vector!(int, 2);

    alias Hexagon = Hex!(int);
    alias FractionalHexagon = Hex!(FT);

    Vec2 origin;
    Vec2 size;

    static if (orientation == Orientation.pointy)
    {
        enum Directions
        {
            East = Hexagon(1, 0),
            E = East,
            NorthEast = Hexagon(1, -1),
            NE = NorthEast,
            NorthWest = Hexagon(0, -1),
            NW = NorthWest,
            West = Hexagon(-1, 0),
            W = West,
            SouthWest = Hexagon(-1, 1),
            SW = SouthWest,
            SouthEast = Hexagon(0, 1),
            SE = SouthEast,
        }
        private enum toPixelMatrix = Mat2.fromRows(
            sqrt3, sqrt3 / 2.0,
            0,     3.0 / 2.0
        );
        private enum fromPixelMatrix = Mat2.fromRows(
            sqrt3 / 3.0, -1.0 / 3.0,
            0,            2.0 / 3.0
        );
        private enum FT[6] angles = [30, 90, 150, 210, 270, 330];
    }
    else
    {
        enum Directions
        {
            SouthEast = Hexagon(1, 0),
            SE = SouthEast,
            NorthEast = Hexagon(1, -1),
            NE = NorthEast,
            North = Hexagon(0, -1),
            N = North,
            NorthWest = Hexagon(-1, 0),
            NW = NorthWest,
            SouthWest = Hexagon(-1, 1),
            SW = SouthWest,
            South = Hexagon(0, 1),
            S = South,
        }
        private enum toPixelMatrix = Mat2.fromRows(
            3.0 / 2.0,   0,
            sqrt3 / 2.0, sqrt3
        );
        private enum fromPixelMatrix = Mat2.fromRows(
            2.0 / 3.0,  0,
            -1.0 / 3.0, sqrt3 / 3.0
        );
        private enum FT[6] angles = [0, 60, 120, 180, 240, 300];
    }

    Vec2 toPixel(const Hexagon hex) const
    {
        typeof(return) result = toPixelMatrix * cast(Vec2) hex.coordinates;
        return result * size + origin;
    }

    FractionalHexagon fromPixel(const Vec2 originalPoint) const
    {
        const Vec2 point = (originalPoint - origin) / size;
        return typeof(return)(fromPixelMatrix * point);
    }

    Vec2[6] corners() const
    {
        typeof(return) result = void;
        foreach (i; 0 .. 6)
        {
            FT angle = deg2rad(angles[i]);
            result[i] = [size.x * cos(angle), size.y * sin(angle)];
        }
        return result;
    }
}

struct Hex(T = int)
{
pure:
    alias ElementType = T;
    /// Axial coordinates, see https://www.redblobgames.com/grids/hexagons/implementation.html
    private Vector!(T, 2) _coordinates;
    @property const(typeof(_coordinates)) coordinates() const
    {
        return _coordinates;
    }
    
    @property T q() const
    {
        return coordinates[0];
    }
    @property T r() const
    {
        return coordinates[1];
    }
    @property T s() const
    {
        return -q -r;
    }

    this(T q, T r)
    {
        _coordinates = [q, r];
    }
    this(T[2] coordinates)
    {
        _coordinates = coordinates;
    }

    // Operations
    Hex opBinary(string op)(const Hex other) const
    if (op.among("+", "-"))
    {
        return Hex(this.coordinates.opBinary!op(other.coordinates));
    }

    Hex opBinary(string op : "*")(const int scale) const
    {
        Hex result;
        result.coordinates = coordinates * scale;
        return result;
    }

    T magnitude() const
    {
        import std.algorithm : sum;
        return cast(T)((fabs(q) + fabs(r) + fabs(s)) / 2);
    }

    T distanceTo(const Hex other) const
    {
        Hex vector = this - other;
        return vector.magnitude();
    }
}

Hex!(int) rounded(FT)(const Hex!(FT) hex)
if (isFloatingPoint!FT)
{
    import std.algorithm : map;
    alias Vec3 = Vector!(FT, 3);
    Vec3 cubic_hex = hex.coordinates ~ hex.s;
    Vec3 roundedVec = cubic_hex[].map!(round);
    Vec3 diff = roundedVec - cubic_hex;

    if (diff[0] > diff[1] && diff[0] > diff[2])
    {
        roundedVec[0] = -roundedVec[1] - roundedVec[2];
    }
    else if (diff[1] > diff[2])
    {
        roundedVec[1] = -roundedVec[0] - roundedVec[2];
    }
    return typeof(return)(cast(int) roundedVec[0], cast(int) roundedVec[1]);
}
unittest
{
    Hexf a = Hexf(2.1, 3.5); // -5.6
    assert(a.rounded() == Hexi(2, 4));
}

struct RectangleHexagrid(Orientation orientation, T, uint columns, uint rows)
{
    Layout!(orientation) layout;
    Hex!(int) hexagons;
    T[columns][rows] values;
}

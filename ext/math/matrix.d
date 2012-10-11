module ext.math.matrix;

/**
 * Waiting for std.linalg or something. It's on the wishlist.
 */

import std.conv;
import std.math;
import std.stdio;

import ext.math.vector;


struct Matrix(size_t r, size_t c, T) {
    // Infos for outside
    enum rows = r;
    enum cols = c;
    alias T ValueType;
    alias Vector!(c, T) RowType;

    // Constructor definition
    this(Args...)(Args args) {
        void construct(size_t argsPassed, Args...)(Args args) {
            
            static if (args.length > 0) {
                auto f = args[0];
                alias typeof(f) First;

                static if (isMatrix!First) {
                    static assert(argsPassed == 0, "Invalid construction.");
                    static assert(is(First.ValueType : T),
                                  "Matrix value types are incompatible.");
                    static assert(sameDims!(Matrix, First),
                                  "Matrix dimensions are incompatible.");
                    _data = f._data;
                } else {
                    this[argsPassed / c][argsPassed % c] = f;
                    construct!(argsPassed + 1)(args[1 .. $]);
                }
            } else {
                static if (argsPassed > r * c) {
                    static assert(false, "Too many construction parameters.");
                } else static if (argsPassed < r * c) {
                    static assert(false, "Not enough construction parameters.");
                }
            }
        }

        construct!0(args);
    }

    unittest {
       auto m = Matrix2x2f(1.0, 2.0, 3.0, 4.0);
       assert(m[] == [Vector2f(1.0, 2.0), Vector2f(3.0, 4.0)]);
    }

    ///////////////////////////////////////////////////////
    // Operators

    /// Matrix multiplication.
    Matrix opBinary(string op)(ref const Matrix rhs)
    if (op == "*") {

        Matrix result;

        foreach (row; 0 .. r) {
            foreach (col; 0 .. c) {
                ValueType res = 0;
                foreach (i; 0 .. r) {
                    res += this[row][i] * rhs[i][col];
                }
                result[row][col] = res;
            }
        }

        return result;
    }

    unittest {
        auto m1 = Matrix2x2f(1.0, 2.0, 3.0, 4.0);
        auto m2 = Matrix2x2f(4.0, 3.0, 2.0, 1.0);

        auto r = m1 * m2;

        assert(r == Matrix2x2f(8.0, 5.0, 20.0, 13.0));
    }

    /// Cast operator overload allows casting matrices explicity.
    auto opCast(Target)() const nothrow pure
    if (isMatrix!Target && sameDims!(Matrix, Target)) {
        Target ret;

        foreach (i; 0 .. n) {
            ret[i] = cast(Target.RowType)this[i];
        }

        return ret;
    }

    /// Index operator overload for direct access to the rows.
    auto ref opIndex(size_t idx) inout nothrow pure {
        return _data[idx];
    }

    /// Slice operator overload
    inout(RowType[]) opSlice(size_t from, size_t to) inout nothrow pure {
        return _data[from .. to];
    }

    /// Slice operator overload that returns the whole array.
    inout(RowType[]) opSlice() inout nothrow pure {
        return _data;
    }

    ///////////////////////////////////////////////////////////
    // Functions
	
	/// Translates the matrix given by the vector v.
    void translate(ref const Vector!(r - 1, T) v) nothrow pure {
        foreach (row; 0 .. r - 1) {
            this[row][c - 1] += v[row];
        }
    }
    
    static if (r == c) {
        /// Scales the matrix.
        void scale(ref const Vector!(r - 1, T) v) nothrow pure {
            Matrix m;
            identity(m);
            foreach (row; 0 .. r - 1) {
                m[row][row] = v[row];
            }
            this = m * this;
        }
    }   
	
	/// Returns the pointer to the raw data.
	inout(T)* ptr() inout nothrow pure {
		return cast(inout(T)*)_data.ptr;
	}

    ///////////////////////////////////////////////////////////
    // Data
    private RowType[r] _data;
}


///////////////////////////////////////////////////////////////
// Functions

/// Sets the matrix to identity.
void identity(size_t r, size_t c, T)(ref Matrix!(r, c, T) m)
if (r == c) {
	static assert(r == c, "Rows have to equal rows.");
	
	foreach (row; 0 .. r) {
		foreach (col; 0 .. c) {
			if (row == col) {
				m[row][col] = 1;
			} else {
				m[row][col] = 0;
			}
		}
	}
}

/// Ortographic view.
void orthographic(T)(ref Matrix!(4, 4, T) m,
	float left, float right,
	float bottom, float top,
	float nearVal, float farVal) {
	
	identity(m);
	m[0][0] = 2.0 / (right - left);
	m[0][3] = -(right + left) / (right - left);
	m[1][1] = 2.0 / (top - bottom);
	m[1][3] = -(top + bottom) / (top - bottom);
	m[2][2] = -2.0 / (farVal - nearVal);
	m[2][3] = -(farVal + nearVal) / (farVal - nearVal);
}


///////////////////////////////////////////////////////////////
// Traits

/// Detect whether T is a Matrix or not.
template isMatrix(T) {
    static if (is(T _ : Matrix!(r, c, U), size_t r, size_t c, U)) {
        enum isMatrix = true;
    } else {
        enum isMatrix = false;
    }
}

unittest {
    static assert(isMatrix!Matrix4x4f);
    static assert(!isMatrix!Vector3f);
    static assert(!isMatrix!int);
}

/// Detect whether T and U have the same dims.
template sameDims(T1 : Matrix!(r1, c1, U1), T2 : Matrix!(r2, c2, U2),
                  size_t r1, size_t c1, U1,
                  size_t r2, size_t c2, U2) {
    enum sameDims = r1 == r2 && c1 == c2;
}

unittest {
    static assert(sameDims!(Matrix4x4f, Matrix4x4r));
    static assert(!sameDims!(Matrix4x3f, Matrix3x4f));
}

////////////////////////////////////////////////////////////////
// Generate aliases
private string generateAliases(string[2][] types) {

    string result;

    foreach (type; types) {
        foreach (r; 2 .. 5) {
            foreach (c; 2 .. 5) {
                result ~= "alias Matrix!(" ~ to!string(r) ~
                ", " ~ to!string(c) ~ ", " ~ type[0] ~ ") Matrix" ~
                to!string(r) ~ "x" ~ to!string(c) ~ type[1] ~ ";\n";
            }
        }
    }

    return result;
}

// Floating point types
//mixin(generateAliases([["float", "f"], ["double", "d"], ["real", "r"]]));

alias Matrix!(2, 2, float) Matrix2x2f;
alias Matrix!(2, 3, float) Matrix2x3f;
alias Matrix!(2, 4, float) Matrix2x4f;
alias Matrix!(3, 2, float) Matrix3x2f;
alias Matrix!(3, 3, float) Matrix3x3f;
alias Matrix!(3, 4, float) Matrix3x4f;
alias Matrix!(4, 2, float) Matrix4x2f;
alias Matrix!(4, 3, float) Matrix4x3f;
alias Matrix!(4, 4, float) Matrix4x4f;
alias Matrix!(2, 2, double) Matrix2x2d;
alias Matrix!(2, 3, double) Matrix2x3d;
alias Matrix!(2, 4, double) Matrix2x4d;
alias Matrix!(3, 2, double) Matrix3x2d;
alias Matrix!(3, 3, double) Matrix3x3d;
alias Matrix!(3, 4, double) Matrix3x4d;
alias Matrix!(4, 2, double) Matrix4x2d;
alias Matrix!(4, 3, double) Matrix4x3d;
alias Matrix!(4, 4, double) Matrix4x4d;
alias Matrix!(2, 2, real) Matrix2x2r;
alias Matrix!(2, 3, real) Matrix2x3r;
alias Matrix!(2, 4, real) Matrix2x4r;
alias Matrix!(3, 2, real) Matrix3x2r;
alias Matrix!(3, 3, real) Matrix3x3r;
alias Matrix!(3, 4, real) Matrix3x4r;
alias Matrix!(4, 2, real) Matrix4x2r;
alias Matrix!(4, 3, real) Matrix4x3r;
alias Matrix!(4, 4, real) Matrix4x4r;

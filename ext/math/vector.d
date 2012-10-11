module ext.math.vector;

/**
 * Waiting for std.linalg or something. It's on the wishlist.
 */

import std.algorithm;
import std.conv;
import std.stdio;
import std.traits;


// ------------------------------------------------------....
// Struct definition
struct Vector(size_t n, T) {
    // Infos for outside
    enum dims = n;
    alias T ValueType;
    
    static {
        /// Creates a ranges containing nulls.
        private T[n] createNullRange() {
            T[n] ret;
            foreach (ref v; ret) {
                ret = 0;
            }
            return ret;
        }
    }

    // Constructor definition
    this(Args...)(Args args) {

        void construct(size_t argsPassed, Args...)(Args args) {

            static if (args.length > 0) {
                auto f = args[0];
                alias typeof(f) First;

                static if (isVector!First) {
                    static assert(is(First.ValueType : T),
                                  "Vector value types are incompatible");
                    foreach (i; 0 ..  First.dims) {
                        this[argsPassed + i] = f[i];
                    }
                    construct!(argsPassed + First.dims)(args[1 .. $]);
                } else static if (!isVector!First) {
                    this[argsPassed] = f;
                    construct!(argsPassed + 1)(args[1 .. $]);
                }
            } else {
                static if (argsPassed > n) {
                    static assert(false, "Too many constructing parameters.");
                } else static if (argsPassed < n) {
                    static assert(false, "Not enough constructing parameters.");
                }
            }
        }

        construct!0(args);
    }

    unittest {
        auto v1 = Vector2f(1.0, 2.0);
        auto v2 = Vector2b(cast(byte)123, cast(byte)21);

        auto res = Vector!(7, double)(124.6, v1, 66.97, v2, 1000.0);
        assert(res[] == [124.6, 1.0, 2.0, 66.97, 123.0, 21.0, 1000.0]);

        static assert(!__traits(compiles, Vector3i(1, 2)));
    }

    // -----------------------------------------------------...
    // Operators
    /// Assignment operator.
    ref Vector opAssign(ref const Vector vec) nothrow pure {
        foreach(i; 0 .. n) {
            _data[i] = vec._data[i];
        }
        return this;
    }
    
    /// Binary operator for math operations.
    Vector opBinary(string op)(in Vector rhs) {
        Vector ret;
        foreach (i; 0 .. n) {
            mixin("ret[i] = this[i] " ~ op ~ " rhs[i];");
        }
        return ret;
    }
    
    unittest {
        auto v1 = Vector2f(1.0, 2.0);
        auto v2 = Vector2f(1.0, 2.0);
        
        assert(v1 / v2 == Vector2f(1.0, 1.0));
        assert(v1 + v2 == Vector2f(2.0, 4.0));
    }
    
    /// ditto
    Vector opBinary(string op)(T rhs) {
        Vector ret;
        foreach (i; 0 .. n) {
            mixin("ret[i] = this[i] " ~ op ~ " rhs;");
        }
        return ret;
    }
    
    /// Cast operator overload allows casting vectors explicitly.
    auto opCast(Target)() const nothrow pure
    if (isVector!Target && sameDims!(Vector, Target)) {
        Target ret;

        foreach (i; 0 .. n) {
            ret[i] = cast(Target.ValueType)this[i];
        }

        return ret;
    }

    unittest {
        auto vOrig = Vector2f(1.0, 2.0);
        static assert(!__traits(compiles, Vector2b(vOrig)));
        Vector2b vCasted = cast(Vector2b)vOrig;
        assert(vCasted[] == [1, 2]);
    }

    /// Index operator overload for direct access.
    inout nothrow pure auto ref opIndex(size_t idx) {
        return _data[idx];
    }

    unittest {
        auto v = Vector2f(1.0, 2.0);
        assert(v[0] == 1.0);
        v[0] = 1337.42;
        assert(v[0] == 1337.42f);
    }

    /// Slice operator overload.
    inout(T[]) opSlice(size_t from, size_t to) inout nothrow pure {
        return _data[from .. to];
    }

    unittest {
        auto v = Vector!(8, int)(1, 2, 3, 4, 5, 6, 7, 8);
        auto slice = v[2 .. 6];
        assert(slice == [3, 4, 5, 6]);
        slice[1] = 123;
        assert(v == Vector!(8, int)(1, 2, 3, 123, 5, 6, 7, 8));
    }

    /// Slice operator overload that returns the entire array.
    inout(T[]) opSlice() inout nothrow pure {
        return _data;
    }

    unittest {
        auto v = Vector2i(1, 2);
        assert(v[] == [1, 2]);
    }

    /// Unary operator overload for pre increment and decrement.
    nothrow pure Vector opUnary(string op)()
    if (op == "--" || op == "++") {
        foreach (ref v; _data) {
            mixin(op ~ "v;");
        }
        return this;
    }

    unittest {
        auto v = Vector2i(1, 2);
        assert(--v == Vector2i(0, 1));
        assert(v == Vector2i(0, 1));
    }
    
    /// Unary operator overload for negation.
    Vector opUnary(string op)()
    if (op == "-") {
        Vector ret;
        foreach (i; 0 .. n) {
            ret[i] = -_data[i];
        }
        return ret;
    }
    
    unittest {
        auto v = Vector2i(1.0, -1.0);
        assert(-v == Vector2i(-1.0, 1.0));
    }

    // ---------------------------------------------------------
    // Data access
    private mixin template defineProperty(size_t idx, string name) {
        static if (n > idx) {
            mixin("
            @property inout nothrow pure auto ref " ~ name ~ "() {
                return _data[idx];
            }
            ");
        }
    }

    mixin defineProperty!(0, "x");
    mixin defineProperty!(1, "y");
    mixin defineProperty!(2, "z");
    mixin defineProperty!(3, "w");

    // Implement storage
    private T[n] _data = createNullRange();
}


// ----------------------------------------------------------
// Traits

/// Detect whether T is a Vector or not.
template isVector(T) {
    static if(is(T _ : Vector!(n, U), uint n, U)) {
        enum isVector = true;
    } else {
        enum isVector = false;
    }
}

unittest {
    static assert(isVector!Vector2f);
    static assert(!isVector!int);
}

/// Detect whether the two vectors have the same dim
template sameDims(T1 : Vector!(n1, U1), T2 : Vector!(n2, U2),
                 size_t n1, U1, size_t n2, U2) {
    enum sameDims = n1 == n2;
}

unittest {
    static assert(sameDims!(Vector2f, Vector2ub));
    static assert(!sameDims!(Vector2i, Vector3i));
}


// -------------------------------------------------------
// Generate aliases
private string generateAliases(string[2][] types) {

    string result;

    foreach (type; types) {
        foreach (dim; 2 .. 5) {
            result ~= "alias Vector!(" ~ to!string(dim) ~
            ", " ~ type[0] ~ ") Vector" ~ to!string(dim) ~ type[1] ~ ";";
        }
    }

    return result;
}

// Integral types
mixin(generateAliases([["byte", "b"], ["short", "s"], ["int", "i"]]));
mixin(generateAliases([["ubyte", "ub"], ["ushort", "us"], ["uint", "ui"]]));

// Floating-point types
mixin(generateAliases([["float", "f"], ["double", "d"]]));


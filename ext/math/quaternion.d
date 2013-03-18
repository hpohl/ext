module ext.math.quaternion;

import std.math;

import ext.math.vector;


struct Quaternion(T) {
	/////////////////////////////////////////////
	// Constructors
	/// Sets x = a, y = b, z = c and w = s.
	this(T a, T b, T c, T s) {
		x = a;
		y = b;
		z = c;
		w = s;
	}

	unittest {
		auto q = Quaternionf(1.0, 2.0, 3.0, 4.0);
		assert(q[0] == 1.0 &&
			   q[1] == 2.0 &&
			   q[2] == 3.0 &&
			   q[3] == 4.0);
	}

	/// Sets x, y, and z to v and w to s (default 0).
	this(Vector!(3, T) v, T s = 0.0) {
		x = v.x;
		y = v.y;
		z = v.z;
		w = s;
	}

	unittest {
		auto v = Vector3f(1.0, 2.0, 3.0);
		auto q = Quaternionf(v, 4.0);
		assert(q == Quaternionf(1.0, 2.0, 3.0, 4.0));
	}

	///////////////////////////////////////////
	// Operators
	/// Assigns a three-dimensional vector to x, y and z. w = 0.
	nothrow pure ref Quaternion opAssign(U)(U v) {
		static if (isVector!U) {
			x = v.x;
			y = v.y;
			z = v.z;
			w = 0;
		} else if (isQuaternion!U) {
			x = v.x;
			y = v.y;
			z = v.z;
			w = v.w;
		}

		return this;
	}

	unittest {
		auto v = Vector3d(1.0, 2.0, 3.0);
		auto q = Quaterniond(3.0, 2.0, 1.0, 4.0);
		q = v;
		assert(q == Quaterniond(1.0, 2.0, 3.0, 0.0));
	}

	/// Index operator overload for direct access.
    inout nothrow pure auto ref opIndex(size_t idx) {
        return _data[idx];
    }

	////////////////////////////////////////////
	// Methods
	/// Returns the magnitude.
	@property const nothrow pure float magnitude() {
		return sqrt(x^^2 + y^^2 + z^^2 + w^^2);
	}

	@property const nothrow pure float squaredMagnitude() {
		return x^^2 + y^^2 + z^^2 + w^^2;
	}


	///////////////////////////////////////////
	// Data access
    private mixin template defineProperty(size_t idx, string name) {
        mixin("
        @property inout nothrow pure auto ref " ~ name ~ "() {
            return _data[idx];
        }
        ");
    }

    mixin defineProperty!(0, "x");
    mixin defineProperty!(1, "y");
    mixin defineProperty!(2, "z");
    mixin defineProperty!(3, "w");

	// Data implementation
	private T[4] _data;
}


//////////////////////////////////////////
// Traits
/// Detect whether T is a Quaternion or not.
template isQuaternion(T) {
    static if(is(T _ : Quaternion!(U), U)) {
        enum isQuaternion = true;
    } else {
        enum isQuaternion = false;
    }
}

unittest {
    static assert(isQuaternion!Quaternionf);
    static assert(!isQuaternion!int);
}


///////////////////////////////////////
// Aliases
alias Quaternion!float Quaternionf;
alias Quaternion!double Quaterniond;
alias Quaternion!real Quaternionr;
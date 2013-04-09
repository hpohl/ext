module ext.resource.model;

import ext.render.context;
import ext.render.geometry;
import ext.resource.exception;
import ext.resource.material;
import ext.resource.resource;


/**
 * Data for creating textured geometries with materials.
 */
class Model : Resource {
    mixin AutoRegister!(Model, 2);
    
    this(Path path) {
        super(path);
        _mat = new Material(Path(Location("ext.model." ~ path.location.value), path.name ~ "_defaultmaterial"));      
    }
    
    /**
     * Generates always a new geometry from this model.
     */
    Geometry genGeometry(Context con) const {
        auto geo = con.createGeometry();
        geo.vertices = _vertices.dup;
        TriangleTexCoords[][] dTexCoords;
        foreach (tcs; _texCoords) {
            dTexCoords ~= tcs.dup;
        }
        geo.texCoords = dTexCoords;
        return geo;
    }
    
    @property nothrow pure {
        /// Returns the used material.
        inout(Material) material() inout nothrow pure {
            return _mat;
        }
        
        /// Sets the material.
        void material(Material mat) nothrow pure {
            _mat = mat;
        }

        /// Returns the triangles of this model.
        inout(Triangle)[] vertices() inout nothrow pure {
            return _vertices;
        }

        /// Sets the triangles of this model.
        void vertices(Triangle[] vertices) nothrow pure {
            _vertices = vertices;
        }
    }
    
    override {
        const(Path)[] depencies() const {
            return [_mat.path];
        }
        
        void loadFromRaw(const(void)[] data, Resource[] depencies) {
            // Load depencies.
            if (depencies.length != 1) {
                throw new ResourceException("Unabelt to load model from raw data: No depencies.");
            }
            
            auto mat = cast(Material)depencies[0];
            
            if (!mat) {
                throw new ResourceException("Unable to load model from raw data: Depency is not a material.");
            }
            
            _mat = mat;
            
            // Load vertices.
            auto nTris = *cast(ulong*)(data.ptr);
            data = data[ulong.sizeof - 1 .. $];
            
            auto vptr = cast(Triangle*)data.ptr;
            _vertices.length = nTris;
            
            foreach (i; 0 .. nTris) {
                _vertices[i] = vptr[i];
            }
            
            // Load tex coords.
            data = data[nTris * Triangle.sizeof - 1 .. $];
            auto nTexDims = *cast(ulong*)data.ptr;
            data = data[ulong.sizeof - 1 .. $];
            
            foreach (d; 0 .. nTexDims) {
                auto nTexCoords = *cast(ulong*)data.ptr;
                
                data = data[ulong.sizeof - 1 .. $];
            }
        }
        
        void[] saveToRaw() const {
			// Write vertices.
			void[] verts;
			verts.length = ulong.sizeof;
			*cast(ulong*)verts.ptr = _vertices.length;
			verts ~= _vertices.dup;

			// Write tex coords.
			void[] texcs;
			texcs.length = ulong.sizeof;
			*cast(ulong*)texcs.ptr = _texCoords.length;

			foreach (tcs; _texCoords) {
				void[] data;
				data.length = ulong.sizeof;
                *cast(ulong*)data.ptr = tcs.length;
                data ~= tcs.dup;
                texcs ~= data;
			}

			return verts ~ texcs;
        }
    }
    
    private {
        Material _mat;
        
        Triangle[] _vertices;
        TriangleTexCoords[][] _texCoords;
    }
}
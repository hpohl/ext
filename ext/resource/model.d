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
    
    this(ref const Path path) {
        super(path);
        _mat = new Material(Path(Location("_internal." ~ path.location.value), path.name ~ "_mat"));      
    }
    
    /**
     * Generates always a new geometry from this model.
     */
    Geometry genGeometry(Context con) const {
        auto geo = con.createGeometry();
        return geo;
    }
    
    @property nothrow pure {
        /// Returns the used material.
        inout(Material) material() inout {
            return _mat;
        }
        
        /// Sets the material.
        void material(Material mat) {
            _mat = mat;
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
                throw new ResourceException("Unable to load model from raw data: Depency is not a mater");
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
            return [];
        }
    }
    
    private {
        Material _mat;
        
        Triangle[] _vertices;
        TriangleTexCoords[][] _texCoords;
    }
}
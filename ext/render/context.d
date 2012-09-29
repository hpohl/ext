module ext.render.context;

import ext.math.vector;
import ext.render.geometry;
import ext.render.program;
import ext.render.target;
import ext.render.texture;
import ext.resource.material;


/**
 * Every object which is created by a render context has to derive from this.
 */
class ContextCreated {
	/// Constructs it by the given context.
	this(Context context) {
		_context = context;
	}
	
	/// Returns the context.
	@property inout(Context) context() inout nothrow pure {
		return _context;
	}
	
	private Context _context;
}

/**
 * A render context, which is implemented by used render systems,
 * e.g. by OpenGL, OpenRL or Direct3D.
 */
interface Context {
	
	/// Creates a texture using this context.
	Texture createTexture(Format format);
	
	/// Creates a render target.
	Target createTarget(in Vector2ui size);
	
	/// Creates a geometry.
	Geometry createGeometry();
	
	/// Creates a program.
	Program createProgram(const Material mat); 
}
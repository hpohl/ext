module ext.render.program;

import ext.render.context;
import ext.render.texture;
import ext.resource.material;


/**
 * A program defines how to draw things.
 */
class Program : ContextCreated {
    /**
     * Creates a program from the context to be used.
     */
    this(Context con) {
        super(con);
    }
    
    abstract {
        /// Specifies how the program works.
        void fromMaterial(const Material mat);
        
        @property {
            /// Returns the textures.
            inout(Texture)[] textures() inout;
            
            /// Sets the textures.
            void textures(Texture[] textures);
        }
    }
}
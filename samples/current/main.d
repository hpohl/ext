module samples.current.main;

import std.algorithm;
import std.random;
import std.stdio;

import ext.gui.layout;
import ext.gui.picture;
import ext.render.opengl.api;
import ext.render.opengl.context;
import ext.render.opengl.exception;
import ext.resource.image;
import ext.resource.material;
import ext.resource.path;
import ext.resource.pool;
import ext.resource.resource;
import ext.window.freeglut.window;


void createResources() {
	auto pool = new Pool("packages");
	
	auto img = new Image(Path("fun:tux"));
	img.loadFromFile("images/tux.png");
	pool.save(img);
	
	auto mat = new Material(Path("material:general"));
	mat.ambient = Color(0.0, 0.0, 0.0, 1.0);
	mat.diffuse = Color(1.0, 0.0, 0.0, 1.0);
	mat.specular = Color(0.0, 0.0, 0.0, 1.0);
	pool.save(mat);
	
	pool.write();
}

void main() {
	createResources();
	
	auto pool = new Pool("packages");
	auto img = pool.load!Image(Path("fun:tux"));
	
	
	////////////////////////////////////////
	auto win = new Window;
	
	auto layout = new Layout(win.inputDevice);
	auto pic = new Picture(img);
	layout.add(pic);
    
    win.target.context.cglClearColor(0.1, 0.1, 0.11, 0.0);
    win.target.clear();
    
	while (true) {
        import ext.window.freeglut.api;
        //glutWireTeapot(1.0);
        
        
        //win.target.clear();
        layout.draw(win.target);
		
		win.update();
	}
}
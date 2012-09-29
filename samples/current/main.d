module samples.current.main;

import std.stdio;

import ext.gui.layout;
import ext.gui.picture;
import ext.resource.image;
import ext.resource.path;
import ext.resource.pool;
import ext.resource.resource;
import ext.window.freeglut.window;


void createResources() {
	auto pool = new Pool("packages");
	auto img = new Image(Path("fun:tux"));
	img.loadFromFile("images/tux.png");
	pool.save(img);
	pool.write();
}

void main() {
	createResources();
	
	auto pool = new Pool("packages");
	auto img = pool.load!Image(Path("fun:tux"));
	
	
	////////////////////////////////////////
	auto win = new Window;
	
	auto layout = new Layout(win.inputDevice);
	auto pic = new Picture(img.getTexture(win.target.context));
	layout.add(pic);
	
	while (true) {
		layout.draw(win.target);
		
		win.update();
	}
}
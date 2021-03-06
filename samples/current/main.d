module samples.current.main;

import std.conv;

import core.memory;

import std.algorithm;
import std.random;
import std.stdio;

import ext.gui.layout;
import ext.gui.picture;
import ext.gui.udim;
import ext.math.vector;
import ext.misc.fpscalc;
import ext.render.geometry;
import ext.render.opengl.api;
import ext.render.opengl.context;
import ext.render.opengl.exception;
import ext.resource.image;
import ext.resource.material;
import ext.resource.model;
import ext.resource.path;
import ext.resource.pool;
import ext.resource.resource;
import ext.window.freeglut.window;
import ext.window.inputdevice;


void createResources() {
    auto pool = new Pool("packages");
    
    auto cur = new Image(Path("cursors:pointer"));
    cur.loadFromFile("images/cursor.tga");
    pool.save(cur);
    
    auto img = new Image(Path("fun:tux"));
    img.loadFromFile("images/tux.tga");
    pool.save(img);

    img = new Image(Path("ext:logo"));
    img.loadFromFile("images/logo.tga");
    pool.save(img);
    
    auto mat = new Material(Path("material:general"));
    mat.ambient = Color(0.0, 0.0, 0.0, 1.0);
    mat.diffuse = Color(1.0, 0.0, 0.0, 1.0);
    mat.specular = Color(0.0, 0.0, 0.0, 1.0);
    mat.textures = mat.textures ~ img;

    auto mdl = new Model(Path("models:triangle"));
    auto tri = Triangle();
    tri.a = Vector3f(0.0, -1.0, 0.0);
    tri.b = Vector3f(1.0, 1.0, 0.0);
    tri.c = Vector3f(-1.0, 1.0, 0.0);
    mdl.vertices = [tri];
    mdl.material = mat;
    pool.save(mdl);
    
    pool.save(mat);
    
    pool.write();
}

void main() {
    auto win = new Window;
    createResources();

    {
        auto pool = new Pool("packages");
        auto mat = pool.load!Material(Path("material:general"));
        auto img = pool.load!Image(Path("fun:tux"));
        auto logo = pool.load!Image(Path("ext:logo"));
        auto cur = pool.load!Image(Path("cursors:pointer"));
        auto mdl = pool.load!Model(Path("models:triangle"));
        
        ////////////////////////////////////////
        auto layout = new Layout(win.inputDevice, cur);
        auto pic = new Picture(logo);
        pic.pos = UDim(Vector2f(0.9, 0.9));
        pic.size = UDim(Vector2f(0.1, 0.1));
        layout.add(pic);
        
        auto fpsc = new FPSCalc;
        
        GC.disable();
        
        while (!win.inputDevice.isPressed(Key.e)) {
            fpsc.frame();
            win.target.clear();
            
            layout.draw(win.target);
            
            win.update();
            GC.collect();
        }

        GC.collect();
    }

    GC.collect();
}
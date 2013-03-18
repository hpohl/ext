module ext.misc.fpscalc;

import std.datetime;


/**
 * This class calculates average FPS based on user input.
 */
class FPSCalc {
    /**
     * Sets up the FPS calculator.
     */
    this() {
        _last = Clock.currTime();
    }
    
    /**
     * Injects a frame event.
     */
    void frame() {
        auto current = Clock.currTime();
        auto diff = current - _last;
        _last = current;
        _fps = 1_000_000_000.0 / diff.total!"nsecs"();
    }
    
    /**
     * Get the calculated FPS.
     */
    @property float get() const nothrow pure {
        return _fps;
    }
    
    private {
        float _fps;
        SysTime _last;
    }
}
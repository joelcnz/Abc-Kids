/**
 * World module
 * 
 * Has World class
 */
module world;

import std.stdio;
import std.string;

import jecfoxid;

import base, /*keyhandling,*/ current;

/**
 * Main loop handler
 */
class World {
public:
	/**
	 * Constructor:
	 * 
	 * Setup display title,
	 * 
	 * Load media,
	 * 
	 * and setup Input instance
	 */
	this() {
		//al_set_window_title(DISPLAY, g_displayTitle.toStringz());
		
		_current = new Current;
		//_keyHandling = new KeyHandling;
	}

	~this() {

	}
	
	/**
	 * Main program loop
	 */
	void run() {
		bool done = false;
		while(! done) {
			FPS.start();
			while(gFEvent.update) {
				if(gFEvent.isQuit) 
					done = true;
			}

			SDL_PumpEvents();		
			
			_current.logic;

			gGraph.clear(); // Clear screen

			_current.draw;
	
			gGraph.drawning(); // Swap buffers

			FPS.rate();
		}
	}
private:
	Current _current; // handles the current state (current picture and display)
}

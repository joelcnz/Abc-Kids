/**
 * World module
 * 
 * Has World class
 */
module world;

import std.stdio;
import std.string;

import jecsdl;

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
		// SDL_Init(SDL_INIT_JOYSTICK);
		
		bool done = false;
		while(! done && ! interrupingQuit) {
			// FPS.start();
			//Handle events on queue
			while( SDL_PollEvent( &gEvent ) != 0 ) {
				//User requests quit
				if (gEvent.type == SDL_QUIT)
					done = true;
			}

			SDL_PumpEvents();

			//if (g_keys[SDL_SCANCODE_BACKSPACE].keyPressed)
			//	mixin(tce("SDL_NumJoysticks()"));
			
			_current.logic;

			// gGraph.clear(); // Clear screen
			// Clear the render target texture to a colour
			SDL_SetRenderDrawColor(gRenderer, 0, 0, 0, 0);
			SDL_RenderClear(gRenderer);

			_current.draw;
	
			// gGraph.drawning(); // Swap buffers
			// And update the window/screen
			SDL_RenderPresent(gRenderer);

			SDL_Delay(2);
			// FPS.rate();
		} // while ! done
		if (interrupingQuit)
			writeln("Exiting early..");
	}
private:
	Current _current; // handles the current state (current picture and display)
}

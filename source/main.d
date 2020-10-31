//#!rdmd

/* To Dos:
 * More work on input.d [ ]
 * Add resize and save photos that are too big to fit in the display [ ]
 */
//#Note: args[ 0 .. $ ] gets all, args[ 1 .. 3 ] gets 1, & 2
//#Note immutable I think is for concurrancy(sp)
//#doesn't draw strait onto bmp
//#Split isn't clear this way ("foo bar".split), I think
//#dlang.ogg is a funny one
/**
 * Type, Hear and See
 */
module type_hear_and_see;

import std.stdio;
import std.string;
import algo = std.algorithm;
import std.typetuple;
import std.path;

import jecfoxid;

import base, world;

/**
 * Title: Main program entry
 * 
 * Init JECA, run main class
 */
int main( string[] args ) {
	//#Note: args[ 0 .. $ ] gets all, args[ 1 .. 3 ] gets 1, & 2

		//args = args[ 0 ] ~ "-wxh 640 480 -mode full".split() ~ args[ 1 .. $ ]; //#Split isn't clear this way ("foo bar".split), I think. Less typing though
	//args = args[ 0 ] ~ "-wxh 640 480".split() ~ args[1 .. $];

	assert(init(args) == 0, "init failed");

	return 0;
} // main

int init(string[] args) {
	assert(jf_setup(g_displayTitle), "jf setup failed");

	scope( exit )
		close;

	scope(failure)
		writeln("An error has occured!");
	base.checkFile("Fonts/DejaVuSans.ttf").setUpGlobalFont();
	version(Windows) base.checkFile("abc.png").setUpIcon();

	// create and launch main class object, then start main loop
	try {
		(new World).run();
	} catch( Exception e ) {
		writeln("Got caught in main: ", e.toString());
		return -1;
	}

	return 0;
}

void close() {
	destroy(gGraph);
	destroy(loader);
	destroy(g_font);

	destroy(window);
	sdlDestroy();
}

/**
 * Setup font for text
 */
void setUpGlobalFont(string fileName) {
	g_font = new Font();
	base.g_font.load(fileName, 36); // 18 seemed nice, (but small)
}

/**
 * Set icon for the window
 */
void setUpIcon(string fileName) {
//	al_set_display_icon(DISPLAY, Bmp.loadBitmap(fileName));
}

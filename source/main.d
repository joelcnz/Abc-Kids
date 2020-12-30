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
 * Init jecfoxid, run main class
 */
int main( string[] args ) {
	import std.stdio, std.file;

	immutable settingsFileName = "settings.txt";
	if (! settingsFileName.exists) {
		writeln(settingsFileName, " - not exist");
		return -2;
	}
	auto fr = File(settingsFileName, "r"); // open for reading
	g_playBackFolder = fr.readln.strip;
	g_voicesFolder = fr.readln.strip;
	fr.close;

	bool prompt;
	import std.getopt;
	auto helpInformation = getopt(
		args,
		"playback", &g_playBackFolder, // pictures and sound
		"letters", &g_voicesFolder,    // Alphabet and numbers
		"prompt", &prompt
	);

	if (prompt) {
		import arsd.terminal;
		import std.algorithm;

		auto chooseFolder(in string folderStart, string progress) {
			string[] files;
			foreach(string name; dirEntries(".",SpanMode.shallow)) {
				if (name.isDir && name.canFind(folderStart))
					files ~= name[2..$];
			}
			writeln(folderStart, " categories ", progress, ":");
			int i;
			files.map!(w => text(i += 1, ". ", w)).each!writeln;
			int sel;
			bool done;
			do {
				done = true;
				auto terminal = Terminal(ConsoleOutputType.linear);
				//import std.string : sstrip = strip;
				string input = terminal.getline();
				try {
					sel = input.to!int;
				} catch(Exception e) {
					writeln("Invalid selection, try again..");
					done = false;
				}
				if (done == true && sel < 1 || sel > files.length) {
					writeln("Out of range, try again..");
					done = false;
				}
			} while(! done);

			return files[sel-1];
		}

		g_playBackFolder = chooseFolder("PlayBack", "1/2");
		g_voicesFolder = chooseFolder("Letters", "2/2");
	}

	import std.file : exists;
	if (! g_voicesFolder.exists) {
		writeln(g_voicesFolder, " - does not exist");
		return -3;
	}
	if (! g_playBackFolder.exists) {
		writeln(g_playBackFolder, " does not exist");
		return -4;
	}
	if (helpInformation.helpWanted) {
		defaultGetoptPrinter("Some information about the program. Eg 'dub -- --letters LettersO --playback PlayBackA'",
		helpInformation.options);
		return 0;
	}
	auto f = File("settings.txt", "w"); // open for writing
	f.writeln(g_playBackFolder, '\n', g_voicesFolder);
	f.close;
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

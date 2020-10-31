//#work
//#Not sure on name
/**
 * Title: Base - variables with that are easiest to access
 * 
 * Kind of global variables (depending if this is imported in other modules)
 */
module base;

import std.stdio;
import std.file;

import jecfoxid;

import progressbar;

string g_inputLets; /// User input

/// global progress bar object
ProgressBar g_progressBar;

/// What appears on the windows title bar
immutable g_displayTitle = "Abc - Type, Hear, and See! :-)";

/// Main font
Font g_font; // public by default. //#Not sure on name

bool g_upDateRefGfx = true;

/// Store the number of letters in the English alphabet
immutable g_numberOfLettersInTheAphabet = 26;

/// Font thickness list of possible settings
enum g_PrintFatness {fat, slim};

/// Empty string
enum g_emptyText = ""; // was g_nothing

/// Alphabet letter sounds folder
immutable g_voicesFolder = "Letters";

/// Sounds, pictures and other media
immutable g_playBackFolder = "Playback";

/// reference word devider
immutable g_devide = ", ";
immutable g_otherDevide = " / "; // unused

/// End of list of keys
immutable g_endOfList = ".";

immutable g_soundExtentions = ".ogg .wav"; /// sound file extentions
immutable g_imageExtentions = ".jpg .png .bmp"; /// image file extentions
immutable g_mediaExtentions = g_soundExtentions ~ ' ' ~ g_imageExtentions; /// both sound and image extentions

//#work
//immutable pathSeparator = '\\';

/**
 * Helper: adds quotes for exceptions
 */
string inQUotes(string str) {
	return `"` ~ str ~ `"`;
}

/**
 * Test file existance and throw an exception if not
 * param: file name
 * return: file name
 */
string checkFile(in string fileName, in string msg = " exists.") {
	if (! fileName.exists())
		throw new FileException(fileName.inQUotes());
	else {
		writeln(fileName.inQUotes, msg);
		
		return fileName;
	}
}

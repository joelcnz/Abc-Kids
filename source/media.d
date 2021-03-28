//# look at getting rid of 'active'
//#not sure here
//#maybe wipe this line
//#does not crash like writefln can
//#why can't I put 'catch( AssertError a )' it prints 'AssertError'?
//#gotcha
import std.stdio;
import std.file; // checks to see if file exists
import std.string;
import std.conv: to;
import std.exception;
import std.traits: EnumMembers; // for foreach enums
import std.path;

import jecsdl;

import base, texthandling, progressbar;

// Media: sound and stuff
interface IMedia {
	IText text(); // key word
	auto ref Image picture(); // picture
	void devide( in bool devide0 ); // word/name devide setter 'cat, mouse' the ', ' is the thing
	void showRefWord(in g_PrintFatness printFatness ); // display word/name, done thick or thin
	void tell(); // play the sound, if one
	//bool isPic();
	// void isPic(bool isPic0);
}

/**
 * Title: Media class - word ref
 * 
 * Display words, pictures, and play sound
 */
class Media: IMedia {
	Image _pic;
	bool _isPic;
	JSound _snd;
	bool _devide;
	IText _text;
	Image refsImg;

	/**
	 * Helper function for the media class - loads media off HDD creating objects for the media
	 */
	static auto loadInMedia() {
		
		IMedia[] media;
		
		bool[string] oneEach;

		bool mediaLengthGreaterThanZero() {
			return media.length > 0;
		}
		
		//#didn't read the instructions properly, didn't see (SpanMode.shallow) single folder only (not use sub folders).
		string[] names;
		import std.algorithm : sort, map;
		import std.array;
		auto sortBy = dirEntries(g_playBackFolder, SpanMode.shallow).array.sort!"a.toLower < b.toLower";
		foreach(string e; sortBy) {
			if (e.isDir)
				writeln( "Ignoring directory - ", e );
			else
				names ~= e;
		}

		// go through all the files setting them up
		g_progressBar = ProgressBar(
			/* step size: */ cast(float)SCREEN_WIDTH / names.length,
			/* fullLength: */ SCREEN_WIDTH);

		Image currentPicture;

		// Init
		load1: foreach(name; names) {
			while( SDL_PollEvent( &gEvent ) != 0 ) {
				//User requests quit
				if (gEvent.type == SDL_QUIT) {
					interrupingQuit = true;
					break load1;
				}
			}

			// gGraph.clear();
			SDL_SetRenderDrawColor(gRenderer, 0, 0, 0, 0);
			SDL_RenderClear(gRenderer);

			import p = std.path;
			import std.file;
			string fileNameBase = p.baseName(name.stripExtension),
				extension = p.extension(name).toLower;
			import std.string;

			debug
				writeln( format!"%s%s"(fileNameBase, extension) ); //#does not crash like writefln can
			
			if ( fileNameBase !in oneEach ) { 
				oneEach[ fileNameBase ] = true;
				auto aMatch = false;
				foreach( current; g_mediaExtentions.split ) {
					
					if ( extension == current ) {
						// mixin(tce("current"));
						aMatch = true;
						media ~= new Media(
							media,
							SDL_Color(255,0,0), //Colour.red,
							SDL_Color(255,255,0),//Colour.yellow,
							g_playBackFolder ~ dirSeparator ~ fileNameBase,
						);
						if (media[$ - 1].picture.mImg !is null) {
							currentPicture = media[$ - 1].picture;
						}
					}
				}

				if (currentPicture.isPic) {
					currentPicture.draw;
					// gGraph.draw(currentPicture,Vec(0,0));
				}
				
				with(g_progressBar)
					process(),
					draw();

				//Update display
				// gGraph.drawning();
				//SDL_Delay(100);
				SDL_RenderPresent(gRenderer);

				// SDL_Delay(50);

				// If no matches for file (eg. 'shoe.mud' wouldn't be a match)
				auto notAMatch = ! aMatch;
				if ( notAMatch )
					writeln( "Reject: ", name); // to!string( al_get_path_filename( path ) ) ); //#not sure here
			}
		} // for Dir
		
		// Take off the devide text for the last referance word
		if ( mediaLengthGreaterThanZero )
			media[ $ - 1 ].devide = false;
		
		return media;
	}

	IText text() { return _text; }
	auto ref Image picture() { return _pic; } // if ( _pic !is null ) return _pic(); else return null; } //#gotcha
	void devide( in bool devide0 ) { _devide = devide0; }

	this(
		IMedia[] media,
		SDL_Color fatColour,
		SDL_Color slimColour,
		string rootName
	) {
		debug(10)
			mixin("rootName".trace);

		string text = rootName[indexOf(rootName, dirSeparator) + 1 .. $].idup;
		_devide = true;
		float xpos = 0f, ypos = 0f;
		bool mediaLengthGreaterThanZero = media.length > 0;

		if (mediaLengthGreaterThanZero) {
			auto last = media[ $ - 1 ]; // prev - previous media object
			// last pos plus new word

			int w,h;
			TTF_SizeText(gFont, (last.text.stringText~g_devide).toStringz, &w, &h);
			xpos = last.text.xpos + w;
			ypos = last.text.ypos;
			TTF_SizeText(gFont, (text ~ g_devide ).toStringz, &w, &h);
			//If would hang over the edge of the screen, then start new line for word etc
			if ( xpos + w > SCREEN_WIDTH ) {
				xpos = 0f;
				ypos = ypos + h;
			}
			writeln(last.text.stringText);
		}
		else {
			xpos = ypos = 0f;
		}
		
		_text = new KText(
			xpos,
			ypos,
			fatColour,
			slimColour,
			text
		);
		
		foreach( ext; g_imageExtentions.split())
			if ( exists( rootName ~ ext ) ) {
				// _pic = new Sprite();
				// foxloader.load!Image(rootName~ext, rootName);
				// _pic.image = foxloader.get!Image(rootName);
				_pic.setup(rootName ~ ext);
				break;
			}

		_snd.active = false; //# look at getting rid of 'active'
		foreach( ext; g_soundExtentions.split())
			if ( exists( rootName ~ ext ) ) {
				//_snd = new Sound();
				try {
					//_snd.load(rootName ~ ext, rootName);
					_snd.loadSnd(rootName ~ ext);
					_snd.active = true;
				} catch(Exception e) {
				//if ( _snd is null )
					writeln( rootName ~ ext ~ " warning sound failed!" );
				}
				break;
			}
	} // this

	~this() {
		// destroy(refsImg);
	}

	/**
	 * Play sound if there's one
	 */
	void tell() {
		if ( _snd.active )
			_snd.play;
	}

	/**
	 * Show key word, gets call twice for drawing both thicknesses
	 */
	void showRefWord(in g_PrintFatness printFatness = g_PrintFatness.slim ) {
		// decides what to add to the end of the word, depending if it's the last word or not
		auto textAndDevide = _text.stringText ~ ( _devide == true ? g_devide : g_endOfList ) ;

		foreach( fatness; EnumMembers!g_PrintFatness )
			with( _text ) {
				_text.draw(xpos, ypos, fatness, textAndDevide );
			}
	}
}

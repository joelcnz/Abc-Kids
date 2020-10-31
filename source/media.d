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

import jecfoxid;

import base, texthandling, progressbar;

// Media: sound and stuff
interface IMedia {
	@property IText text(); // key word
	@property Sprite picture(); // picture
	@property void devide( in bool devide0 ); // word/name devide setter 'cat, mouse' the ', ' is the thing
	void showRefWord( Display graph, in g_PrintFatness printFatness ); // display word/name, done thick or thin
	void tell(); // play the sound, if one
}

/**
 * Title: Media class - word ref
 * 
 * Display words, pictures, and play sound
 */
class Media: IMedia {
private:
	Sprite _pic;
	Sound _snd;
	bool _devide;
	IText _text;
	Image refsImg;
public:
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
		import std.algorithm : sort;
		import std.array;
		foreach(string e; dirEntries(g_playBackFolder, SpanMode.shallow).array.sort!"a < b") {
			names ~= e;
		}

		/+
		// go through all the files setting them up
		g_progressBar = ProgressBar(
			/* step size: */ cast(float)window.width / names.length,
			/* fullLength: */ window.width);
		+/

		auto currentPicture = new Sprite();

		// Init
		//with(g_progressBar)
		//	process(),
		//	draw();

		gGraph.drawning(); //#maybe wipe this line

		foreach(ref name; names) {
			gGraph.clear();
			with(g_progressBar)
				process(),
				draw();
			/+
			auto path = al_create_path(name.toStringz());
			scope( exit )
				al_destroy_path( path );

			alias al_get_path_extension getExtension;
			string 
				extension = getExtension(path).to!string().toLower(),
				fileNameBase;
			if ( name.isFile )
				fileNameBase = to!string( al_get_path_basename( path ) );
			else {
				writeln( "Ignore directory - ", name );
				continue;
			}
			+/
			import p = std.path;
			import std.file;
			string fileNameBase = p.baseName(name[0..$-4]),
				extension = p.extension(name).toLower;
			import std.string;
			if (name.isDir) {
				writeln( "Ignore directory - ", name );
				continue;
			}

			debug
				writeln( format( "%s%s", fileNameBase, extension ) ); //#does not crash like writefln can
			
			if ( fileNameBase !in oneEach ) { 
				oneEach[ fileNameBase ] = true;
				auto aMatch = false;
				foreach( current; g_mediaExtentions.split ) {
					
					if ( extension == current ) {
						aMatch = true;
						media ~= new Media(
							media,
							Color(255,0,0), //Colour.red,
							Color(255,255,0),//Colour.yellow,
							g_playBackFolder ~ dirSeparator ~ fileNameBase,
							//filename,
						);
						//if (name.toLower.indexOf(".jpg") != -1)
						if (media[$ - 1].picture) {
							//al_draw_bitmap(media[$ - 1].picture, 0f, 25f, 0);
							currentPicture = media[$ - 1].picture;
						}
					}
				}

				if (currentPicture !is null)
					gGraph.draw(currentPicture,Vec(0,0));
					//al_draw_bitmap(currentPicture, 0f, 25f, 0);
				
				//Update display
				gGraph.drawning();

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

	@property IText text() { return _text; }
	@property Sprite picture() { return _pic; } // if ( _pic !is null ) return _pic(); else return null; } //#gotcha
	@property void devide( in bool devide0 ) { _devide = devide0; }

	this(
		IMedia[] media,
		Color fatColour,
		Color slimColour,
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
			//xpos = last.text.xpos + al_get_text_width( base.g_font, toStringz( last.text.stringText ~ g_devide) );
			xpos = last.text.xpos + (last.text.stringText~g_devide).getWidthText(g_font);
			ypos = last.text.ypos;
			//If would hang over the edge of the screen, then start new line for word etc
			if ( xpos + (text ~ g_devide ).getWidthText(g_font) > window.width ) {
				xpos = 0f;
				ypos = ypos + base.g_font.height;
			}
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
				//al_set_new_bitmap_flags(ALLEGRO_MAG_LINEAR);
				//_pic = new Bmp( (rootName ~ ext).checkFile(" image file loaded.") );
				_pic = new Sprite();
				foxloader.load!Image(rootName~ext, rootName);
				_pic.image = foxloader.get!Image(rootName);
				break;
			}

		foreach( ext; g_soundExtentions.split())
			if ( exists( rootName ~ ext ) ) {
				//_snd = al_load_sample( toStringz( (rootName ~ ext).checkFile(" sound file loaded.") ) );
				//_snd = al_load_sample( toStringz( (rootName ~ ext)) );
				_snd = new Sound();
				try
					_snd.load(rootName ~ ext, rootName);
				catch(Exception e) {
				//if ( _snd is null )
					writeln( rootName ~ ext ~ " warning sound failed!" );
				}
				break;
			}
	} // this

	~this() {
		destroy(refsImg);
	}

	/**
	 * Play sound if there's one
	 */
	void tell() {
		if ( _snd )
			_snd.play(false);
			/+
			al_play_sample(
				_snd,
				1.0,
				ALLEGRO_AUDIO_PAN_NONE,
				1.0,
				ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_ONCE,
				null
			);
			+/
	}
	
	/**
	 * Show key word, gets call twice for drawing both thicknesses
	 */
	void showRefWord( Display graph, in g_PrintFatness printFatness = g_PrintFatness.slim ) {
		// decides what to add to the end of the word, depending if it's the last word or not
		auto textAndDevide = _text.stringText ~ ( _devide == true ? g_devide : g_endOfList ) ;

		foreach( fatness; EnumMembers!g_PrintFatness )
			with( _text )
				_text.draw(graph, xpos, ypos, fatness, textAndDevide );
	}
}

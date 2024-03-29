//#?
//#under construction - (repeating keys)
//#should break this method into two -- maybe not
//#speed (pitch?)
module input;

import std.stdio;
import std.string;
import std.file;
import std.conv;
import std.traits: EnumMembers; // for foreach enums
import std.array; // for empty
import std.path; // for pathSeparator( '\\' or '/' )
import std.ascii;

import jecsdl;

import base, texthandling; //, keys;

alias std.ascii.lowercase lowercase;

/**
 * For typing in the words to activate
 */
@("hello", 1, 2.3, '4')
class Input {
public:
	JSound blowSnd;
	string _lastInput;
	int keysEnd = SDL_NUM_SCANCODES;
	bool updateRefGraphs;

	this() {
		_text = new KText(
			/* xpos: */ 0,
			/* ypos: */ SCREEN_HEIGHT - 50,
			/* fat colour: */ SDL_Color(0,0,255), //Colour.blue,
			/* slim colour: */ SDL_Color(0,255,255) //Colour.cyan
		);
		
		// go through the letters of the alphabet
		immutable a = 0, z = 26;
		// Use this sound in the case of each letter sound fails to load
		//blowSnd = new Sound();
		blowSnd.loadSnd(g_playBackFolder ~ dirSeparator ~ "blow.wav");
		foreach( letter; a .. z ) {
			auto fileName = g_voicesFolder ~ dirSeparator ~ lowercase[ letter ] ~ ".wav";
			auto otherFileName = fileName[ 0 .. $ - 4 ] ~ ".ogg";
			
			if ( ! exists( fileName ) && exists( otherFileName ) )
				fileName = otherFileName;

			if ( exists( fileName ) ) {
				//_lsnds[ letter ] = new Sound();
				_lsnds[ letter ].loadSnd( fileName );
				if ( _lsnds[ letter ].mSnd is null ) {
					writeln( fileName, " - not load! - Get hold of your vendor at once!" );
					_lsnds[ letter ] = blowSnd; // default sound
				}
			}
			else
				writeln( fileName, " - not exist! - Get hold of your vendor at once!" );
		}
		
		foreach( number; 0 .. 9 + 1) {
			auto fileName = g_voicesFolder ~ dirSeparator ~ number.to!string() ~ ".wav";

			auto otherFileName = fileName[ 0 .. $ - 4 ] ~ ".ogg";
			
			if ( ! exists( fileName ) && exists( otherFileName ) )
				fileName = otherFileName;

			if ( exists( fileName ) ) {
				// _nsnds[ number ] = new JSound();
				_nsnds[ number ].loadSnd( fileName );
				if ( _nsnds[ number ].mSnd is null ) {
					writeln( fileName, " - not load! - Get hold of your vendor at once!" );
					//_nsnds[ number ] = blowSnd; // default sound
				}
			}
			else
				writeln( fileName, " - not exist! - Get hold of your vendor at once!" );
		}
		updateRefGraphs = true;
	}

	/**
	 * Receive input and play its letter
	 */
	//#should break this method into two -- maybe not
	auto doKeyInput( ref bool doShowRefWords, ref bool doShowPicture ) {
		// put object text into the care of string text until later
		string text = _text.stringText;

		// update text before exiting function
		scope( exit ) {
			_text.stringText = text;
			g_inputLets = text;
		}

		// Do input
		foreach(int keyId; keysStart .. keysEnd ) { //#not sure if keysEnd is a key, it isn't in the loop
			foreach(keyStuff; [&doAlphabet, &doSpace, &doNumbers, &doBackSpace, &doEnter]) {
				auto result = keyStuff( keyId, text, doShowRefWords, doShowPicture );
				auto notEmpty = ! result.empty;
				if ( notEmpty ) {
					_lastInput = result;
					return result;
				}
			}
		}
		
		return g_emptyText;
	} // get input key
	
	/**
	 * Display input text on screen
	 */
	void drawTextInput() {
		foreach( fatness; EnumMembers!g_PrintFatness )
			_text.draw(fatness, true);
	}
private:
	JSound[g_numberOfLettersInTheAphabet] _lsnds;
	JSound[10] _nsnds; //#?
	IText _text;
	immutable
		enum keysStart = 0;

	// Add a letter and play a sound if letter key hit
	string doAlphabet( int keyId, ref string text, ref bool doShowRefWords, ref bool doShowPicture  ) {
		if ( keyId >= SDL_SCANCODE_A && keyId <= SDL_SCANCODE_Z && g_keys[ keyId ].keyTrigger ) {
			// Play letter
			_lsnds[ keyId - SDL_SCANCODE_A ].play;

			// add letter
			bool keyShift() {
				return ( g_keys[ SDL_SCANCODE_LSHIFT ].keyPressed || g_keys[ SDL_SCANCODE_RSHIFT ].keyPressed );
			}
			text ~= ( ( ! keyShift ? 'a' : 'A' ) + ( keyId - SDL_SCANCODE_A ) & 0xFF );
		}
		return g_emptyText;
	}
	
	string doSpace( int keyId, ref string text, ref bool doShowRefWords, ref bool doShowPicture  ) {
		if ( keyId == SDL_SCANCODE_SPACE && g_keys[ SDL_SCANCODE_SPACE ].keyTrigger ) {
			text ~= ' ';
		}
		return g_emptyText;
	}
	
	string doNumbers( int keyId, ref string text, ref bool doShowRefWords, ref bool doShowPicture ) {
		struct NumKeys {
			int scanc;
			char n;
		}
		NumKeys[] numKeys = [
			{SDL_SCANCODE_0,'0'},
			{SDL_SCANCODE_1,'1'},
			{SDL_SCANCODE_2,'2'},
			{SDL_SCANCODE_3,'3'},
			{SDL_SCANCODE_4,'4'},
			{SDL_SCANCODE_5,'5'},
			{SDL_SCANCODE_6,'6'},
			{SDL_SCANCODE_7,'7'},
			{SDL_SCANCODE_8,'8'},
			{SDL_SCANCODE_9,'9'}];
		foreach(sni, nk; numKeys)
			if (g_keys[nk.scanc].keyTrigger) {
				_nsnds[sni].play;
				text ~= nk.n;
			}
		return g_emptyText;
	}
	
	string doBackSpace( int keyId, ref string text, ref bool doShowRefWords, ref bool doShowPicture  ) {
		bool wordHasLength = text.length > 0;
		if ( wordHasLength && keyId == SDL_SCANCODE_BACKSPACE && g_keys[ SDL_SCANCODE_BACKSPACE ].keyTrigger ) {
			blowSnd.play;
			text = text[ 0 .. $ - 1 ];
		}
		return g_emptyText;
	}

	string doEnter( int keyId, ref string text, ref bool doShowRefWords, ref bool doShowPicture ) {
		// Activate the entered word
		auto textIsSomeThing = text != g_emptyText;
		if ( keyId == SDL_SCANCODE_RETURN && g_keys[ SDL_SCANCODE_RETURN ].keyTrigger ) {
			//"return".gh;
			g_upDateRefGfx = true;
			if ( textIsSomeThing ) {
				if (text == "r" || text == "R") {
					text = g_emptyText;
					doShowRefWords = false;
					doShowPicture = true;
					return _lastInput;
				}
				if ( doShowRefWords ) {
					// show picture without the words
					doShowRefWords = false;
					doShowPicture = true;
					// g_upDateRefGfx = true;
				}
				
				auto text2 = _text.stringText.idup;
				text = g_emptyText;
				
				return text2; // and here's a hasty return
			} // if _text.. is not nothing
			
			if ( text == g_emptyText ) {
				if ( ! doShowRefWords && doShowPicture ) {
					// show picture and words
					doShowRefWords = true;
					
					return g_emptyText;
				}
				
				if ( doShowRefWords && doShowPicture ) {
					// show words but no picture
					doShowPicture = false;

					return g_emptyText;
				}
			} // if input is nothing
		} // Activate the entered word
		return g_emptyText;
	}
} // class input

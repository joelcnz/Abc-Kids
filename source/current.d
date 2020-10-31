//#not work should look at D->UDA on delicious
//#hack, uses global symbol
//#not sure on using with with only one method call
/**
 * Title: Current (like current picture)
 */
module current;

import std.stdio;
import std.string;
import std.conv;
import std.traits: EnumMembers; // for foreach enums
import std.math;
import std.random;

import jecfoxid;

import base, media, input;

/**
 * Title: Current class for current viewing state
 */
class Current {
public:
	
	this() {
		doShowRefWords = true,
		doShowPicture = false;
		noPicture = null;
		_strInput = g_emptyText;
		_media = Media.loadInMedia(); // from media module
		_input = new Input();

		_refsImg = new Image();
		window.blendMode = BlendMode.blend;
		_refsImg.createTexture(window.width,window.height,Color(0,0,0,0),PixelFormat.RGBA);
		window.blendMode = BlendMode.none;
	}
	
	void logic() {
		doInputStuff();
	}

	void draw() {
		drawPicture(); // if one

		drawReferenceWords(); // words and stuff

		_input.drawTextInput();
	}
private:
	IMedia[] _media; // sound, picture, and word dynamic array
	Input _input; // handle keyboard input (user typing in the words/names)
	Sprite _picture; // current picture
	Image _refsImg;
	bool
		doShowRefWords,
		doShowPicture;
	
	Sprite noPicture;
	string _strInput;

	void doInputStuff() {
		pragma(msg, __traits(getAttributes, typeof(_input)));

		// main Input method
		with( _input ) {
			_strInput = doKeyInput( /* ref: */ doShowRefWords, /* ref: */ doShowPicture );
			if ( ! doShowPicture )
				_picture = noPicture;

			if ( _strInput != g_emptyText ) {
				auto noMedia = true;
				foreach( m; _media ) {
					auto inputNameMatch = _strInput.toLower == m.text.stringText.toLower;
					if ( inputNameMatch ) {
						noMedia = false;
						m.tell;
						if ( isAPicture( m.picture ) )
							_picture = m.picture;
					}	
				}
				if ( noMedia && _strInput.length > 0 ) {
					IMedia m;
						m = _media[ uniform( 0, $ ) ];
					_picture = m.picture;
					m.tell;
				}
			}
		}
	}
	
	// check for picture (is it null or pointing to picture data)
	bool isAPicture( in Sprite picture ) {
		return ( picture !is null );
	}

	void drawPicture() {
		// Show picture
		if ( doShowPicture && isAPicture( _picture ) ) {
			float
				sw = _picture.image.width,
				sh = _picture.image.height;
			import std.string;
			float dw, dh;
			dw = dh = 0;
			if ( sw > window.width || sh > window.height ) {
				float max = fmax( sw, sh );
				float max2 = ( max == sw ? window.width : window.height );

				dw = sw / max * max2,
				dh = sh / max * max2;
			} else {
				dw = sw;
				dh = sh;
			}

			gGraph.draw(_picture.image,Vec((window.width-dw)/2,(window.height-dh)/2));
		}
	}

	void drawReferenceWords() {
		// show ref words
		if ( doShowRefWords ) {
			if (g_upDateRefGfx) {
				_refsImg.edit((Display graph) @trusted {
					foreach( media; _media )
						foreach( printFatness; EnumMembers!g_PrintFatness ) { // fat and slim type - fat prints slim x9
							media.showRefWord( graph, printFatness );
						}
				});
				g_upDateRefGfx = false;
				//"update".gh;
			} else {
				gGraph.draw(_refsImg, Vec(0,0));
			}
		} // show ref words
	}
}

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

import jecsdl;

import base, media, input;

/**
 * Title: Current class for current viewing state
 */
class Current {
public:
	
	this() {
		doShowRefWords = true,
		doShowPicture = false;
		// noPicture = null;
		_strInput = g_emptyText;
		_media = Media.loadInMedia(); // from media module
		_input = new Input();

		//_refsImg = new Image();
		// window.blendMode = BlendMode.blend;
		SDL_SetRenderDrawBlendMode(gRenderer, SDL_BLENDMODE_BLEND);
		//_refsImg.createTexture(window.width,window.height,SDL_Color(0,0,0,0),PixelFormat.RGBA);
		// _refsImg.setup("transparent.png"); 
		_refsImg.setup(SCREEN_WIDTH, SCREEN_HEIGHT);
		// window.blendMode = BlendMode.none;
		SDL_SetRenderDrawBlendMode(gRenderer, SDL_BLENDMODE_NONE);
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
	Image _picture; // current picture
	Image _refsImg;
	bool
		doShowRefWords,
		doShowPicture;
	
	// Image noPicture;
	string _strInput;

	void doInputStuff() {
		// pragma(msg, __traits(getAttributes, typeof(_input)));

		// main Input method
		with( _input ) {
			_strInput = doKeyInput( /* ref: */ doShowRefWords, /* ref: */ doShowPicture );
			// if ( ! doShowPicture ) {
				// _picture = noPicture;
				//_picture.close;
			// }

			if ( _strInput != g_emptyText ) {
				auto noMedia = true;
				foreach( m; _media ) {
					auto inputNameMatch = (_strInput.toLower == m.text.stringText.toLower);
					if ( inputNameMatch ) {
						noMedia = false;
						m.tell;
						if ( m.picture.isPic )
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
	
	void drawPicture() {
		// Show picture
		if ( doShowPicture && _picture.isPic ) {
			float
				sw = _picture.mRect.w,
				sh = _picture.mRect.h;
			import std.string;
			float dw, dh;
			dw = dh = 0;
			if ( sw > SCREEN_WIDTH || sh > SCREEN_HEIGHT ) {
				float max = fmax( sw, sh );
				float max2 = ( max == sw ? SCREEN_WIDTH : SCREEN_HEIGHT );

				dw = sw / max * max2,
				dh = sh / max * max2;
			} else {
				dw = sw;
				dh = sh;
			}

			// gGraph.draw(_picture.image,Vec((window.width-dw)/2,(window.height-dh)/2));
			_picture.pos = Point((SCREEN_WIDTH-dw)/2, (SCREEN_HEIGHT-dh)/2);
			_picture.draw;
		}
	}

	void drawReferenceWords() {
		// show ref words
		if ( doShowRefWords ) {
			if (g_upDateRefGfx) {
				// _refsImg.edit((Display graph) @trusted {
				SDL_SetRenderTarget(gRenderer, _refsImg.mImg);
				SDL_SetRenderDrawColor(gRenderer, 0, 0, 0, 0);
				SDL_RenderClear(gRenderer);
				drawPicture;
				foreach( media; _media )
					foreach( printFatness; EnumMembers!g_PrintFatness ) { // fat and slim type - fat prints slim x9
						media.showRefWord( printFatness );
					}
				// });
				g_upDateRefGfx = false;
				//"update".gh;
				SDL_SetRenderTarget(gRenderer, null);
			} else {
				//gGraph.draw(_refsImg, Vec(0,0));

				_refsImg.draw;
			}
		} // show ref words
	}
}

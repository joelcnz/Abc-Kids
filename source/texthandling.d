//#final switch?
/**
 *	Text handling
 */
module texthandling;

import std.stdio;
import std.conv: convText = text, to; // Rename to avoid symbol collistion(sp)
import std.string: toStringz; // only allow access to toStringz
import std.ascii : toLwr = toLower;
import std.traits;

import jecsdl;

import base;

bool hasLets(in char test) {
	foreach(c; g_inputLets)
		if (c.toLwr() == test.toLwr())
			return true;
	return false;
}

interface IText {
	pure string stringText() const; // getter - IText A = new Media(..); string a = A.text;
	string stringText( in string stringText0 ); // setter - IText A = new Media(..); A.text = "goody dollars";
	pure float xpos() const; 
	pure float ypos() const;
	float xpos( in float xpos0 ); 
	float ypos( in float ypos0 );
	void draw(g_PrintFatness fatness, in bool inputLets = false);
	void draw(float x, float y, g_PrintFatness fatness, in string text, in bool inputLets = false);
}

/**
 * Handles the text part
 */
class KText: IText {
private:
	static JText _txt;
	string _stringText;
	float _x, _y;
	SDL_Color
		_fatColour,
		_slimColour;
public:
	pure string stringText() const { return _stringText; }
	string stringText( in string stringText0 ) { return _stringText = stringText0; }
	pure float xpos() const { return _x; }
	pure float ypos() const { return _y; }
	float xpos( in float xpos0 ) { return _x = xpos0; }
	float ypos( in float ypos0 ) { return _y = ypos0; }
	
	this( in float x, in float y, in SDL_Color fatColour, in SDL_Color slimColour) {
		this( x, y, fatColour, slimColour, g_emptyText );
	}
	
	this( in float x, in float y, in SDL_Color fatColour, in SDL_Color slimColour, in string stringText ) {
		"KText constructor".gh;
		_txt = JText("", SDL_Point(), SDL_Color(), 38, "DejaVuSans.ttf");
		xpos = x;
		ypos = y;
		_fatColour = fatColour;
		_slimColour = slimColour;
		_stringText = stringText;
	}
	
	void draw( g_PrintFatness printFatness, in bool inputLets = false ) {
		draw( xpos, ypos, printFatness, stringText, inputLets);
	}

	void draw( float x, float y, g_PrintFatness printFatness, in string stringText, in bool inputLets = false) {
		void drawThin( SDL_Color colour, float x, float y ) {
			/+
			float p = x;
			foreach(c; stringText) {
	 			al_draw_text(
					base.g_font, // ALLEGRO_FONT
					(hasLets(c) && ! inputLets ? Colour.red : colour), // colour
					p, y, // xpos, ypos
					ALLEGRO_ALIGN_LEFT, // alignment
					(c ~ "").toStringz() // string text (char*)
				);
				p += al_get_text_width(base.g_font, (c ~ "").toStringz());
			}
			+/
			_txt.pos = Point(x,y);
			_txt.colour = colour;
			_txt.setString = stringText;
			_txt.draw(gRenderer);
		}
		
		switch( printFatness ) { //#final switch?
			case g_PrintFatness.slim:
				drawThin( _slimColour, xpos + 1, ypos + 1 );
			break;
			case g_PrintFatness.fat:
				foreach( py;     _y .. _y + 3 )
					foreach( px; _x .. _x + 3 )
						drawThin( _fatColour, px, py );
			break;
			default:
				assert( false, convText( printFatness, " is invalid." ) );
		}
	} // draw
} // text

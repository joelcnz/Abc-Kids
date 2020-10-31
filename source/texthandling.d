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

import jecfoxid;

import base;

bool hasLets(in char test) {
	foreach(c; g_inputLets)
		if (c.toLwr() == test.toLwr())
			return true;
	return false;
}

interface IText {
	@property pure string stringText() const; // getter - IText A = new Media(..); string a = A.text;
	@property string stringText( in string stringText0 ); // setter - IText A = new Media(..); A.text = "goody dollars";
	@property pure float xpos() const; 
	@property pure float ypos() const;
	@property float xpos( in float xpos0 ); 
	@property float ypos( in float ypos0 );
	void draw(g_PrintFatness fatness, in bool inputLets = false);
	void draw(Display graph, float x, float y, g_PrintFatness fatness, in string text, in bool inputLets = false);
}

/**
 * Handles the text part
 * 
 * To do: make it part of the JECA library
 */
class KText: IText {
private:
	static JText _txt;
	string _stringText;
	float _x, _y;
	Color
		_fatColour,
		_slimColour;
public:
	@property pure string stringText() const { return _stringText; }
	@property string stringText( in string stringText0 ) { return _stringText = stringText0; }
	@property pure float xpos() const { return _x; }
	@property pure float ypos() const { return _y; }
	@property float xpos( in float xpos0 ) { return _x = xpos0; }
	@property float ypos( in float ypos0 ) { return _y = ypos0; }
	
	this( in float x, in float y, in Color fatColour, in Color slimColour) {
		this( x, y, fatColour, slimColour, g_emptyText );
	}
	
	this( in float x, in float y, in Color fatColour, in Color slimColour, in string stringText ) {
		"KText constructor".gh;
		_txt = JText("","DejaVuSans.ttf",38);
		xpos = x;
		ypos = y;
		_fatColour = fatColour;
		_slimColour = slimColour;
		_stringText = stringText;
	}
	
	void draw( g_PrintFatness printFatness, in bool inputLets = false ) {
		draw( gGraph, xpos, ypos, printFatness, stringText, inputLets);
	}

	void draw( Display graph, float x, float y, g_PrintFatness printFatness, in string stringText, in bool inputLets = false) {
		void drawThin( Color colour, float x, float y ) {
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
			_txt.position = Vec(x,y);
			_txt.colour = colour;
			_txt.text = stringText;
			_txt.draw(graph);
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

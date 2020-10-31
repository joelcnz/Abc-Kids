module progressbar;

import jecfoxid;

import base;

/**
 * Progress bar used when program is loading
 */
struct ProgressBar {
	float step; /// step size
	float fullLength; /// width of progress bar display
	float prgrss = 0f; /// Current advance progress indicator
	
	/**
	 * Ctor
	 * para:increment size, width of bar display
	 */
	this(float step0, float fullLength0) {
		step = step0;
		fullLength = fullLength0;
	}

	/// update
	void process() {
		prgrss += step;
	}

	/// draw
	void draw() {
		gGraph.drawRect(Vec(2,2),Vec(prgrss,20), Color(255,180,0), true);
		gGraph.drawRect(Vec(2,2),Vec(fullLength,20), Color(255,255,0), false);
		//al_draw_filled_rectangle(2,2, progress,20, Colour.amber);
		//al_draw_rectangle(2,2, fullLength,20, Colour.yellow, 2);

	}
}

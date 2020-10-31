			real
				w = al_get_bitmap_width( _picture ),
				h = al_get_bitmap_height( _picture ),
				SCREEN_W = al_get_display_width( DISPLAY ),
				SCREEN_H = al_get_display_height( DISPLAY );
			void draw() {
				al_draw_scaled_bitmap(
					/* bitmap: */ _picture,
					/* sx: */ 0,
					/* sy: */ 0,
					/* sw: */ al_get_bitmap_width( _picture ),
					/* sh: */ al_get_bitmap_height( _picture ),
					/* dx: */ ( SCREEN_W - w ) / 2,
					/* dy: */ 0,
					/* dw: */ w,
					/* dh: */ h,
					/* flags: */ 0
				);
			}
			
			while( w > SCREEN_W || h > SCREEN_H ) {
				draw;
				al_flip_display;
				
				poll_input;
				while( key[ ALLEGRO_KEY_SPACE ] ) { poll_input; }
				
				al_rest( 0.01 );
				--w;
				--h;
				mixin( trace( "w" ) );
				mixin( trace( "h" ) );
			}

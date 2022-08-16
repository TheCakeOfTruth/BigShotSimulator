/*
	Date: 24-11-2021
	Description: Battle arena
*/

package scripts {
	import flash.display.Sprite;
	import flash.events.Event;

	public class Arena extends Sprite {
		// No need for a contstructor
		
		// Change the size
		public function setSize(w:Number, h:Number):void {
			// Wall dimensions
			// Always change width because Wall objects are laid out horizontally
			upwall.getChildAt(0).width = w;
			downwall.getChildAt(0).width = w;
			leftwall.getChildAt(0).width = h - 1;
			rightwall.getChildAt(0).width = h - 1;
			// The background
			bg.width = w;
			bg.height = h;
			
			// Change Wall positions
			upwall.y = Math.ceil(-h / 2 + 5);
			downwall.y = Math.floor(h / 2 - 5);
			leftwall.x = Math.ceil(-w / 2) + 5;
			rightwall.x = Math.floor(w / 2) - 5;
		}
	}
}
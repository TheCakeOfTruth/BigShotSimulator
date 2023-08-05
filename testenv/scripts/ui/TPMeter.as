/*
	Date: 08-11-2021
	Description: TP bar
*/

package scripts.ui {
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.text.TextFormat;
	
	public class TPMeter extends Sprite {
		public static var instance:TPMeter;
		public var tp:Number = 0;
		private var defaultColor:ColorTransform;
		private var yellowColor:ColorTransform;
		private var ismax:Boolean = false;
		
		// Constructor
		public function TPMeter() {
			// Global reference
			instance = this;
			// Colors
			defaultColor = tpbar.transform.colorTransform;
			yellowColor = new ColorTransform(0, 0, 0, 1, 255, 208, 32);
			// Text format
			var format:TextFormat = new TextFormat();
			format.letterSpacing = -3;
			tptext.defaultTextFormat = format;
			// Initiate the sprite for max TP
			maxsign.visible = false;
			maxsign.alpha = 1;
			// Start at 0
			setTP(0);
		}
		
		// Change TP
		public function setTP(n:Number):void {
			// Max 250
			var newtp:Number = Math.min(250, n);
			// Change the variable
			tp = newtp;
			// Show a percentage
			var p:int = Math.floor(100 * newtp / 250);
			tptext.text = String(p);
			// Increase the height of the bar
			tpbar.height = Math.max(Math.ceil(187 * p / 100) - 2, 1);
			tpbar_white.height = Math.ceil(187 * p / 100);
			// If we're at the max, show the MAX sign and change the color a little
			if (tp == 250) {
				tpbar.height += 10;
				tpbar.transform.colorTransform = yellowColor;
				tptext.visible = false;
				percent.visible = false;
				maxsign.visible = true;
				ismax = true;
			}
			// Change the display back to non-max stuff
			else if (tp < 250 && ismax) {
				tpbar.transform.colorTransform = defaultColor;
				tptext.visible = true;
				percent.visible = true;
				maxsign.visible = false;
				ismax = false;
			}
		}
		
		// Shortcut for adding TP
		public function addTP(n:Number):void {
			setTP(tp + n);
		}
		
		// Shortcut for removing TP
		public function removeTP(n:Number):void {
			setTP(Math.max(0, tp - n));
		}
	}
}
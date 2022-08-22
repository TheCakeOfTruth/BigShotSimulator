/*
	Date: 18-11-2021
	Description: Spamton's HP bar
*/

package scripts.ui {
	import flash.display.Sprite;
	import flash.text.TextFormat;
	
	public class EnemyHPBar extends Sprite {
		// Constructor
		public function EnemyHPBar(percent:Number) {
			// Format the text
			var format:TextFormat = new TextFormat();
			format.letterSpacing = -3;
			percentage.defaultTextFormat = format;
			
			// Show the text
			percentage.text = percent + "%";
			// Change the bar
			hpmeter.width = Math.floor(0.01 * percent * 81);
		}
	}
}
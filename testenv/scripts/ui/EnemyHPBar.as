/*
	File Name: EnemyHPBar.as
	Programmeur: William Mallette
	Date: 18-11-2021
	Description: La mètre d'HP de l'ennemi
*/

package scripts.ui {
	import flash.display.Sprite;
	import flash.text.TextFormat;
	
	public class EnemyHPBar extends Sprite {
		// constructor
		public function EnemyHPBar(percent:Number) {
			// Formatter le texte
			var format:TextFormat = new TextFormat();
			format.letterSpacing = -3;
			percentage.defaultTextFormat = format;
			
			// Montrer le texte
			percentage.text = percent + "%";
			// Changer le bar
			hpmeter.width = Math.floor(0.01 * percent * 81);
		}
	}
}
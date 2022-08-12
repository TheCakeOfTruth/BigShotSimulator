/*
	File Name: TPMeter.as
	Programmeur: William Mallette
	Date: 08-11-2021
	Description: La barre qui montre le TP.
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
		
		// constructor
		public function TPMeter() {
			// Établir un référence global
			instance = this;
			// Établir des couleurs utilisés
			defaultColor = tpbar.transform.colorTransform;
			yellowColor = new ColorTransform(0, 0, 0, 1, 255, 208, 32);
			// Établir un format de text avec du letterSpacing idéal
			var format:TextFormat = new TextFormat();
			format.letterSpacing = -3;
			tptext.defaultTextFormat = format;
			// Initier le maxsign
			maxsign.visible = false;
			maxsign.alpha = 1;
			// Initier avec 0 TP
			setTP(0);
		}
		
		// Changer le TP
		public function setTP(n:Number):void {
			// Ne pas permettre un nombre au dessus de 250
			var newtp:Number = Math.min(250, n);
			// Changer la variable interne
			tp = newtp;
			// Calculer un pourcentage pour montrer
			var p:int = Math.floor(100 * newtp / 250);
			tptext.text = String(p);
			// Changer le height du bar
			tpbar.height = Math.max(Math.ceil(187 * p / 100) - 2, 1);
			tpbar_white.height = Math.ceil(187 * p / 100);
			// Si on est au maximum, montrer l'image MAX et changer le couleur du bar
			if (tp == 250) {
				tpbar.height += 10;
				tpbar.transform.colorTransform = yellowColor;
				tptext.visible = false;
				percent.visible = false;
				maxsign.visible = true;
				ismax = true;
			}
			// Si on était au maximum mais n'est pas maintenant, reset le display
			else if (tp < 250 && ismax) {
				tpbar.transform.colorTransform = defaultColor;
				tptext.visible = true;
				percent.visible = true;
				maxsign.visible = false;
				ismax = false;
			}
		}
		
		// Shortcut pour facilement ajouter un nombre donné au TP
		public function addTP(n:Number):void {
			setTP(tp + n);
		}
	}
}
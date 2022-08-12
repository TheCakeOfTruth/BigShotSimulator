/*
	File Name: Arena.as
	Programmeur: William Mallette
	Date: 24-11-2021
	Description: L'aréna
*/

package scripts {
	import flash.display.Sprite;
	import flash.events.Event;

	public class Arena extends Sprite {
		// On n'a pas besoin d'un constructor car il n'y a rien à faire
		
		// Changer la grandeur de l'Arena
		public function setSize(w:Number, h:Number):void {
			// Les dimensions
			upwall.getChildAt(0).width = w;
			downwall.getChildAt(0).width = w;
			// On change toujours 'width' car l'objet Wall est horizontal
			leftwall.getChildAt(0).width = h - 1;
			rightwall.getChildAt(0).width = h - 1;
			// L'espace noir
			bg.width = w;
			bg.height = h;
			
			// Changer les positions des murs
			upwall.y = Math.ceil(-h / 2 + 5);
			downwall.y = Math.floor(h / 2 - 5);
			leftwall.x = Math.ceil(-w / 2) + 5;
			rightwall.x = Math.floor(w / 2) - 5;
		}
	}
}
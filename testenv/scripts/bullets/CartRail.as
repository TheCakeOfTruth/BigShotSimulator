/*
	File Name: CartRail.as
	Programmeur: William Mallette
	Date: 30-11-2021
	Description: Le rail du cart de RollerCoaster
*/

package scripts.bullets {
	import flash.display.Sprite;
	import flash.events.Event;
	import scripts.utils.GlobalListener;
	
	public class CartRail extends Sprite {
		private var eventID:String;
	
		// constructor
		public function CartRail() {
			eventID = "CartRail-" + String(Math.random());
			GlobalListener.addEvent(update, eventID);
			addEventListener(Event.REMOVED_FROM_STAGE, destroy, false, 0, true);
		}
		
		// Mouvement du rail
		private function update():void {
			// Pour chaque IndividualRail
			for (var i:int = 0; i < this.numChildren; i++) {
				var rail = this.getChildAt(i);
				// Repositionner si nécessaire
				if (rail.x > (640 - this.x)) {rail.x = -this.width + 330;}
				else {rail.x += 3.5;}
			}
		}
		
		// Détruire l'objet
		private function destroy(e:Event):void {
			GlobalListener.removeEvent(eventID);
			removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
	}
}
/*
	File Name: InventoryArrow.as
	Programmeur: William Mallette
	Date: 22-11-2021
	Description: Signe qui pointe vers le reste de l'inventory
*/

package scripts.ui {
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class InventoryArrow extends Sprite {
		private var baseX:Number;
		private var baseY:Number;
		private var timer:int = 0;
	
		// constructor
		public function InventoryArrow(x:Number, y:Number) {
			// positionner
			baseX = x;
			baseY = y;
			this.x = x;
			this.y = y;
			// eventListener
			addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		}
		
		// Animation simple (mouvement sinus)
		private function update(e:Event):void {
			timer++;
			this.y = Math.round(3 * Math.sin(timer/10)) + baseY;
		}
		
		// Tourner 180 degrés
		public function flip():void {
			this.rotation += 180;
		}
		
		// Enlever l'eventListener
		public function prepDestruction():void {
			removeEventListener(Event.ENTER_FRAME, update);
		}
	}
}
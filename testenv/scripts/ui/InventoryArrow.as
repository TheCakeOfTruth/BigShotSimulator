/*
	Date: 22-11-2021
	Description: Arrow that floats and points up and down
*/

package scripts.ui {
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class InventoryArrow extends Sprite {
		private var baseX:Number;
		private var baseY:Number;
		private var timer:int = 0;
	
		// Constructor
		public function InventoryArrow(x:Number, y:Number) {
			// Position
			baseX = x;
			baseY = y;
			this.x = x;
			this.y = y;
			// eventListener
			addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		}
		
		// Simple animation
		private function update(e:Event):void {
			timer++;
			this.y = Math.round(3 * Math.sin(timer/10)) + baseY;
		}
		
		// Flip it
		public function flip():void {
			this.rotation += 180;
		}
		
		// Remove eventListener
		public function prepDestruction():void {
			removeEventListener(Event.ENTER_FRAME, update);
		}
	}
}
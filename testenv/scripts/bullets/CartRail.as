/*
	Date: 30-11-2021
	Description: Rail for the rollercoaster (not a bullet)
*/

package scripts.bullets {
	import flash.display.Sprite;
	import flash.events.Event;
	import scripts.utils.GlobalListener;
	
	public class CartRail extends Sprite {
		private var eventID:String;
	
		// Constructor
		public function CartRail() {
			eventID = "CartRail-" + String(Math.random());
			GlobalListener.addEvent(update, eventID);
			addEventListener(Event.REMOVED_FROM_STAGE, destroy, false, 0, true);
		}
		
		// Movement
		private function update():void {
			// For each IndividualRail
			for (var i:int = 0; i < this.numChildren; i++) {
				var rail = this.getChildAt(i);
				// Repositioning
				if (rail.x > (640 - this.x)) {rail.x = -this.width + 330;}
				else {rail.x += 3.5;}
			}
		}
		
		// Destruction
		private function destroy(e:Event):void {
			GlobalListener.removeEvent(eventID);
			removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
		}
	}
}
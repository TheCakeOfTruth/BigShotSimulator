/*
	Date: 20-11-2021
	Description: Basically "do while" but on every frame instead of all at once
*/

package scripts.utils {
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class RepeatUntil extends Sprite {
		public static var queue:Array = [];
		private var action:Function;
		private var endCondition:Function;
		private var arrayIndex:uint;
		
		// Constructor
		public function RepeatUntil(func:Function, end:Function) {
			// Stock the functions
			action = func;
			endCondition = end;
			
			// Add to the array and add an eventListener
			arrayIndex = queue.push(this) - 1;
			this.addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		}
		
		// update
		private function update(e:Event):void {
			// Run action every frame until endCondition returns true
			if (endCondition.call() != true) {action.call();}
			// Delete the object when finished
			else {removeFromQueue();}
		}
		
		// Delete the object
		private function removeFromQueue():void {
			removeEventListener(Event.ENTER_FRAME, update);
			for each (var obj:RepeatUntil in queue) {
				if (obj.arrayIndex > arrayIndex) {obj.arrayIndex--;}
			}
			obj = null;
			queue.splice(arrayIndex, 1);
		}
		
		public function _removeEventListener():void {
			removeEventListener(Event.ENTER_FRAME, update);
		}
		
		public static function clearQueue():void {
			for each (var repeatobj:RepeatUntil in queue) {
				repeatobj._removeEventListener();
			}
			repeatobj = null;
			queue = [];
		}
	}
}
/*  
	Date: 09/11/2021
	Description: Executes a function after a delay
*/

package scripts.utils {
	import flash.display.Sprite;
	import flash.events.Event;
	
	// I used something similar in past projects, it's very useful and I'll probably use it a lot in almost everything I do
	public class Wait extends Sprite {
		// Global array to hold all the Waits
		public static var waitArray:Array = [];
	
		// Time (in frames)
		private var _time:int;
		// The function to run
		private var func:Function;
		// The index in the array
		private var array_index:int;
		
		public function Wait(t:int, action:Function) {
			// Store the parameters
			_time = t;
			func = action;
			// updateTimer every frame
			addEventListener(Event.ENTER_FRAME, updateTimer, false, 0, true);
			// Add the object to the array
			array_index = waitArray.push(this) - 1;
		}
		
		private function updateTimer(e:Event):void {
			// Reduce _time to 0
			if (_time > 0) {_time--;}
			// Run the function and delete the object
			else {func.call(); removeFromQueue();}
		}
		
		private function removeFromQueue():void {
			// Stop updateTimer
			removeEventListener(Event.ENTER_FRAME, updateTimer)
			for (var i in waitArray) {
				// For every other Wait, if it's later, adjust its array_index
				if (waitArray[i].array_index > array_index) {
					waitArray[i].array_index--;
				}
			}
			i = null;
			// Remove the object from the array
			// If there are no longer any global references to the object, it should no longer exist
			waitArray.splice(array_index, 1);
		}
		
		// Remove the eventlistener
		public function _removeEventListener():void {
			removeEventListener(Event.ENTER_FRAME, updateTimer);
		}
		
		// Empty waitArray
		public static function clearQueue():void {
			for each (var waitobj:Wait in waitArray) {
				waitobj._removeEventListener();
			}
			waitobj = null;
			waitArray = [];
		}
	}
}
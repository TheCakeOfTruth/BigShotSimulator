/*
	Date: 05-01-2022
	Description: A global eventListener for Event.ENTER_FRAME
*/

package scripts.utils {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	public class GlobalListener extends Sprite {
		public static var handler:GlobalListener;
		public static var globalTimer:int = 0;
		private static var eventDict:Dictionary = new Dictionary();
		// For debugging purposes only
		private static var eventKeys:Dictionary = new Dictionary();
	
		// Constructor, only run once
		public function GlobalListener() {
			handler = this;
			startAll();
		}
		
		// Every frame
		private static function update(e:Event):void {
			// Run each function in eventDict
			for each (var func:Function in eventDict) {
				func.call();
			}
			func = null;
			globalTimer++;
		}
		
		// Add an event to eventDict
		public static function addEvent(event:Function, keyname:String):void {
			eventDict[keyname] = event;
			eventKeys[keyname] = keyname;
		}
		
		// Remove an event from eventDict
		public static function removeEvent(keyname:String):void {
			delete eventDict[keyname];
			delete eventKeys[keyname];
		}
		
		// Remove the eventListener and if specified, empty eventDict
		public static function stopAll(clear:Boolean = false):void {
			handler.removeEventListener(Event.ENTER_FRAME, update);
			if (clear) {clearEvents();}
		}
		
		// Empty eventDict
		public static function clearEvents():void {
			eventDict = new Dictionary();
			eventKeys = new Dictionary();
		}
		
		// Add the eventlistener
		public static function startAll():void {
			handler.addEventListener(Event.ENTER_FRAME, update);
		}
		
		// Debug: trace every active event
		public static function debugPrintAllEvents():void {
			for each (var eventkey:String in eventKeys) {
				trace(eventkey);
			}
			eventkey = null;
		}
	}
}
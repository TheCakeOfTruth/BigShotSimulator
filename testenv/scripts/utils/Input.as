/*
	Date: 17-11-2021
	Description: Better input system
*/

package scripts.utils {
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	
	/* Important keyCodes
		ARROW KEYS
		L: 37
		U: 38
		R: 39
		D: 40
		
		Z: 90
		X: 88
		C: 67
		
		ENTER: 13
	*/
	
	public class Input extends Sprite {
		// Global reference to keep the object active
		public static var handler:Input;
		private static var keys:Dictionary = new Dictionary();
		private static var eventDict:Dictionary = new Dictionary();
		private static var upEventDict:Dictionary = new Dictionary();
	
		// Constructor, run only once
		public function Input() {
			handler = this;
			// Add eventListeners
			Main.screen.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown, false, 0, true);
			Main.screen.stage.addEventListener(KeyboardEvent.KEY_UP, keyUp, false, 0, true);
		}
		
		// KEY_DOWN
		private function keyDown(e:KeyboardEvent):void {
			// Run an event only if we weren't already touching the key
			// KeyboardEvent.KEY_DOWN triggers multiple times when we hold the key, which we don't want
			// Also make sure the pressed key has an associated event dictionnary 
			if (keys[e.keyCode] != true && eventDict[e.keyCode] is Dictionary) {
				// For every event in the eventDict for the key, run the stored function
				for each (var func:Function in eventDict[e.keyCode]) {
					func.call();
				}
				func = null;
			}
			// Mark the key as being pressed
			keys[e.keyCode] = true;
			
			// DEBUG
			//trace(e.keyCode);
		}
		
		// KEY_UP
		private function keyUp(e:KeyboardEvent):void {
			// Mark the key as no longer being pressed
			keys[e.keyCode] = false;
			// Trigger any release events stored in that key
			if (upEventDict[e.keyCode] is Dictionary) {
				for each (var func2:Function in upEventDict[e.keyCode]) {
					func2.call();
				}
				func2 = null;
			}
		}
		
		// Returns the state of the specified key
		public static function getKey(code:int):Boolean {
			return keys[code];
		}
		
		// Add an event to the key
		public static function addEvent(code:int, event:Function, keyname:String):void {
			// Initiate the dictionnary for that key if needed
			if (eventDict[code] == null) {eventDict[code] = new Dictionary();}
			// Add the function to that key
			eventDict[code][keyname] = event;
			
			// DEBUG
			//trace("Added event " + keyname + " to " + code);
		}
		
		// Remove a specified event from the dictionnary of a specified key
		public static function removeEvent(code:int, keyname:String):void {
			if (eventDict[code] is Dictionary) {
				delete eventDict[code][keyname];
			}
			
			// DEBUG
			//trace("Removed event " + keyname + " from " + code);
		}
		
		// Add an event to the key
		public static function addUpEvent(code:int, event:Function, keyname:String):void {
			// Initiate the dictionnary for that key if needed
			if (upEventDict[code] == null) {upEventDict[code] = new Dictionary();}
			// Add the function to that key
			upEventDict[code][keyname] = event;
			
			// DEBUG
			//trace("Added release event " + keyname + " to " + code);
		}
		
		// Remove a specified event from the dictionnary of a specified key
		public static function removeUpEvent(code:int, keyname:String):void {
			if (upEventDict[code] is Dictionary) {
				delete upEventDict[code][keyname];
			}
			
			// DEBUG
			//trace("Removed release event " + keyname + " from " + code);
		}
		
		// Erase all events
		public static function clearEvents():void {
			eventDict = new Dictionary();
		}
	}
}
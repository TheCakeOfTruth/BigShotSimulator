/*
	Date: 18-11-2021
	Description: Options in the menu
*/

package scripts.ui {
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.text.TextFormat;
	import flash.events.Event;
	import flash.media.SoundTransform;
	import scripts.SoundLibrary;
	import scripts.utils.Input;
	import scripts.utils.Wait;
	
	public class MenuOption extends MovieClip {
		public var selected = false;
		public var TPCost:int = 0;
		public var effect:Function;
		public var description:String;
		public var icon:Bitmap;
		public var iconEnabled:Boolean = false;
		
		private var eventID:String;
		
		// Constructor
		public function MenuOption(x:Number, y:Number, _text:String) {
			// Hide the soul
			toggleSelection(false);
			// Unique reference for the input handler
			eventID = "MenuOption-" + String(Math.random());
			// Empty function to be redefined elsewhere
			effect = function() {};
			// Positioning
			this.x = x;
			this.y = y;
			// Text format
			var format:TextFormat = new TextFormat();
			format.letterSpacing = -2;
			txt.defaultTextFormat = format;
			txt.htmlText = _text;
			
			// EventListeners
			this.addEventListener(Event.ADDED_TO_STAGE, activateFunction, false, 0, true);
			this.addEventListener(Event.REMOVED_FROM_STAGE, deactivateFunction, false, 0, true);
		}

		// Let it be active when it's on screen
		private function activateFunction(e:Event):void {
			// Text color depends on current TP
			if (!checkAffordability()) {txt.textColor = 0x808080;}
			else {txt.textColor = 0xFFFFFF;}
			// Add an event to the Z key
			new Wait(2, function() {Input.addEvent(90, selectOption, eventID);});
		}
		
		// Remove the event from the Z key
		private function deactivateFunction(e:Event):void {
			Input.removeEvent(90, eventID);
		}
		
		// Show/hide the soul
		public function toggleSelection(bool:Boolean):void {
			soul.visible = bool;
		}
		
		// Check that the option is selected and we have enough TP, play a sound and play the function
		public function selectOption():void {
			if (this.parent != null && soul.visible == true && checkAffordability()) {
				SoundLibrary.play("menuselect", 0.5);
				effect.call();
			}
		}
		
		// Make sure there's enough TP (in %)
		private function checkAffordability():Boolean {
			if (100 * TPMeter.instance.tp / 250 < TPCost) {return false;}
			else {return true;}
		}
		
		// Create the icon and add it to the MenuOption
		public function createIcon(img:BitmapData):void {
			iconEnabled = true;
			icon = new Bitmap(img);
			icon.x = txt.x;
			icon.y = txt.y + 8;
			this.addChild(icon);
		}
		
		// Destroy the MenuOption
		public function destroy():void {
			if (iconEnabled) {this.removeChild(icon); icon = null;}
			deactivateFunction(null);
			removeEventListener(Event.ADDED_TO_STAGE, activateFunction);
			removeEventListener(Event.REMOVED_FROM_STAGE, deactivateFunction);
			if (this.parent) {this.parent.removeChild(this);}
		}
	}
}
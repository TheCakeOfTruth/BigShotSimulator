/*
	Date: 16-11-2021
	Description: Handles text
*/

package scripts {
	import flash.display.Sprite;
	import flash.events.Event;
	import scripts.utils.Input;
	import scripts.utils.Wait;
	import scripts.utils.XMLToDialogue;
	
	public class TypeText extends Sprite {
		private static var mutedChars:RegExp = /[*,.?!:;\[\]]/;
		private static var punctuation:RegExp = /[,.?!]/;
	
		private var txtpages:Array = [];
		private var pageindex:int = 0;
		private var charindex:int = 0;
		private var txtvoice:String;
		private var advancemode:String;
		private var avgDelay:int;
		private var func:Function;
		private var queuedSkip:Boolean = false;
		private var eventKey:String;
		
		public var fulltext:String;
		public var chararray:Array;
		public var onAdvance:Function;
		
		// Constructor
		public function TypeText(txt = "", voice:String = "", advmode:String = "default", endfunc:Function = null, averageDelay:int = 1) {
			// Start the text
			startText(txt, voice, advmode, endfunc, averageDelay);
		}
		
		// Check C and X for their effects
		private function update(e:Event):void {
			if (Input.getKey(67) == true) {
				if (advancemode == "default") {
					skipText();
				}
			}
			else if (Input.getKey(88) == true) {finishText();}
		}
		
		// Start text
		public function startText(txt = "", voice:String = "", advmode:String = "default", endfunc:Function = null, averageDelay:int = 1):void {
			// Reset txtpages
			txtpages = [];
			if (txt is String) {txtpages.push(txt);}
			else if (txt is XMLList) {txtpages = XMLToDialogue(txt);}
			else {txtpages = txt;}
			
			// Change variables
			txtvoice = voice;
			advancemode = advmode;
			avgDelay = averageDelay;
			if (endfunc != null) {func = endfunc;}
			else {func = function() {};}
			
			// The advancemode
			if (advancemode == "default") {
				eventKey = "TypeText-" + String(Math.random());
				Input.addEvent(90, tryAdvance, eventKey);
			}
			
			// Initialise the first page
			pageindex = 0;
			setupPage();
			
			// Add the eventListener
			this.addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		}
		
		// If the text is complete, move on to the next
		private function tryAdvance():void {
			if (textfield.text.length == chararray.length) {
				pageindex++;
				setupPage();
				if (onAdvance is Function) {onAdvance.call();}
			}
		}
		
		// Initialise a text page
		private function setupPage():void {	
			// If there's still a page
			if (pageindex < txtpages.length) {
				// Reset the TextField and charindex
				textfield.text = "";
				charindex = 0;
				
				// Get fulltext and chararray
				fulltext = txtpages[pageindex];
				chararray = fulltext.split("");
				
				// Start adding characters
				addChar();
			}
			// Otherwise, end the text
			else {
				endText();
			}
		}
		
		// Finish the current line (X)
		public function finishText():void {
			charindex = fulltext.length;
			textfield.text = fulltext;
		}
		
		// Skip through with C
		private function skipText():void {
			if (!queuedSkip) {
				queuedSkip = true;
				finishText();
				new Wait(5, function() {queuedSkip = false; tryAdvance();});
			}
		}
		
		// Add a character
		private function addChar():void {
			// Only if we haven't typed out the fulltext yet
			if (charindex < fulltext.length) {
				// Get the next two characters
				var newchar:String = chararray[charindex];
				var nextchar:String = chararray[(charindex + 1) % chararray.length];
				
				// Play a sound if the stars align
				if (txtvoice != "" && charindex % 2 == 0 && newchar.match(mutedChars) == null) {SoundLibrary.play(txtvoice, 0.5);}
				
				// Add the new character and increase charindex
				textfield.appendText(newchar);
				charindex++;
				
				// Calculate the delay between this char and the next
				var delay:int = avgDelay;
				if (newchar == " ") {delay = 0;}
				else if (newchar.match(punctuation) != null && nextchar.match(punctuation) == null) {delay = 10;}
				new Wait(delay, addChar);
			}
		}
		
		// End the text
		public function endText():void {
			Input.removeEvent(90, eventKey);
			this.removeEventListener(Event.ENTER_FRAME, update);
			
			// Call the function
			func.call();
		}
	}
}
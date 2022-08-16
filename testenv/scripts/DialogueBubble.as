/*
	Date: 23-11-2021
	Description: Enemy text bubbles
*/

package scripts {
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import scripts.utils.Input;
	import scripts.utils.Wait;
	import scripts.utils.XMLToDialogue;
	
	public class DialogueBubble extends Sprite {	
		public var bubbletext:Array = [];
		public var onAdvance:Function;
		public var whileTyping:Function;
		
		private var textformat:TextFormat = new TextFormat();
		private var textvoice:String;
		private var storedfunc:Function;
		private var isFirstPage:Boolean = true;
		private var queuedSkip:Boolean = false;
		private var ended:Boolean = false;
		private var arrow:Bitmap;
		private var txt:BubbleText;
		private var rectHorizontal:Pixel;
		private var rectVertical:Pixel;
		private var eventKey:String;
		
		// Constructor
		public function DialogueBubble(dialogue, voice:String = "", endfunc:Function = null) {
			// Stock variables
			if (dialogue is String) {bubbletext.push(dialogue);}
			else if (dialogue is XMLList) {bubbletext = XMLToDialogue(dialogue);}
			else {bubbletext = dialogue;}
			if (endfunc == null) {storedfunc = function() {};}
			else {storedfunc = endfunc;}
			textvoice = voice;
			
			// Change TextFormat
			textformat.letterSpacing = 1;
			textformat.leading = 4;
			
			// Create the tail and position it to (0,0)
			arrow = new Bitmap();
			arrow.bitmapData = new BubbleArrow(0,0);
			arrow.x = -arrow.width + 1;
			arrow.y = -8;
			addChild(arrow);
			
			// Create the bubble
			drawBubble();
			
			// Reused from TypeText
			eventKey = "DialogueBubble-" + String(Math.random());
			Input.addEvent(90, tryAdvance, eventKey);
			addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		}
		
		// Create bubble
		private function drawBubble():void {
			// Destroy bubble components that may have already existed
			if (isFirstPage == false) {
				txt.endText();
				this.removeChild(txt);
				this.removeChild(rectHorizontal);
				this.removeChild(rectVertical);
			}
			
			// The text
			txt = new BubbleText();
			txt.textfield.defaultTextFormat = textformat;
			txt.textfield.autoSize = TextFieldAutoSize.LEFT;
			// Fill text to get dimensions for the bubble
			txt.textfield.text = bubbletext[0];
			
			// Get dimensions for the bubble
			var fullwidth:Number = Math.round(txt.textfield.width) + 35;
			var fullheight:Number = Math.round(txt.textfield.height) + 16;
			
			// Two rectangles
			rectHorizontal = new Pixel();
			rectHorizontal.width = fullwidth - 18;
			rectHorizontal.height = fullheight - 10;
			rectHorizontal.x = Math.round(arrow.x - rectHorizontal.width);
			rectHorizontal.y = Math.round(arrow.y - Math.round(rectHorizontal.height / 2) + 9);
			addChild(rectHorizontal);
			
			rectVertical = new Pixel();
			rectVertical.width = fullwidth - 28;
			rectVertical.height = fullheight;
			rectVertical.x = Math.round(arrow.x - rectVertical.width - 5);
			rectVertical.y = Math.round(arrow.y - Math.round(rectVertical.height / 2) + 9);
			addChild(rectVertical);
			
			// Position the text
			txt.x = rectHorizontal.x + 8;
			txt.y = rectHorizontal.y + 4;
			addChild(txt);
			
			// Start the text
			txt.startText(bubbletext[0], textvoice, "none");
			// Prepare for the next line of text
			bubbletext.splice(0, 1);
			isFirstPage = false;
		}
		
		// Every frame
		private function update(e:Event):void {
			// C -> skipText
			// X does the same as TypeText
			if (Input.getKey(67) == true) {skipText();}
			// whileTyping
			if (whileTyping is Function && txt != null) {
				if (txt.textfield.text.length != txt.chararray.length) {
					whileTyping.call();
				}
			}
		}
		
		// Pulled from TypeText
		private function skipText():void {
			if (!queuedSkip) {
				queuedSkip = true;
				txt.finishText();
				new Wait(5, function() {queuedSkip = false; tryAdvance();});
			}
		}
		
		// Similar to TypeText, but redraws the bubble too
		private function tryAdvance():void {
			if (txt.textfield.text.length == txt.fulltext.length) {
				if (bubbletext.length > 0) {
					drawBubble();
				}
				else {
					if (!ended) {endText();}
				}
				if (onAdvance is Function) {onAdvance.call();}
			}
		}
		
		// Destroy the bubble
		private function endText():void {
			ended = true;
			txt.endText();
			this.removeChild(arrow);
			this.removeChild(txt);
			this.removeChild(rectHorizontal);
			this.removeChild(rectVertical);
			this.removeEventListener(Event.ENTER_FRAME, update);
			Input.removeEvent(90, eventKey);
			this.parent.removeChild(this);
			storedfunc.call();
		}
	}
}
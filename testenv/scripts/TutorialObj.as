/*
	Date: 16-01-2022
	Description: Handles the tutorial
*/

package scripts {
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.geom.ColorTransform;
	
	public class TutorialObj extends MovieClip {
		// Constructor
		public function TutorialObj() {
			// TextFormat
			var format:TextFormat = new TextFormat(); 
			format.align = TextFormatAlign.CENTER;
			txt.textfield.defaultTextFormat = format;
			txt.textfield.autoSize = TextFieldAutoSize.CENTER;
			txt.textfield.wordWrap = false;
			
			// eventListeners
			arrowLeft.addEventListener(MouseEvent.ROLL_OVER, makeButtonYellow);
			arrowLeft.addEventListener(MouseEvent.ROLL_OUT, makeButtonWhite);
			arrowLeft.addEventListener(MouseEvent.CLICK, changePage);
			arrowRight.addEventListener(MouseEvent.ROLL_OVER, makeButtonYellow);
			arrowRight.addEventListener(MouseEvent.ROLL_OUT, makeButtonWhite);
			arrowRight.addEventListener(MouseEvent.CLICK, changePage);
		}
		
		// Make button yellow and play sound
		private function makeButtonYellow(e:MouseEvent):void {
			e.target.transform.colorTransform = new ColorTransform(1, 1, 0);
			SoundLibrary.play("menumove");
		}
		
		// Reset button to white
		private function makeButtonWhite(e:MouseEvent):void {
			e.target.transform.colorTransform = new ColorTransform(1, 1, 1);
		}
		
		// Change the page (frame)
		private function changePage(e:MouseEvent):void {
			// Determine which frame to go to
			var targetFrame:int;
			if (e.target == arrowLeft) {
				targetFrame = currentFrame - 1;
				if (targetFrame < 1) {targetFrame = totalFrames - targetFrame;}
			}
			else {
				targetFrame = currentFrame + 1;
				if (targetFrame > totalFrames) {targetFrame = (targetFrame - totalFrames);}
			}
			// Change the frame and play a sound
			gotoAndStop(targetFrame);
			SoundLibrary.play("menuselect");
		}
		
		// Cleanup
		public function destroy():void {
			arrowLeft.removeEventListener(MouseEvent.ROLL_OVER, makeButtonYellow);
			arrowLeft.removeEventListener(MouseEvent.ROLL_OUT, makeButtonWhite);
			arrowLeft.removeEventListener(MouseEvent.CLICK, changePage);
			arrowRight.removeEventListener(MouseEvent.ROLL_OVER, makeButtonYellow);
			arrowRight.removeEventListener(MouseEvent.ROLL_OUT, makeButtonWhite);
			arrowRight.removeEventListener(MouseEvent.CLICK, changePage);
		}
		
		// When you change tutorialText, it'll also change the textfield.
		public function set tutorialText(val:String):void {
			txt.textfield.text = Main.getText(val);
		}
	}
}
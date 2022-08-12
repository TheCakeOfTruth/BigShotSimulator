/*
	File Name: TutorialObj.as
	Programmeur: William Mallette
	Date: 16-01-2022
	Description: Un objet qui gère le tutorial
*/

package scripts {
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.geom.ColorTransform;
	
	public class TutorialObj extends MovieClip {
		// constructor
		public function TutorialObj() {
			// TextFormat
			var format:TextFormat = new TextFormat(); 
			format.align = TextFormatAlign.CENTER;
			txt.textfield.defaultTextFormat = format;
			txt.textfield.autoSize = TextFieldAutoSize.CENTER;
			txt.textfield.wordWrap = false;
			
			// Les eventListeners
			arrowLeft.addEventListener(MouseEvent.ROLL_OVER, makeButtonYellow);
			arrowLeft.addEventListener(MouseEvent.ROLL_OUT, makeButtonWhite);
			arrowLeft.addEventListener(MouseEvent.CLICK, changePage);
			arrowRight.addEventListener(MouseEvent.ROLL_OVER, makeButtonYellow);
			arrowRight.addEventListener(MouseEvent.ROLL_OUT, makeButtonWhite);
			arrowRight.addEventListener(MouseEvent.CLICK, changePage);
		}
		
		// Changer un bouton à jaune et jouer un son
		private function makeButtonYellow(e:MouseEvent):void {
			e.target.transform.colorTransform = new ColorTransform(1, 1, 0);
			SoundLibrary.play("menumove");
		}
		
		// Changer un bouton à blanc
		private function makeButtonWhite(e:MouseEvent):void {
			e.target.transform.colorTransform = new ColorTransform(1, 1, 1);
		}
		
		// Changer de page (frame)
		private function changePage(e:MouseEvent):void {
			// Déterminer quelle frame auquel il faut y aller (je ne pouvais pas utiliser % car les frames commencent à 1)
			var targetFrame:int;
			if (e.target == arrowLeft) {
				targetFrame = currentFrame - 1;
				if (targetFrame < 1) {targetFrame = totalFrames - targetFrame;}
			}
			else {
				targetFrame = currentFrame + 1;
				if (targetFrame > totalFrames) {targetFrame = (targetFrame - totalFrames);}
			}
			// Changer de frame et jouer un son
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
		
		// Lorsqu'on change le 'variable' tutorialText, modifier txt.textfield.text
		public function set tutorialText(val:String):void {
			txt.textfield.text = Main.getText(val);
		}
	}
}
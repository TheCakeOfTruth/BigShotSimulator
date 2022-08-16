/*
	Date: 06-01-2022
	Description: GAME OVER
*/

package scripts {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextFieldAutoSize;
	import flash.system.fscommand;
	import scripts.utils.Wait;
	import scripts.utils.RepeatUntil;
	import scripts.utils.Input;
	
	public class GameOverScreen extends Sprite {
		private var goscreen:GameOverScreen;
		private var selectedOption:String;
		
		// Constructor
		public function GameOverScreen() {
			goscreen = this;
		
			// Change letterSpacing and text alignment
			var format:TextFormat = new TextFormat();
			format.letterSpacing = -2;
			format.align = TextFormatAlign.CENTER;
			txtContinue.defaultTextFormat = format;
			txtContinue.autoSize = TextFieldAutoSize.CENTER;
			txtContinue.wordWrap = false;
			txtQuit.defaultTextFormat = format;
			txtQuit.autoSize = TextFieldAutoSize.CENTER;
			txtQuit.wordWrap = false;
			
			// Hide menu
			txtContinue.alpha = 0;
			txtQuit.alpha = 0;
			heart.alpha = 0;
			
			// Change text
			txtContinue.text = Main.dialogue.gameOverContinue;
			txtQuit.text = Main.dialogue.gameOverGiveUp;
			
			// Fade in GAME OVER screen
			alpha = 0;
			new RepeatUntil(function() {
				alpha += 0.025;
			}, function() {
				if (alpha >= 1) {alpha = 1; return true;}
			});
			
			// Wait a bit & fade in menu
			new Wait(30, function() {
				new RepeatUntil(function() {
					heart.alpha += 0.025;
					txtContinue.alpha += 0.05;
					txtQuit.alpha += 0.05;
				}, function() {
					if (heart.alpha >= 0.60) {
						// Add Input events
						Input.addEvent(37, function() {moveHeart("l");}, "MoveHeartLeft");
						Input.addEvent(39, function() {moveHeart("r");}, "MoveHeartRight");
						Input.addEvent(90, handlePrompt, "GameOverPrompt");
						heart.alpha = 0.60; 
						return true;
					}
				});
			});
		}
		
		// Move the heart between the options
		private function moveHeart(dir:String):void {
			// Reset RepeatUntils
			RepeatUntil.clearQueue();
			
			// Change variables and colors
			var x1:Number = heart.x;
			var x2:Number;
			if (dir == "l") {
				selectedOption = "continue";
				txtContinue.textColor = 0xFFFF00;
				txtQuit.textColor = 0xFFFFFF;
				x2 = 216;
			}
			else {
				selectedOption = "giveup";
				txtContinue.textColor = 0xFFFFFF;
				txtQuit.textColor = 0xFFFF00;
				x2 = 424;
			}
			
			// RepeatUntil for heart movement
			var t:Number = 0;
			new RepeatUntil(function() {
				t += 0.25;
				heart.x = -((x2 - x1) / 2) * Math.cos(t) + ((x1 + x2) / 2);
			}, function() {
				if (t > Math.PI) {heart.x = x2; return true;}
			});
		}
		
		// When you press Z
		private function handlePrompt():void {
			// While selecting "Continue"
			if (selectedOption == "continue") {
				// Stop events and inputs and music & play a sound
				Input.clearEvents();
				Main.bgm.stop();
				SoundLibrary.play("intronoise");
				
				// Un écran blanc
				var whitescreen:Pixel = new Pixel();
				whitescreen.width = 640;
				whitescreen.height = 480;
				whitescreen.alpha = 0;
				Main.screen.addChild(whitescreen);
				
				// Fade in a white screen and fade out everything else
				new RepeatUntil(function() {
					whitescreen.alpha += 0.008;
					if (txtContinue.alpha > 0) {
						heart.alpha -= 0.05;
						txtContinue.alpha -= 0.05;
						txtQuit.alpha -= 0.05;
					}
				}, function() {
					if (whitescreen.alpha >= 1) {
						new Wait(20, function() {
							// Remove GameOverScreen and restart the game
							Main.screen.removeChild(goscreen);
							Main.screen.removeChild(whitescreen);
							Main.reinitialize();
						});
						return true;
					}
				});
			}
			// While selecting "Give Up"
			else if (selectedOption == "giveup") {
				// Remove events and music, hide everything
				Input.clearEvents();
				Main.bgm.stop();
				this.visible = false;
				
				// Create text
				var quitText:GasterText = new GasterText();
				var newformat:TextFormat = new TextFormat();
				newformat.letterSpacing = 7;
				newformat.leading = 7;
				quitText.textfield.defaultTextFormat = newformat;
				quitText.x = 460;
				quitText.y = 210;
				// Start text
				Main.screen.addChild(quitText);
				quitText.startText(Main.dialogue.gameOverQuit, "", "default", function() {
					quitText.textfield.text = "";
					darkscreen();
				}, 5);
			}
		}
		
		// Truly a "Game Over" moment
		private function darkscreen():void {
			// Remove all events, play music, close game when song ends
			Input.clearEvents();
			SoundLibrary.play("mus_darkness");
			new Wait(4150, function() {fscommand("quit");});
		}
	}
}
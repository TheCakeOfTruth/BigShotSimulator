/*
	File Name: GameOverScreen.as
	Programmeur: William Mallette
	Date: 06-01-2022
	Description: L'écran de "GAME OVER"
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
		
		// constructor
		public function GameOverScreen() {
			goscreen = this;
		
			// Changer le letterSpacing et l'alignement des textes
			var format:TextFormat = new TextFormat();
			format.letterSpacing = -2;
			format.align = TextFormatAlign.CENTER;
			txtContinue.defaultTextFormat = format;
			txtContinue.autoSize = TextFieldAutoSize.CENTER;
			txtContinue.wordWrap = false;
			txtQuit.defaultTextFormat = format;
			txtQuit.autoSize = TextFieldAutoSize.CENTER;
			txtQuit.wordWrap = false;
			
			// Cacher le menu
			txtContinue.alpha = 0;
			txtQuit.alpha = 0;
			heart.alpha = 0;
			
			// Changer le texte
			txtContinue.text = Main.dialogue.gameOverContinue;
			txtQuit.text = Main.dialogue.gameOverGiveUp;
			
			// Fade in l'écran de GAME OVER
			alpha = 0;
			new RepeatUntil(function() {
				alpha += 0.025;
			}, function() {
				if (alpha >= 1) {alpha = 1; return true;}
			});
			
			// Après un délai, fade in le menu
			new Wait(30, function() {
				new RepeatUntil(function() {
					heart.alpha += 0.025;
					txtContinue.alpha += 0.05;
					txtQuit.alpha += 0.05;
				}, function() {
					if (heart.alpha >= 0.60) {
						// Ajouter des Input events
						Input.addEvent(37, function() {moveHeart("l");}, "MoveHeartLeft");
						Input.addEvent(39, function() {moveHeart("r");}, "MoveHeartRight");
						Input.addEvent(90, handlePrompt, "GameOverPrompt");
						heart.alpha = 0.60; 
						return true;
					}
				});
			});
		}
		
		// Bouger le coeur entre les options
		private function moveHeart(dir:String):void {
			// Reset les RepeatUntils
			RepeatUntil.clearQueue();
			
			// Changer des variables et des couleurs
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
			
			// Un RepeatUntil pour le mouvement du coeur
			var t:Number = 0;
			new RepeatUntil(function() {
				t += 0.25;
				heart.x = -((x2 - x1) / 2) * Math.cos(t) + ((x1 + x2) / 2);
			}, function() {
				if (t > Math.PI) {heart.x = x2; return true;}
			});
		}
		
		// Lorsqu'on touche le clé Z
		private function handlePrompt():void {
			// En sélectionnant "continue"
			if (selectedOption == "continue") {
				// Arrêter les events Input et la musique, jouer un son
				Input.clearEvents();
				Main.bgm.stop();
				SoundLibrary.play("intronoise");
				
				// Un écran blanc
				var whitescreen:Pixel = new Pixel();
				whitescreen.width = 640;
				whitescreen.height = 480;
				whitescreen.alpha = 0;
				Main.screen.addChild(whitescreen);
				
				// Fade in le whitescreen et fade out les autres choses
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
							// Enlever le GameOverScreen et le whitescreen, recommencer le jeu
							Main.screen.removeChild(goscreen);
							Main.screen.removeChild(whitescreen);
							Main.reinitialize();
						});
						return true;
					}
				});
			}
			// En sélectionnant "give up"
			else if (selectedOption == "giveup") {
				// Arrêter les events Input, la musique, et cacher le GameOverScreen
				Input.clearEvents();
				Main.bgm.stop();
				this.visible = false;
				
				// Créer le texte
				var quitText:GasterText = new GasterText();
				var newformat:TextFormat = new TextFormat();
				newformat.letterSpacing = 7;
				newformat.leading = 7;
				quitText.textfield.defaultTextFormat = newformat;
				quitText.x = 460;
				quitText.y = 210;
				// Commencer le texte
				Main.screen.addChild(quitText);
				quitText.startText(Main.dialogue.gameOverQuit, "", "default", function() {
					quitText.textfield.text = "";
					darkscreen();
				}, 5);
			}
		}
		
		// Un vrai "game over"
		private function darkscreen():void {
			// Arrêter les events Input, jouer une chanson, fermer le jeu lorsque la chanson est fini
			Input.clearEvents();
			SoundLibrary.play("mus_darkness");
			new Wait(4150, function() {fscommand("quit");});
		}
	}
}
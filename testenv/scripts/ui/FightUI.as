/*
	File Name: FightUI.as
	Programmeur: William Mallette
	Date: 21-11-2021
	Description: L'interface d'attaque
*/

package scripts.ui {
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import flash.events.Event;
	import flash.media.SoundTransform;
	import scripts.DamageNumber;
	import scripts.Kris;
	import scripts.SoundLibrary;
	import scripts.spam.Spamton;
	import scripts.utils.Input;
	import scripts.utils.Wait;
	import scripts.utils.RepeatUntil;
	
	public class FightUI extends MovieClip {
		private var strikeTime:Number;
		private var canMoveBar:Boolean = true;
		
		// constructor
		public function FightUI() {
			addEventListener(Event.ENTER_FRAME, update, false, 0, true);
			new Wait(2, function() {Input.addEvent(90, strike, "attack");});
		}
		
		// bouger le bar, si on a manqué, forcer un strike
		private function update(e:Event):void {
			if (canMoveBar) {
				bar.x -= 4;
				if (bar.x == 68) {strike();}
			}
		}
		
		// faire l'attaque
		private function strike():void {
			// Enregistrer le position du bar au moment du strike
			strikeTime = bar.x;
			
			// S'il y a un miss, faire le bar continuer au bord et fade au noir
			// Autrement, augmenter scaleY et arrêter le mouvement
			if (strikeTime != 68) {
				new RepeatUntil(function() {bar.scaleY += 0.05}, function() {if (bar.scaleY >= 1.35) {return true;}});
				canMoveBar = false;
			}
			new RepeatUntil(function() {bar.alpha -= 0.05}, function() {if (bar.alpha <= 0) {removeChild(bar); return true;}});
			
			// Prévenir un attaque double
			Input.removeEvent(90, "attack");
			
			// Un strike parfait
			if (strikeTime == 84) {
				// Faire le bar jaune et jouer un autre son qui indique un strike parfait
				bar.transform.colorTransform = new ColorTransform(1, 1, 0);
				SoundLibrary.play("critswing", 0.5);
			}
			
			// Jouer le son
			SoundLibrary.play("swing", 0.5);
			
			// Animer Kris et endommager Spamton
			Kris.instance.gotoAndPlay("fight");
			Main.screen.spamton.damage(calculateDamage());
		}
		
		// Calculer le dommage, voir ce page: https://deltarune.fandom.com/wiki/Stats#Damage
		private function calculateDamage():int {
			var accuracy:int;
			if (strikeTime == 84) {accuracy = 150;}
			else if (strikeTime == 88 || strikeTime == 80) {accuracy = 120;}
			else if (strikeTime == 92 || strikeTime == 76) {accuracy = 110;}
			else if (strikeTime == 68) {accuracy = 0;}
			else {accuracy = Math.abs(100 - (Math.abs(strikeTime - 84) / 4 * 2))}
			// Augmenter le TP
			TPMeter.instance.addTP(accuracy / 10);
			return Math.round(((Kris.instance.calculateAttack() * accuracy) / 20) - 3 * Main.screen.spamton.defense);
		}
		
		// Commencer à fader le FightUI
		public function fadeOut():void {
			new RepeatUntil(reduceAlpha, tryRemove);
		}
		
		// Réduire this.alpha
		private function reduceAlpha():void {this.alpha -= 0.05;}
		
		// endCondition pour fadeOut, enlève l'objet quand this.alpha == 0
		private function tryRemove() {
			if (this.alpha <= 0) {
				remove();
				return true;
			}
		}
		
		private function remove():void {
			removeEventListener(Event.ENTER_FRAME, update);
			this.parent.removeChild(this);
		}
	}
}
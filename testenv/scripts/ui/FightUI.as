/*
	Date: 21-11-2021
	Description: When you attack
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
		
		// Constructor
		public function FightUI() {
			addEventListener(Event.ENTER_FRAME, update, false, 0, true);
			new Wait(2, function() {Input.addEvent(90, strike, "attack");});
		}
		
		// Move the bar, force an attack if it goes too far
		private function update(e:Event):void {
			if (canMoveBar) {
				bar.x -= 4;
				if (bar.x == 68) {strike();}
			}
		}
		
		// Do the attack
		private function strike():void {
			// Hold on to the current position of the bar
			strikeTime = bar.x;
			
			// If you miss, fade to black
			// Otherwise, stop moving and expand height
			if (strikeTime != 68) {
				new RepeatUntil(function() {bar.scaleY += 0.05}, function() {if (bar.scaleY >= 1.35) {return true;}});
				canMoveBar = false;
			}
			new RepeatUntil(function() {bar.alpha -= 0.05}, function() {if (bar.alpha <= 0) {removeChild(bar); return true;}});
			
			// Prevent a double attack
			Input.removeEvent(90, "attack");
			
			// Crit
			if (strikeTime == 84) {
				// Yellow bar and different sound
				bar.transform.colorTransform = new ColorTransform(1, 1, 0);
				SoundLibrary.play("critswing", 0.5);
			}
			
			// Sound
			SoundLibrary.play("swing", 0.5);
			
			// Animate and damage
			Kris.instance.gotoAndPlay("fight");
			Main.screen.spamton.damage(calculateDamage());
		}
		
		// Calculates damage, see: https://deltarune.fandom.com/wiki/Stats#Damage
		private function calculateDamage():int {
			var accuracy:int;
			if (strikeTime == 84) {accuracy = 150;}
			else if (strikeTime == 88 || strikeTime == 80) {accuracy = 120;}
			else if (strikeTime == 92 || strikeTime == 76) {accuracy = 110;}
			else if (strikeTime == 68) {accuracy = 0;}
			else {accuracy = Math.abs(100 - (Math.abs(strikeTime - 84) / 4 * 2))}
			// Increase TP
			TPMeter.instance.addTP(accuracy / 10);
			return Math.round(((Kris.instance.calculateAttack() * accuracy) / 20) - 3 * Main.screen.spamton.defense);
		}
		
		// Start to fade the FightUI
		public function fadeOut():void {
			new RepeatUntil(reduceAlpha, tryRemove);
		}
		
		// Reduce this.alpha
		private function reduceAlpha():void {this.alpha -= 0.05;}
		
		// endCondition for fadeOut, removes it when this.alpha == 0
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
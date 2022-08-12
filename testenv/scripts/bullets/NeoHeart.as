/*
	File Name: NeoHeart.as
	Programmeur: William Mallette
	Date: 08-12-2021
	Description: Le coeur pour HeartAttack
*/

package scripts.bullets {
	import scripts.Bullet;
	import scripts.BigShot;
	import scripts.SoundLibrary;
	
	public class NeoHeart extends Bullet {
		public var chain:HeartString;
		private var hp:Number = 140;
	
		// constructor
		public function NeoHeart() {
			shootable = true;
			destroyBigShot = true;
			destroyOnHit = false;
			element = 6;
		}
		
		// Quand le heart est shot
		public override function onShot(shot):void {
			// Jouer un animation et un son
			gotoAndPlay("shot");
			SoundLibrary.play("enemydamage", 0.5);
			
			// Réduire hp
			if (shot is BigShot) {hp -= 20;}
			else {hp -= 5;}
			
			// Si hp dépasse 0, commencer la destruction
			if (hp <= 0) {chain.destroy();}
		}
	}
}
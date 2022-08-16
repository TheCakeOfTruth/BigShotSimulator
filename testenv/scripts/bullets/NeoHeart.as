/*
	Date: 08-12-2021
	Description: The heart of the problem
*/

package scripts.bullets {
	import scripts.Bullet;
	import scripts.BigShot;
	import scripts.SoundLibrary;
	
	public class NeoHeart extends Bullet {
		public var chain:HeartString;
		private var hp:Number = 140;
	
		// Constructor
		public function NeoHeart() {
			shootable = true;
			destroyBigShot = true;
			destroyOnHit = false;
			element = 6;
		}
		
		// When the heart is shot
		public override function onShot(shot):void {
			// Play an animation and a sound
			gotoAndPlay("shot");
			SoundLibrary.play("enemydamage", 0.5);
			
			// Reduce the heart's HP
			if (shot is BigShot) {hp -= 20;}
			else {hp -= 5;}
			
			// At 0, begin destruction
			if (hp <= 0) {chain.destroy();}
		}
	}
}
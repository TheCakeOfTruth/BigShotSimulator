/*
	Date: 02-11-2021
	Description: Bomb that explodes when shot
*/

package scripts.bullets {
	import flash.media.SoundTransform;
	import scripts.SoundLibrary;
	import scripts.Bullet;
	import scripts.EnemyWave;
	import scripts.utils.Input;

	public class Bomb extends Bullet {
		private var beenShot:Boolean = false;
	
		// Constructor
		public function Bomb() {
			shootable = true;
			element = 6;
		}
		
		// When you shoot it
		public override function onShot(shot):void {
			if (!beenShot) {explode();}
			beenShot = true;
		}
		
		// Play a sound and an animation (see action code for Bomb and BombBlast objects)
		private function explode():void {
			SoundLibrary.play("bombbeep", 0.5, 2);
			this.play();
		}
		
		// Create the lines of BombBlast
		private function createBeams():void {
			// Play a sound and shake the screen
			SoundLibrary.play("bomb", 0.5);
			Main.screen.shakeScreen(3);
			// Create 4 lines
			for (var i:int = 0; i < 4; i++) {createBeam(i);}
		}
		
		// Creates 1 line of BombBlast
		private function createBeam(dir:int):void {
			for (var reps:int = 0; reps < 20; reps++) {
				// Make a BombBlast
				var blastSegment:BombBlast = new BombBlast();
				// Rotate and position
				// L
				if (dir == 0) {
					blastSegment.rotation += 90;
					blastSegment.x = this.x - 5 - 24 * (reps + 1);
					blastSegment.y = this.y;
				}
				// U
				else if (dir == 1) {
					blastSegment.x = this.x;
					blastSegment.y = this.y - 5 - 24 * reps;
				}
				// R
				else if (dir == 2) {
					blastSegment.rotation -= 90;
					blastSegment.x = this.x + 5 + 24 * (reps + 1);
					blastSegment.y = this.y;
				}
				// D
				else if (dir == 3) {
					blastSegment.rotation = 180;
					blastSegment.x = this.x;
					blastSegment.y = this.y + 5 + 24 * reps;
				}
				// Add to the screen
				this.parent.addChild(blastSegment);
				EnemyWave.currentWave.addBullet(blastSegment, false);
			}
		}
	}
}
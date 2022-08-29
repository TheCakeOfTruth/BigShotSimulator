/*
	Date: 26-08-2022
	Description: The head part of the phone-hand-head thing
*/

package scripts.bullets {
	import flash.display.MovieClip;
	import flash.geom.Point;
	import scripts.Bullet;
	import scripts.utils.Wait;
	import scripts.SoundLibrary;
	import scripts.BigShot;
	
	public class ChompyHead extends Bullet {
		public var crawler:CrawlyHead;
	
		// Constructor
		public function ChompyHead() {
			shootable = true;
			destroyBigShot = true;
			destroyOnHit = false;
			element = 6;
			deleteOffScreen = false;
		}
		
		// When the head is shot
		public override function onShot(shot):void {
			// Keep him from going too far
			if (crawler.localToGlobal(new Point(x, 0)).x < 480) {
				// Double speed for big shots
				if (shot is BigShot) {
					crawler.hspeed += 4;
				}
				else {
					crawler.hspeed += 2;
				}
				// Cap speed at 8 so it doesn't take forever to reset after big shot spam (you dirty cheater)
				crawler.hspeed = Math.min(8, crawler.hspeed);
				SoundLibrary.play("enemydamage");
			}
		}
	}
}
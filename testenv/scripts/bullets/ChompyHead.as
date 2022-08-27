/*
	Date: 26-08-2022
	Description: The head part of the phone-hand-head thing
*/

package scripts.bullets {
	import flash.display.MovieClip;
	import scripts.Bullet;
	import scripts.utils.Wait;
	import scripts.BigShot;
	
	public class ChompyHead extends Bullet {
		public var crawler:CrawlyHead;
	
		// Constructor
		public function ChompyHead() {
			shootable = true;
			destroyBigShot = true;
			destroyOnHit = false;
			element = 6;
		}
		
		public override function onShot(shot):void {
			if (shot is BigShot) {
				x += 4;
			}
			else {
				x += 1;
			}
		}
	}
}
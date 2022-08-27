/*
	Date: 26-08-2022
	Description: The hand part of the phone-hand-head thing
*/

package scripts.bullets {
	import flash.display.MovieClip;
	import scripts.Bullet;
	import scripts.utils.Wait;
	
	public class PhoneHand extends Bullet {
		// Constructor
		public function PhoneHand() {
			destroyOnHit = false;
			element = 6;
		}
	}
}
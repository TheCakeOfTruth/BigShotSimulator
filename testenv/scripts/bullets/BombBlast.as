/*
	Date: 02-12-2021
	Description: The blast of the bombs
*/

package scripts.bullets {
	import scripts.Bullet;
	
	public class BombBlast extends Bullet {
		// Constructor
		public function BombBlast() {
			destroyOnHit = false;
			element = 6;
		}
	}
}
/*
	File Name: BombBlast.as
	Programmeur: William Mallette
	Date: 02-12-2021
	Description: Les colonnes qui proviennent d'un Bomb
*/

package scripts.bullets {
	import scripts.Bullet;
	
	public class BombBlast extends Bullet {
		// constructor
		public function BombBlast() {
			destroyOnHit = false;
			element = 6;
		}
	}
}
/*
	File Name: MailWall.as
	Programmeur: William Mallette
	Date: 02-11-2021
	Description: Les icones de e-mail de l'attaque de RollerCoaster
*/

package scripts.bullets {
	import scripts.Bullet;
	import scripts.SoundLibrary;

	public class MailWall extends Bullet {
		// constructor
		public function MailWall() {
			shootable = true;
			destroyBigShot = true;
			element = 6;
		}
		
		// Quand on frappe avec un Shot, jouer un son (et détruire le Shot, voir Bullet)
		public override function onShot(shot):void {
			SoundLibrary.play("bell", 0.5);
		}
	}
}
/*
	Date: 02-11-2021
	Description: I USED TO BE THE [[E-MAIL]] GUY
*/

package scripts.bullets {
	import scripts.Bullet;
	import scripts.SoundLibrary;

	public class MailWall extends Bullet {
		// Constructor
		public function MailWall() {
			shootable = true;
			destroyBigShot = true;
			element = 6;
		}
		
		// It blocks the shots
		public override function onShot(shot):void {
			SoundLibrary.play("bell", 0.5);
		}
	}
}
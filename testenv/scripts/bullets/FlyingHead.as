/*
	File Name: FlyingHead.as
	Programmeur: William Mallette
	Date: 02-11-2021
	Description: Les têtes bleues
*/

package scripts.bullets {
	import flash.media.SoundTransform;
	import scripts.Bullet;
	import scripts.SoundLibrary;
	import scripts.BigShot;
	import scripts.ui.TPMeter;

	public class FlyingHead extends Bullet {
		public var willShoot:Boolean = true;
		public var loopAnimation:Boolean = false;
		
		// constructor
		public function FlyingHead() {
			shootable = true;
			element = 6;
		}
		
		// Quand on frappe avec un Shot
		public override function onShot(shot):void {
			// Un BigShot ajoute du TP
			if (shot is BigShot) {TPMeter.instance.addTP(3);}
			SoundLibrary.play("bomb", 0.35);
			destroy();
		}
	}
}
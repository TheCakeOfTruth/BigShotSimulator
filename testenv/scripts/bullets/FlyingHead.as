/*
	Date: 02-11-2021
	Description: Blue heads
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
		
		// Constructor
		public function FlyingHead() {
			shootable = true;
			element = 6;
		}
		
		public override function onShot(shot):void {
			// BigShot adds TP
			if (shot is BigShot) {TPMeter.instance.addTP(3);}
			SoundLibrary.play("bomb", 0.35);
			destroy();
		}
	}
}
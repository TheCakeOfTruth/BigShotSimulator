/*
	File Name: Cungadero.as
	Programmeur: William Mallette
	Date: 02-12-2021
	Description: Les carts du RollerCoaster. "TAKE A [ride around town] ON OUR [Specil] CUNGADERO!"
*/

package scripts.bullets {
	import flash.display.Sprite;
	import scripts.EnemyWave;
	import scripts.utils.Wait;

	public class Cungadero extends Sprite {
		public var isMoving:Boolean = false;
		
		// constructor
		public function Cungadero(contents:Array) {
			// Itérer par contents
			for (var i:String in contents) {
				var item:String = contents[i];
				var obj;
				// Un FlyingHead
				if (item == "h") {
					obj = new FlyingHead();
					obj.willShoot = false;
					obj.loopAnimation = true;
				}
				// Un MailWall
				else if (item == "m") {
					obj = new MailWall();
					obj.x -= 2
				}
				// Un Bomb
				else if (item == "b") {
					obj = new Bomb();
				}
				// Positionner et addChild
				obj.y = 5 - (int(i) + 2) * 34;
				this.addChild(obj);
				EnemyWave.currentWave.addBullet(obj, false);
			}
			
			// Positionner
			this.x = 700;
			this.y = 301;
		}
		
		// Commencer un délai avant de changer isMoving
		public function startWait(t:int):void {
			new Wait(t, function() {isMoving = true;});
		}
	}
}
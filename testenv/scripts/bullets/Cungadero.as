/*
	Date: 02-12-2021
	Description: "TAKE A [ride around town] ON OUR [Specil] CUNGADERO!"
*/

package scripts.bullets {
	import flash.display.Sprite;
	import scripts.EnemyWave;
	import scripts.utils.Wait;

	public class Cungadero extends Sprite {
		public var isMoving:Boolean = false;
		
		// Constructor
		public function Cungadero(contents:Array) {
			// Iterate through contents
			for (var i:String in contents) {
				var item:String = contents[i];
				var obj;
				// FlyingHead
				if (item == "h") {
					obj = new FlyingHead();
					obj.willShoot = false;
					obj.loopAnimation = true;
				}
				// MailWall
				else if (item == "m") {
					obj = new MailWall();
					obj.x -= 2
				}
				// Bomb
				else if (item == "b") {
					obj = new Bomb();
				}
				// Position and addChild
				obj.y = 5 - (int(i) + 2) * 34;
				this.addChild(obj);
				EnemyWave.currentWave.addBullet(obj, false);
			}
			
			// Position (of the Cungadero)
			this.x = 700;
			this.y = 301;
		}
		
		// Wait a bit before moving
		public function startWait(t:int):void {
			new Wait(t, function() {isMoving = true;});
		}
	}
}
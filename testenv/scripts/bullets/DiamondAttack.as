/*	
	Date: 13-12-2021
	Description: Mine Diamonds
*/

package scripts.bullets {
	import flash.geom.Point;
	import scripts.Bullet;
	import scripts.utils.MovementVector;
	
	public class DiamondAttack extends Bullet {
		private var vector:MovementVector;
		
		// Constructor
		public function DiamondAttack(rotation:Number = 0) {
			element = 6;
			damageMultiplier = 4;
			this.rotation = rotation;
			vector = new MovementVector(this.rotation, 2);
		}
		
		// Each frame
		public override function update():void {
			// Destroy the object when it's no longer on screen
			if (this.x < -100 || this.y < -100 || this.x > 700 || this.y > 500) {
				destroy();
			}
			else {
				// Acceleration and movement
				vector.setMagnitude(vector.getMagnitude() + 0.05);
				var dim:Point = vector.getDimensions();
				this.x += dim.x;
				this.y += dim.y;
			}
		}
	}
}
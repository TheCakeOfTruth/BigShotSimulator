/*
	Date: 03-11-2021
	Description: [[BIG]] white, "friendliness pellets"
*/

package scripts.bullets {
	import flash.geom.Point;
	import scripts.Bullet;
	import scripts.Player;
	import scripts.utils.MovementVector;

	public class HeadPellet extends Bullet {
		private var vector:MovementVector;
		
		// Constructor
		public function HeadPellet(x:Number, y:Number) {
			element = 6;
			// Positioning
			this.x = x;
			this.y = y;
			// The vector (aims at player's current position)
			vector = MovementVector.getVectorFromDimensions(Player.instance.x - x, -(Player.instance.y - y));
			vector.setMagnitude(5);
		}
		
		// Every frame
		public override function update():void {
			// Rotation
			this.rotation -= 15
			// Movement
			var dim:Point = vector.getDimensions()
			this.x += dim.x;
			this.y -= dim.y;
		}
	}
}
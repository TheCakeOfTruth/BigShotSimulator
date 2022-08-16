/*
	Date: 28-12-2021
	Description: Spamton Heads (pipis)
*/

package scripts.bullets {
	import flash.geom.Point;
	import scripts.Bullet;
	import scripts.utils.MovementVector;
	import scripts.utils.RandomRange;
	
	public class pipisHead extends Bullet {
		public var vector:MovementVector;
		
		// Constructor
		public function pipisHead(angleRange:Array = null, minSpeed:Number = 2) {
			element = 6;
			// Pick a random direction within the range given
			if (angleRange) {
				vector = new MovementVector(RandomRange(angleRange[0], angleRange[1]), RandomRange(minSpeed, minSpeed + 3));
			}
			// If no range is given, completely random scattering
			else {
				vector = new MovementVector(360 * Math.random(), RandomRange(minSpeed, minSpeed + 3));
			}
			// Start the animation at a random spot
			this.gotoAndPlay(int(RandomRange(0, 39)));
		}
		
		// Every frame
		public override function update():void {
			// Move the head
			var dim:Point = vector.getDimensions();
			this.x += dim.x;
			this.y -= dim.y;
		}
	}
}
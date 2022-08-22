/*
	Date: 30-10-2021
	Description: Vectors
*/

package scripts.utils {
	import flash.geom.Point;
	
	public class MovementVector {
		private var magnitude:Number;
		private var angle:Number;
		
		// Constructor
		public function MovementVector(a:Number=0, m:Number=0) {
			// Define the angle and magnitude
			setAngle(a);
			setMagnitude(m);
		}
		
		// Various functions to change or return private variables
		
		public function setAngle(n:Number):void {angle = n % 360;}
		
		public function getAngle():Number {return angle;}
		
		public function setMagnitude(n:Number):void {magnitude = n;}
		
		public function getMagnitude():Number {return magnitude;}
		
		// Convert the vector into its components under the form of a Point
		public function getDimensions():Point {
			var pt:Point = new Point();
			pt.x = BetterRound(magnitude * Math.cos(angle * Math.PI/180), 2);
			pt.y = BetterRound(magnitude * Math.sin(angle * Math.PI/180), 2);
			return pt;
		}
		
		// Add two vectors together (overwrites the base vector)
		public function add(v:MovementVector):void {
			// Take the components of the two vectors and combine them
			var newpt:Point = getDimensions().add(v.getDimensions());
			// Pythagoras for the new magnitude
			setMagnitude(BetterRound(Math.sqrt(Math.pow(newpt.x, 2) + Math.pow(newpt.y, 2)), 2));
			// Inverse tan to get the new angle
			// (avoid dividing by 0 by adding a very small decimal to the horizontal value)
			setAngle(BetterRound(Math.atan(newpt.y / (newpt.x + 1e-5)) * 180/Math.PI, 2));
			// Inverse tan doesn't work great with angles between 90 and 270 degrees
			// So, if the horizontal value is negative, add 180 degrees to the angle
			if (newpt.x < 0) {setAngle(getAngle() + 180);}
		}
		
		// Same math as in MovementVector.add, but use those dimensions to make a new vector altogether
		public static function getVectorFromDimensions(x:Number, y:Number):MovementVector {
			var a:Number = Math.atan(y / (x + 1e-5)) * 180/Math.PI;
			if (x < 0) {a += 180;}
			var m:Number = Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2));
			return new MovementVector(a, m);
		}
	}
}
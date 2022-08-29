/*
	Date: 26-08-2022
	Description: The shot fired by the head of the crawly phone head thing
*/

package scripts.bullets {
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.geom.ColorTransform;
	import scripts.Bullet;
	import scripts.utils.Wait;
	import scripts.utils.RandomRange;
	import scripts.BigShot;
	
	public class CrawlShot extends Bullet {
		private static var white:ColorTransform = new ColorTransform(1, 1, 1);
		private static var yellow:ColorTransform = new ColorTransform(1, 1, 0);
		private var currColor:String = "white";
		private var timer:int = 0;
		private var speed:Number = 6;
		private var friction:Number = 0.5;
	
		// Constructor
		public function CrawlShot() {
			element = 6;
			rotation = RandomRange(-5, 5);
		}
		
		// Every frame
		public override function update():void {
			timer++;
			// Movement
			x -= speed;
			if (speed > 0) {speed -= friction;}
			// Changing color
			if (timer % 10 == 0) {
				changeColor();
			}
			// Explode
			if (timer == 50) {explode();}
		}
		
		private function changeColor():void {
			if (currColor == "white") {transform.colorTransform = yellow; currColor = "yellow";}
			else {transform.colorTransform = white; currColor = "white";}
		}
		
		private function explode():void {
			destroy();
		}
	}
}
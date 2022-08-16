/*
	Date: 08-12-2021
	Description: [[Heart]] ON A [[Chain]]
*/

package scripts.bullets {
	import flash.display.Sprite;
	import scripts.utils.Wait;
	import scripts.SoundLibrary;
	
	public class HeartString extends Sprite {
		private var balls:Array;
		
		// Constructor
		public function HeartString() {
			balls = [ball1, ball2, ball3, ball4, ball5, ball6, ball7, ball8, ball9, ball10];
			heart.chain = this;
		}
		
		// Move the heart and the balls
		public function moveHeartTo(x:Number = 0, y:Number = 0):void {
			if (heart) {
				heart.x = x;
				heart.y = y;
			}
			// Positioning balls relative to the heart
			for (var ball in balls) {
				if (balls[ball]) {
					balls[ball].x = ball * x / 10;
					balls[ball].y = ball * y / 10;
				}
			}
		}
		
		// Move relative to current position
		public function moveHeart(x:Number = 0, y:Number = 0):void {
			moveHeartTo(heart.x + x, heart.y + y);
		}
		
		// Begin destroying the HeartString
		public function destroy():void {
			heart.destroy();
			heart.chain = null;
			heart = null;
			SoundLibrary.play("bomb", 0.5);
			for (var i:int = 0; i < balls.length; i++) {new Wait(4 * (i + 1), destroyball);}
		}
		
		// The chain falls apart until there is nothing left
		private function destroyball():void {
			// Remove the last ball in the array
			removeChild(balls[balls.length - 1]);
			balls.splice(balls.length - 1, 1);
			// Play a sound
			SoundLibrary.play("bomb", 0.5);
			
			// Remove the object when everything is gone
			if (balls.length == 0) {
				balls = null;
				this.parent.removeChild(this);
			}
		}
	}
}
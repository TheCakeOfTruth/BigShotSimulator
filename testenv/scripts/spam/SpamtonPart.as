/*
	Date: 14-11-2021
	Description: Base class for Spamton NEO body parts
*/

package scripts.spam {
	import flash.display.MovieClip;
	import flash.events.Event;
	import scripts.utils.Wait;
	import scripts.utils.RepeatUntil;
	import scripts.utils.GlobalListener;
	import scripts.utils.RandomRange;
	
	public class SpamtonPart extends MovieClip {
		public var enableRotation:Boolean = true;
		public var minRotation:Number = 0;
		public var maxRotation:Number = 0;
		public var rotSpeed:Number = 0.0625;
		public var offset:Number = 0;
		
		private var timer:Number = 0;
		private var eventID:String;
		
		// Constructor
		public function SpamtonPart() {
			eventID = "SpamtonPart-" + String(Math.random());
			GlobalListener.addEvent(update, eventID);
		}
		
		// Every frame
		private function update():void {
			if (enableRotation) {
				timer = (timer + 1) % ((2 * Math.PI) / rotSpeed);
				// Rotate the object according to its settings
				this.rotation = 0.5 * (maxRotation - minRotation) * (Math.sin(rotSpeed * timer + offset)) + 0.5 * (maxRotation + minRotation);
			}
		}
		
		// Nice function for controlling settings
		public function setRotValues(_min:Number = 0, _max:Number = 0, _speed:Number = 0, _offset:Number = 0):void {
			minRotation = _min;
			maxRotation = _max;
			rotSpeed = _speed;
			offset = _offset;
		}
		
		// Rotate an object to a specific angle following a specified direction
		public function rotateTo(targetRot:Number, clockwise:Boolean = true, t:Number = 10):void {
			// Turn off the base rotation from the update function
			enableRotation = false;
			
			// Get the difference
			var diff:Number = Math.abs(targetRot - rotation);
			
			// Use a RepeatUntil to do the rotation
			new RepeatUntil(function() {
				if (clockwise) {
					rotation += diff / t;
				} 
				else {
					rotation -= diff / t;
				}
			}, function() {
				if (rotation < targetRot + 5 && rotation > targetRot - 5) {
					return true;
				}
			})
		}
		
		// rotateTo except it follows the shortest path
		public function rotateToSmart(targetRot:Number, t:Number = 10):void {
			// Store some variables
			var r1:Number = rotation;
			var diff:Number = (targetRot % 360) - (rotation % 360);
			// Make sure the difference is the smallest of the two possibilities
			// I found this here: https://stackoverflow.com/questions/1878907/how-can-i-find-the-difference-between-two-angles
			diff = (diff + 180) % 360 - 180;
			
			// Rotate along the calculated path for (t) frames
			var rtimer:Number = 0;
			new RepeatUntil(function() {
				rtimer++
				// Nice function to accelerate the rotation: https://www.desmos.com/calculator/pffdzeypre
				rotation = diff * Math.sqrt(rtimer / t) + r1;
			}, function() {
				if (rtimer >= t) {rotation = targetRot; return true;}
			});
		}
		
		// Shake things up
		public function shake(intensity:Number = 2) {
			// Two random numbers
			var val_x:Number = RandomRange(-intensity, intensity);
			var val_y:Number = RandomRange(-intensity, intensity);
			// Displace
			this.getChildAt(0).x = val_x;
			this.getChildAt(0).y = val_y;
		}
		
		// remove the EventListener
		public function destroy():void {
			GlobalListener.removeEvent(eventID);
		}
	}
}
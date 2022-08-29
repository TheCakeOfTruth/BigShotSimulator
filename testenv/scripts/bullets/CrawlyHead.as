/*
	Date: 26-08-2022
	Description: The phone-hand-head thing
*/

package scripts.bullets {
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.ColorTransform;
	import scripts.Player;
	import scripts.Bullet;
	import scripts.utils.Wait;
	import scripts.utils.MovementVector;
	import scripts.utils.GlobalListener;
	import scripts.BigShot;
	
	public class CrawlyHead extends MovieClip {
		private var timer:int = 0;
		public var hspeed:Number = 0;
		public var friction:Number = 0.25;
	
		// Constructor
		public function CrawlyHead() {
			head.crawler = this;
		
			configureArmSegment(uparm, 106, -21);
			configureArmSegment(downarm, 66, 201);
			
			configureArmSegment(ufarm, 40, -110, true)
			configureArmSegment(dfarm, 40, -70, true)
			
			moveHandTo(uphone, -70, -70);
			moveHandTo(dphone, -70, 60);

			GlobalListener.addEvent(update, "updateCrawler");
			addEventListener(Event.REMOVED_FROM_STAGE, cleanup);
		}
		
		// Every frame
		private function update():void {
			// collision code for the arms would go here if i knew how to do collision code :(
		}
		
		// Sets up arm lengths and rotations
		public function configureArmSegment(arm, len:Number, rot:Number, isForearm:Boolean = false, adjustForearm:Boolean = true):void {
			// Change the length and rotation
			arm.arm.getChildAt(0).height = len;
			arm.arm.rotation = rot;
			
			// Position the balls accordingly
			var dim:Point = new MovementVector(90 - rot, len).getDimensions();
			for (var b:int = 1; b <= 4; b++) {
				var ball = arm["ball" + String(b)];
				ball.x = dim.x - (0.25 * dim.x * (b - 1));
				ball.y = -dim.y + (0.25 * dim.y * (b - 1));
			}
			
			if (adjustForearm) {
				// If we're not moving a forearm, position the respective forearm correctly
				var forearm;
				if (isForearm == false) {
					// Hacky way to get the position of arm's ball1 relative to the main container (this object)
					var pt:Point = this.globalToLocal(arm.localToGlobal(new Point(arm.ball1.x, arm.ball1.y)));
					// Hacky way to get the forearm associated to the moved arm
					forearm = this[arm.name.charAt(0) + "farm"];
					forearm.x = pt.x;
					forearm.y = pt.y;
				}
				else {
					forearm = arm;
				}
				
				// Hacky way to get and position the associated phone
				var phone = this[arm.name.charAt(0) + "phone"];
				var pt2:Point = this.globalToLocal(forearm.localToGlobal(new Point(forearm.ball1.x, forearm.ball1.y)));
				phone.x = pt2.x;
				phone.y = pt2.y;
			}
		}
		
		// Moves the head and adjusts arms accordingly
		public function moveHeadTo(x:Number, y:Number):void {
			head.x = x;
			head.y = y;
			
			uparm.x = x + 10;
			uparm.y = y + 20;
			var upPointer:MovementVector = MovementVector.getVectorFromDimensions(ufarm.x - uparm.x, ufarm.y - uparm.y);
			configureArmSegment(uparm, upPointer.getMagnitude(), upPointer.getAngle() + 90, false, false);
			
			downarm.x = x + 10;
			downarm.y = y + 20;
			var downPointer:MovementVector = MovementVector.getVectorFromDimensions(dfarm.x - downarm.x, dfarm.y - downarm.y);
			configureArmSegment(downarm, downPointer.getMagnitude(), downPointer.getAngle() + 90, false, false);
		}
		
		// Move a hand and adjust the forearms accordingly
		public function moveHandTo(phone, x:Number, y:Number):void {
			phone.x = x;
			phone.y = y;
			var forearm2 = this[phone.name.charAt(0) + "farm"];
			var phonePointer:MovementVector = MovementVector.getVectorFromDimensions(phone.x - forearm2.x, phone.y - forearm2.y);
			configureArmSegment(forearm2, phonePointer.getMagnitude(), phonePointer.getAngle() + 90, true);
		}
		
		// Remove things
		private function cleanup(e:Event):void {
			GlobalListener.removeEvent("updateCrawler");
			removeEventListener(Event.REMOVED_FROM_STAGE, cleanup);
		}
	}
}
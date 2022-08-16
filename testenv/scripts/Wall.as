/*
	Date: 30-10-2021
	Description: Arena walls
*/

package scripts{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import scripts.utils.MovementVector;
	
	public class Wall extends Sprite {
		public var colliderVector:MovementVector;
		private var arrayID:int = -1;
		
		// Constructor
		public function Wall() {
			// Make a vector perpendicular to the wall
			colliderVector = new MovementVector(-this.rotation + 90, 3.89);
			// An eventListener
			addEventListener(Event.ENTER_FRAME, checkCollision, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, cleanup, false, 0, true);
		}
		
		// Check for collision each frame
		private function checkCollision(e:Event):void {
			// Depending on the rotation, increase the magnitude
			if (Math.round(rotation) % 90 == 0) {colliderVector.setMagnitude(2.75);}
			else {colliderVector.setMagnitude(3.89);}
			// Make sure the angle is right
			colliderVector.setAngle(-rotation + 90);
			
			if (Player.instance != null) {
				// For each collision point on the player, check if it's colliding with the wall
				for each (var cP:Point in Player.instance.collisionPoints) {
					// If there is a collision, add the wall to an array (if needed)
					if (hitTestPoint(cP.x, cP.y, true) && arrayID == -1) {
						Player.instance.collidingWalls.push(this);
						arrayID = Player.instance.collidingWalls.length - 1;
						break;
					}
					// If not, and the wall is still in the array, remove it
					else {
						if (arrayID != -1) {
							Player.instance.collidingWalls.splice(arrayID, 1);
							// Adjust other arrayIDs
							for each (var otherWall:Wall in Player.instance.collidingWalls) {
								if (otherWall.arrayID > arrayID) {otherWall.arrayID--;}
							}
							otherWall = null;
							// Reset arrayID
							arrayID = -1;
						}
					}
				}
				cP = null;
			}
		}
		
		// Remove eventListeners
		private function cleanup(e:Event):void {
			removeEventListener(Event.ENTER_FRAME, checkCollision);
			removeEventListener(Event.REMOVED_FROM_STAGE, cleanup);
		}
	}
}
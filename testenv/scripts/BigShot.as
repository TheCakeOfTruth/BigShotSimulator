/*
	Date: 01-11-2021
	Description: The BIG SHOT
*/

package scripts {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import scripts.utils.GlobalListener;

	public class BigShot extends Sprite {
		public var hitPoints:Array = [];
		public var shotID:uint;
		private var vel:Number = 7;
		private var eventID:String;
		
		// Constructor
		public function BigShot(x:Number, y:Number) {
			// Add an eventListener, position the shot and its collider points
			eventID = "BigShot-" + String(Math.random());
			GlobalListener.addEvent(update, eventID);
			this.x = x;
			this.y = y;
			this.scaleX = 0.25;
			hitPoints.push(new Point(x+18.5, y-10));
			hitPoints.push(new Point(x+22.5, y));
			hitPoints.push(new Point(x+18.5, y+10));
			
			shotID = Player.shots.push(this) - 1;
		}
		
		// Each frame
		private function update():void {
			// Expand
			if (this.scaleX < 1) {this.scaleX += 0.04;}
		
			// Move
			this.x += vel;
			for each (var pt:Point in hitPoints) {pt.x += vel;}
			pt = null;
			
			// Destroy the shot once it's offscreen
			if (this.x > 640) {
				destroy();
			}
		}
		
		// Destroy the object
		public function destroy():void {
			// Remove from shot array, adjust other shotIDs
			Player.shots.splice(shotID, 1);
			for each (var shot in Player.shots) {
				if (shot.shotID > shotID) {shot.shotID--;}
			}
			shot = null;
		
			// Remove eventListener
			GlobalListener.removeEvent(eventID);
			this.parent.removeChild(this);
		}
	}
}
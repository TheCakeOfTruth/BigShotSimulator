/*
	Date: 21-10-2021
	Description: Small shot
*/

package scripts {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import scripts.utils.GlobalListener;
	
	public class Shot extends Sprite {
		public var hitPoints:Array = [];
		public var shotID:uint;
		private var vel:Number = 7;
		private var eventID:String;
		
		// Constructor
		public function Shot(x:Number, y:Number) {
			// Add eventListener, position things
			eventID = "Shot-" + String(Math.random());
			GlobalListener.addEvent(update, eventID);
			this.x = x;
			this.y = y;
			hitPoints.push(new Point(x+12.5, y-3));
			hitPoints.push(new Point(x+12.5, y));
			hitPoints.push(new Point(x+12.5, y+3));
			
			shotID = Player.shots.push(this) - 1;
		}
		
		// Every frame
		private function update():void {
			// Move shot and points
			this.x += vel;
			for each (var pt:Point in hitPoints) {pt.x += vel;}
			pt = null;
			
			// Remove when offscreen
			if (this.x > 640) {
				destroy();
			}
		}
		
		// Destroy the object
		public function destroy():void {
			// Remove from array, adjust other shotIDs
			Player.shots.splice(shotID, 1);
			for each (var shot in Player.shots) {
				if (shot.shotID > shotID) {shot.shotID--;}
			}
			shot = null;
		
			// Remove eventListener and object
			GlobalListener.removeEvent(eventID);
			this.parent.removeChild(this);
		}
	}
}
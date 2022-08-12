/*
	File Name: Shot.as
	Programmeur: William Mallette
	Date: 21-10-2021
	Description: La petite balle jaune utilisé par le coeur
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
			// Ajouter un eventListener, positionner la balle et ses points
			eventID = "Shot-" + String(Math.random());
			GlobalListener.addEvent(update, eventID);
			this.x = x;
			this.y = y;
			hitPoints.push(new Point(x+12.5, y-3));
			hitPoints.push(new Point(x+12.5, y));
			hitPoints.push(new Point(x+12.5, y+3));
			
			shotID = Player.shots.push(this) - 1;
		}
		
		// Effectuer des changements à chaque frame
		private function update():void {
			// Boujer la balle et ses points
			this.x += vel;
			for each (var pt:Point in hitPoints) {pt.x += vel;}
			pt = null;
			
			// Si la balle dépasse 100 pixels à la droite de l'écran, enlève-la.
			if (this.x > 640) {
				destroy();
			}
		}
		
		// Détruire l'objet
		public function destroy():void {
			// Enlever l'objet de l'array de Shots, adjuster les shotID des autres Shots.
			Player.shots.splice(shotID, 1);
			for each (var shot in Player.shots) {
				if (shot.shotID > shotID) {shot.shotID--;}
			}
			shot = null;
		
			// Enlèver l'eventListener pour prévenir un memory leak et enlève l'objet du DisplayList
			GlobalListener.removeEvent(eventID);
			this.parent.removeChild(this);
		}
	}
}
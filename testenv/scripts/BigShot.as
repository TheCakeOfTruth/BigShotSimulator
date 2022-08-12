/*
	File Name: BigShot.as
	Programmeur: William Mallette
	Date: 01-11-2021
	Description: La grande balle jaune utilisé par le coeur
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
		
		// constructor
		public function BigShot(x:Number, y:Number) {
			// Ajouter un eventListener, positionner la balle et ses points
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
		
		// Effectuer des changements à chaque frame
		private function update():void {
			// Une animation d'expansion
			if (this.scaleX < 1) {this.scaleX += 0.04;}
		
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
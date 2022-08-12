/*
	File Name: Wall.as
	Programmeur: William Mallette
	Date: 30-10-2021
	Description: Les murs de l'aréna
*/

package scripts{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import scripts.utils.MovementVector;
	
	public class Wall extends Sprite {
		public var colliderVector:MovementVector;
		private var arrayID:int = -1;
		
		// constructor
		public function Wall() {
			// Créer une vecteur correspondant à la rotation du mur.
			colliderVector = new MovementVector(-this.rotation + 90, 3.89);
			// Un eventListener
			addEventListener(Event.ENTER_FRAME, checkCollision, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, cleanup, false, 0, true);
		}
		
		// Vérifier pour une collision à chaque frame
		private function checkCollision(e:Event):void {
			// Changer la magnitude du vecteur dépendant de la rotation.
			if (Math.round(rotation) % 90 == 0) {colliderVector.setMagnitude(2.75);}
			else {colliderVector.setMagnitude(3.89);}
			// Assurer que l'angle est correct
			colliderVector.setAngle(-rotation + 90);
			
			if (Player.instance != null) {
				// Pour chaque point de collision du Player.instance, vérifie s'il est en collision
				for each (var cP:Point in Player.instance.collisionPoints) {
					// Si on est en collision, et ce mur n'est pas encore dans l'array du Player.instance,
					if (hitTestPoint(cP.x, cP.y, true) && arrayID == -1) {
						// Ajoute le mur à l'array, identifie son index, et break pour éviter une duplication
						Player.instance.collidingWalls.push(this);
						arrayID = Player.instance.collidingWalls.length - 1;
						break;
					}
					// Si non,
					else {
						// S'il n'y a aucun collision, et le mur est dans l'array, enlève-lui.
						if (arrayID != -1) {
							Player.instance.collidingWalls.splice(arrayID, 1);
							// Adjuster les indexes des autres murs en collision.
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
		
		// Enlever les eventListener
		private function cleanup(e:Event):void {
			removeEventListener(Event.ENTER_FRAME, checkCollision);
			removeEventListener(Event.REMOVED_FROM_STAGE, cleanup);
		}
	}
}
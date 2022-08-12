/*
	File Name: HeadPellet.as
	Programmeur: William Mallette
	Date: 03-11-2021
	Description: Les disques lancés par les FlyingHeads
*/

package scripts.bullets {
	import flash.geom.Point;
	import scripts.Bullet;
	import scripts.Player;
	import scripts.utils.MovementVector;

	public class HeadPellet extends Bullet {
		private var vector:MovementVector;
		
		// constructor
		public function HeadPellet(x:Number, y:Number) {
			element = 6;
			// Positionner
			this.x = x;
			this.y = y;
			// Calculer le vecteur de mouvement
			vector = MovementVector.getVectorFromDimensions(Player.instance.x - x, -(Player.instance.y - y));
			vector.setMagnitude(5);
		}
		
		// À chaque frame
		public override function update():void {
			// Rotation
			this.rotation -= 15
			// Mouvement
			var dim:Point = vector.getDimensions()
			this.x += dim.x;
			this.y -= dim.y;
		}
	}
}
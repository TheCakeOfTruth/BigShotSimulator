/*	
	File Name: DiamondAttack.as
	Programmeur: William Mallette
	Date: 13-12-2021
	Description: Le Bullet de diamant relié au HeartAttack
*/

package scripts.bullets {
	import flash.geom.Point;
	import scripts.Bullet;
	import scripts.utils.MovementVector;
	
	public class DiamondAttack extends Bullet {
		private var vector:MovementVector;
		
		// constructor
		public function DiamondAttack(rotation:Number = 0) {
			element = 6;
			damageMultiplier = 4;
			this.rotation = rotation;
			vector = new MovementVector(this.rotation, 2);
		}
		
		// À chaque frame
		public override function update():void {
			// Détruire l'objet quand elle n'est plus sur l'écran
			if (this.x < -100 || this.y < -100 || this.x > 700 || this.y > 500) {
				destroy();
			}
			else {
				// Accélération et mouvement
				vector.setMagnitude(vector.getMagnitude() + 0.05);
				var dim:Point = vector.getDimensions();
				this.x += dim.x;
				this.y += dim.y;
			}
		}
	}
}
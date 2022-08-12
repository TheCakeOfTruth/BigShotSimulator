/*
	File Name: pipisHead.as
	Programmeur: William Mallette
	Date: 28-12-2021
	Description: Les têtes de Spamton qui proviennent du pipis
*/

package scripts.bullets {
	import flash.geom.Point;
	import scripts.Bullet;
	import scripts.utils.MovementVector;
	import scripts.utils.RandomRange;
	
	public class pipisHead extends Bullet {
		public var vector:MovementVector;
		
		// constructor
		public function pipisHead(angleRange:Array = null, minSpeed:Number = 2) {
			element = 6;
			// Créer un vecteur avec une direction aléatoire entre les paramètres de angleRange et un magnitude relativement aléatoire
			if (angleRange) {
				vector = new MovementVector(RandomRange(angleRange[0], angleRange[1]), RandomRange(minSpeed, minSpeed + 3));
			}
			// Créer un vecteur avec une direction complètement aléatoire et un magnitude relativement aléatoire
			else {
				vector = new MovementVector(360 * Math.random(), RandomRange(minSpeed, minSpeed + 3));
			}
			// Commencer l'animation à un frame aléatoire pour la diversité visuel
			this.gotoAndPlay(int(RandomRange(0, 39)));
		}
		
		// À chaque frame,
		public override function update():void {
			// Le mouvement
			var dim:Point = vector.getDimensions();
			this.x += dim.x;
			this.y -= dim.y;
		}
	}
}
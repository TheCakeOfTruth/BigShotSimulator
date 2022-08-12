/*
	File Name: MovementVector.as
	Programmeur: William Mallette
	Date: 30-10-2021
	Description: Des vecteurs, bonne chance que j'ai pris physique l'année passée!
*/

package scripts.utils {
	import flash.geom.Point;
	
	public class MovementVector {
		private var magnitude:Number;
		private var angle:Number;
		
		// constructor
		public function MovementVector(a:Number=0, m:Number=0) {
			// Définir l'angle et le magnitude
			setAngle(a);
			setMagnitude(m);
		}
		
		// Plusieurs fonctions qui changent ou retournent des variables privés
		
		public function setAngle(n:Number):void {angle = n % 360;}
		
		public function getAngle():Number {return angle;}
		
		public function setMagnitude(n:Number):void {magnitude = n;}
		
		public function getMagnitude():Number {return magnitude;}
		
		// Convertir le vecteur en ses composants et retournent en forme de Point
		public function getDimensions():Point {
			var pt:Point = new Point();
			// Les merveilles de la trigonométrie
			pt.x = BetterRound(magnitude * Math.cos(angle * Math.PI/180), 2);
			pt.y = BetterRound(magnitude * Math.sin(angle * Math.PI/180), 2);
			return pt;
		}
		
		// Ajouter deux vecteurs ensemble (overwrite le vecteur de base)
		public function add(v:MovementVector):void {
			// Prendre les composants des deux vecteurs et combine-les
			var newpt:Point = getDimensions().add(v.getDimensions());
			// Utilise pythagore pour calculer la nouvelle magnitude
			setMagnitude(BetterRound(Math.sqrt(Math.pow(newpt.x, 2) + Math.pow(newpt.y, 2)), 2));
			// Utilise la loi du tangent inverse pour calculer le nouvel angle
			// (éviter une division par 0 en ajoutant un décimal insignificant au valeur horizontal)
			setAngle(BetterRound(Math.atan(newpt.y / (newpt.x + 1e-5)) * 180/Math.PI, 2));
			// La loi du tan inverse ne fonctionne pas bien avec les angles des quadrants 2 et 3.
			// Donc si la valeur horizontal est négatif, ajoute 180 degrés à l'angle.
			if (newpt.x < 0) {setAngle(getAngle() + 180);}
		}
		
		// Effectuer les mêmes calculs que MovementVector.add, mais utilise les dimensions pour créer un nouvel vecteur
		// static pour qu'on puisse créer ces vecteurs de n'importe quel fichier
		public static function getVectorFromDimensions(x:Number, y:Number):MovementVector {
			var a:Number = Math.atan(y / (x + 1e-5)) * 180/Math.PI;
			if (x < 0) {a += 180;}
			var m:Number = Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2));
			return new MovementVector(a, m);
		}
	}
}
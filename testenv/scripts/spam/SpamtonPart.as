/*
	File Name: SpamtonPart.as
	Programmeur: William Mallette
	Date: 14-11-2021
	Description: Les parties de l'ennemi
*/

package scripts.spam {
	import flash.display.MovieClip;
	import flash.events.Event;
	import scripts.utils.Wait;
	import scripts.utils.RepeatUntil;
	import scripts.utils.GlobalListener;
	import scripts.utils.RandomRange;
	
	public class SpamtonPart extends MovieClip {
		public var enableRotation:Boolean = true;
		public var minRotation:Number = 0;
		public var maxRotation:Number = 0;
		public var rotSpeed:Number = 0.0625;
		public var offset:Number = 0;
		
		private var timer:Number = 0;
		private var eventID:String;
		
		// constructor
		public function SpamtonPart() {
			eventID = "SpamtonPart-" + String(Math.random());
			GlobalListener.addEvent(update, eventID);
		}
		
		// changements à chaque frame
		private function update():void {
			if (enableRotation) {
				timer = (timer + 1) % ((2 * Math.PI) / rotSpeed);
				// Changer la rotation de l'objet selon les paramètres inscrits
				this.rotation = 0.5 * (maxRotation - minRotation) * (Math.sin(rotSpeed * timer + offset)) + 0.5 * (maxRotation + minRotation);
			}
		}
		
		// Methode nette pour modifier chaque paramètre de rotation
		public function setRotValues(_min:Number = 0, _max:Number = 0, _speed:Number = 0, _offset:Number = 0):void {
			minRotation = _min;
			maxRotation = _max;
			rotSpeed = _speed;
			offset = _offset;
		}
		
		// Effectuer une rotation jusqu'à un point désiré selon une piste désirée
		public function rotateTo(targetRot:Number, clockwise:Boolean = true, t:Number = 10):void {
			// Éviter qu'update empêche notre rotation
			enableRotation = false;
			
			// Calculer la différence entre les deux rotations
			var diff:Number = Math.abs(targetRot - rotation);
			
			// Utiliser un RepeatUntil pour changer la rotation juqu'au point désiré
			new RepeatUntil(function() {
				if (clockwise) {
					rotation += diff / t;
				} 
				else {
					rotation -= diff / t;
				}
			}, function() {
				if (rotation < targetRot + 5 && rotation > targetRot - 5) {
					return true;
				}
			})
		}
		
		// rotateTo mais ça calcule l'angle le plus petit et suit ce piste-la, utilisant un fonction qui donne la rotation une apparance plus organique
		public function rotateToSmart(targetRot:Number, t:Number = 10):void {
			// Garder des variables
			var r1:Number = rotation;
			var diff:Number = (targetRot % 360) - (rotation % 360);
			// Faire certain que le différence d'angles est le plus petit des deux possibilités
			// J'ai trouvé ceci ici: https://stackoverflow.com/questions/1878907/how-can-i-find-the-difference-between-two-angles
			diff = (diff + 180) % 360 - 180;
			
			// Changer la rotation selon un piste racinale pour (t) frames
			var rtimer:Number = 0;
			new RepeatUntil(function() {
				rtimer++
				// J'ai modelé des différents pistes possibles utilisant desmos: https://www.desmos.com/calculator/pffdzeypre
				rotation = diff * Math.sqrt(rtimer / t) + r1;
			}, function() {
				if (rtimer >= t) {rotation = targetRot; return true;}
			});
		}
		
		// Agiter le SpamtonPart
		public function shake(intensity:Number = 2) {
			// Générer deux nombres aléatoires
			var val_x:Number = RandomRange(-intensity, intensity);
			var val_y:Number = RandomRange(-intensity, intensity);
			// Déplacer le SpamtonPart par les valeurs générés
			this.getChildAt(0).x = val_x;
			this.getChildAt(0).y = val_y;
		}
		
		// Enlever l'eventListener
		public function destroy():void {
			GlobalListener.removeEvent(eventID);
		}
	}
}
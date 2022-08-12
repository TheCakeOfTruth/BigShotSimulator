/*
	File Name: HeartString.as
	Programmeur: William Mallette
	Date: 08-12-2021
	Description: Le coeur et sa corde pour HeartAttack
*/

package scripts.bullets {
	import flash.display.Sprite;
	import scripts.utils.Wait;
	import scripts.SoundLibrary;
	
	public class HeartString extends Sprite {
		private var balls:Array;
		
		// constructor
		public function HeartString() {
			balls = [ball1, ball2, ball3, ball4, ball5, ball6, ball7, ball8, ball9, ball10];
			heart.chain = this;
		}
		
		// Bouger le coeur et les balles en conséquence
		public function moveHeartTo(x:Number = 0, y:Number = 0):void {
			if (heart) {
				heart.x = x;
				heart.y = y;
			}
			// Positionner proportionnel au heart
			for (var ball in balls) {
				if (balls[ball]) {
					balls[ball].x = ball * x / 10;
					balls[ball].y = ball * y / 10;
				}
			}
		}
		
		// Shortcut pour un déplacement par rapport à la position courant
		public function moveHeart(x:Number = 0, y:Number = 0):void {
			moveHeartTo(heart.x + x, heart.y + y);
		}
		
		// Commencer la destruction
		public function destroy():void {
			heart.destroy();
			heart.chain = null;
			heart = null;
			SoundLibrary.play("bomb", 0.5);
			for (var i:int = 0; i < balls.length; i++) {new Wait(4 * (i + 1), destroyball);}
		}
		
		// Détruire la chaine jusqu'à temps qu'il n'y a rien qui reste
		private function destroyball():void {
			// Enlever le dernier balle de l'array
			removeChild(balls[balls.length - 1]);
			balls.splice(balls.length - 1, 1);
			// Jouer un son
			SoundLibrary.play("bomb", 0.5);
			
			// Endlever le HeartString quand tout est fini
			if (balls.length == 0) {
				balls = null;
				this.parent.removeChild(this);
			}
		}
	}
}
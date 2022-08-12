/*
	File Name: Bomb.as
	Programmeur: William Mallette
	Date: 02-11-2021
	Description: Une bombe qui se déclenche quand Shot
*/

package scripts.bullets {
	import flash.media.SoundTransform;
	import scripts.SoundLibrary;
	import scripts.Bullet;
	import scripts.EnemyWave;
	import scripts.utils.Input;

	public class Bomb extends Bullet {
		private var beenShot:Boolean = false;
	
		// constructor
		public function Bomb() {
			shootable = true;
			element = 6;
		}
		
		// Quand on frappe avec un Shot
		public override function onShot(shot):void {
			if (!beenShot) {explode();}
			beenShot = true;
		}
		
		// Jouer un son et l'animation d'explosion (voir les actions pour Bomb et BombBlast)
		private function explode():void {
			SoundLibrary.play("bombbeep", 0.5, 2);
			this.play();
		}
		
		// Créer les lignes de BombBlast
		private function createBeams():void {
			// Jouer un son et agiter l'écran
			SoundLibrary.play("bomb", 0.5);
			Main.screen.shakeScreen(3);
			// Créer 4 lignes
			for (var i:int = 0; i < 4; i++) {createBeam(i);}
		}
		
		// Créer une ligne de BombBlast
		private function createBeam(dir:int):void {
			for (var reps:int = 0; reps < 20; reps++) {
				// Créer un BombBlast
				var blastSegment:BombBlast = new BombBlast();
				// Rotation et positionner dépendant de la direction
				// L
				if (dir == 0) {
					blastSegment.rotation += 90;
					blastSegment.x = this.x - 5 - 24 * (reps + 1);
					blastSegment.y = this.y;
				}
				// U
				else if (dir == 1) {
					blastSegment.x = this.x;
					blastSegment.y = this.y - 5 - 24 * reps;
				}
				// R
				else if (dir == 2) {
					blastSegment.rotation -= 90;
					blastSegment.x = this.x + 5 + 24 * (reps + 1);
					blastSegment.y = this.y;
				}
				// D
				else if (dir == 3) {
					blastSegment.rotation = 180;
					blastSegment.x = this.x;
					blastSegment.y = this.y + 5 + 24 * reps;
				}
				// Ajouter à l'écran
				this.parent.addChild(blastSegment);
				EnemyWave.currentWave.addBullet(blastSegment, false);
			}
		}
	}
}
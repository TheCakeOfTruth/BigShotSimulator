/*
	File Name: FlyingHeads.as
	Programmeur: William Mallette
	Date: 28-11-2021
	Description: Le premier attaque
*/

package scripts.attacks {
	import scripts.EnemyWave;
	import scripts.bullets.FlyingHead;
	import scripts.utils.Wait;
	
	public class FlyingHeads extends EnemyWave {
		private var heads:Array = [];
		
		// constructor
		public function FlyingHeads() {
			// Établir les paramètres du wave
			waveTimer = 8600;
			arenaConfig = {x: 301, y: 171, width: 240, height: 112};
			// Après un délai, commence les headVolleys
			new Wait(20, headVolley);
			new Wait(120, headVolley);
			new Wait(240, headVolley);
			new Wait(360, headVolley);
		}
		
		// Créer quatre FlyingHead
		private function headVolley():void {
			// Choisir un row aléatoire
			var headrow:int = Math.floor(Math.random() * 3);
			
			// Créer les quatre FlyingHead
			for (var i:int = 0; i < 4; i++) {
				new Wait(i * 8, function() {if (waveTimer > 0) {createHead(700 + i * 20, arena.y + 40 * (headrow - 1));}});
			}
		}
		
		// À chaque frame
		public override function update():void {
			for each (var b:FlyingHead in heads) {
				// Faire qu'on peut seulement détruire le FlyingHead s'il est sur l'écran
				if (b.x > 640) {b.shootable = false;}
				else {b.shootable = true;}
				
				// Bouger chaque FlyingHead avec une vitesse variable
				var xvel:Number = 2 * (-Math.cos(((Math.PI * b.x) / 320) + 320 * Math.PI) - 2.5);
				b.x += xvel;
			}
			b = null;
		}
		
		// Nettoyer les objets
		public override function cleanup(transition:Boolean):void {heads = null;}
		
		// Créer un FlyingHead avec les paramètres désirés
		private function createHead(x:Number = 700, y:Number = 170):void {
			// Créer, positionner, arrêter l'animation, et stocker
			var head:FlyingHead = new FlyingHead();
			head.x = x;
			head.y = y;
			head.stop();
			addBullet(head);
			heads.push(head);
			// Après un moment, joue l'animation du FlyingHead (il y a du code dans l'animation qui gère les HeadPellets)
			new Wait(65, head.play);
		}
	}
}
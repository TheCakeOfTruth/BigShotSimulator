/*
	File Name: EnemyWave.as
	Programmeur: William Mallette
	Date: 26-11-2021
	Description: Classe de base pour les attaques de l'ennemi
*/

package scripts {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.getTimer;
	import scripts.utils.Wait;
	import scripts.utils.RepeatUntil;
	import scripts.utils.MovementVector;
	import scripts.utils.GlobalListener;
	import scripts.utils.Input;
	import scripts.Arena;
	import scripts.Bullet;
	import scripts.Player;
	import scripts.Kris;

	public class EnemyWave extends Sprite {
		public static var currentWave:EnemyWave;
		
		public var arenaConfig:Object = {x: 320, y: 200, width: 100, height: 100};
		public var playerPosition:Array;
		public var timer:int = 0;
		public var waveTimer:Number = 5000;
		public var arena:Arena;
		public var player:Player;
		public var bullets:Array = [];
		
		private var lastTime:Number;
		private var eventID:String;
		
		// constructor
		public function EnemyWave() {
			currentWave = this;
			// Commencer le timer, ajouter l'eventListener
			lastTime = getTimer();
			eventID = "EnemyWave-" + String(Math.random());
			// Un délai avant le setup (pour que le constructor des classes hérités peuvent affecter ce qui arrive)
			new Wait(1, function() {setupArena(); setupPlayer(); GlobalListener.addEvent(updateWave, eventID);});
		}
		
		// À chaque frame
		private function updateWave():void {
			timer++;
			// Réduire waveTimer
			waveTimer -= getTimer() - lastTime;
			lastTime = getTimer();
			// Réduire waveTimer encore plus si on graze
			if (player.grazingBullets.length > 0) {waveTimer--;}
			// Terminer le wave quand waveTimer est 0
			if (waveTimer <= 0) {endWave();}
			// Fonctionalité héritable
			update();
		}
		
		// Terminer le wave
		public function endWave(transition:Boolean = true):void {
			// Détruire chaque Bullet
			for each (var waveBullet:Bullet in bullets) {
				if (waveBullet.exists) {
					waveBullet.destroy();
				}
			}
			waveBullet = null;
			bullets = null;
			
			// Enlever l'objet, l'eventListener, et effectuer n'importe quel fonction spécifique d'un wave (cleanup())
			if (this.parent) {this.parent.removeChild(this);}
			GlobalListener.removeEvent(eventID);
			cleanup(transition);
			currentWave = null;
			
			if (transition) {
				// Animer et enlever le Player et l'Arena
				var returnVector:MovementVector = MovementVector.getVectorFromDimensions(Kris.instance.x + 25 - player.x, Kris.instance.y - 25 - player.y);
				returnVector.setMagnitude(returnVector.getMagnitude() / 10);
				var returnDim:Point = returnVector.getDimensions();
				if (player) {
					new RepeatUntil(function() {player.move(returnDim.x, returnDim.y);}, function() {
						if (player.x <= Kris.instance.x + 25) {
							Main.screen.removeChild(player); 
							player = null;
							return true;
						}
					});
				}
				
				if (arena) {
					new RepeatUntil(function() {
						arena.scaleX -= 0.05;
						arena.scaleY -= 0.05;
						arena.rotation -= 9;
					}, function() {if (arena.scaleX <= 0) {
						Main.screen.removeChild(arena);
						arena = null;
						return true;
					}});
				}
			}
			else {
				// Enlever le Player et l'Arena sans d'animation
				Main.screen.removeChild(player);
				player = null;
				
				Main.screen.removeChild(arena);
				arena = null;
			}
			
			// Retourne à selectingButton
			Main.setState("selectingButton");
		}
		
		// Fonction vide, pour être utilisé comme 'override'
		public function update():void {}
		
		// Fonction vide, pour être utilisé comme 'override'
		public function cleanup(transition:Boolean):void {}
		
		// Positionner, redimensionner, et animer l'Arena
		private function setupArena():void {
			arena = new Arena();
			arena.x = arenaConfig.x;
			arena.y = arenaConfig.y;
			arena.setSize(arenaConfig.width, arenaConfig.height);
			Main.screen.addChildAt(arena, Main.screen.getChildIndex(this));
			
			arena.scaleX = 0;
			arena.scaleY = 0;
			new RepeatUntil(function() {
				arena.scaleX += 0.05;
				arena.scaleY += 0.05;
				arena.rotation += 9;
			}, function() {if (arena.scaleX >= 1) {
				arena.scaleX = 1;
				arena.scaleY = 1;
				arena.rotation = 0;
				return true;
			}})
		}
		
		// Créer et animer le Player
		private function setupPlayer():void {
			// Utiliser le position de l'Arena par défaut
			var targetpos:Array;
			if (playerPosition == null) {targetpos = [arenaConfig.x, arenaConfig.y];}
			else {targetpos = playerPosition;}
			
			// Commencer à Kris
			player = new Player();
			player.moveTo(Kris.instance.x + 25, Kris.instance.y - 25);
			// Disable l'input pendant l'animation
			player.takeInput = false;
			Main.screen.addChildAt(player, Main.screen.getChildIndex(this) + 1);
			
			// Un vecteur entre le Player et sa position final
			var path:MovementVector = MovementVector.getVectorFromDimensions(targetpos[0] - player.x, targetpos[1] - player.y);
			// Comme ceci, il devrait prendre 15 frames pour arriver
			path.setMagnitude(path.getMagnitude() / 15);
			var dim:Point = path.getDimensions();
			
			// Bouger le Player vers sa position final jusqu'à temps qu'il arrive
			new RepeatUntil(function() {player.move(dim.x, dim.y);}, function() {if (player.x >= targetpos[0]) {
				player.takeInput = true;
				player.moveTo(targetpos[0], targetpos[1]);
				return true;
			}});
		}
		
		// Ajouter un Bullet à l'array
		public function addBullet(newBullet:Bullet, addToScreen:Boolean = true):void {
			bullets.push(newBullet);
			if (addToScreen) {addChild(newBullet);}
		}
	}
}
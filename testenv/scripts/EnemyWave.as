/*
	Date: 26-11-2021
	Description: Base class for waves
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
		
		// Constructor
		public function EnemyWave() {
			currentWave = this;
			// Start the timer & add eventListener
			lastTime = getTimer();
			eventID = "EnemyWave-" + String(Math.random());
			// Small delay to let everything work its magic
			new Wait(1, function() {setupArena(); setupPlayer(); GlobalListener.addEvent(updateWave, eventID);});
		}
		
		// Every frame
		private function updateWave():void {
			timer++;
			// Reduce waveTimer
			waveTimer -= getTimer() - lastTime;
			lastTime = getTimer();
			// Reduce waveTimer more if grazing
			if (player.grazingBullets.length > 0) {waveTimer--;}
			// End the wave when waveTimer is 0
			if (waveTimer <= 0) {endWave();}
			// Inherited functionality
			update();
		}
		
		// End the wave
		public function endWave(transition:Boolean = true):void {
			// Destroy all Bullets
			for each (var waveBullet:Bullet in bullets) {
				if (waveBullet.exists) {
					waveBullet.destroy();
				}
			}
			waveBullet = null;
			bullets = null;
			
			// Remove the object
			if (this.parent) {this.parent.removeChild(this);}
			GlobalListener.removeEvent(eventID);
			cleanup(transition);
			currentWave = null;
			
			if (transition) {
				// Animate the removal of the Player and Arena
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
				// Removes Player and Arena without transition animations
				Main.screen.removeChild(player);
				player = null;
				
				Main.screen.removeChild(arena);
				arena = null;
			}
			
			// Return to selectingButton
			Main.setState("selectingButton");
		}
		
		// Override function for frame-by-frame action
		public function update():void {}
		
		// Override function for clearing the wave
		public function cleanup(transition:Boolean):void {}
		
		// Position, resize, and animate the arena
		private function setupArena():void {
			arena = new Arena();
			arena.x = arenaConfig.x;
			arena.y = arenaConfig.y;
			arena.setSize(arenaConfig.width, arenaConfig.height);
			
			var rot:Number = 0;
			if (arenaConfig.rotation != null) {rot = arenaConfig.rotation;}
			arena.rotation = rot;
			
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
				arena.rotation = rot;
				return true;
			}})
		}
		
		// Create and animate the player
		private function setupPlayer():void {
			// Use Arena position by default
			var targetpos:Array;
			if (playerPosition == null) {targetpos = [arenaConfig.x, arenaConfig.y];}
			else {targetpos = playerPosition;}
			
			// Start at Kris
			player = new Player();
			player.moveTo(Kris.instance.x + 25, Kris.instance.y - 25);
			// Disable inputs during animation
			player.takeInput = false;
			Main.screen.addChildAt(player, Main.screen.getChildIndex(this) + 1);
			
			// Use a vector to move the player
			var path:MovementVector = MovementVector.getVectorFromDimensions(targetpos[0] - player.x, targetpos[1] - player.y);
			// It'll take 15 frames to reach the position
			path.setMagnitude(path.getMagnitude() / 15);
			var dim:Point = path.getDimensions();
			
			// Move the player until they arrive
			new RepeatUntil(function() {player.move(dim.x, dim.y);}, function() {if (player.x >= targetpos[0]) {
				player.takeInput = true;
				player.moveTo(targetpos[0], targetpos[1]);
				return true;
			}});
		}
		
		// Add a bullet to the array
		public function addBullet(newBullet:Bullet, addToScreen:Boolean = true):void {
			bullets.push(newBullet);
			if (addToScreen) {addChild(newBullet);}
		}
	}
}
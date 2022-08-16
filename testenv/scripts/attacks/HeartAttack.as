/*
	Date: 08-12-2021
	Description: The HeartAttack
*/

package scripts.attacks {
	import flash.geom.Point;
	import scripts.EnemyWave;
	import scripts.bullets.HeartString;
	import scripts.bullets.DiamondAttack;
	import scripts.spam.Spamton;
	import scripts.utils.MovementVector;
	import scripts.utils.Wait;
	
	public class HeartAttack extends EnemyWave {
		private var heart:HeartString;
		private var pos1:Point;
		private var pos2:Point;
		private var motionTimer:Number = 0;
		private var firing:Boolean = false;
		private var ending:Boolean = false;
		
		// Constructor
		public function HeartAttack() {
			waveTimer = 50000;
			arenaConfig = {x: 246, y: 171, width: 150, height: 150};
			
			// Make the HeartString
			heart = new HeartString();
			heart.x = 500;
			heart.y = 165;
			this.addChild(heart);
			addBullet(heart.heart, false);
			new Wait(10, setTarget);
		}
		
		// pos1 and pos2 handle movement
		private function setTarget():void {
			// Calculate a random pos2
			var targetpos:Point = heart.globalToLocal(new Point((arena.x + arena.width / 2) + 25 + 10 * Math.random() + 5, arena.y + 120 * Math.random() - 60));
			
			// Get the positions of everything
			var x1:Number = heart.heart.x;
			var x2:Number = targetpos.x;
			var y1:Number = heart.heart.y;
			var y2:Number = targetpos.y;
			
			// Update positions
			pos1 = new Point(x1, y1);
			pos2 = new Point(x2, y2);
			
			// Reset some values
			motionTimer = 0;
			firing = false;
		}
		
		// Every frame
		public override function update():void {
			if (heart.heart && pos1 && pos2) {
				// At roughly the "peak" of the sine function that handles the heart
				if (heart.heart.x < (pos2.x + 2) && heart.heart.x > (pos2.x - 2)) {
					// Fire diamonds!
					if (!firing) {
						firing = true;
						diamondVolley();
					}
					// Slow down movement a little here
					motionTimer += 0.9;
				}
				// On return, set a new target
				else if (heart.heart.x < 10 && heart.heart.x > -2 && motionTimer > 10) {
					setTarget();
				}
				// Normally, move ahead at normal speed
				else {
					motionTimer++;
				}
				
				// Move the NeoHeart along that sine function built from pos1 and pos2
				var newX:Number = -((pos2.x - pos1.x) / 2) * Math.cos(motionTimer / 15) + ((pos2.x - pos1.x) / 2) + pos1.x;
				var newY:Number = -((pos2.y - pos1.y) / 2) * Math.cos(motionTimer / 15) + ((pos2.y - pos1.y) / 2) + pos1.y;
				heart.moveHeartTo(newX, newY);
			}
			// Finish the attack when the heart is destroyed
			else if (!heart.heart && !ending) {
				ending = true;
				new Wait(70, function() {waveTimer = 0;})
			}
		}
		
		// Make groups of diamonds
		private function diamondVolley():void {
			// 3 'waves'
			for (var i:int = 0; i < 3; i++) {
				// 5 lines of diamonds
				new Wait(15 * i, function() {createDiamond(100);});
				new Wait(15 * i, function() {createDiamond(140);});
				new Wait(15 * i, function() {createDiamond(220);});
				new Wait(15 * i, function() {createDiamond(260);});
				new Wait(15 * i, function() {createDiamond(180);});
			}
		}
		
		// Making of one diamonde
		private function createDiamond(rotation:Number):void {
			if (heart.heart) {
				// At the position of the NeoHeart, make a DiamondAttack with a specified rotation
				var heartPos:Point = heart.localToGlobal(new Point(heart.heart.x, heart.heart.y));
				var diamond:DiamondAttack = new DiamondAttack(rotation);
				diamond.x = heartPos.x;
				diamond.y = heartPos.y;
				this.addChildAt(diamond, getChildIndex(heart));
				addBullet(diamond, false);
			}
		}
	}
}
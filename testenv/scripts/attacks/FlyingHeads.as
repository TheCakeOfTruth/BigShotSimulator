/*
	Date: 28-11-2021
	Description: First attack with the three rows of heads flying in
*/

package scripts.attacks {
	import scripts.EnemyWave;
	import scripts.bullets.FlyingHead;
	import scripts.utils.Wait;
	
	public class FlyingHeads extends EnemyWave {
		private var heads:Array = [];
		
		// Constructor
		public function FlyingHeads() {
			// Parameters
			waveTimer = 8600;
			arenaConfig = {x: 301, y: 171, width: 240, height: 112};
			// Wait a bit and start sending in volleys of heads
			new Wait(20, headVolley);
			new Wait(120, headVolley);
			new Wait(240, headVolley);
			new Wait(360, headVolley);
		}
		
		// Makes four FlyingHeads
		private function headVolley():void {
			// Pick a random row
			var headrow:int = Math.floor(Math.random() * 3);
			
			// Make the FlyingHeads
			for (var i:int = 0; i < 4; i++) {
				new Wait(i * 8, function() {if (waveTimer > 0) {createHead(700 + i * 20, arena.y + 40 * (headrow - 1));}});
			}
		}
		
		// Every frame
		public override function update():void {
			for each (var b:FlyingHead in heads) {
				// Only shoot the head if it's on-screen
				if (b.x > 640) {b.shootable = false;}
				else {b.shootable = true;}
				
				// Move the heads with varying speed
				var xvel:Number = 2 * (-Math.cos(((Math.PI * b.x) / 320) + 320 * Math.PI) - 2.5);
				b.x += xvel;
			}
			b = null;
		}
		
		// Make sure the objects can be properly removed
		public override function cleanup(transition:Boolean):void {heads = null;}
		
		// Make a FlyingHead with the right parameters
		private function createHead(x:Number = 700, y:Number = 170):void {
			// Create, position, stop, and store the head
			var head:FlyingHead = new FlyingHead();
			head.x = x;
			head.y = y;
			head.stop();
			addBullet(head);
			heads.push(head);
			// Wait a bit, and play the animation (there's code in the animation that launches the pellets)
			new Wait(65, head.play);
		}
	}
}
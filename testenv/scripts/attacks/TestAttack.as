/*
	Date: 24-08-2022
	Description: Blank attack for testing stuff
*/

package scripts.attacks {
	import scripts.EnemyWave;
	import scripts.utils.Wait;
	import scripts.utils.Input;
	import scripts.bullets.*;
	
	public class TestAttack extends EnemyWave {
		// Constructor
		public function TestAttack():void {
			// Parameters
			waveTimer = int.MAX_VALUE;
			arenaConfig = {x: 301, y: 171, width: 240, height: 112};
			
			Input.addEvent(67, function() {waveTimer = 0;}, "endTest");
			
			var b = new FlyingHead();
			b.willShoot = false;
			b.stop();
			b.destroyOnHit = false;
			b.x = 380;
			b.y = 171;
			this.addChild(b);
		}
		
		// Every frame
		public override function update():void {
			
		}
		
		// Make sure the objects can be properly removed
		public override function cleanup(transition:Boolean):void {
			Input.removeEvent(67, "endTest");
		}
	}
}
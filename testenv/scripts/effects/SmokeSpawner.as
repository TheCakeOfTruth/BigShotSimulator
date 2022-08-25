/*
	Date: 25-08-2022
	Description: Spawns smoke particles
*/

package scripts.effects {
	import flash.display.MovieClip;
	import flash.events.Event;
	import scripts.utils.GlobalListener;
	
	public class SmokeSpawner extends MovieClip {
		private var timer:int = 0;
		
		// Constructor
		public function SmokeSpawner() {
			GlobalListener.addEvent(update, "updateSmokeSpawner");
			addEventListener(Event.REMOVED_FROM_STAGE, cleanup);
		}
		
		// Every frame
		private function update():void {
			timer++;
			// Summon smoke every 3 frames
			if (timer % 3 == 0) {
				addChild(new CarSmoke());
			}
		}
		
		// Cleans everything up nicely
		private function cleanup(e:Event):void {
			GlobalListener.removeEvent("updateSmokeSpawner");
			removeEventListener(Event.REMOVED_FROM_STAGE, cleanup);
		}
	}
}
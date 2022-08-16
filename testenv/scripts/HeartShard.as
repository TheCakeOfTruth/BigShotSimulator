/*
	Date: 05-01-2022
	Description: The shards from the death anim
*/

package scripts {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import scripts.utils.MovementVector;
	import scripts.utils.RandomRange;
	
	public class HeartShard extends MovieClip {
		private var timer:int = 0;
		private var vector:MovementVector;
		
		// Constructor
		public function HeartShard() {
			vector = new MovementVector(RandomRange(0, 360), RandomRange(3, 5));
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		// Every frame
		private function update(e:Event):void {
			// Fade out after a while
			timer++;
			if (timer > 60 && this.alpha > 0) {this.alpha -= 0.025;}
		
			// Gravity
			vector.add(new MovementVector(270, 0.098));
			
			// Movement
			var dim:Point = vector.getDimensions();
			this.x += dim.x;
			this.y -= dim.y;
			
			// Destruction
			if (this.y > 490) {destroy();}
		}
		
		// Destruction
		private function destroy():void {
			removeEventListener(Event.ENTER_FRAME, update);
			this.parent.removeChild(this);
		}
	}
}
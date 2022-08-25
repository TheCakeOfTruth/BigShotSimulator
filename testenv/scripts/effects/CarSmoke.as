/*
	Date: 25-08-2022
	Description: Smoke particle
*/

package scripts.effects {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import scripts.utils.MovementVector;
	import scripts.utils.RandomRange;
	import scripts.utils.GlobalListener;
	
	public class CarSmoke extends MovieClip {
		private var eventID:String;
		private var timer:int = 0;
		private var vector:MovementVector;
		private var scale:Number;
		private var scaleRate:Number;
	
		// Constructor
		public function CarSmoke() {
			// Setup
			// alpha = 0.75
			vector = new MovementVector(RandomRange(20, 95), RandomRange(1, 6));
			scale = RandomRange(0.5, 2);
			scaleRate = RandomRange(0.02, 0.06);
			scaleX = scale;
			scaleY = scale;
			
			// eventListeners
			eventID = "CarSmoke-" + String(Math.random());
			GlobalListener.addEvent(update, eventID);
			addEventListener(Event.REMOVED_FROM_STAGE, cleanup);
		}
		
		// Every frame
		private function update():void {
			timer++;
			
			// Upscale
			scaleX += scaleRate;
			scaleY += scaleRate;
			
			// Move
			var dim:Point = vector.getDimensions();
			x += dim.x;
			y -= dim.y;
			
			// Fade
			if (timer > 20) {
				if (alpha > 0) {
					alpha -= 0.025;
				}
				else {
					parent.removeChild(this);
				}
			}
		}
		
		// Cleans everything up nicely
		private function cleanup(e:Event):void {
			GlobalListener.removeEvent(eventID);
			removeEventListener(Event.REMOVED_FROM_STAGE, cleanup);
		}
	}
}
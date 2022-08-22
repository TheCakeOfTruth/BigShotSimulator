/*
	Date: 21-08-2022
	Description: The dark fountain
*/

package scripts.effects {
	import flash.display.MovieClip;
	import flash.geom.Point;
	import scripts.utils.GlobalListener;
	import scripts.utils.BetterRound;
	
	public class DarkFountain extends MovieClip {
		private var timer:int = 0;
		private var frontQs:Array;
		private var backQs:Array;
		
		// Constructor
		public function DarkFountain():void {
			GlobalListener.addEvent(update, "UpdateFountain");
			frontQs = [IntFront.Q1, IntFront.Q2, IntFront.Q3, IntFront.Q4, IntFront.Q5, IntFront.Q6];
			backQs = [IntBack.Q1, IntBack.Q2, IntBack.Q3, IntBack.Q4, IntBack.Q5, IntBack.Q6];
		}
		
		// Every frame
		private function update():void {
			timer++;
			
			// Edges
			edges.L2.x = -41.5 - (-6.6 * Math.cos(timer/45));
			edges.R2.x = 42 + (-6.6 * Math.cos(timer/45));
			
			edges.L3.x = -41.5 - (6.6 * Math.cos(timer/45));
			edges.R3.x = 42 + (6.6 * Math.cos(timer/45));
			
			if (edges.y > -210) {edges.y -= 0.25;}
			else {edges.y = 46;}
			
			// Edges2
			edges2.L2.x = -41.5 - (-6.6 * Math.cos(timer/45));
			edges2.R2.x = 42 + (-6.6 * Math.cos(timer/45));
			
			edges2.L3.x = -41.5 - (6.6 * Math.cos(timer/45));
			edges2.R3.x = 42 + (6.6 * Math.cos(timer/45));
			
			if (edges2.y > -210) {edges2.y -= 0.25;}
			else {edges2.y = 46;}
			
			// Front background
			IntFront.x -= 0.1;
			IntFront.y -= 0.2;
			for each (var q:MovieClip in frontQs) {
				var globalCoords:Point = q.localToGlobal(new Point(0,0));
				if (globalCoords.x <= 120) {q.x += 240;}
				if (globalCoords.y <= -120) {q.y += 360;}
			}
			
			// Back background
			IntBack.x += 0.1;
			IntBack.y += 0.2;
			for each (var q2:MovieClip in backQs) {
				var globalCoords2:Point = q2.localToGlobal(new Point(0,0));
				if (globalCoords2.x >= 530) {q2.x -= 240;}
				if (globalCoords2.y >= 375) {q2.y -= 360;}
			}
			
			trace(IntFront.width + " " + IntFront.height);
		}
	}
}
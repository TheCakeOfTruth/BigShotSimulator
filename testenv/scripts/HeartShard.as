/*
	File Name: HeartShard.as
	Programmeur: William Mallette
	Date: 05-01-2022
	Description: Les petits "shards" du coeur quand on meurt
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
		
		// constructor
		public function HeartShard() {
			vector = new MovementVector(RandomRange(0, 360), RandomRange(3, 5));
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		// À chaque frame
		private function update(e:Event):void {
			// Fade après du temps
			timer++;
			if (timer > 60 && this.alpha > 0) {this.alpha -= 0.025;}
		
			// La gravité
			vector.add(new MovementVector(270, 0.098));
			
			// Le mouvement
			var dim:Point = vector.getDimensions();
			this.x += dim.x;
			this.y -= dim.y;
			
			// Détruire l'objet
			if (this.y > 490) {destroy();}
		}
		
		// Détruire l'objet
		private function destroy():void {
			removeEventListener(Event.ENTER_FRAME, update);
			this.parent.removeChild(this);
		}
	}
}
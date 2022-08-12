/*
	File Name: RepeatUntil.as
	Programmeur: William Mallette
	Date: 20-11-2021
	Description: Essentiellement "do while" mais à chaque frame au lieu de le faire dans un frame
*/

package scripts.utils {
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class RepeatUntil extends Sprite {
		public static var queue:Array = [];
		private var action:Function;
		private var endCondition:Function;
		private var arrayIndex:uint;
		
		// constructor
		public function RepeatUntil(func:Function, end:Function) {
			// Stocker les méthodes
			action = func;
			endCondition = end;
			
			// Ajouter à l'array et créer un eventListener
			arrayIndex = queue.push(this) - 1;
			this.addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		}
		
		// update
		private function update(e:Event):void {
			// Exécute action à chaque frame jusqu'à temps que endCondition return true
			if (endCondition.call() != true) {action.call();}
			// Supprimer l'objet RepeatUntil lorsqu'elle est terminée
			else {removeFromQueue();}
		}
		
		// Supprimer l'objet
		private function removeFromQueue():void {
			removeEventListener(Event.ENTER_FRAME, update);
			for each (var obj:RepeatUntil in queue) {
				if (obj.arrayIndex > arrayIndex) {obj.arrayIndex--;}
			}
			obj = null;
			queue.splice(arrayIndex, 1);
		}
		
		public function _removeEventListener():void {
			removeEventListener(Event.ENTER_FRAME, update);
		}
		
		public static function clearQueue():void {
			for each (var repeatobj:RepeatUntil in queue) {
				repeatobj._removeEventListener();
			}
			repeatobj = null;
			queue = [];
		}
	}
}
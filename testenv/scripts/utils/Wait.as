/*  
	Nom du fichier: Wait.as
	Programmeur: William Mallette
	Date: 09/11/2021
	Description: exécuter une fonction après un montant de temps spécifié
*/

package scripts.utils {
	import flash.display.Sprite;
	import flash.events.Event;
	
	// J'ai utilisé quelque chose similaire dans le passé pour des projets personnels (et peut-être en ICS3U), c'est un outil très utile que j'utiliserais probablement beaucoup dans ce cours aussi.
	public class Wait extends Sprite {
		// Un array global qui garde les objets Wait
		public static var waitArray:Array = [];
	
		// un montant de temps (en frames)
		private var _time:int;
		// une fonction à exécuter
		private var func:Function;
		// L'index dans l'array
		private var array_index:int;
		
		public function Wait(t:int, action:Function) {
			// Garder les paramètres
			_time = t;
			func = action;
			// updateTimer à chaque frame
			addEventListener(Event.ENTER_FRAME, updateTimer, false, 0, true);
			// Mettre l'objet dans l'Array et garder le position de l'objet dans l'Array
			array_index = waitArray.push(this) - 1;
		}
		
		private function updateTimer(e:Event):void {
			// Diminue _time jusqu'à 0
			if (_time > 0) {_time--;}
			// Exécute la fonction et enlève l'objet de l'Array
			else {func.call(); removeFromQueue();}
		}
		
		private function removeFromQueue():void {
			// Arrêter d'exécuter updateTimer
			removeEventListener(Event.ENTER_FRAME, updateTimer)
			for (var i in waitArray) {
				// Pour chaque autre objet Wait, si c'est après celui-ci, shift à la gauche par 1
				if (waitArray[i].array_index > array_index) {
					waitArray[i].array_index--;
				}
			}
			i = null;
			// Enlève l'objet de l'Array
			// S'il n'y a plus de références globales à l'objet, ça devrait ne plus exister
			waitArray.splice(array_index, 1);
		}
		
		// Enlever l'eventlistener indépendamment de removeFromQueue
		public function _removeEventListener():void {
			removeEventListener(Event.ENTER_FRAME, updateTimer);
		}
		
		// Vider waitArray
		public static function clearQueue():void {
			for each (var waitobj:Wait in waitArray) {
				waitobj._removeEventListener();
			}
			waitobj = null;
			waitArray = [];
		}
	}
}
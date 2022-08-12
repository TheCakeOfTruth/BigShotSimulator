/*
	File Name: GlobalListener.as
	Programmeur: William Mallette
	Date: 05-01-2022
	Description: Un EventListener pour ENTER_FRAME global pour (la plupart) des objets
	             Réutilise des parties de code de Input.as
*/

package scripts.utils {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	public class GlobalListener extends Sprite {
		public static var handler:GlobalListener;
		private static var eventDict:Dictionary = new Dictionary();
		// Celui-ci est pour le débogage et sert aucun utilité fonctionnel
		private static var eventKeys:Dictionary = new Dictionary();
	
		// constructor, faut seulement être exécuté un fois
		public function GlobalListener() {
			handler = this;
			startAll();
		}
		
		// À chaque frame
		private static function update(e:Event):void {
			// Exécuter chaque fonction dans eventDict
			for each (var func:Function in eventDict) {
				func.call();
			}
			func = null;
		}
		
		// Ajouter un event à eventDict
		public static function addEvent(event:Function, keyname:String):void {
			eventDict[keyname] = event;
			eventKeys[keyname] = keyname;
		}
		
		// Enlever un event de eventDict
		public static function removeEvent(keyname:String):void {
			delete eventDict[keyname];
			delete eventKeys[keyname];
		}
		
		// Enlever l'eventlistener et si spécifié, vider eventDict
		public static function stopAll(clear:Boolean = false):void {
			handler.removeEventListener(Event.ENTER_FRAME, update);
			if (clear) {clearEvents();}
		}
		
		// Vider eventDict
		public static function clearEvents():void {
			eventDict = new Dictionary();
			eventKeys = new Dictionary();
		}
		
		// Ajouter l'eventlistener
		public static function startAll():void {
			handler.addEventListener(Event.ENTER_FRAME, update);
		}
		
		// Trace chaque event actif
		public static function debugPrintAllEvents():void {
			for each (var eventkey:String in eventKeys) {
				trace(eventkey);
			}
			eventkey = null;
		}
	}
}
/*
	File Name: Input.as
	Programmeur: William Mallette
	Date: 17-11-2021
	Description: Une meilleure système d'input, utilisant la magie des Dictionary
*/

package scripts.utils {
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	
	/* Quelques keyCodes importants
		ARROW KEYS
		L: 37
		U: 38
		R: 39
		D: 40
		
		Z: 90
		X: 88
		C: 67
	*/
	
	public class Input extends Sprite {
		// Référence global pour garder l'objet actif
		public static var handler:Input;
		// Les dictionnaires! J'ai appris à propos de cette classe magnifique ici (le documentation d'actionscript):
		// https://help.adobe.com/en_US/as3/dev/WS5b3ccc516d4fbf351e63e3d118a9b90204-7eea.html
		// https://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/utils/Dictionary.html
		private static var keys:Dictionary = new Dictionary();
		private static var eventDict:Dictionary = new Dictionary();
	
		// constructor, faut seulement être exécuté au commencement du jeu
		public function Input() {
			handler = this;
			// Ajouter les eventListeners
			Main.screen.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown, false, 0, true);
			Main.screen.stage.addEventListener(KeyboardEvent.KEY_UP, keyUp, false, 0, true);
		}
		
		// KEY_DOWN
		private function keyDown(e:KeyboardEvent):void {
			// Effectuer un événement seulement si on ne touche pas déjà le clé
			// KeyboardEvent.KEY_DOWN s'effectue plusieurs fois quand on maintenez le clé enfoncé, qu'on veut pas
			// Vérifie aussi que le clé touché a un dictionnaire d'event associé.
			if (keys[e.keyCode] != true && eventDict[e.keyCode] is Dictionary) {
				// Pour chaque event dans le eventDict du clé, effectue la méthode stocké
				for each (var func:Function in eventDict[e.keyCode]) {
					func.call();
				}
				func = null;
			}
			// Marque le clé comme étant touché
			keys[e.keyCode] = true;
			
			// DEBUG
			//trace(e.keyCode);
		}
		
		// KEY_UP
		private function keyUp(e:KeyboardEvent):void {
			// Marque le clé comme n'étant pas touché
			keys[e.keyCode] = false;
		}
		
		// Retourne l'état du clé spécifié
		public static function getKey(code:int):Boolean {
			return keys[code];
		}
		
		// Ajouter un event au clé qui s'exécutera lorsque le clé est touché!
		public static function addEvent(code:int, event:Function, keyname:String):void {
			// Initier le dictionnaire d'événements pour le clé si besoin
			if (eventDict[code] == null) {eventDict[code] = new Dictionary();}
			// Ajouter la méthode désiré à la clé désiré
			eventDict[code][keyname] = event;
			
			// DEBUG
			//trace("Added event " + keyname + " to " + code);
		}
		
		// Enlever un événement spécifié du dictionnaire d'event d'un clé
		public static function removeEvent(code:int, keyname:String):void {
			if (eventDict[code] is Dictionary) {
				delete eventDict[code][keyname];
			}
			
			// DEBUG
			//trace("Removed event " + keyname + " from " + code);
		}
		
		// Efface tous les events
		public static function clearEvents():void {
			eventDict = new Dictionary();
		}
	}
}
/*
	File Name: MenuOption.as
	Programmeur: William Mallette
	Date: 18-11-2021
	Description: Les options de menu
*/

package scripts.ui {
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.text.TextFormat;
	import flash.events.Event;
	import flash.media.SoundTransform;
	import scripts.SoundLibrary;
	import scripts.utils.Input;
	import scripts.utils.Wait;
	
	public class MenuOption extends MovieClip {
		public var selected = false;
		public var TPCost:int = 0;
		public var effect:Function;
		public var description:String;
		public var icon:Bitmap;
		public var iconEnabled:Boolean = false;
		
		private var eventID:String;
		
		// constructor
		public function MenuOption(x:Number, y:Number, _text:String) {
			// Cacher le soul
			toggleSelection(false);
			// Créer un référence unique pour l'event (voir Input)
			eventID = "MenuOption-" + String(Math.random());
			// Fonction vide (à être rédéfini)
			effect = function() {};
			// Positionner
			this.x = x;
			this.y = y;
			// Format du texte
			var format:TextFormat = new TextFormat();
			format.letterSpacing = -2;
			txt.defaultTextFormat = format;
			txt.htmlText = _text;
			
			// Les eventListeners
			this.addEventListener(Event.ADDED_TO_STAGE, activateFunction, false, 0, true);
			this.addEventListener(Event.REMOVED_FROM_STAGE, deactivateFunction, false, 0, true);
		}
		
		// Permettre l'activation quand l'objet est sur le stage
		private function activateFunction(e:Event):void {
			// Changer le couleur du texte dépendant du coût de TP
			if (!checkAffordability()) {txt.textColor = 0x808080;}
			else {txt.textColor = 0xFFFFFF;}
			// Ajouter un event au clé Z
			new Wait(2, function() {Input.addEvent(90, selectOption, eventID);});
		}
		
		// Enlever l'event du clé Z
		private function deactivateFunction(e:Event):void {
			Input.removeEvent(90, eventID);
		}
		
		// Montrer/cacher le soul
		public function toggleSelection(bool:Boolean):void {
			soul.visible = bool;
		}
		
		// Vérifier si l'option est sélectionné et on a assez de TP, et jouer un son et effectuer la méthode stockée
		public function selectOption():void {
			if (this.parent != null && soul.visible == true && checkAffordability()) {
				SoundLibrary.play("menuselect", 0.5);
				effect.call();
			}
		}
		
		// Vérifier si on a assez de TP (en %)
		private function checkAffordability():Boolean {
			if (100 * TPMeter.instance.tp / 250 < TPCost) {return false;}
			else {return true;}
		}
		
		// Créer l'icone (img) et ajouter-la au MenuOption
		public function createIcon(img:BitmapData):void {
			iconEnabled = true;
			icon = new Bitmap(img);
			icon.x = txt.x;
			icon.y = txt.y + 8;
			this.addChild(icon);
		}
		
		// Détruire le MenuOption
		public function destroy():void {
			if (iconEnabled) {this.removeChild(icon); icon = null;}
			deactivateFunction(null);
			removeEventListener(Event.ADDED_TO_STAGE, activateFunction);
			removeEventListener(Event.REMOVED_FROM_STAGE, deactivateFunction);
			if (this.parent) {this.parent.removeChild(this);}
		}
	}
}
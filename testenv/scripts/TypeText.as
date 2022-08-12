/*
	File Name: TypeText.as
	Programmeur: William Mallette
	Date: 16-11-2021
	Description: Le controleur de base du texte
*/

package scripts {
	import flash.display.Sprite;
	import flash.events.Event;
	import scripts.utils.Input;
	import scripts.utils.Wait;
	import scripts.utils.XMLToDialogue;
	
	public class TypeText extends Sprite {
		private static var mutedChars:RegExp = /[*,.?!:;\[\]]/;
		private static var punctuation:RegExp = /[,.?!]/;
	
		private var txtpages:Array = [];
		private var pageindex:int = 0;
		private var charindex:int = 0;
		private var txtvoice:String;
		private var advancemode:String;
		private var avgDelay:int;
		private var func:Function;
		private var queuedSkip:Boolean = false;
		private var eventKey:String;
		
		public var fulltext:String;
		public var chararray:Array;
		public var onAdvance:Function;
		
		// constructor
		public function TypeText(txt = "", voice:String = "", advmode:String = "default", endfunc:Function = null, averageDelay:int = 1) {
			// commencer le text
			startText(txt, voice, advmode, endfunc, averageDelay);
		}
		
		// Vérifier les clés X et C pour leurs effets
		private function update(e:Event):void {
			if (Input.getKey(67) == true) {
				if (advancemode == "default") {
					skipText();
				}
			}
			else if (Input.getKey(88) == true) {finishText();}
		}
		
		// commencer le text (fonction séparée pour qu'on peut recommencer un objet qui est déjà initialisé
		public function startText(txt = "", voice:String = "", advmode:String = "default", endfunc:Function = null, averageDelay:int = 1):void {
			// reset txtpages
			txtpages = [];
			if (txt is String) {txtpages.push(txt);}
			else if (txt is XMLList) {txtpages = XMLToDialogue(txt);}
			else {txtpages = txt;}
			
			// Changer des variables nécessaires
			txtvoice = voice;
			advancemode = advmode;
			avgDelay = averageDelay;
			if (endfunc != null) {func = endfunc;}
			else {func = function() {};}
			
			// L'advancemode
			if (advancemode == "default") {
				eventKey = "TypeText-" + String(Math.random());
				Input.addEvent(90, tryAdvance, eventKey);
			}
			
			// Initialiser le premier page
			pageindex = 0;
			setupPage();
			
			// Ajouter l'eventListener
			this.addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		}
		
		// Si le texte est complèt, avancer d'une page
		private function tryAdvance():void {
			if (textfield.text.length == chararray.length) {
				pageindex++;
				setupPage();
				if (onAdvance is Function) {onAdvance.call();}
			}
		}
		
		// Initialiser une page de texte
		private function setupPage():void {	
			// S'il y a un autre page
			if (pageindex < txtpages.length) {
				// Reset le TextField et charindex
				textfield.text = "";
				charindex = 0;
				
				// Obtenir fulltext et chararray
				fulltext = txtpages[pageindex];
				chararray = fulltext.split("");
				
				// Commencer à ajouter les caractères
				addChar();
			}
			// Sinon, termine le texte.
			else {
				endText();
			}
		}
		
		// Terminer la ligne courant
		public function finishText():void {
			charindex = fulltext.length;
			textfield.text = fulltext;
		}
		
		// Avancer au prochain ligne de texte (presque) instamment, hold C pour skipper tout le texte
		private function skipText():void {
			if (!queuedSkip) {
				queuedSkip = true;
				finishText();
				new Wait(5, function() {queuedSkip = false; tryAdvance();});
			}
		}
		
		// Ajouter un caractère
		private function addChar():void {
			// Seulement si on est en dedans la longueur du fulltext
			if (charindex < fulltext.length) {
				// Obtenir le nouveau caractère et le prochain (loop au premier si nécessaire)
				var newchar:String = chararray[charindex];
				var nextchar:String = chararray[(charindex + 1) % chararray.length];
				
				// Jouer un son si les conditions sont bonnes
				if (txtvoice != "" && charindex % 2 == 0 && newchar.match(mutedChars) == null) {SoundLibrary.play(txtvoice, 0.5);}
				
				// Ajouter le nouveau caractère et changer charindex
				textfield.appendText(newchar);
				charindex++;
				
				// Calculer un délai et attendre avant ajouter un autre caractère (la ponctuation cause un délai supérieur, mais pas si le prochaine caractère est aussi de la ponctuation)
				var delay:int = avgDelay;
				if (newchar == " ") {delay = 0;}
				else if (newchar.match(punctuation) != null && nextchar.match(punctuation) == null) {delay = 10;}
				new Wait(delay, addChar);
			}
		}
		
		// Terminer le texte
		public function endText():void {
			Input.removeEvent(90, eventKey);
			this.removeEventListener(Event.ENTER_FRAME, update);
			
			// Exécuter la méthode stockée
			func.call();
		}
	}
}
/*  
	Nom du fichier: LocalizationHandler.as
	Programmeur: William Mallette
	Date: 24/12/2021
	Description: Utiliser de l'XML interne pour gérer du dialogue en différents languages
*/


package lang {
	import flash.utils.Dictionary;

	public class LocalizationHandler {
		public static var languages:Dictionary = new Dictionary();
		
		// constructor (exécuter un fois pour ouvrir les languages
		public function LocalizationHandler() {
			include "eng.as";
			include "fre.as";
		}
	}
}
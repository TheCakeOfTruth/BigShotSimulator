/*  
	Date: 24/12/2021
	Description: Uses internal XML files to handle dialogue in different languages
*/


package lang {
	import flash.utils.Dictionary;

	public class LocalizationHandler {
		public static var languages:Dictionary = new Dictionary();
		
		// Constructor (execute once at startup to setup the languages)
		public function LocalizationHandler() {
			include "eng.as";
			include "fre.as";
		}
	}
}
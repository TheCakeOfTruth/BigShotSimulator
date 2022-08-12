/*
	File Name: XMLToDialogue.as
	Programmeur: William Mallette
	Date: 15-12-2021
	Description: Prendre du XML d'un fichier de dialogue et convertir en dialogue valide
*/

package scripts.utils {
	// Convertir de l'XML en dialogue usable
	public function XMLToDialogue(xml:XMLList):Array {
		var array:Array = [];
		// Itérer pour l'XMLList donné
		for each (var item in xml) {
			// XML.toString() interprète des linebreaks (\n) comme étant ces caractères et non un linebreak, alors on doit convertir.
			var string:String = item.toString().replace(/\\n/g, "\n");
			// Ajoute à l'array
			array.push(string);
		}
		
		// Retourner l'array
		return array;
	}
}
/*
	Date: 15-12-2021
	Description: Takes localization XML and converts it to a useable dialogue array
*/

package scripts.utils {
	public function XMLToDialogue(xml:XMLList):Array {
		var array:Array = [];
		// Iterate through the given XMLList
		for each (var item in xml) {
			// XML.toString() interprets linebreaks (\n) as being separate characters and not a linebreak, so let's fix that
			var string:String = item.toString().replace(/\\n/g, "\n");
			// Add to the array
			array.push(string);
		}
		
		// Return the array
		return array;
	}
}
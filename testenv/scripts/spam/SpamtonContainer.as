/*
	Date: 25-08-2022
	Description: Contains Spamton NEO and accessories
*/

package scripts.spam {
	import flash.display.MovieClip;
	import flash.utils.Dictionary;
	
	public class SpamtonContainer extends MovieClip {
		public var children:Dictionary;
	
		// Constructor
		public function SpamtonContainer() {
			children = new Dictionary();
			children["spamton"] = spamton;
			spamton.container = this;
		}
	}
}
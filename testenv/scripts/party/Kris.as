/*
	Date: 12-11-2021
	Description: * It's what they call "You."
*/

package scripts.party {
	import flash.geom.ColorTransform;

	public class Kris extends PartyMember {
		public static var instance:Kris;
		
		// Constructor
		public function Kris() {
			instance = this;
			
			hp = 160;
			maxhp = 160;
			
			attack = 14;
			defense = 2;
			
			button2 = "act";
			
			startingIcon = "kris0";
			colors = {
				hpbar:		new ColorTransform(0, 1, 1),
				icon:		new ColorTransform(0, 162/255, 232/255),
				numbers:	new ColorTransform(128/255, 1, 1)
			}
		}
	}
}
/*
	Date: 12-11-2021
	Description: * It's what they call "You."
*/

package scripts.party {
	public class Kris extends PartyMember {
		public static var instance:Kris;
		
		// Constructor
		public function Kris() {
			instance = this;
			attack = 14;
			defense = 2;
		}
	}
}
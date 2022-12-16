/*
	Date: 15/12/22
	Description: [[ANGEL, ANGEL]]
*/

package scripts.party {
	public class Noelle extends PartyMember {
		public function Noelle(strong:Boolean=true) {
			attack = 3;
			defense = 1;
			magic = 11;
			if (strong) {
				anims.hurt += "strong";
				anims.defend += "strong";
			}
		}
	}
}
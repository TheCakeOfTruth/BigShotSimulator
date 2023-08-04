/*
	Date: 15/12/22
	Description: [[ANGEL, ANGEL]]
*/

package scripts.party {
	public class Noelle extends PartyMember {
		public var isStrong:Boolean = false;
	
		public function Noelle(strong:Boolean=true) {
			attack = 3;
			defense = 1;
			magic = 11;
			
			anims.item = "spell";
			
			colors = {
				hpbar:		{r: 255, g: 255, b: 0},
				icon:		{r: 255, g: 255, b: 0},
				numbers:	{r: 255, g: 255, b: 75}
			}
			
			isStrong = strong;
			if (strong) {
				anims.prefight = "spell";
				anims.fight = "spell";
				anims.hurt += "strong";
				anims.defend += "strong";
			}
		}
	}
}
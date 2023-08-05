/*
	Date: 15/12/22
	Description: [[ANGEL, ANGEL]]
*/

package scripts.party {
	import flash.geom.ColorTransform;

	public class Noelle extends PartyMember {
		public var isStrong:Boolean = false;
		
		// Constructor
		public function Noelle(strong:Boolean=true) {
			hp = 55;
			maxhp = 190;
			
			attack = 3;
			defense = 1;
			magic = 11;
			
			anims.item = "spell";
			
			cname = "noelle";
			startingIcon = "noelle0";
			colors = {
				hpbar:		new ColorTransform(1, 1, 0),
				icon:		new ColorTransform(1, 1, 0),
				numbers:	new ColorTransform(1, 1, 75/255)
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
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
			
			button2 = "act";
			
			colors = {
				hpbar:		{r: 0,   g: 255, b: 255},
				icon:		{r: 0,   g: 162, b: 232},
				numbers:	{r: 128, g: 255, b: 255}
			}
		}
	}
}
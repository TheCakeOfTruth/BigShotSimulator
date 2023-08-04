/*
	Date: 15/12/22
	Description: Base class for party members
*/

package scripts.party {
	import flash.display.MovieClip;
	
	public class PartyMember extends MovieClip {
		public var isDefending:Boolean = false;
		
		public var attack:Number;
		public var defense:Number;
		public var magic:Number;
		
		public var weapon:Object = {at: 0};
		public var armor:Array = [];
		
		public var button2:String = "spell";
		
		public var anims:Object = {
			idle: "idle",
			hurt: "hurt",
			act: "act",
			prefight: "prefight",
			fight: "fight",
			item: "item",
			defend: "defend",
			spell: "spell"
		}
		
		public var colors:Object = {
			hpbar:		{r: 255, g: 255, b: 255},
			icon:		{r: 255, g: 255, b: 255},
			numbers:	{r: 255, g: 255, b: 255}
		}
		
		// Constructor
		public function PartyMember() {}
		
		// Returns combined AT stat
		public function calculateAttack():Number {
			// Get Weapon AT
			var weaponat:Number = Number(weapon.at);
			if (isNaN(weaponat)) {weaponat = 0;}
			
			// Get Armor AT
			var armorat:Number = 0;
			for each (var equipment:Object in armor) {
				var at:Number = Number(equipment.at);
				if (isNaN(at)) {at = 0;}
				armorat += at;
			}
			equipment = null;
			
			// Return sum
			return attack + weaponat + armorat;
		}
		
		// Returns combined DF stat
		public function calculateDefense():Number {
			// Get Armor DF
			var armordf:Number = 0;
			for each (var equipment:Object in armor) {
				var df:Number = Number(equipment.df);
				if (isNaN(df)) {df = 0;}
				armordf += df;
			}
			equipment = null;
			
			// Get Weapon DF
			var weapondf:Number = Number(weapon.df);
			if (isNaN(weapondf)) {weapondf = 0;}
			
			// Return sum
			return defense + armordf + weapondf;
		}
		
		// Returns combined MAGIC stat
		public function calculateMagic():Number {
			// Get Armor MAGIC
			var armormg:Number = 0;
			for each (var equipment:Object in armor) {
				var mg:Number = Number(equipment.magic);
				if (isNaN(mg)) {mg = 0;}
				armormg += mg;
			}
			equipment = null;
			
			// Get Weapon MAGIC
			var weaponmg:Number = Number(weapon.magic);
			if (isNaN(weaponmg)) {weaponmg = 0;}
			
			// Return sum
			return magic + armormg + weaponmg;
		}
		
		// Return elemental resistance 
		public function getResistPercent(element):Number {
			var total:Number = 1;
			// For every armor, apply appropriate resistance
			for each (var armorpiece:Object in armor) {
				if (armorpiece.elementResist == element) {
					total *= armorpiece.resistMultiplier;
				}
			}
			armorpiece = null;
			return total;
		}
	}
}
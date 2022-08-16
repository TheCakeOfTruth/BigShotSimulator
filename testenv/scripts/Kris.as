/*
	Date: 12-11-2021
	Description: * It's what they call "You."
*/

package scripts {
	import flash.display.MovieClip;
	import scripts.utils.Wait;
	
	public class Kris extends MovieClip {
		public static var instance:Kris;
		public static var weapon:Object;
		public static var armor:Array = [];
		
		public var isDefending:Boolean = false;
		public var attack:Number = 14;
		public var defense:Number = 2;
		
		// Constructor
		public function Kris() {instance = this;}
		
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
			for each (var equip:Object in armor) {
				var df:Number = Number(equip.df);
				if (isNaN(df)) {df = 0;}
				armordf += df;
			}
			equip = null;
			
			// Get Weapon DF
			var weapondf:Number = Number(weapon.df);
			if (isNaN(weapondf)) {weapondf = 0;}
			
			// Return sum
			return defense + armordf + weapondf;
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
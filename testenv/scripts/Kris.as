/*
	File Name: Kris.as
	Programmeur: William Mallette
	Date: 12-11-2021
	Description: Kris, le personnage principal
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
		
		// constructor
		public function Kris() {instance = this;}
		
		// Retourner l'AT combiné de Kris et l'arme qu'iel tiens.
		public function calculateAttack():Number {
			// L'attaque de l'arme
			var weaponat:Number = Number(weapon.at);
			if (isNaN(weaponat)) {weaponat = 0;}
			
			// L'attaque de l'armure (s'il y a lieu)
			var armorat:Number = 0;
			for each (var equipment:Object in armor) {
				var at:Number = Number(equipment.at);
				if (isNaN(at)) {at = 0;}
				armorat += at;
			}
			equipment = null;
			
			// Retourner la somme
			return attack + weaponat + armorat;
		}
		
		// Retourner le DF combiné de Kris et leur équipement
		public function calculateDefense():Number {
			// La défense de l'armure
			var armordf:Number = 0;
			for each (var equip:Object in armor) {
				var df:Number = Number(equip.df);
				if (isNaN(df)) {df = 0;}
				armordf += df;
			}
			equip = null;
			
			// La défense de l'arme (s'il y a lieu)
			var weapondf:Number = Number(weapon.df);
			if (isNaN(weapondf)) {weapondf = 0;}
			
			// Retourner la somme
			return defense + armordf + weapondf;
		}
		
		// Retourner la résistence élémental de l'équipement
		public function getResistPercent(element):Number {
			var total:Number = 1;
			// Pour chaque armure, s'il y a un résistence à l'élément spécifié, modifier total par le montant stocké dans l'item
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
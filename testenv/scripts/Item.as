/*
	File Name: Item.as
	Programmeur: William Mallette
	Date: 22-11-2021
	Description: Les items
*/

package scripts {
	import flash.utils.Dictionary;
	import scripts.ui.TPMeter;
	import scripts.ui.UI;
	import scripts.utils.Wait;
	
	public class Item {
		public static var items:Dictionary = new Dictionary();
		public static var armors:Dictionary = new Dictionary();
		public static var krisweapons:Dictionary = new Dictionary();
		public static var inventory:Array = [];
		
		// constructor
		public function Item() {
			/*
				name(String) = nom
				info(String) = description
				effect(Function) = fonction exécuté quand l'item est utilisé
				targetPlayer(Boolean) = si l'item est consommé directement ou on doit sélectionner Kris
				noConsume(Boolean) = ne pas supprimer l'item sur utilisation
			*/
		
			// Initier les items
			items["DarkCandy"] = {name: "Dark Candy", info: Main.getText("itemHeal") + "\n40 HP", effect: function() {Player.heal(40);}, targetPlayer: true};
			items["TopCake"] = {name: "Top Cake", info: Main.getText("itemHeal") + "\n160 HP", effect: function() {Player.heal(160);}, targetPlayer: false};
			items["Darkburger"] = {name: "Darkburger", info: Main.getText("itemHeal") + "\n70 HP", effect: function() {Player.heal(70);}, targetPlayer: true};
			items["LancerCookie"] = {name: "Lancer Cookie", info: Main.getText("itemHeal") + "\n40 HP", effect: function() {Player.heal(40);}, targetPlayer: true};
			items["ChocoDiamond"] = {name: "Choco Diamond", info: Main.getText("itemHeal") + "\n80 HP", effect: function() {Player.heal(80);}, targetPlayer: true};
			items["HeartsDonut"] = {name: "Hearts Donut", info: Main.getText("itemHeal") + "\n10 HP", effect: function() {Player.heal(10);}, targetPlayer: true};
			items["ClubsSandwich"] = {name: "ClubsSandwich", info: Main.getText("itemHeal") + "\n70 HP", effect: function() {Player.heal(70);}, targetPlayer: false};
			items["FavoriteSandwich"] = {name: "FavoriteSandwich", info: Main.getText("itemHeal") + "\n500 HP", effect: function() {Player.heal(500);}, targetPlayer: true};
			items["RouxlsRoux"] = {name: "RouxlsRoux", info: Main.getText("itemHeal") + "\n50 HP", effect: function() {Player.heal(50);}, targetPlayer: true};
			items["TensionBit"] = {name: "Tension Bit", info: "+32% TP", effect: function() {TPMeter.instance.addTP(80);}, targetPlayer: false};
			items["LightCandy"] = {name: "Light Candy", info: Main.getText("itemHeal") + "\n120 HP", effect: function() {Player.heal(120);}, targetPlayer: true};
			items["CDBagel"] = {name: "CD Bagel", info: Main.getText("itemHeal") + "\n80 HP", effect: function() {Player.heal(80);}, targetPlayer: true};
			items["DDBurger"] = {name: "DD-Burger", info: Main.getText("DDBurgerDesc"), effect: function() {
				Player.heal(60); 
				// Remplacer le DD-Burger avec un Darkburger
				inventory[UI.instance.selectedOption] = items["Darkburger"];
			}, targetPlayer: true, noConsume: true};
			items["ButlerJuice"] = {name: "ButlerJuice", info: Main.getText("itemHeal") + "\n100 HP", effect: function() {Player.heal(100);}, targetPlayer: true};
			items["SpaghettiCode"] = {name: "SpaghettiCode", info: Main.getText("itemHeal") + "\n30 HP", effect: function() {Player.heal(30);}, targetPlayer: false};
			items["JavaCookie"] = {name: "JavaCookie", info: Main.getText("itemHeal") + "\n100 HP", effect: function() {Player.heal(100);}, targetPlayer: true};
			items["TensionGem"] = {name: "Tension Gem", info: "+50% TP", effect: function() {TPMeter.instance.addTP(125);}, targetPlayer: false};
			items["TensionMax"] = {name: "Tension Max", info: "+MAX% TP", effect: function() {TPMeter.instance.setTP(250);}, targetPlayer: false};
			items["Glowshard"] = {name: "Glowshard", info: "Glowshard", effect: function() {}, targetPlayer: true, noConsume: true};
			items["SPoison"] = {name: "S.POISON", info: Main.getText("itemHeal") + "?\n40 HP", effect: function() {
				Player.heal(40);
				// Réduire graduellement HP par 60 (ne pas dépasser 1 HP)
				for (var hurt:int = 0; hurt < 60; hurt++) {
					new Wait(hurt * 10, function() {
						if (UI.instance.hp > 1) {
							UI.instance.setHP(UI.instance.hp - 1);
						}
					});
				}
			}, targetPlayer: true};
			
			
			/* Items de Deltarune non-inclus (à cause d'un manque d'utilité):
			   Revive Mint
			   Life Dew
			   Revive Dust
			   Manual
			   Revive Brite
			*/
			
			/*
				name(String) = nom
				df(Number) = défense
				at(Number) = attaque
				magic(Number) = magie (stat non-utilisé en ce moment)
				elementResist(int) = l'élément à résister (le seul élément est '6')
				resistMultiplier(Number) = multiplier tout dommage d'un Bullet de l'élément (elementResist) par ce nombre
				grazeArea(Number) = augmente l'aire du "grazeZone" du Player (pas ajouté en ce moment)
				grazeTime(Number) = multiplie le montant de temps enlevé du waveTimer (voir EnemyWave) lorsqu'on graze (pas ajouté en ce moment)
				TPGain(Number) = multiple le montant de TP on gagne lorsqu'on graze par ce nombre (pas ajouté en ce moment)
			*/
			
			// Initier les armures, il y a certains effets spécials, mais ils ne sont pas tous inclus en ce moment.
			armors["AmberCard"] = {name: "Amber Card", df: 1};
			armors["BShotBowtie"] = {name: "B.ShotBowtie", df: 2, magic: 1};
			armors["ChainMail"] = {name: "Chain Mail", df: 3};
			armors["DarkGoldBand"] = {name: "Dark Gold Band"};
			armors["Dealmaker"] = {name: "Dealmaker", df: 5, magic: 5, elementResist: 6, resistMultiplier: 0.6};
			armors["DiceBrace"] = {name: "Dice Brace", df: 2};
			armors["FrayedBowtie"] = {name: "Frayed Bowtie", df: 1, at: 1, magic: 1, elementResist: 6, resistMultiplier: 0.85};
			armors["GlowWrist"] = {name: "Glow Wrist", df: 2};
			armors["IronShackle"] = {name: "Iron Shackle", df: 2, at: 1};
			armors["Jevilstail"] = {name: "Jevilstail", df: 2, at: 2, magic: 2};
			armors["Mannequin"] = {name: "Mannequin", elementResist: 6, resistMultiplier: 0.65};
			armors["MouseToken"] = {name: "Mouse Token", df: 1, magic: 2};
			armors["PinkRibbon"] = {name: "Pink Ribbon", df: 1, grazeArea: 1.44};
			armors["RoyalPin"] = {name: "Royal Pin", df: 3, magic: 1};
			armors["SilverCard"] = {name: "Silver Card", df: 2};
			armors["SilverWatch"] = {name: "Silver Watch", df: 2, grazeTime: 1.1};
			armors["SkyMantle"] = {name: "Sky Mantle", df: 1};
			armors["SpikeBand"] = {name: "Spike Band", df: 1, at: 2};
			armors["SpikeShackle"] = {name: "Spike Shackle", df: 1, at: 3};
			armors["TensionBow"] = {name: "Tension Bow", df: 2, TPGain: 1.1};
			armors["TwinRibbon"] = {name: "Twin Ribbon", df: 3, grazeArea: 1.5625};
			armors["WhiteRibbon"] = {name: "White Ribbon", df: 2};
			
			// Initier les armes de Kris
			krisweapons["MechaSaber"] = {name: "Mecha Saber", at: 4};
			krisweapons["BounceBlade"] = {name: "Bounce Blade", at: 2, df: 1};
			krisweapons["SpookySword"] = {name: "Spooky Sword", at: 2};
			krisweapons["Trefoil"] = {name: "Trefoil", at: 4};
			krisweapons["TwistedSword"] = {name: "Twisted Sword", at: 16};
			krisweapons["WoodBlade"] = {name: "Wood Blade", at: 1};
		}
	}
}
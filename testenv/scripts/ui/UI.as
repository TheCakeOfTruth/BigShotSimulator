/*
	File Name: UI.as
	Programmeur: William Mallette
	Date: 05-11-2021
	Description: Le barre des boutons et d'information pendant la bataille
*/

package scripts.ui {
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import scripts.Item;
	import scripts.SoundLibrary;
	import scripts.Kris;
	import scripts.utils.Wait;
	import scripts.utils.Input;
	import scripts.utils.RepeatUntil;
	import scripts.utils.XMLToDialogue;
	import scripts.spam.Spamton;
	
	public class UI extends Sprite {
		public static var instance:UI;
		private static var yellow = new ColorTransform(1,1,0);
		private static var white = new ColorTransform();
		
		public var hp:int = 160;
		public var itemAdvanceStage:int = 0;
		public var displayText:String = Main.getText("NEOencounterStart");
		public var selectedOption:int = 0;
		public var itempage:int = 0;
		
		private var selectedButton:int = 0;
		private var oldbutton:int = 0;
		private var buttons:Array;
		private var options:Array = [];
		private var menuElements:Array = [];
		private var allItems:Array = [];
		private var page1:Array = [];
		private var page2:Array = [];
		private var textformat:TextFormat = new TextFormat();
		private var descriptiontext:SimpleText;
		private var descriptionformat:TextFormat = new TextFormat();
		private var tptext:SimpleText;
		private var tpformat:TextFormat = new TextFormat();
		
		// constructor
		public function UI() {
			// Un array pour les boutons
			buttons = [fight, act, item, spare, defend];
		
			// garder cette objet dans le variable static
			instance = this;
			// changer l'HP
			setHP(hp);
			
			// Initier les TextFormat
			textformat.letterSpacing = -1;
			textformat.leading = -5;
			textbox.textfield.defaultTextFormat = textformat;
			
			descriptionformat.letterSpacing = -2;
			descriptionformat.leading = 0;
			descriptionformat.color = 0x808080;
			
			tpformat.letterSpacing = -2;
			tpformat.leading = 0;
			tpformat.color = 0xFFA040;
		}
		
		// changer l'HP
		public function setHP(n:int):void {
			hp = n;
			// voir HPText.setHP()
			info.hptext.setHP(n);
			// Changer le longueur du hpbar en accordance avec l'HP
			info.hpbar.width = Math.floor(76 * n / 160);
			
			// Si l'HP est 1/5 ou moins du MAXHP (160), hptext et maxhp doivent être jaune.
			var colorToSet:ColorTransform;
			if (n <= 32) {colorToSet = yellow;}
			else {colorToSet = white;}
			info.hptext.transform.colorTransform = colorToSet;
			info.maxhp.transform.colorTransform = colorToSet;
		}
		
		// Changer le texte de l'UI
		public function setText(txt, endfunc:Function = null):void {
			textbox.startText(txt, "defaultvoice", "default", endfunc);
			textbox.visible = true;
		}
		
		// Cacher le menu (l'info, les boutons, etc.)
		public function hideMenu():void {
			// Cacher menu et les boutons
			menu.visible = false;
			for each (var btn:MovieClip in buttons) {btn.visible = false; btn.gotoAndStop("off");}
			btn = null;
			selectedButton = 0;
			// Bouger l'info
			new RepeatUntil(function(){
				info.y += 3.5;
				for each (btn in buttons) {btn.y += 3.5;}
				btn = null;
				menu.y += 3.5
			}, function(){if (info.y >= -32) {info.y = -32; return true;}});
		}
		
		// Montrer le menu (l'inverse de hideMenu)
		public function showMenu():void {
			menu.visible = true;
			for each (var button:MovieClip in buttons) {button.visible = true}
			button = null;
			new RepeatUntil(function() {
				info.y -= 3.5;
				for each (button in buttons) {button.y -= 3.5}
				button = null;
				menu.y -= 3.5
			}, function() {if (info.y <= -63) {info.y = -63; return true}});
		}
		
		/////////////////////////////////////////////////////////////////// Gérer les gameState
		
		// Commencer l'état "selectingButton"
		public function enterSelectingButton():void {
			// Reset le menu et Kris si nécessaire
			if (menu.visible == false) {
				showMenu();
			}
			
			if (Kris.instance.isDefending) {
				Kris.instance.gotoAndPlay("idle");
				Kris.instance.isDefending = false;
			}
		
			// Plusieurs clés peuvent avoir des événements avec des noms communs, à cause que les événements fonctionnent par clé
			Input.addEvent(37, function(){moveBtn("L")}, "selectingButton");
			Input.addEvent(39, function(){moveBtn("R")}, "selectingButton");
			Input.addEvent(90, openBtn, "selectingButton");
			info.icon.gotoAndStop("head");
			setText(displayText);
			textbox.visible = true;
			updateBtns();
		}
		
		// Changer quel bouton est sélectionné
		private function moveBtn(dir:String):void {
			oldbutton = selectedButton;
			if (dir == "L") {
				selectedButton = (selectedButton - 1) % 5;
				if (selectedButton < 0) {selectedButton = 5 + selectedButton;}
			}
			else {selectedButton = (selectedButton + 1) % 5;}
			SoundLibrary.play("menumove", 0.5);
			updateBtns();
		}
		
		// Ouvrir le menu respectif du bouton sélectionné
		private function openBtn():void {
			// FIGHT/ACT/SPARE
			if (selectedButton == 0 || selectedButton == 1 || selectedButton == 3) {Main.setState("enemySelect");}
			// ITEM
			else if (selectedButton == 2) {
				if (Item.inventory.length > 0) {
					Main.setState("itemSelect");
				}
			}
			// DEFEND
			else if (selectedButton == 4) {
				Main.setState("enemyDialogue");
				TPMeter.instance.addTP(40);
				Kris.instance.gotoAndPlay("defend");
				Kris.instance.isDefending = true;
				info.icon.gotoAndStop("defend");
				hideMenu();
			}
			SoundLibrary.play("menuselect", 0.5);
		}
		
		// Changer l'image des boutons
		private function updateBtns():void {
			buttons[oldbutton].gotoAndStop("off");
			buttons[selectedButton].gotoAndStop("on");
		}
		
		// Terminer l'état "selectingButton"
		public function exitSelectingButton():void {
			// Enlever les event, cacher le texte
			Input.removeEvent(37, "selectingButton");
			Input.removeEvent(39, "selectingButton");
			Input.removeEvent(90, "selectingButton");
			textbox.finishText();
			textbox.visible = false;
		}
		
		// Commencer l'état enemySelect
		public function enterEnemySelect():void {
			// Créer le sélecteur de Spamton
			var menuoption:MenuOption = new MenuOption(-266, 19, "Spamton NEO");
			menuoption.toggleSelection(true);
			menuoption.effect = enemySelectTryAdvance;
			this.addChild(menuoption);
			menuElements.push(menuoption);
			
			// Image statique
			var meters_overlay:Bitmap = new Bitmap(new EnemyMeters(0,0));
			this.addChild(meters_overlay);
			meters_overlay.x = 100;
			meters_overlay.y = 3;
			menuElements.push(meters_overlay);
			
			// Montrer l'HP de Spamton
			var spamton_hpbar:EnemyHPBar = new EnemyHPBar(Math.round(Main.screen.spamton.hp / Main.screen.spamton.maxhp * 100));
			this.addChild(spamton_hpbar);
			spamton_hpbar.x = 100;
			spamton_hpbar.y = 15;
			menuElements.push(spamton_hpbar);
			
			// L'option de retourner (X)
			Input.addEvent(88, function(){Main.setState("selectingButton")}, "back");
		}
		
		// Fonction qui gère le progression après enemySelect
		private function enemySelectTryAdvance():void {
			// FIGHT
			if (selectedButton == 0) {
				Main.setState("attacking");
				info.icon.gotoAndStop("fight");
				hideMenu();
				Kris.instance.gotoAndStop("prefight");
			}
			
			// ACT
			if (selectedButton == 1) {Main.setState("actionSelect");}
			
			// SPARE
			if (selectedButton == 3) {
				Main.setState("actionResult");
				Kris.instance.gotoAndPlay("act");
				info.icon.gotoAndStop("spare");
				hideMenu();
				new Wait(30, function() {Kris.instance.gotoAndPlay("idle"); info.icon.gotoAndStop("head");})
				setText(XMLToDialogue(Main.dialogue.krisSpare)[0] + " SPAMTON NEO!\n" + XMLToDialogue(Main.dialogue.spareFail)[0], function() {Main.setState("enemyDialogue");});
			}
		}
		
		// Terminer l'état enemySelect
		public function exitEnemySelect():void {
			// Enlever les menuElements
			for each (var obj in menuElements) {
				this.removeChild(obj);
				if (obj is MenuOption) {obj.destroy();}
			}
			obj = null;
			menuElements = [];
			// Enlever l'event de retour
			Input.removeEvent(88, "back");
			// Jouer un son si on va à selectingButton
			if (Main.gameState == "selectingButton") {SoundLibrary.play("menumove", 0.5);}
		}
		
		// Commencer l'état attacking
		public function enterAttacking():void {
			// Créer le FightUI (voir FightUI)
			var fighting:FightUI = new FightUI();
			fighting.x = -320;
			fighting.y = 0;
			this.addChild(fighting);
			menuElements.push(fighting);
		}
		
		// Terminer l'état attacking
		public function exitAttacking():void {
			// Enlever le FightUI
			menuElements[0].fadeOut();
			menuElements = [];
		}
		
		// Commencer l'état actionSelect
		public function enterActionSelect():void {
			selectedOption = 0;
			// Créer les options
			for each (var option:MenuOption in Main.screen.spamton.actions) {
				option.toggleSelection(false);
				this.addChild(option);
				menuElements.push(option);
				options.push(option);
			}
			option = null;
			options[selectedOption].toggleSelection(true);
			
			// Le TextField du description de l'option
			// Actionscript a de la difficulté à intéragir avec des fonts embarqués
			// Alors, j'ai crée SimpleText (qui est simplement un TextField avec Determination Mono comme font)
			descriptiontext = new SimpleText();
			descriptiontext.field.defaultTextFormat = descriptionformat;
			descriptiontext.x = 175;
			descriptiontext.y = 6;
			this.addChild(descriptiontext);
			menuElements.push(descriptiontext);
			
			// Le TextField du coût de TP
			tptext = new SimpleText();
			tptext.field.defaultTextFormat = tpformat;
			tptext.x = 175;
			tptext.y = 71;
			this.addChild(tptext);
			menuElements.push(tptext);
			
			// Le mouvement
			Input.addEvent(37, function(){moveOption("H")}, "actionSelect");
			Input.addEvent(38, function(){moveOption("U")}, "actionSelect");
			Input.addEvent(39, function(){moveOption("H")}, "actionSelect");
			Input.addEvent(40, function(){moveOption("D")}, "actionSelect");
			// Le retour
			Input.addEvent(88, function() {Main.setState("selectingButton")}, "back");
		}
		
		// Changer quelle option est sélectionnée
		private function moveOption(dir:String):void {
			options[selectedOption].toggleSelection(false);
			if (dir == "H") {selectedOption = Math.min(((selectedOption + 1) % 2) + selectedOption + (-selectedOption % 2), options.length - 1);}
			else if (dir == "U" && selectedOption - 2 >= 0) {selectedOption -= 2;}
			else if (dir == "D" && selectedOption + 2 < options.length) {selectedOption += 2;}
			options[selectedOption].toggleSelection(true);
			
			// Montrer/cacher le description
			if (descriptiontext != null) {
				if (options[selectedOption].description != null) {descriptiontext.field.text = options[selectedOption].description;}
				else {descriptiontext.field.text = "";}
			}
			
			// Montrer/cacher le coût
			if (tptext != null) {
				if (options[selectedOption].TPCost > 0) {tptext.field.text = options[selectedOption].TPCost + "% TP";}
				else {tptext.field.text = "";}
			}
		}
		
		// Terminer l'état actionSelect
		public function exitActionSelect():void {
			// Enlever les menuElements
			for each (var _obj:DisplayObject in menuElements) {this.removeChild(_obj);}
			_obj = null;
			menuElements = [];
			// Reset l'array d'options donc on pourrait modifier les options plus tard
			options = [];
			
			// Enlever les events
			Input.removeEvent(37, "actionSelect");
			Input.removeEvent(38, "actionSelect");
			Input.removeEvent(39, "actionSelect");
			Input.removeEvent(40, "actionSelect");
			Input.removeEvent(88, "back");
		}
		
		// Commencer l'état itemSelect
		public function enterItemSelect():void {
			// Changer des variables dépendant de l'état précédent
			if (Main.oldstate != "itemTarget") {
				selectedOption = 0;
				itempage = 0;
			}
			else {
				if (itempage == 1) {itempage = 2;}
				else {itempage = 1;}
			}
			
			// Pour chaque item
			for (var itemno in Item.inventory) {
				// Déterminer quelle array à utiliser
				var targetArray:Array;
				if (itemno < 6) {targetArray = page1;}
				else {targetArray = page2;}
				
				// Calculer le coordonnée Y de l'option
				var itemheight:Number = 19 + (Math.floor((itemno % 6)/2) * 30);
				var item:MenuOption;
				// Côté gauche (paire)
				if (itemno % 2 == 0) {item = new MenuOption(-311, itemheight, Item.inventory[itemno].name);}
				// Côté droite (impaire)
				else {item = new MenuOption(-87, itemheight, Item.inventory[itemno].name);}
				
				// Remplir des valeurs du MenuOption par rapport à celles de l'item
				item.description = Item.inventory[itemno].info;
				if (Item.inventory[itemno].targetPlayer == true) {
					item.effect = function() {Main.setState("itemTarget");}
				}
				// Si l'item ne target pas un personnage, skip à actionResult
				else {
					item.effect = function() {
						Main.setState("actionResult");
						info.icon.gotoAndStop("item");
						hideMenu();
						setText(XMLToDialogue(Main.dialogue.krisItemUse)[0] + " " + Item.inventory[selectedOption + (6 * (itempage - 1))].name.toUpperCase() + "!", function() {
							itemAdvanceStage++;
							new RepeatUntil(function(){}, function(){
								if (itemAdvanceStage >= 2) {
									Main.setState("enemyDialogue");
									itemAdvanceStage = 0;
									return true;
								}
							});
						});
						// Voir les actions au fin du section "item" dans Kris pour voir d'autre code
						Kris.instance.gotoAndPlay("item");
					}
				}
				
				// Insérer dans l'array correct
				targetArray.push(item);
				allItems.push(item);
			}
			itemno = null;
			
			// Créer l'indicateur de l'inventory
			if (page2.length != 0) {
				var itemarrow:InventoryArrow = new InventoryArrow(156, 60);
				this.addChild(itemarrow);
				// menuElements[0]
				menuElements.push(itemarrow);
			}
			
			// Montrer le correct page
			if (itempage == 1) {
				page2[selectedOption].toggleSelection(true);
				showItemPage(page2);
				itemarrow.flip();
			}
			else {
				page1[selectedOption].toggleSelection(true);
				showItemPage(page1);
			}
			
			// Le texte qui montre le description de l'item
			descriptiontext = new SimpleText();
			descriptiontext.field.defaultTextFormat = descriptionformat;
			descriptiontext.x = 175;
			descriptiontext.y = 6;
			this.addChild(descriptiontext);
			menuElements.push(descriptiontext);
			descriptiontext.field.text = options[selectedOption].description;
			
			// Le mouvement (L, U, R, D)
			Input.addEvent(37, function(){moveOption("H");}, "itemSelect");
			Input.addEvent(38, function(){
				// Changer de page
				if ((itempage == 2) && (selectedOption == 0 || selectedOption == 1)) {
					options[selectedOption].toggleSelection(false);
					selectedOption = ((selectedOption % 2) + 4); 
					showItemPage(page1);
					menuElements[0].flip();
					options[selectedOption].toggleSelection(true);
				}
				else {moveOption("U");}
			}, "itemSelect");
			Input.addEvent(39, function(){moveOption("H");}, "itemSelect");
			Input.addEvent(40, function(){
				// Changer de page
				if ((itempage == 1) && (selectedOption == 4 || selectedOption == 5) && (page2.length > 0)) {
					options[selectedOption].toggleSelection(false);
					selectedOption = (selectedOption % 2) % page2.length; 
					showItemPage(page2);
					menuElements[0].flip();
					options[selectedOption].toggleSelection(true);
				}
				else {moveOption("D");}
			}, "itemSelect");
			
			// Retourner à selectingButton
			new Wait(2, function() {Input.addEvent(88, function() {Main.setState("selectingButton");}, "back");});
		}
		
		// Montrer une page d'items
		private function showItemPage(items:Array):void {
			// Changer itempage
			if (itempage == 1) {itempage = 2;}
			else {itempage = 1;}
			
			// Effacer les options déjà montrés
			for each (var itemoption:MenuOption in options) {this.removeChild(itemoption);}
			itemoption = null;
			options = [];
			
			// Créer les propres items
			for each (var newitem:MenuOption in items) {
				this.addChild(newitem);
				options.push(newitem);
			}
			newitem = null;
			if (descriptiontext) {descriptiontext.field.text = options[selectedOption].description;}
		}
		
		// Terminer l'état itemSelect
		public function exitItemSelect():void {
			// Enlever les objets
			for each (var object in menuElements) {
				if (object is InventoryArrow) {object.prepDestruction();}
				this.removeChild(object);
			}
			object = null;
			for each (var itemobj in allItems) {itemobj.destroy();}
			itemobj = null;
			menuElements = [];
			options = [];
			allItems = [];
			page1 = [];
			page2 = [];
			// Enlever les events
			Input.removeEvent(37, "itemSelect");
			Input.removeEvent(38, "itemSelect");
			Input.removeEvent(39, "itemSelect");
			Input.removeEvent(40, "itemSelect");
			Input.removeEvent(88, "back");
			
			// Jouer un son
			if (Main.gameState == "selectingButton") {SoundLibrary.play("menumove", 0.5);}
		}
		
		
		// Commencer l'état itemTarget
		public function enterItemTarget():void {
			// Créer le sélecteur de Kris
			var krisoption:MenuOption = new MenuOption(-266, 19, "Kris");
			krisoption.toggleSelection(true);
			krisoption.effect = function() {
				// Utiliser l'item
				Main.setState("actionResult");
				info.icon.gotoAndStop("item");
				hideMenu();
				setText(XMLToDialogue(Main.dialogue.krisItemUse)[0] + " " + Item.inventory[selectedOption + (6 * (itempage - 1))].name.toUpperCase() + "!", function() {
					itemAdvanceStage++;
					new RepeatUntil(function(){}, function(){
						if (itemAdvanceStage >= 2) {
							Main.setState("enemyDialogue");
							itemAdvanceStage = 0;
							return true;
						}
					});
				});
				// Voir les actions au fin du section "item" dans Kris pour voir d'autre code
				Kris.instance.gotoAndPlay("item");
			};
			this.addChild(krisoption);
			menuElements.push(krisoption);
			
			// Montrer l'HP de Kris
			var kris_hpbar:EnemyHPBar = new EnemyHPBar(Math.round(hp / 160 * 100));
			kris_hpbar.percentage.visible = false;
			this.addChild(kris_hpbar);
			kris_hpbar.x = 80;
			kris_hpbar.width += 20;
			kris_hpbar.y = 15;
			menuElements.push(kris_hpbar);
			
			// Retourner à itemSelect
			Input.addEvent(88, function() {Main.setState("itemSelect");}, "back");
		}
		
		// Terminer l'état itemTarget
		public function exitItemTarget():void {
			for each (var targets in menuElements) {
				if (targets is MenuOption) {targets.destroy();}
				else {this.removeChild(targets);}
			}
			targets = null;
			menuElements = [];
			Input.removeEvent(88, "back");
		}
	}
}
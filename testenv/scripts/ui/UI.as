/*
	Date: 05-11-2021
	Description: The battle UI
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
		
		// Constructor
		public function UI() {
			// An array for the buttons
			buttons = [fight, act, item, spare, defend];
		
			// Keep a global reference
			instance = this;
			// Change the HP
			setHP(hp);
			
			// Setup textformats
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
		
		// Changes HP
		public function setHP(n:int):void {
			hp = n;
			// Change text display
			info.hptext.setHP(n);
			// Resize hpbar
			info.hpbar.width = Math.floor(76 * n / 160);
			
			// Make text yellow when HP is less than 1/5 of maxhp
			var colorToSet:ColorTransform;
			if (n <= 32) {colorToSet = yellow;}
			else {colorToSet = white;}
			info.hptext.transform.colorTransform = colorToSet;
			info.maxhp.transform.colorTransform = colorToSet;
		}
		
		// Change UI text
		public function setText(txt, endfunc:Function = null):void {
			textbox.startText(txt, "defaultvoice", "default", endfunc);
			textbox.visible = true;
		}
		
		// Hide the menu
		public function hideMenu():void {
			// Hide menu and buttons
			menu.visible = false;
			for each (var btn:MovieClip in buttons) {btn.visible = false; btn.gotoAndStop("off");}
			btn = null;
			selectedButton = 0;
			// Move info down
			new RepeatUntil(function(){
				info.y += 3.5;
				for each (btn in buttons) {btn.y += 3.5;}
				btn = null;
				menu.y += 3.5
			}, function(){if (info.y >= -32) {info.y = -32; return true;}});
		}
		
		// Show the menu (just the opposite of hideMenu)
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
		
		/////////////////////////////////////////////////////////////////// GameState handlers
		
		// Start "selectingButton"
		public function enterSelectingButton():void {
			// Reset the menu and Kris
			if (menu.visible == false) {
				showMenu();
			}
			
			if (Kris.instance.isDefending) {
				Kris.instance.gotoAndPlay("idle");
				Kris.instance.isDefending = false;
			}
		
			Input.addEvent(37, function(){moveBtn("L")}, "selectingButton");
			Input.addEvent(39, function(){moveBtn("R")}, "selectingButton");
			Input.addEvent(90, openBtn, "selectingButton");
			info.icon.gotoAndStop("head");
			setText(displayText);
			textbox.visible = true;
			updateBtns();
		}
		
		// Changes which button is selected
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
		
		// Open the selected button's menu
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
		
		// Change the button sprite
		private function updateBtns():void {
			buttons[oldbutton].gotoAndStop("off");
			buttons[selectedButton].gotoAndStop("on");
		}
		
		// Exit "selectingButton"
		public function exitSelectingButton():void {
			// Remove events and hide text
			Input.removeEvent(37, "selectingButton");
			Input.removeEvent(39, "selectingButton");
			Input.removeEvent(90, "selectingButton");
			textbox.finishText();
			textbox.visible = false;
		}
		
		// Start enemySelect
		public function enterEnemySelect():void {
			// Creates the MenuOption for Spamton
			var menuoption:MenuOption = new MenuOption(-266, 19, "Spamton NEO");
			menuoption.toggleSelection(true);
			menuoption.effect = enemySelectTryAdvance;
			this.addChild(menuoption);
			menuElements.push(menuoption);
			
			// Static image for the meters
			var meters_overlay:Bitmap = new Bitmap(new EnemyMeters(0,0));
			this.addChild(meters_overlay);
			meters_overlay.x = 100;
			meters_overlay.y = 3;
			menuElements.push(meters_overlay);
			
			// Shows Spamton's HP
			var spamton_hpbar:EnemyHPBar = new EnemyHPBar(Math.round(Main.screen.spamton.hp / Main.screen.spamton.maxhp * 100));
			this.addChild(spamton_hpbar);
			spamton_hpbar.x = 100;
			spamton_hpbar.y = 15;
			menuElements.push(spamton_hpbar);
			
			// X to return
			Input.addEvent(88, function(){Main.setState("selectingButton")}, "back");
		}
		
		// Handles progression past enemySelect
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
		
		// Exit enemySelect
		public function exitEnemySelect():void {
			// Remove menuElements
			for each (var obj in menuElements) {
				this.removeChild(obj);
				if (obj is MenuOption) {obj.destroy();}
			}
			obj = null;
			menuElements = [];
			// Remove inputs
			Input.removeEvent(88, "back");
			// Play a sound if we're going to selectingButton
			if (Main.gameState == "selectingButton") {SoundLibrary.play("menumove", 0.5);}
		}
		
		// Start attacking
		public function enterAttacking():void {
			// Setup FightUI
			var fighting:FightUI = new FightUI();
			fighting.x = -320;
			fighting.y = 0;
			this.addChild(fighting);
			menuElements.push(fighting);
		}
		
		// Exit attacking
		public function exitAttacking():void {
			// Remove FightUI
			menuElements[0].fadeOut();
			menuElements = [];
		}
		
		// Start actionSelect
		public function enterActionSelect():void {
			selectedOption = 0;
			// Create options
			for each (var option:MenuOption in Main.screen.spamton.actions) {
				option.toggleSelection(false);
				this.addChild(option);
				menuElements.push(option);
				options.push(option);
			}
			option = null;
			options[selectedOption].toggleSelection(true);
			
			// A TextField that describes the option (if applicable)
			descriptiontext = new SimpleText();
			descriptiontext.field.defaultTextFormat = descriptionformat;
			descriptiontext.x = 175;
			descriptiontext.y = 6;
			this.addChild(descriptiontext);
			menuElements.push(descriptiontext);
			
			// A TextField that show the TP cost (if applicable)
			tptext = new SimpleText();
			tptext.field.defaultTextFormat = tpformat;
			tptext.x = 175;
			tptext.y = 71;
			this.addChild(tptext);
			menuElements.push(tptext);
			
			// Movement
			Input.addEvent(37, function(){moveOption("H")}, "actionSelect");
			Input.addEvent(38, function(){moveOption("U")}, "actionSelect");
			Input.addEvent(39, function(){moveOption("H")}, "actionSelect");
			Input.addEvent(40, function(){moveOption("D")}, "actionSelect");
			// Go back
			Input.addEvent(88, function() {Main.setState("selectingButton")}, "back");
		}
		
		// Change which option is selected
		private function moveOption(dir:String):void {
			options[selectedOption].toggleSelection(false);
			if (dir == "H") {selectedOption = Math.min(((selectedOption + 1) % 2) + selectedOption + (-selectedOption % 2), options.length - 1);}
			else if (dir == "U" && selectedOption - 2 >= 0) {selectedOption -= 2;}
			else if (dir == "D" && selectedOption + 2 < options.length) {selectedOption += 2;}
			options[selectedOption].toggleSelection(true);
			
			// Show/hide description
			if (descriptiontext != null) {
				if (options[selectedOption].description != null) {descriptiontext.field.text = options[selectedOption].description;}
				else {descriptiontext.field.text = "";}
			}
			
			// Show/hide TP cost
			if (tptext != null) {
				if (options[selectedOption].TPCost > 0) {tptext.field.text = options[selectedOption].TPCost + "% TP";}
				else {tptext.field.text = "";}
			}
		}
		
		// Exit actionSelect
		public function exitActionSelect():void {
			// Remove menuElements
			for each (var _obj:DisplayObject in menuElements) {this.removeChild(_obj);}
			_obj = null;
			menuElements = [];
			// Reset the options array
			options = [];
			
			// Remove inputs
			Input.removeEvent(37, "actionSelect");
			Input.removeEvent(38, "actionSelect");
			Input.removeEvent(39, "actionSelect");
			Input.removeEvent(40, "actionSelect");
			Input.removeEvent(88, "back");
		}
		
		// Start itemSelect
		public function enterItemSelect():void {
			// Change variables depending on the previous state
			if (Main.oldstate != "itemTarget") {
				selectedOption = 0;
				itempage = 0;
			}
			else {
				if (itempage == 1) {itempage = 2;}
				else {itempage = 1;}
			}
			
			// For each item
			for (var itemno in Item.inventory) {
				// Figure out which array to use
				var targetArray:Array;
				if (itemno < 6) {targetArray = page1;}
				else {targetArray = page2;}
				
				// Calculate the vertical position of the option
				var itemheight:Number = 19 + (Math.floor((itemno % 6)/2) * 30);
				var item:MenuOption;
				// Even numbers on the left
				if (itemno % 2 == 0) {item = new MenuOption(-311, itemheight, Item.inventory[itemno].name);}
				// Odd numbers on the right
				else {item = new MenuOption(-87, itemheight, Item.inventory[itemno].name);}
				
				// Fill in MenuOption settings using item data
				item.description = Item.inventory[itemno].info;
				if (Item.inventory[itemno].targetPlayer == true) {
					item.effect = function() {Main.setState("itemTarget");}
				}
				// If itemTarget isn't needed, skip to actionResult
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
						// There's code in Kris' item animation that uses the item
						Kris.instance.gotoAndPlay("item");
					}
				}
				
				// Insert to the correct array
				targetArray.push(item);
				allItems.push(item);
			}
			itemno = null;
			
			// Make the InventoryArrow
			if (page2.length != 0) {
				var itemarrow:InventoryArrow = new InventoryArrow(156, 60);
				this.addChild(itemarrow);
				menuElements.push(itemarrow);
			}
			
			// Show the right page
			if (itempage == 1) {
				page2[selectedOption].toggleSelection(true);
				showItemPage(page2);
				itemarrow.flip();
			}
			else {
				page1[selectedOption].toggleSelection(true);
				showItemPage(page1);
			}
			
			// Text for the item description
			descriptiontext = new SimpleText();
			descriptiontext.field.defaultTextFormat = descriptionformat;
			descriptiontext.x = 175;
			descriptiontext.y = 6;
			this.addChild(descriptiontext);
			menuElements.push(descriptiontext);
			descriptiontext.field.text = options[selectedOption].description;
			
			// Movement (L, U, R, D)
			Input.addEvent(37, function(){moveOption("H");}, "itemSelect");
			Input.addEvent(38, function(){
				// Change page
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
				// Change page
				if ((itempage == 1) && (selectedOption == 4 || selectedOption == 5) && (page2.length > 0)) {
					options[selectedOption].toggleSelection(false);
					selectedOption = (selectedOption % 2) % page2.length; 
					showItemPage(page2);
					menuElements[0].flip();
					options[selectedOption].toggleSelection(true);
				}
				else {moveOption("D");}
			}, "itemSelect");
			
			// Return to selectingButton
			new Wait(2, function() {Input.addEvent(88, function() {Main.setState("selectingButton");}, "back");});
		}
		
		// Show an item page
		private function showItemPage(items:Array):void {
			// Change itempage
			if (itempage == 1) {itempage = 2;}
			else {itempage = 1;}
			
			// Hide current options
			for each (var itemoption:MenuOption in options) {this.removeChild(itemoption);}
			itemoption = null;
			options = [];
			
			// Create the right items
			for each (var newitem:MenuOption in items) {
				this.addChild(newitem);
				options.push(newitem);
			}
			newitem = null;
			if (descriptiontext) {descriptiontext.field.text = options[selectedOption].description;}
		}
		
		// Exit itemSelect
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
			// Remove events
			Input.removeEvent(37, "itemSelect");
			Input.removeEvent(38, "itemSelect");
			Input.removeEvent(39, "itemSelect");
			Input.removeEvent(40, "itemSelect");
			Input.removeEvent(88, "back");
			if (Main.gameState == "selectingButton") {SoundLibrary.play("menumove", 0.5);}
		}
		
		
		// Start itemTarget
		public function enterItemTarget():void {
			// Kris selector
			var krisoption:MenuOption = new MenuOption(-266, 19, "Kris");
			krisoption.toggleSelection(true);
			krisoption.effect = function() {
				// Use the item
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
				// See Kris' item animation code
				Kris.instance.gotoAndPlay("item");
			};
			this.addChild(krisoption);
			menuElements.push(krisoption);
			
			// Show Kris' HP
			var kris_hpbar:EnemyHPBar = new EnemyHPBar(Math.round(hp / 160 * 100));
			kris_hpbar.percentage.visible = false;
			this.addChild(kris_hpbar);
			kris_hpbar.x = 80;
			kris_hpbar.width += 20;
			kris_hpbar.y = 15;
			menuElements.push(kris_hpbar);
			
			// Return to itemSelect
			Input.addEvent(88, function() {Main.setState("itemSelect");}, "back");
		}
		
		// Exit itemTarget
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
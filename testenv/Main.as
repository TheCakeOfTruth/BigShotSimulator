/*  
	Date: 21/10/2021
	Description: The class document
*/

package {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.getTimer;
	import flash.system.fscommand;
	import flash.system.System;
	import flash.net.FileReference;
	import flash.net.FileFilter;
	import flash.geom.ColorTransform;
	import fl.controls.ComboBox;
	import scripts.DialogueBubble;
	import scripts.Kris;
	import scripts.SoundLibrary;
	import scripts.DamageNumber;
	import scripts.Bullet;
	import scripts.EnemyWave;
	import scripts.Player;
	import scripts.GameOverScreen;
	import scripts.Item;
	import scripts.ui.UI;
	import scripts.ui.TPMeter;
	import scripts.utils.RandomRange;
	import scripts.utils.Wait;
	import scripts.utils.XMLToDialogue;
	import scripts.utils.GlobalListener;
	import scripts.utils.RepeatUntil;
	import scripts.utils.Input;
	import scripts.utils.BetterSoundChannel;
	import scripts.spam.Spamton;
	import lang.LocalizationHandler;
	
	public class Main extends MovieClip {
		public static var screen:Main;
		public static var bgm:BetterSoundChannel;
		public static var gameState:String;
		public static var oldstate:String;
		public static var dialogue:XML;
		public static var isMenu:Boolean;
		
		public var spamton:Spamton;
		public var kris:Kris;
		
		// Debug tools
		private var skipmenu:Boolean = true;
		private var showDebugInfo:Boolean = true;
		private var _time:Number;
		private var frames:int = 0;
		
		// Menu variables
		private var titleFormat:TextFormat;
		private var itemboxes:Array;
		private var selectedSword:Object;
		private var selectedArmorA:Object;
		private var selectedArmorB:Object;
		private var selectedItems:Array = [];
		private var presetFile:FileReference;
		
		public function Main() {
			// Keep a reference to the screen
			screen = this;
			
			// Set up titleFormat
			titleFormat = new TextFormat();
			titleFormat.align = TextFormatAlign.CENTER;
			titleFormat.letterSpacing = 4;
			
			// Initiate localization
			new LocalizationHandler();
			dialogue = LocalizationHandler.languages["english"];
			// Initiate inputs
			new Input();
			// Initiate items and equip default inventory
			new Item();
			selectedSword = {index: 0, item: Item.krisweapons["BounceBlade"]};
			selectedArmorA = {index: 0, item: Item.armors["AmberCard"]};
			selectedArmorB = {index: 0, item: Item.armors["AmberCard"]};
			for (var i:int = 0; i < 12; i++) {selectedItems.push({index: 2, item: Item.items["CDBagel"]});}
			// Initiate the sound library
			new SoundLibrary();
			// Initiate the GlobalListener
			new GlobalListener();
			
			// Initiate the main menu
			setupMenu();
			
			// I discovered an issue with sounds, which caused lots of lag
			// The problem was that Flash's sound handler was unloading after there was no longer a sound playing
			// Causing it to load back in every time a sound came back (causing the lag)
			// To prevent this, a sound has to be playing at all times.
			bgm = SoundLibrary.play("mus_menu", 0.3, int.MAX_VALUE);
			
			// Establish some variables used for debugging
			_time = getTimer();
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		// Run each frame
		private function update(e:Event) {
			// FPS/Memory display
			if (!isMenu) {
				if (showDebugInfo) {
					// Got this FPS counter from: https://bit.ly/34QWpiO
					var newtime:Number = (getTimer() - _time) / 1000;
					frames++;
					if (newtime > 1) {
						fpsText.text = "FPS: " + String(Math.floor(frames/newtime) + "       Memory: " + System.totalMemory);
						_time = getTimer();
						frames = 0;
					}
				}
				else {fpsText.visible = false;}
			}
		}
		
		// Shakes the screen
		public function shakeScreen(intensity:Number = 2) {
			// Generates two random numbers between -intensity and intensity
			var val_x:Number = RandomRange(-intensity, intensity);
			var val_y:Number = RandomRange(-intensity, intensity);
			// Displace the screen by those values
			screen.x += val_x;
			screen.y += val_y;
			// 5 frames later, move the screen back
			new Wait(5, function():void {
				screen.x -= val_x;
				screen.y -= val_y;
			});
		}
		
		// Change the game state
		public static function setState(newstate:String):void {
			// Switch variables
			oldstate = gameState;
			gameState = newstate;
			
			// oldstate (handles ending the current state)
			if (oldstate == "selectingButton") {UI.instance.exitSelectingButton();}
			else if (oldstate == "enemySelect") {UI.instance.exitEnemySelect();}
			else if (oldstate == "attacking") {UI.instance.exitAttacking();}
			else if (oldstate == "actionSelect") {UI.instance.exitActionSelect();}
			else if (oldstate == "itemSelect") {UI.instance.exitItemSelect();}
			else if (oldstate == "itemTarget") {UI.instance.exitItemTarget();}
			
			// newstate (starts the new state)
			if (newstate == "selectingButton") {UI.instance.enterSelectingButton();}
			else if (newstate == "enemySelect") {UI.instance.enterEnemySelect();}
			else if (newstate == "attacking") {UI.instance.enterAttacking();}
			else if (newstate == "actionSelect") {UI.instance.enterActionSelect();}
			else if (newstate == "itemSelect") {UI.instance.enterItemSelect();}
			else if (newstate == "itemTarget") {UI.instance.enterItemTarget();}
			else if (newstate == "enemyDialogue") {
				// Reset Kris' animation if necessary
				if (!Kris.instance.isDefending) {Kris.instance.gotoAndPlay("idle");}
				// Hide UI text
				UI.instance.setText("");
				// Create a dialogue bubble
				var textbubble:DialogueBubble = new DialogueBubble(screen.spamton.getDialogue(), "voice_sneo", function() {
					// Handle effects based on which text is playing
					if (screen.spamton.helpCount == 4) {screen.spamton.setAnimMode("defaultIdle");}
					else if (screen.spamton.helpCount == 5) {
						// Stop the music and start the laugh
						bgm.stop();
						screen.spamton.setAnimMode("laughing"); 
						// After the laugh, stop animating Spamton
						new Wait(180, function() {
							screen.spamton.setAnimMode("none"); 
							// Wait a little then do the final dialogue
							new Wait(45, function() {
								screen.spamton.nextDialogue = XMLToDialogue(dialogue.NEORant6); 
								screen.spamton.helpCount++; 
								setState("enemyDialogue");
							});
						});
					}
					// After the final text
					else if (screen.spamton.helpCount == 6) {
						// Black screen
						SoundLibrary.play("switch");
						var blackscreen:Pixel = new Pixel();
						blackscreen.width = 640;
						blackscreen.height = 480;
						blackscreen.transform.colorTransform = new ColorTransform(0, 0, 0);
						Main.screen.addChild(blackscreen);
						// Wait a moment
						new Wait(60, function() {
							// Play a sound
							SoundLibrary.play("iceshock");
							// Show the damage
							new Wait(30, function() {
								new DamageNumber(RandomRange(690, 710, 0), screen.spamton, "yellow", -40);
								SoundLibrary.play("enemydamage");
								new Wait(5, function() {
									new DamageNumber(RandomRange(690, 710, 0), screen.spamton, "yellow", -40, 30);
									SoundLibrary.play("enemydamage");
									new Wait(5, function() {
										new DamageNumber(RandomRange(690, 710, 0), screen.spamton, "yellow", -40);
										SoundLibrary.play("enemydamage");
										// Wait a moment and end the game
										new Wait(240, function() {fscommand("quit");;});
									});
								});
							});
						});
					}
					// Most of the time, start enemyAttack
					if (screen.spamton.helpCount < 5) {new Wait(2, function() {Main.setState("enemyAttack");});}
				});
				// Start an animation depending on the text
				if (screen.spamton.helpCount == 4) {screen.spamton.setAnimMode("angerShake");}
				// Position and show the dialogue bubble
				textbubble.x = 460;
				textbubble.y = 170;
				Main.screen.addChild(textbubble);
				// Randomly select flavor text
				if (!screen.spamton.bluelightMode) {UI.instance.displayText = getText("NEOFRandom" + RandomRange(1, 10, 0));}
				else {UI.instance.displayText = getText("NEOFBlue" + RandomRange(1, 2, 0));}
			}
			else if (newstate == "enemyAttack") {
				// Start the attack
				screen.addChild(screen.spamton.getAttack());
			}
		}
		
		// Game Over
		public static function gameOver():void {
			// Stop everything
			GlobalListener.clearEvents();
			bgm.stop();
			screen.spamton.head.stop();
			screen.kris.stop();
			for each (var b:Bullet in EnemyWave.currentWave.bullets) {b.stop();}
			Wait.clearQueue();
			RepeatUntil.clearQueue();
			Input.clearEvents();
			
			// Wait a bit
			new Wait(30, function() {
				// Death animation
				var explodingheart:PlayerDeathAnim = new PlayerDeathAnim();
				explodingheart.x = EnemyWave.currentWave.player.x;
				explodingheart.y = EnemyWave.currentWave.player.y;
				screen.addChild(explodingheart);
				
				// Destroy everything
				if (Player.shots.length > 0) {do {Player.shots[0].destroy();} while (Player.shots.length > 0);}
				EnemyWave.currentWave.endWave(false);
				setState("void");
				screen.spamton.destroy();
				screen.removeChild(screen.kris);
				screen.removeChild(TPMeter.instance);
				screen.removeChild(UI.instance);
				
				// Play music and show the GameOverScreen
				new Wait(160, function() {
					bgm = SoundLibrary.play("mus_defeat", 0.5, int.MAX_VALUE);
					screen.addChild(new GameOverScreen());
				});
			});
		}
		
		// Set up the game again post-GameOverScreen
		public static function reinitialize():void {
			// Kris
			screen.kris = new Kris();
			screen.kris.x = 76;
			screen.kris.y = 250;
			screen.kris.scaleX = 2;
			screen.kris.scaleY = 2;
			screen.addChild(screen.kris);
			
			// Spamton
			screen.spamton = new Spamton();
			screen.spamton.x = 460;
			screen.spamton.y = 254;
			screen.spamton.scaleX = 2;
			screen.spamton.scaleY = 2;
			screen.addChild(screen.spamton);
			
			// TPMeter
			var tpmeter:TPMeter = new TPMeter();
			tpmeter.x = 48;
			tpmeter.y = 233;
			screen.addChild(tpmeter);
			
			// UI
			var newUI:UI = new UI();
			newUI.x = 320;
			newUI.y = 365;
			screen.addChild(newUI);
			
			// Sounds and selectingButton
			bgm = SoundLibrary.play("mus_bigshot", 0.3, int.MAX_VALUE);
			setupInventory();
			setState("selectingButton");
		}
		
		// From the menu, start the game
		public static function startGame():void {
			bgm.stop();
			bgm = SoundLibrary.play("mus_bigshot", 0.3, int.MAX_VALUE);
			screen.changeMenu("none");
			screen.gotoAndStop(1, "Fight");
			setupInventory();
		}
		
		// Setup inventory and equipment
		private static function setupInventory():void {
			// Inventory
			Item.inventory = [];
			for each (var gameitem:Object in screen.selectedItems) {
				Item.inventory.push(gameitem.item);
			}
			
			// Equipement
			Kris.weapon = screen.selectedSword.item;
			Kris.armor = [];
			Kris.armor.push(screen.selectedArmorA.item);
			Kris.armor.push(screen.selectedArmorB.item);
		}
		
		// Setup mainMenu
		public function setupMenu():void {
			// TextFormats
			title.textfield.defaultTextFormat = titleFormat;
			txtTutorial.field.defaultTextFormat = titleFormat;
			txtStart.field.defaultTextFormat = titleFormat;
			txtItems.field.defaultTextFormat = titleFormat;
			txtTutorial.field.autoSize = TextFieldAutoSize.CENTER;
			txtTutorial.field.wordWrap = false;
			txtStart.field.autoSize = TextFieldAutoSize.CENTER;
			txtStart.field.wordWrap = false;
			txtItems.field.autoSize = TextFieldAutoSize.CENTER;
			txtItems.field.wordWrap = false;
			
			// Change texts
			title.textfield.text = getText("menuTitle");
			txtTutorial.field.text = getText("menuBtnTutorial");
			txtStart.field.text = getText("menuBtnStart");
			txtItems.field.text = getText("menuBtnItems");
			
			// Wait for the ComboBox to set itself up
			new Wait(1, function() {
				cmbLanguage.removeAll();
				// ComboBox for the languages
				for each (var _language:XML in LocalizationHandler.languages) {
					cmbLanguage.addItem({label: _language.langName, ref: _language});
				}
				// Start the game (debugging purposes)
				if (skipmenu == true) {startGame();}
			});
			
			// Add eventListeners
			txtStart.field.addEventListener(MouseEvent.ROLL_OVER, makeButtonYellow);
			txtStart.field.addEventListener(MouseEvent.ROLL_OUT, makeButtonWhite);
			txtStart.field.addEventListener(MouseEvent.CLICK, clickButton);
			txtItems.field.addEventListener(MouseEvent.ROLL_OVER, makeButtonYellow);
			txtItems.field.addEventListener(MouseEvent.ROLL_OUT, makeButtonWhite);
			txtItems.field.addEventListener(MouseEvent.CLICK, clickButton);
			txtTutorial.field.addEventListener(MouseEvent.ROLL_OVER, makeButtonYellow);
			txtTutorial.field.addEventListener(MouseEvent.ROLL_OUT, makeButtonWhite);
			txtTutorial.field.addEventListener(MouseEvent.CLICK, clickButton);
			cmbLanguage.addEventListener(Event.CHANGE, changeLanguage);
		}
		
		// Change languages
		private function changeLanguage(e:Event):void {
			dialogue = cmbLanguage.getItemAt(cmbLanguage.selectedIndex).ref;
			// Refresh mainMenu
			changeMenu("main");
			// Re-initiate items to have new names & descriptions
			new Item();
			// Searches for unchanged descriptions in already-selected items
			for each (var inventoryItem:Object in selectedItems) {
				for each (var anyItem:Object in Item.items) {
					if (inventoryItem.item.name == anyItem.name) {
						inventoryItem.item.info = anyItem.info;
					}
				}
			}
		}
		
		// Makes a button yellow and plays a sound
		private function makeButtonYellow(e):void {
			SoundLibrary.play("menumove", 0.3);
			e.target.textColor = 0xFFFF00;
		}
		
		// Sets the button back to white
		private function makeButtonWhite(e):void {
			e.target.textColor = 0xFFFFFF;
		}
		
		// Handle button clicks
		private function clickButton(e:MouseEvent):void {
			// In mainMenu
			if (currentFrameLabel == "mainMenu") {
				// txtStart start the game
				if (e.target == txtStart.field) {startGame();}
				// txtItems open the item menu
				else if (e.target == txtItems.field) {changeMenu("item");}
				// txtTutorial open the tutorial
				else if (e.target == txtTutorial.field) {changeMenu("tutorial");}
			}
			// In itemMenu
			else if (currentFrameLabel == "itemMenu") {
				// txtBack returns to mainMenu
				if (e.target == txtBack.field) {changeMenu("main");}
				// txtExport and txtImport handles XML stuff
				else if (e.target == txtExport.field) {saveInventory();}
				else if (e.target == txtImport.field) {openInventory();}
			}
			// In tutorialMenu
			else if (currentFrameLabel == "tutorialMenu") {
				// txtBack returns to mainMenu
				if (e.target == txtBack.field) {changeMenu("main");}
			}
			// Play a sound
			SoundLibrary.play("menuselect", 0.3);
		}
		
		// Changes the menu
		private function changeMenu(targetMenu:String):void {
			// Cleanup from last menu
			if (currentFrameLabel == "mainMenu") {
				txtStart.field.removeEventListener(MouseEvent.ROLL_OVER, makeButtonYellow);
				txtStart.field.removeEventListener(MouseEvent.ROLL_OUT, makeButtonWhite);
				txtStart.field.removeEventListener(MouseEvent.CLICK, clickButton);
				txtItems.field.removeEventListener(MouseEvent.ROLL_OVER, makeButtonYellow);
				txtItems.field.removeEventListener(MouseEvent.ROLL_OUT, makeButtonWhite);
				txtItems.field.removeEventListener(MouseEvent.CLICK, clickButton);
				txtTutorial.field.removeEventListener(MouseEvent.ROLL_OVER, makeButtonYellow);
				txtTutorial.field.removeEventListener(MouseEvent.ROLL_OUT, makeButtonWhite);
				txtTutorial.field.removeEventListener(MouseEvent.CLICK, clickButton);
				cmbLanguage.removeEventListener(Event.CHANGE, changeLanguage);
				makeButtonWhite({target: txtStart.field});
				makeButtonWhite({target: txtItems.field});
				makeButtonWhite({target: txtTutorial.field});
			}
			else if (currentFrameLabel == "itemMenu") {
				cmbSword.removeEventListener(Event.CHANGE, changeSelection);
				cmbArmorA.removeEventListener(Event.CHANGE, changeSelection);
				cmbArmorB.removeEventListener(Event.CHANGE, changeSelection);
				txtBack.field.removeEventListener(MouseEvent.ROLL_OVER, makeButtonYellow);
				txtBack.field.removeEventListener(MouseEvent.ROLL_OUT, makeButtonWhite);
				txtBack.field.removeEventListener(MouseEvent.CLICK, clickButton);
				for each (var _box:ComboBox in itemboxes) {_box.removeEventListener(Event.CHANGE, changeSelection);}
				itemboxes = null;
			}
			else if (currentFrameLabel == "tutorialMenu") {
				txtBack.field.removeEventListener(MouseEvent.ROLL_OVER, makeButtonYellow);
				txtBack.field.removeEventListener(MouseEvent.ROLL_OUT, makeButtonWhite);
				txtBack.field.removeEventListener(MouseEvent.CLICK, clickButton);
				tutorialObj.destroy();
			}
		
			// The new menu
			// To mainMenu
			if (targetMenu == "main") {
				gotoAndStop("mainMenu");
				setupMenu();
			}
			// To itemMenu
			else if (targetMenu == "item") {
				gotoAndStop("itemMenu");
				// Change TextFormats
				txtBack.field.defaultTextFormat = titleFormat;
				txtBack.field.autoSize = TextFieldAutoSize.CENTER;
				txtBack.field.wordWrap = false;
				txtEquipment.field.defaultTextFormat = titleFormat;
				txtEquipment.field.autoSize = TextFieldAutoSize.CENTER;
				txtEquipment.field.wordWrap = false;
				txtItems.field.defaultTextFormat = titleFormat;
				txtItems.field.autoSize = TextFieldAutoSize.CENTER;
				txtItems.field.wordWrap = false;
				txtImport.field.defaultTextFormat = titleFormat;
				txtImport.field.autoSize = TextFieldAutoSize.CENTER;
				txtImport.field.wordWrap = false;
				txtExport.field.defaultTextFormat = titleFormat;
				txtExport.field.autoSize = TextFieldAutoSize.CENTER;
				txtExport.field.wordWrap = false;
				
				// Sets texts
				title.textfield.text = getText("menuItemTitle");
				txtBack.field.text = getText("back");
				txtEquipment.field.text = getText("menuEquipment");
				txtItems.field.text = getText("menuBtnItems");
				txtImport.field.text = getText("menuImport") + "\n(XML)";
				txtExport.field.text = getText("menuExport") + "\n(XML)";
				
				// Set up equipment ComboBoxes
				for each (var sword:Object in Item.krisweapons) {
					cmbSword.addItem({label: sword.name + " (" + concatStat(sword.at) + "AT " + concatStat(sword.df) + "DF)", ref: sword});
				}
				for each (var armor:Object in Item.armors) {
					cmbArmorA.addItem({label: armor.name + " (" + concatStat(armor.df) + "DF " + concatStat(armor.at) + "AT)", ref: armor});
					cmbArmorB.addItem({label: armor.name + " (" + concatStat(armor.df) + "DF " + concatStat(armor.at) + "AT)", ref: armor});
				}
				cmbSword.sortItemsOn("label", "ASC");
				cmbArmorA.sortItemsOn("label", "ASC");
				cmbArmorB.sortItemsOn("label", "ASC");
				
				// Select the right items
				cmbSword.selectedIndex = selectedSword.index;
				cmbArmorA.selectedIndex = selectedArmorA.index;
				cmbArmorB.selectedIndex = selectedArmorB.index;
				
				// The items
				itemboxes = [cmbItem1, cmbItem2, cmbItem3, cmbItem4, cmbItem5, cmbItem6, cmbItem7, cmbItem8, cmbItem9, cmbItem10, cmbItem11, cmbItem12];
				for (var i:int = 0; i < itemboxes.length; i++) {
					// Setup ComboBoxes
					var box:ComboBox = itemboxes[i];
					box.dropdownWidth = box.width + 50;
					for each (var item:Object in Item.items) {
						var itemlabel:String = String(item.name + " (" + item.info + ")").replace(new RegExp(getText("itemHeal"), "g"), "+").replace(/\n/g, " ");
						box.addItem({label: itemlabel, ref: item});
					}
					box.sortItemsOn("label", "ASC");
					
					// Empty option for no item
					box.addItemAt({label: ""}, 0);
					
					// Select the right item (it remembers)
					if (i < selectedItems.length) {box.selectedIndex = selectedItems[i].index;}
					
					// Add eventListener
					box.addEventListener(Event.CHANGE, changeSelection);
				}
				
				// Add eventListeners
				cmbSword.addEventListener(Event.CHANGE, changeSelection);
				cmbArmorA.addEventListener(Event.CHANGE, changeSelection);
				cmbArmorB.addEventListener(Event.CHANGE, changeSelection);
				txtBack.field.addEventListener(MouseEvent.ROLL_OVER, makeButtonYellow);
				txtBack.field.addEventListener(MouseEvent.ROLL_OUT, makeButtonWhite);
				txtBack.field.addEventListener(MouseEvent.CLICK, clickButton);
				txtImport.field.addEventListener(MouseEvent.ROLL_OVER, makeButtonYellow);
				txtImport.field.addEventListener(MouseEvent.ROLL_OUT, makeButtonWhite);
				txtImport.field.addEventListener(MouseEvent.CLICK, clickButton);
				txtExport.field.addEventListener(MouseEvent.ROLL_OVER, makeButtonYellow);
				txtExport.field.addEventListener(MouseEvent.ROLL_OUT, makeButtonWhite);
				txtExport.field.addEventListener(MouseEvent.CLICK, clickButton);
			}
			// To tutorialMenu
			else if (targetMenu == "tutorial") {
				gotoAndStop("tutorialMenu");
				title.textfield.text = "";
				txtBack.defaultTextFormat = titleFormat;
				txtBack.field.autoSize = TextFieldAutoSize.CENTER;
				txtBack.field.wordWrap = false;
				txtBack.field.text = getText("back");
				txtBack.field.addEventListener(MouseEvent.ROLL_OVER, makeButtonYellow);
				txtBack.field.addEventListener(MouseEvent.ROLL_OUT, makeButtonWhite);
				txtBack.field.addEventListener(MouseEvent.CLICK, clickButton);
			}
		}
		
		// Handle changes to ComboBoxes in itemMenu
		private function changeSelection(e:Event):void {
			// Update the memory variables
			selectedSword = {index: cmbSword.selectedIndex, item: cmbSword.getItemAt(cmbSword.selectedIndex).ref};
			selectedArmorA = {index: cmbArmorA.selectedIndex, item: cmbArmorA.getItemAt(cmbArmorA.selectedIndex).ref};
			selectedArmorB = {index: cmbArmorB.selectedIndex, item: cmbArmorB.getItemAt(cmbArmorB.selectedIndex).ref};
			selectedItems = [];
			for each (var itembox:ComboBox in itemboxes) {
				var _item:Object = itembox.getItemAt(itembox.selectedIndex);
				// Only adds if a valid item is selected
				if (_item.label != "") {
					selectedItems.push({index: itembox.selectedIndex, item: _item.ref});
				}
			}
		}
		
		// Creates an XML file that corresponds to the current state of the itemMenu
		private function saveInventory():void {
			// Base XML object, add equipment
			var inventoryXML:XML = <spamtonItems>
				<sword>{selectedSword.index}</sword>
				<armorA>{selectedArmorA.index}</armorA>
				<armorB>{selectedArmorB.index}</armorB>
			</spamtonItems>;
			
			// Add items
			for each (var invItem:Object in selectedItems) {inventoryXML.appendChild(<item>{invItem.index}</item>);}
			
			// With user input, save to file
			new FileReference().save(inventoryXML, "InvPreset.xml");
		}
		
		// Open the file browser and load the selected file
		private function openInventory():void {
			// Keep a ref to FileReference and add an eventListener
			presetFile = new FileReference();
			presetFile.addEventListener(Event.SELECT, startLoad);
			// Open the file browser (filtered for .xml)
			presetFile.browse([new FileFilter("XML", "*.xml")]);
		}
		
		// Begin loading the file
		private function startLoad(e:Event):void {
			// Cleanup
			presetFile.removeEventListener(Event.SELECT, startLoad);
			// An eventListener and start loading
			presetFile.addEventListener(Event.COMPLETE, loadInventory);
			presetFile.load();
		}
		
		// Enact changes from the XML
		private function loadInventory(e:Event):void {
			// Cleanup and XML object setup
			presetFile.removeEventListener(Event.COMPLETE, loadInventory);
			var loadedData:XML = new XML(e.target.data);
			
			// Make sure the data is valid
			if (loadedData.hasOwnProperty("sword") && loadedData.hasOwnProperty("armorA") && loadedData.hasOwnProperty("armorB")) {
				// Undo error text
				title.textfield.text = getText("menuItemTitle");
				title.textfield.textColor = 0xFFFFFF;
				
				// Replace variables with XML data
				cmbSword.selectedIndex = loadedData.sword;
				cmbArmorA.selectedIndex = loadedData.armorA;
				cmbArmorB.selectedIndex = loadedData.armorB;
				// If the XML had items, fill the boxes with them
				if (loadedData.hasOwnProperty("item")) {for (var n:int = 0; n < itemboxes.length; n++) {itemboxes[n].selectedIndex = int(loadedData.item[n]);}}
				// Otherwise, all item ComboBoxes will be empty
				else {for each (var __box:ComboBox in itemboxes) {__box.selectedIndex = 0;}}
				
				// changeSelection() to solidify changes
				changeSelection(null);
			}
			// Alert user to invalid data
			else {
				SoundLibrary.play("err");
				title.textfield.text = getText("fileImportError");
				title.textfield.textColor = 0xFF0000;
				new Wait(10, function() {title.textfield.textColor = 0xFFFFFF;});
			}
		}
		
		// Replace null with 0 for stat display
		private function concatStat(n):Number {
			if (n == null) {return 0;}
			else {return n;}
		}
		
		// Return formatted string ripped from localization XML
		public static function getText(ref:String):String {
			return dialogue[ref].toString().replace(/\\n/g, "\n");
		}
	}
}
/*  
	Nom du fichier: Main.as
	Programmeur: William Mallette
	Date: 21/10/2021
	Description: Le classe de document
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
		
		// Choses de débogage (changez showDebugInfo à true pour voir l'info)
		private var showDebugInfo:Boolean = false;
		private var _time:Number;
		private var frames:int = 0;
		
		// Variables pour les menus
		private var titleFormat:TextFormat;
		private var itemboxes:Array;
		private var selectedSword:Object;
		private var selectedArmorA:Object;
		private var selectedArmorB:Object;
		private var selectedItems:Array = [];
		private var presetFile:FileReference;
		
		public function Main() {
			// Un référence à l'écran
			screen = this;
			
			// Établir titleFormat
			titleFormat = new TextFormat();
			titleFormat.align = TextFormatAlign.CENTER;
			titleFormat.letterSpacing = 4;
			
			// Initier le localization (dialogue)
			new LocalizationHandler();
			dialogue = LocalizationHandler.languages["french"];
			// Initier l'input
			new Input();
			// Initier les items (et les sélections par défaut)
			new Item();
			selectedSword = {index: 0, item: Item.krisweapons["BounceBlade"]};
			selectedArmorA = {index: 0, item: Item.armors["AmberCard"]};
			selectedArmorB = {index: 0, item: Item.armors["AmberCard"]};
			for (var i:int = 0; i < 12; i++) {selectedItems.push({index: 2, item: Item.items["CDBagel"]});}
			// Initier les sons
			new SoundLibrary();
			// Initier le GlobalListener
			new GlobalListener();
			
			// J'ai découvert qu'il y avait un problème avec les sons, qui causait beaucoup de lag
			// Cependant, ce problème n'arrivait pas lorsqu'il y avait déjà un son qui jouait.
			// Donc il faut toujours avoir un son qui joue
			bgm = SoundLibrary.play("mus_menu", 0.3, int.MAX_VALUE);
			
			// Initier le mainMenu
			setupMenu();
			
			// Choses de débogage
			_time = getTimer();
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		// À chaque frame,
		private function update(e:Event) {
			if (!isMenu) {
				if (showDebugInfo) {
					// J'ai utilisé ce site pour faire le compteur d'FPS: https://bit.ly/34QWpiO
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
		
		// Fonction qui agite l'écran
		public function shakeScreen(intensity:Number = 2) {
			// Générer deux nombres aléatoires entre -intensity et intensity
			var val_x:Number = RandomRange(-intensity, intensity);
			var val_y:Number = RandomRange(-intensity, intensity);
			// Déplacer l'écran par les valeurs générés
			screen.x += val_x;
			screen.y += val_y;
			// Après 5 frames, reset le déplacement
			new Wait(5, function():void {
				screen.x -= val_x;
				screen.y -= val_y;
			});
		}
		
		// Changer l'état du jeu (gère les contrôles, les objets, etc.)
		public static function setState(newstate:String):void {
			// Changer les variables
			oldstate = gameState;
			gameState = newstate;
			
			// oldstate (terminer l'état courant)
			if (oldstate == "selectingButton") {UI.instance.exitSelectingButton();}
			else if (oldstate == "enemySelect") {UI.instance.exitEnemySelect();}
			else if (oldstate == "attacking") {UI.instance.exitAttacking();}
			else if (oldstate == "actionSelect") {UI.instance.exitActionSelect();}
			else if (oldstate == "itemSelect") {UI.instance.exitItemSelect();}
			else if (oldstate == "itemTarget") {UI.instance.exitItemTarget();}
			
			// newstate (commencer une nouvelle état)
			if (newstate == "selectingButton") {UI.instance.enterSelectingButton();}
			else if (newstate == "enemySelect") {UI.instance.enterEnemySelect();}
			else if (newstate == "attacking") {UI.instance.enterAttacking();}
			else if (newstate == "actionSelect") {UI.instance.enterActionSelect();}
			else if (newstate == "itemSelect") {UI.instance.enterItemSelect();}
			else if (newstate == "itemTarget") {UI.instance.enterItemTarget();}
			else if (newstate == "enemyDialogue") {
				// Reset l'animation de Kris si nécessaire
				if (!Kris.instance.isDefending) {Kris.instance.gotoAndPlay("idle");}
				// Cacher le texte de l'UI
				UI.instance.setText("");
				// Créer le DialogueBubble
				var textbubble:DialogueBubble = new DialogueBubble(screen.spamton.getDialogue(), "voice_sneo", function() {
					// Des effets qui dépendant de quelle texte vient de terminer (celles-ci sont plutôt au fin du jeu)
					if (screen.spamton.helpCount == 4) {screen.spamton.setAnimMode("defaultIdle");}
					else if (screen.spamton.helpCount == 5) {
						// Arrêter la musique et commencer à rire
						bgm.stop();
						screen.spamton.setAnimMode("laughing"); 
						// Après le rire, arrêter l'animation de Spamton
						new Wait(180, function() {
							screen.spamton.setAnimMode("none"); 
							// Attendre un peu et faire la dialogue finale
							new Wait(45, function() {
								screen.spamton.nextDialogue = XMLToDialogue(dialogue.NEORant6); 
								screen.spamton.helpCount++; 
								setState("enemyDialogue");
							});
						});
					}
					// Après la dialogue finale
					else if (screen.spamton.helpCount == 6) {
						// Un écran noir
						SoundLibrary.play("switch");
						var blackscreen:Pixel = new Pixel();
						blackscreen.width = 640;
						blackscreen.height = 480;
						blackscreen.transform.colorTransform = new ColorTransform(0, 0, 0);
						Main.screen.addChild(blackscreen);
						// Attendre un moment
						new Wait(60, function() {
							// Jouer un son
							SoundLibrary.play("iceshock");
							// Montrer le dommage et jouer un son (3 fois, avec un petit délai entre chacun)
							new Wait(30, function() {
								new DamageNumber(RandomRange(690, 710, 0), screen.spamton, "yellow", -40);
								SoundLibrary.play("enemydamage");
								new Wait(5, function() {
									new DamageNumber(RandomRange(690, 710, 0), screen.spamton, "yellow", -40, 30);
									SoundLibrary.play("enemydamage");
									new Wait(5, function() {
										new DamageNumber(RandomRange(690, 710, 0), screen.spamton, "yellow", -40);
										SoundLibrary.play("enemydamage");
										// Attendre un moment, fermer le jeu
										new Wait(240, function() {fscommand("quit");;});
									});
								});
							});
						});
					}
					// La plupart du temps, commence enemyAttack
					if (screen.spamton.helpCount < 5) {new Wait(2, function() {Main.setState("enemyAttack");});}
				});
				// Commencer un animation dépendant du texte
				if (screen.spamton.helpCount == 4) {screen.spamton.setAnimMode("angerShake");}
				// Positionner et montrer le DialogueBubble
				textbubble.x = 460;
				textbubble.y = 170;
				Main.screen.addChild(textbubble);
				// Changer le "flavor text" de l'UI aléatoirement
				if (!screen.spamton.bluelightMode) {UI.instance.displayText = getText("NEOFRandom" + RandomRange(1, 10, 0));}
				else {UI.instance.displayText = getText("NEOFBlue" + RandomRange(1, 2, 0));}
			}
			else if (newstate == "enemyAttack") {
				// Commencer l'attaque de l'ennemi
				screen.addChild(screen.spamton.getAttack());
			}
		}
		
		// Le Game Over
		public static function gameOver():void {
			// Arrêter tout
			GlobalListener.clearEvents();
			bgm.stop();
			screen.spamton.head.stop();
			screen.kris.stop();
			for each (var b:Bullet in EnemyWave.currentWave.bullets) {b.stop();}
			Wait.clearQueue();
			RepeatUntil.clearQueue();
			Input.clearEvents();
			
			// Après un délai
			new Wait(30, function() {
				// Créer l'animation de mort
				var explodingheart:PlayerDeathAnim = new PlayerDeathAnim();
				explodingheart.x = EnemyWave.currentWave.player.x;
				explodingheart.y = EnemyWave.currentWave.player.y;
				screen.addChild(explodingheart);
				
				// Détruire tout
				if (Player.shots.length > 0) {do {Player.shots[0].destroy();} while (Player.shots.length > 0);}
				EnemyWave.currentWave.endWave(false);
				setState("void");
				screen.spamton.destroy();
				screen.removeChild(screen.kris);
				screen.removeChild(TPMeter.instance);
				screen.removeChild(UI.instance);
				
				// Jouer la musique et créer le GameOverScreen
				new Wait(160, function() {
					bgm = SoundLibrary.play("mus_defeat", 0.5, int.MAX_VALUE);
					screen.addChild(new GameOverScreen());
				});
			});
		}
		
		// Set up le jeu après un GameOver
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
			
			// Son et selectingButton
			bgm = SoundLibrary.play("mus_bigshot", 0.3, int.MAX_VALUE);
			setupInventory();
			setState("selectingButton");
		}
		
		// Provenant du menu, commence le jeu
		public static function startGame():void {
			bgm.stop();
			bgm = SoundLibrary.play("mus_bigshot", 0.3, int.MAX_VALUE);
			screen.changeMenu("none");
			screen.gotoAndStop(1, "Jeu");
			setupInventory();
		}
		
		// Établir l'inventory et l'équipement 
		private static function setupInventory():void {
			// L'inventory
			Item.inventory = [];
			for each (var gameitem:Object in screen.selectedItems) {
				Item.inventory.push(gameitem.item);
			}
			
			// L'équipement
			Kris.weapon = screen.selectedSword.item;
			Kris.armor = [];
			Kris.armor.push(screen.selectedArmorA.item);
			Kris.armor.push(screen.selectedArmorB.item);
		}
		
		// Set up le mainMenu
		public function setupMenu():void {
			// Les TextFormats
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
			
			// Changer les textes
			title.textfield.text = getText("menuTitle");
			txtTutorial.field.text = getText("menuBtnTutorial");
			txtStart.field.text = getText("menuBtnStart");
			txtItems.field.text = getText("menuBtnItems");
			
			// Attendre pour que le ComboBox s'initie
			new Wait(1, function() {
				cmbLanguage.removeAll();
				// Setup le combobox des languages
				for each (var _language:XML in LocalizationHandler.languages) {
					cmbLanguage.addItem({label: _language.langName, ref: _language});
				}
			});
			
			// Ajouter les eventListeners
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
		
		// Changer le language
		private function changeLanguage(e:Event):void {
			dialogue = cmbLanguage.getItemAt(cmbLanguage.selectedIndex).ref;
			// Refresh le mainMenu
			changeMenu("main");
			// Réinitier Item pour avoir les nouvelles descriptions
			new Item();
			// Algorithme de recherche pour changer les descriptions des items déjà sélectionnés
			for each (var inventoryItem:Object in selectedItems) {
				for each (var anyItem:Object in Item.items) {
					if (inventoryItem.item.name == anyItem.name) {
						inventoryItem.item.info = anyItem.info;
					}
				}
			}
		}
		
		// Changer un bouton à jaune et jouer un son
		private function makeButtonYellow(e):void {
			SoundLibrary.play("menumove", 0.3);
			e.target.textColor = 0xFFFF00;
		}
		
		// Mettre le couleur d'un bouton à blanc encore
		private function makeButtonWhite(e):void {
			e.target.textColor = 0xFFFFFF;
		}
		
		// Répondre à un clic d'un bouton
		private function clickButton(e:MouseEvent):void {
			// Le mainMenu
			if (currentFrameLabel == "mainMenu") {
				// txtStart commence le jeu
				if (e.target == txtStart.field) {startGame();}
				// txtItems ouvre le itemMenu
				else if (e.target == txtItems.field) {changeMenu("item");}
				// txtTutorial ouvre le tutorial
				else if (e.target == txtTutorial.field) {changeMenu("tutorial");}
			}
			// Le itemMenu
			else if (currentFrameLabel == "itemMenu") {
				// txtBack retour au mainMenu
				if (e.target == txtBack.field) {changeMenu("main");}
				// txtExport et txtImport commencent le processus de charger l'XML
				else if (e.target == txtExport.field) {saveInventory();}
				else if (e.target == txtImport.field) {openInventory();}
			}
			// Le tutorialMenu
			else if (currentFrameLabel == "tutorialMenu") {
				// txtBack retour au mainMenu
				if (e.target == txtBack.field) {changeMenu("main");}
			}
			// Jouer un son
			SoundLibrary.play("menuselect", 0.3);
		}
		
		// Changer de menu
		private function changeMenu(targetMenu:String):void {
			// Dépendant de quel menu on change de, effectue des fonctions différents pour nettoyer tout
			// Enlever les eventListeners, changer des variables, mettre des références à null
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
		
			// Le nouveau menu
			// À mainMenu
			if (targetMenu == "main") {
				gotoAndStop("mainMenu");
				setupMenu();
			}
			// À itemMenu
			else if (targetMenu == "item") {
				gotoAndStop("itemMenu");
				// Changer les TextFormat des textes
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
				
				// Changer les textes
				title.textfield.text = getText("menuItemTitle");
				txtBack.field.text = getText("back");
				txtEquipment.field.text = getText("menuEquipment");
				txtItems.field.text = getText("menuBtnItems");
				txtImport.field.text = getText("menuImport") + "\n(XML)";
				txtExport.field.text = getText("menuExport") + "\n(XML)";
				
				// Établir les ComboBox à gauche (l'équipement)
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
				
				// Sélectionner le bon item (ça souvient des vieux sélections)
				cmbSword.selectedIndex = selectedSword.index;
				cmbArmorA.selectedIndex = selectedArmorA.index;
				cmbArmorB.selectedIndex = selectedArmorB.index;
				
				// Les items
				itemboxes = [cmbItem1, cmbItem2, cmbItem3, cmbItem4, cmbItem5, cmbItem6, cmbItem7, cmbItem8, cmbItem9, cmbItem10, cmbItem11, cmbItem12];
				for (var i:int = 0; i < itemboxes.length; i++) {
					// Établir les ComboBox
					var box:ComboBox = itemboxes[i];
					box.dropdownWidth = box.width + 50;
					for each (var item:Object in Item.items) {
						var itemlabel:String = String(item.name + " (" + item.info + ")").replace(new RegExp(getText("itemHeal"), "g"), "+").replace(/\n/g, " ");
						box.addItem({label: itemlabel, ref: item});
					}
					box.sortItemsOn("label", "ASC");
					
					// Un option vide
					box.addItemAt({label: ""}, 0);
					
					// Sélectionner le bon item (ça souvient des vieux sélections)
					if (i < selectedItems.length) {box.selectedIndex = selectedItems[i].index;}
					
					// Ajouter l'eventListener
					box.addEventListener(Event.CHANGE, changeSelection);
				}
				
				// Ajouter les eventListeners
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
			// À tutorialMenu
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
		
		// Lorsqu'on change de sélection d'un ComboBox en itemMenu
		private function changeSelection(e:Event):void {
			// Mettre à jour les variables qui souviennent des sélections
			selectedSword = {index: cmbSword.selectedIndex, item: cmbSword.getItemAt(cmbSword.selectedIndex).ref};
			selectedArmorA = {index: cmbArmorA.selectedIndex, item: cmbArmorA.getItemAt(cmbArmorA.selectedIndex).ref};
			selectedArmorB = {index: cmbArmorB.selectedIndex, item: cmbArmorB.getItemAt(cmbArmorB.selectedIndex).ref};
			selectedItems = [];
			for each (var itembox:ComboBox in itemboxes) {
				var _item:Object = itembox.getItemAt(itembox.selectedIndex);
				// Ajouter seulement si un item valid est sélectionné
				if (_item.label != "") {
					selectedItems.push({index: itembox.selectedIndex, item: _item.ref});
				}
			}
		}
		
		// Créer un fichier XML de l'état courant du itemMenu
		private function saveInventory():void {
			// L'objet XML, l'épée et les armures
			var inventoryXML:XML = <spamtonItems>
				<sword>{selectedSword.index}</sword>
				<armorA>{selectedArmorA.index}</armorA>
				<armorB>{selectedArmorB.index}</armorB>
			</spamtonItems>;
			
			// Ajouter les items
			for each (var invItem:Object in selectedItems) {inventoryXML.appendChild(<item>{invItem.index}</item>);}
			
			// Avec l'input de l'utilisateur, sauvegarder un fichier avec le data XML ci-dessus
			new FileReference().save(inventoryXML, "InvPreset.xml");
		}
		
		// Ouvrir le File Browser et commencer à charger le fichier sélectionné lorsqu'il y a un
		private function openInventory():void {
			// Garder référence au FileReference et ajouter le premier eventListener
			presetFile = new FileReference();
			presetFile.addEventListener(Event.SELECT, startLoad);
			// Ouvre le File Browser, filtrer pour des fichiers XML
			presetFile.browse([new FileFilter("XML", "*.xml")]);
		}
		
		// Commencer à charger le fichier
		private function startLoad(e:Event):void {
			// Cleanup
			presetFile.removeEventListener(Event.SELECT, startLoad);
			// Un eventListener et commence le chargement
			presetFile.addEventListener(Event.COMPLETE, loadInventory);
			presetFile.load();
		}
		
		// Effectuer les changements selon le fichier chargé
		private function loadInventory(e:Event):void {
			// Cleanup et établissement de l'objet XML
			presetFile.removeEventListener(Event.COMPLETE, loadInventory);
			var loadedData:XML = new XML(e.target.data);
			
			// Vérifier que le data est valide
			if (loadedData.hasOwnProperty("sword") && loadedData.hasOwnProperty("armorA") && loadedData.hasOwnProperty("armorB")) {
				// Reset le titre du page s'il y avait un erreur avant
				title.textfield.text = getText("menuItemTitle");
				title.textfield.textColor = 0xFFFFFF;
				
				// Remplacer des variables selon les données du fichier sélectionné
				cmbSword.selectedIndex = loadedData.sword;
				cmbArmorA.selectedIndex = loadedData.armorA;
				cmbArmorB.selectedIndex = loadedData.armorB;
				// S'il y a des items dans l'XML, remplacer les boites
				if (loadedData.hasOwnProperty("item")) {for (var n:int = 0; n < itemboxes.length; n++) {itemboxes[n].selectedIndex = int(loadedData.item[n]);}}
				// Si non, vider tout les boites d'items
				else {for each (var __box:ComboBox in itemboxes) {__box.selectedIndex = 0;}}
				
				// Effectuer changeSelection() pour solidifier les changements
				changeSelection(null);
			}
			// Si non, jouer un son et avertir l'utilisateur
			else {
				SoundLibrary.play("err");
				title.textfield.text = getText("fileImportError");
				title.textfield.textColor = 0xFF0000;
				new Wait(10, function() {title.textfield.textColor = 0xFFFFFF;});
			}
		}
		
		// Transforme null en 0 pour faciliter l'affichage des statistiques
		private function concatStat(n):Number {
			if (n == null) {return 0;}
			else {return n;}
		}
		
		// Retourner une piàce de dialogue en forme de String formatté
		public static function getText(ref:String):String {
			return dialogue[ref].toString().replace(/\\n/g, "\n");
		}
	}
}
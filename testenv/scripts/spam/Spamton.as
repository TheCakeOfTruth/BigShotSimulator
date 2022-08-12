/*
	File Name: Spamton.as
	Programmeur: William Mallette
	Date: 14-11-2021
	Description: L'ennemi
*/

package scripts.spam {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.media.SoundTransform;
	import scripts.SoundLibrary;
	import scripts.Kris;
	import scripts.Player;
	import scripts.DamageNumber;
	import scripts.DialogueBubble;
	import scripts.EnemyWave;
	import scripts.ui.UI;
	import scripts.ui.TPMeter;
	import scripts.ui.MenuOption;
	import scripts.utils.Wait;
	import scripts.utils.BetterRound;
	import scripts.utils.RepeatUntil;
	import scripts.utils.XMLToDialogue;
	import scripts.utils.RandomRange;
	import scripts.utils.BetterSoundChannel;
	import scripts.attacks.*;
	
	public class Spamton extends MovieClip {
		public var parts:Array;
		public var attacks:Array;
		private var attackID:int = -1;
		private var part:SpamtonPart;
		public var animMode:String;
		public var actions:Array = [];
		public var maxhp:Number = 4809;
		public var hp:Number = 4809;
		public var attack:Number = 13;
		public var defense:Number = -27;
		public var nextDialogue:Array;
		public var bluelightMode:Boolean = false;
		public var helpCount:int = 0;
		
		private var checktext:XMLList;
		private var dialogueChain:int = 0;
		
	
		// constructor
		public function Spamton() {
			new Wait(1, function() {checktext = Main.dialogue.spamNeoCheck1;});
			// Les SpamtonParts et les attaques
			parts = [rarm, rwing, rleg, lleg, body, larm, lwing, head, body];
			attacks = [FlyingHeads, RollerCoaster, HeartAttack, PipisForYou];
			// Commencer l'animation
			setAnimMode("defaultIdle");
			head.enableRotation = false;
			
			////////// Les options (ACT)
			// Check, donne des infos
			var check:MenuOption = new MenuOption(-311, 19, "Check");
			check.txt.x -= 6;
			check.effect = function() {
				Main.setState("actionResult"); 
				UI.instance.setText(checktext, function() {Main.setState("enemyDialogue");});
				UI.instance.hideMenu();
				UI.instance.info.icon.gotoAndStop("act");
				Kris.instance.gotoAndPlay("act");
				checktext = Main.dialogue.spamNeoCheck2;
			}
			check.toggleSelection(true);
			actions.push(check);
			
			// X-Slash (endommage Spamton)
			var xslash:MenuOption = new MenuOption(-87, 19, "X-Slash");
			xslash.effect = function() {
				// Dépenser le TP
				TPMeter.instance.setTP(TPMeter.instance.tp - (25 / 100) * 250);
				// Transition
				Main.setState("actionResult");
				UI.instance.hideMenu();
				UI.instance.setText(Main.getText("XSlash"), function() {Main.setState("enemyDialogue");});
				// Le dommage
				var dmg:Number = Math.round(1.25 * (((Kris.instance.calculateAttack() * 150) / 20) - 3 * Main.screen.spamton.defense));
				// Animation et son
				Kris.instance.gotoAndPlay("fight");
				SoundLibrary.play("xslash", 0.5);
				// damage
				damage(dmg, false, false);
				// Attendre 1/2 seconde
				new Wait(30, function() {
					// Animation et son
					Kris.instance.gotoAndPlay("fight");
					SoundLibrary.play("xslash", 0.5);
					// damage
					damage(dmg, false, true, true);
				});
			}
			xslash.description = Main.getText("damageDesc");
			xslash.TPCost = 25;
			actions.push(xslash);
			
			// FriedPipis (heal le Player)
			var friedpipis:MenuOption = new MenuOption(-311, 49, "FriedPipis");
			friedpipis.effect = function() {
				TPMeter.instance.setTP(TPMeter.instance.tp - (32 / 100) * 250);
				Main.setState("actionResult");
				UI.instance.info.icon.gotoAndStop("act");
				UI.instance.hideMenu();
				UI.instance.setText(Main.getText("pipisHeal"), function() {UI.instance.info.icon.gotoAndStop("head"); Main.setState("enemyDialogue");});
				
				// Le pipis
				var healingpipis:Sprite = new Sprite();
				var img:Bitmap = new Bitmap(new pipisImg(0,0));
				healingpipis.addChild(img);
				img.x -= img.width / 2;
				img.y -= img.height / 2;
				healingpipis.scaleX = 0;
				healingpipis.scaleY = 0;
				healingpipis.x = Kris.instance.x + 85;
				healingpipis.y = Kris.instance.y - 22;
				Main.screen.addChild(healingpipis);
				
				// Bouger le pipis vers Kris
				var moveToKris:Function = function() {
					// Petit délai
					new Wait(20, function() {
						// Bouger
						new RepeatUntil(function () {healingpipis.x -= 4}, function() {
							if (healingpipis.x <= Kris.instance.x + 20) {
								// Animation de disparition du pipis
								new RepeatUntil(function() {
									healingpipis.scaleX += 0.04;
									healingpipis.scaleY += 0.04;
									healingpipis.alpha -= 0.03;
								}, function() {
									if (healingpipis.alpha <= 0) {
										Main.screen.removeChild(healingpipis);
										return true;
									}
								});
								// Heal le Player
								Player.heal(120);
								// Arrêter de bouger
								return true;
							}
						});
					});
				}
				// Jouer un son
				SoundLibrary.play("healspell", 0.5);
				// Animation d'apparition du pipis
				new RepeatUntil(function() {
					healingpipis.scaleX += 0.05;
					healingpipis.scaleY += 0.05;
					healingpipis.rotation -= 18;
				}, function() {if (healingpipis.scaleX >= 1) {
					// Commencer de bouger
					moveToKris();
					return true;
				}});
				// Animer Kris
				Kris.instance.gotoAndPlay("act");
			}
			friedpipis.description = Main.getText("itemHeal") + "\n120 HP";
			friedpipis.txt.x -=6;
			friedpipis.TPCost = 32;
			actions.push(friedpipis);
		}
		
		// Retourner quelle dialogue à utiliser
		public function getDialogue():Array {
			// nextDialogue override le système ici
			if (nextDialogue == null) {
				// Les premiers 10 tournes ont la dialogue linéaire, après ça utiliser la dialogue random
				// bluelightMode répète le même chose si qu'on ne choisi pas l'option d'ACT
				dialogueChain++;
				if (bluelightMode) {return XMLToDialogue(Main.dialogue.NEOFireworks2);}
				else if (dialogueChain <= 10) {return XMLToDialogue(Main.dialogue["NEODialogue" + dialogueChain]);}
				else {return XMLToDialogue(Main.dialogue["NEODRandom" + RandomRange(1, 6, 0)]);}
			}
			else {
				// Effacer nextDialogue pour le prochain turn
				var txt:Array = nextDialogue;
				nextDialogue = null;
				return txt;
			}
		}
		
		// Retourner une attaque
		public function getAttack():EnemyWave {
			attackID = (attackID + 1) % attacks.length;
			return new attacks[attackID]();
		}
		
		// Endommager
		public function damage(n:int, doSound:Boolean = true, resetAnim:Boolean = true, mirrorSlash:Boolean = false):void {
			// L'effet de slash
			var slash:DamageSlash = new DamageSlash();
			slash.x = this.x + 20;
			slash.y = this.y - 100;
			slash.scaleX = 2;
			slash.scaleY = 2;
			if (mirrorSlash) {
				slash.scaleX *= -1
				slash.x += 100
			}
			Main.screen.addChild(slash);
			
			// Jouer un son, montrer et effectuer le dommage
			new Wait(15, function() {
				// Pauser l'animation, jouer une animation rapide d'endommagement
				head.gotoAndStop(1);
				head.rotation = -15;
				
				forAllParts(function() {
					part.enableRotation = false;
					var signs:Array = [-1, 1];
					if (part != body) {
						part.rotation =  signs[Math.floor(Math.random() * 2)] * 20 * Math.random();
					}
				});
				
				// Imiter la défense augmenté pendant bluelight mode
				if (bluelightMode) {n = RandomRange(5, 11, 0);}
				
				if (doSound) {SoundLibrary.play("enemydamage", 0.5);}
				new DamageNumber(n, Main.screen.spamton, "blue", -40); 
				shake(); 
				UI.instance.info.icon.gotoAndStop("head");
				hp -= n;
				// Ne pas dépasser 278.54 HP
				hp = Math.max(278.54, hp);
				
				// Lorsqu'on dépasse 15% de maxhp, commence le "bluelight specil"
				if (hp < 0.15 * maxhp && !bluelightMode && resetAnim) {startBluelight();}
				// Normalement,
				else {
					// Recommencer l'animation
					if (resetAnim) {
						new Wait(25, function() {
							Kris.instance.gotoAndPlay("idle");
							head.rotation = 0;
							head.play();
							forAllParts(function() {part.enableRotation = true;});
							if (!mirrorSlash) {Main.setState("enemyDialogue");}
						});
					}
				}
			});
		}
		
		// Commencer bluelightMode, le fin du jeu
		private function startBluelight():void {
			// Setup
			bluelightMode = true;
			Kris.instance.gotoAndPlay("idle");
			UI.instance.setText("");
			Main.setState("none");
			Main.bgm.fadeOut();
			
			// Attendre une seconde
			new Wait(60, function() {
				// Commencer la dialogue.
				var textbubble:DialogueBubble = new DialogueBubble(Main.dialogue.NEOLowHP, "voice_sneo", function() {
					new Wait(2, function() {
						// Lorsque la dialogue termine, jouer l'animation et indiquer à l'utilisateur que les stats de Spamton ont changés
						SoundLibrary.play("specil");
						forAllParts(function() {part.rotateToSmart(0);}, false);
						Main.setState("actionResult");
						UI.instance.setText(Main.dialogue.NEOBluelight, function() {
							// Lorsque l'utilisateur avance le texte, recommencer l'animation, jouer la musique, et avance à enemyDialogue
							nextDialogue = XMLToDialogue(Main.dialogue.NEOFireworks);
							forAllParts(function() {part.enableRotation = true;});
							head.play();
							Main.bgm = SoundLibrary.play("mus_gonewrong", 0.3, int.MAX_VALUE);
							Main.setState("enemyDialogue");
						});
					});
				})
				textbubble.x = 460;
				textbubble.y = 170;
				Main.screen.addChild(textbubble);
			});
			
			// Les vieux options ACT disparaissent, remplacés par ceci
			actions = [];
			var resultText:XMLList = Main.dialogue.callForHelp;
			var help:MenuOption = new MenuOption(-311, 19, "");
			// Lorsqu'on l'utilise,
			help.effect = function() {
				// Avancer helpCount
				helpCount++;
				// Dépendant du helpCount, changer l'icone et la dernière fois, la dialogue aussi
				if (helpCount == 2) {help.icon.bitmapData = new SusieIcon(0,0);}
				else if (helpCount == 4) {help.icon.bitmapData = new NoelleIcon(0,0);}
				else if	(helpCount == 5) {resultText = Main.dialogue.callForHer;}
				// Avancer comme n'importe quel autre option ACT
				Main.setState("actionResult");
				UI.instance.setText(XMLToDialogue(resultText), function() {
					UI.instance.info.icon.gotoAndStop("head");
					// Utilise la dialogue du branche NEORant
					nextDialogue = XMLToDialogue(Main.dialogue["NEORant" + helpCount]);
					Main.setState("enemyDialogue");
				});
				UI.instance.hideMenu();
				UI.instance.info.icon.gotoAndStop("act");
				Kris.instance.gotoAndPlay("act");
			}
			// Créer l'icone et valider le MenuOption
			help.createIcon(new RalseiIcon(0,0));
			help.toggleSelection(true);
			actions.push(help);
		}
		
		// Fonction qui agite Spamton
		public function shake(intensity:Number = 2) {
			// Générer deux nombres aléatoires avec la signe choisi aléatoirement
			var val_x:Number = RandomRange(-intensity, intensity);
			var val_y:Number = RandomRange(-intensity, intensity);
			// Déplacer Spamton par les valeurs générés
			Main.screen.spamton.x += val_x;
			Main.screen.spamton.y += val_y;
			// Après 5 frames, reset le déplacement
			new Wait(5, function():void {
				Main.screen.spamton.x -= val_x;
				Main.screen.spamton.y -= val_y;
			});
		}
		
		// Changer l'animation
		public function setAnimMode(mode:String):void {
			animMode = mode;
			if (mode == "defaultIdle") {
				// Chaque SpamtonPart sauf la tête change de rotation périodiquement
				rarm.setRotValues(10, -20, 0.07);
				rwing.setRotValues(10, -20, 0.09);
				rleg.setRotValues(10, -10, 0.05);
				lleg.setRotValues(10, -10, 0.055, 0.2);
				body.setRotValues(-10, 10, 0.065);
				larm.setRotValues(10, -10, 0.05, 0.2);
				lwing.setRotValues(20, -10, 0.03);
				forAllParts(function() {part.enableRotation = true;});
				head.rotation = 0;
				head.gotoAndPlay("default_HeadSwitch");
			}
			else if (mode == "angerShake") {
				// Arrêter l'animation de la tête, et la rotation des autres SpamtonParts
				head.gotoAndStop(1);
				forAllParts(function() {part.enableRotation = false});
				// Périodiquement, changer la rotation de chaque SpamtonPart (sauf la tête) aléatoirement
				var changeRotTimer:int = 0;
				new RepeatUntil(function() {
					changeRotTimer = (changeRotTimer + 1) % 30;
					if (changeRotTimer == 0) {
						forAllParts(function() {part.rotation = RandomRange(-30, 30);});
						// Changer l'image de la tête
						if (head.currentFrame == 1) {head.rotation = 0; head.gotoAndStop(61);}
						else {head.rotation = -20; head.gotoAndStop(1);}
					}
					// Agiter chaque SpamtonPart (sauf la tête)
					forAllParts(function() {part.shake(1);});
				}, function() {if (animMode != "angerShake") {return true;}});
			}
			else if (mode == "laughing") {
				// Setup
				head.gotoAndStop(1);
				forAllParts(function() {part.enableRotation = false;});
				// Jouer le son de rire
				var laughsound:BetterSoundChannel = SoundLibrary.play("laugh");
				new RepeatUntil(function() {
					// Agiter les SpamtonParts en même temps
					forAllParts(function() {part.shake(0.75);});
					// Animer la tête selon le son
					if (laughsound.position < 1000) {head.minRotation = -50;}
					else if (laughsound.position > 1000 && laughsound.position < 1500) {head.minRotation = 20; head.gotoAndStop(31);}
					else if (laughsound.position > 1500 && laughsound.position < 2000) {head.minRotation = -10; head.gotoAndStop(61);}
					else {head.minRotation = 15;}
					head.rotation = RandomRange(head.minRotation - 2, head.minRotation + 2);
				}, function() {if (animMode != "laughing") {return true;}});
			}
		}
		
		// Itérer pour chaque SpamtonPart
		public function forAllParts(fToDo:Function, excludeHead:Boolean = true):void {
			for each (part in parts) {
				// Exclure la tête si spécifié
				if (excludeHead == true) {
					if (part != head) {fToDo.call();}
				}
				else {
					fToDo.call();
				}
			}
			part = null;
		}
		
		// Détruire l'objet
		public function destroy():void {
			// Effectuer les méthodes destroy() pour chaque SpamtonPart
			forAllParts(function() {part.destroy();}, false);
			part = null;
			parts = [];
			// Enlever l'objet de l'écran
			this.parent.removeChild(this);
		}
	}
}
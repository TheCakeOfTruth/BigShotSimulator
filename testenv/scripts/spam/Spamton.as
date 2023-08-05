/*
	Date: 14-11-2021
	Description: The BIG SHOT
*/

package scripts.spam {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.media.SoundTransform;
	import flash.geom.ColorTransform;
	import scripts.SoundLibrary;
	import scripts.party.Kris;
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
	import scripts.effects.SmokeSpawner;
	import scripts.attacks.*;
	
	public class Spamton extends MovieClip {
		public var container:SpamtonContainer;
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
		public var enraged:Boolean = false;
		
		private var checktext:XMLList;
		private var dialogueChain:int = 0;
		
	
		// Constructor
		public function Spamton() {		
			new Wait(1, function() {checktext = Main.dialogue.spamNeoCheck1;});
			// His parts and his attacks
			parts = [rarm, rwing, rleg, lleg, body, larm, lwing, head, body];
			attacks = [FlyingHeads, RollerCoaster, HeartAttack, PipisForYou];
			// attacks = [PhoneCrawl];
			// Begin the animation
			setAnimMode("defaultIdle");
			head.enableRotation = false;
			
			////////// ACT options
			// Check
			var check:MenuOption = new MenuOption(-311, 19, "Check");
			check.txt.x -= 6;
			check.effect = function() {
				Main.setState("actionResult"); 
				/*
				UI.instance.setText(checktext, function() {Main.setState("enemyDialogue");});
				UI.instance.hideMenu();
				UI.instance.info.icon.gotoAndStop("act");
				*/
				Main.screen.kris.gotoAndPlay(Main.screen.kris.anims.act);
				checktext = Main.dialogue.spamNeoCheck2;
			}
			check.toggleSelection(true);
			actions.push(check);
			
			// X-Slash
			var xslash:MenuOption = new MenuOption(-87, 19, "X-Slash");
			xslash.effect = function() {
				// Reduce TP
				TPMeter.instance.setTP(TPMeter.instance.tp - (25 / 100) * 250);
				// Transition
				Main.setState("actionResult");
				/*
				UI.instance.hideMenu();
				UI.instance.setText(Main.getText("XSlash"), function() {Main.setState("enemyDialogue");});
				*/
				// Calculate damage
				var dmg:Number = Math.round(1.25 * (((Main.screen.kris.calculateAttack() * 150) / 20) - 3 * Main.screen.spamton.defense));
				// Animation
				Main.screen.kris.gotoAndPlay(Main.screen.kris.anims.fight);
				SoundLibrary.play("xslash", 0.5);
				// Damage
				damage(dmg, false, false);
				// Wait a little
				new Wait(30, function() {
					// Animate again
					Main.screen.kris.gotoAndPlay(Main.screen.kris.anims.fight);
					SoundLibrary.play("xslash", 0.5);
					// Damage again
					damage(dmg, false, true, true);
				});
			}
			xslash.description = Main.getText("damageDesc");
			xslash.TPCost = 25;
			actions.push(xslash);
			
			// FriedPipis
			var friedpipis:MenuOption = new MenuOption(-311, 49, "FriedPipis");
			friedpipis.effect = function() {
				TPMeter.instance.setTP(TPMeter.instance.tp - (32 / 100) * 250);
				Main.setState("actionResult");
				/*
				UI.instance.info.icon.gotoAndStop("act");
				UI.instance.hideMenu();
				UI.instance.setText(Main.getText("pipisHeal"), function() {UI.instance.info.icon.gotoAndStop("head"); Main.setState("enemyDialogue");});
				*/
				
				// pipis
				var healingpipis:Sprite = new Sprite();
				var img:Bitmap = new Bitmap(new pipisImg(0,0));
				healingpipis.addChild(img);
				img.x -= img.width / 2;
				img.y -= img.height / 2;
				healingpipis.scaleX = 0;
				healingpipis.scaleY = 0;
				healingpipis.x = Main.screen.kris.x + 85;
				healingpipis.y = Main.screen.kris.y - 22;
				Main.screen.addChild(healingpipis);
				
				// Move towards Kris
				var moveToKris:Function = function() {
					new Wait(20, function() {
						new RepeatUntil(function () {healingpipis.x -= 4}, function() {
							if (healingpipis.x <= Main.screen.kris.x + 20) {
								// Disappear
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
								// Heal
								Player.heal(120);
								// Stop moving
								return true;
							}
						});
					});
				}
				SoundLibrary.play("healspell", 0.5);
				// Appear
				new RepeatUntil(function() {
					healingpipis.scaleX += 0.05;
					healingpipis.scaleY += 0.05;
					healingpipis.rotation -= 18;
				}, function() {if (healingpipis.scaleX >= 1) {
					// Begin moving
					moveToKris();
					return true;
				}});
				// Animate Kris
				Main.screen.kris.gotoAndPlay(Main.screen.kris.anims.act);
			}
			friedpipis.description = Main.getText("itemHeal") + "\n120 HP";
			friedpipis.txt.x -=6;
			friedpipis.TPCost = 32;
			actions.push(friedpipis);
		}
		
		// Handles whcih dialogue to use
		public function getDialogue():Array {
			// nextDialogue overrides the advancing text
			if (nextDialogue == null) {
				// First 10 turns have linear progression, followed by random stuff
				// bluelightMode repeats the same thing unless you ACT
				dialogueChain++;
				if (bluelightMode) {return XMLToDialogue(Main.dialogue.NEOFireworks2);}
				else if (dialogueChain <= 10) {return XMLToDialogue(Main.dialogue["NEODialogue" + dialogueChain]);}
				else {return XMLToDialogue(Main.dialogue["NEODRandom" + RandomRange(1, 6, 0)]);}
			}
			else {
				// Set nextDialogue to null for the next turn
				var txt:Array = nextDialogue;
				nextDialogue = null;
				return txt;
			}
		}
		
		// Returns an attack to use
		public function getAttack():EnemyWave {
			attackID = (attackID + 1) % attacks.length;
			return new attacks[attackID]();
		}
		
		// Damage
		public function damage(n:int, doSound:Boolean = true, resetAnim:Boolean = true, mirrorSlash:Boolean = false):void {
			// Slash effect
			var slash:DamageSlash = new DamageSlash();
			slash.x = container.x + 20;
			slash.y = container.y - 100;
			slash.scaleX = 2;
			slash.scaleY = 2;
			if (mirrorSlash) {
				slash.scaleX *= -1
				slash.x += 100
			}
			Main.screen.addChild(slash);
			
			// Play a sound, show and apply damage
			new Wait(15, function() {
				// Pause the animation and show a hurt one
				head.gotoAndStop(1);
				head.rotation = -15;
				
				forAllParts(function() {
					part.enableRotation = false;
					if (part != body) {
						part.rotation =  part.rotation + RandomRange(-45, 45);
					}
				});
				
				// Imitate bluelight defense
				if (bluelightMode) {n = RandomRange(5, 11, 0);}
				
				if (doSound) {SoundLibrary.play("enemydamage", 0.5);}
				new DamageNumber(n, Main.screen.spamton.container, "blue", -40); 
				shake(); 
				// UI.instance.info.icon.gotoAndStop("head");
				hp -= n;
				// Don't go below 278.54 HP
				hp = Math.max(278.54, hp);
				
				// Once below 15% HP, start the bluelight specil
				if (hp < 0.15 * maxhp && !bluelightMode && resetAnim) {startBluelight();}
				// Otherwise,
				else {
					// Restart animation
					if (resetAnim) {
						new Wait(25, function() {
							Main.screen.kris.gotoAndPlay(Main.screen.kris.anims.idle);
							head.rotation = 0;
							head.play();
							forAllParts(function() {part.enableRotation = true;});
							if (!mirrorSlash) {Main.setState("enemyDialogue");}
						});
					}
				}
			});
		}
		
		// Enrage
		public function enrage():void {
			enraged = true;
			var breenMult:Number = 1;
			var honkTimer:int = 0;
			new RepeatUntil(function() {
				// Fade head to red
				breenMult -= 0.025;
				head.transform.colorTransform = new ColorTransform(1, breenMult, breenMult);
			}, function() {
				if (breenMult <= 0) {
					// Add smoke & start honking 
					container.children["smoker"] = new SmokeSpawner();
					container.children["smoker"].x = container.width / 2 - 10;
					container.children["smoker"].y = -container.height / 2;
					container.addChildAt(container.children["smoker"], 0);
					SoundLibrary.play("carhonk", 0.6);
					new RepeatUntil(function() {
						honkTimer++;
						if (honkTimer <= 30) {
							head.scaleX = -0.5 * Math.cos((Math.PI / 15) * honkTimer) + 1.5;
							head.scaleY = -0.5 * Math.cos((Math.PI / 15) * honkTimer) + 1.5;
						}
						else {
							head.scaleX = -0.5 * Math.cos((Math.PI / 27) * (honkTimer - 30)) + 1.5;
							head.scaleY = -0.5 * Math.cos((Math.PI / 27) * (honkTimer - 30)) + 1.5;
						}
						head.shake(3, true);
					}, function() {
						if (honkTimer == 84) {
							head.x = 28;
							head.y = -57;
							return true;
						}
					});
				
					return true;
				}
			});
		}
		
		// Start bluelightMode
		private function startBluelight():void {
			// Setup
			bluelightMode = true;
			Main.screen.kris.gotoAndPlay(Main.screen.kris.anims.idle);
			// UI.instance.setText("");
			Main.setState("none");
			Main.bgm.fadeOut();

			new Wait(60, function() {
				// Dialogue
				var textbubble:DialogueBubble = new DialogueBubble(Main.dialogue.NEOLowHP, "voice_sneo", function() {
					new Wait(2, function() {
						// When it ends, apply the effect
						SoundLibrary.play("specil");
						forAllParts(function() {part.rotateToSmart(0);}, false);
						Main.setState("actionResult");
						/*
						UI.instance.setText(Main.dialogue.NEOBluelight, function() {
							// We're in the end stages, now
							nextDialogue = XMLToDialogue(Main.dialogue.NEOFireworks);
							forAllParts(function() {part.enableRotation = true;});
							head.play();
							Main.bgm = SoundLibrary.play("mus_gonewrong", 0.3, int.MAX_VALUE);
							Main.setState("enemyDialogue");
						});
						*/
					});
				})
				textbubble.x = 460;
				textbubble.y = 170;
				Main.screen.addChild(textbubble);
			});
			
			// Old acts replaced by this
			actions = [];
			var resultText:XMLList = Main.dialogue.callForHelp;
			var help:MenuOption = new MenuOption(-311, 19, "");
			// On use,
			help.effect = function() {
				// Advance helpCount
				helpCount++;
				// Change icon depending on helpCount
				if (helpCount == 2) {help.icon.bitmapData = new SusieIcon(0,0);}
				else if (helpCount == 4) {help.icon.bitmapData = new NoelleIcon(0,0);}
				else if	(helpCount == 5) {resultText = Main.dialogue.callForHer;}
				Main.setState("actionResult");
				/*
				UI.instance.setText(XMLToDialogue(resultText), function() {
					UI.instance.info.icon.gotoAndStop("head");
					nextDialogue = XMLToDialogue(Main.dialogue["NEORant" + helpCount]);
					Main.setState("enemyDialogue");
				});
				UI.instance.hideMenu();
				UI.instance.info.icon.gotoAndStop("act");
				*/
				Main.screen.kris.gotoAndPlay(Main.screen.kris.anims.act);
			}
			// Create the icon of the MenuOption
			help.createIcon(new RalseiIcon(0,0));
			help.toggleSelection(true);
			actions.push(help);
		}
		
		// Shake Spamton
		public function shake(intensity:Number = 2) {
			// Two random numbers
			var val_x:Number = RandomRange(-intensity, intensity);
			var val_y:Number = RandomRange(-intensity, intensity);
			// Displace by those numberse
			Main.screen.spamton.x += val_x;
			Main.screen.spamton.y += val_y;
			// Wait a bit and reset
			new Wait(5, function():void {
				Main.screen.spamton.x -= val_x;
				Main.screen.spamton.y -= val_y;
			});
		}
		
		// Change the animation
		public function setAnimMode(mode:String):void {
			animMode = mode;
			if (mode == "defaultIdle") {
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
				head.gotoAndStop(1);
				forAllParts(function() {part.enableRotation = false});
				var changeRotTimer:int = 0;
				new RepeatUntil(function() {
					changeRotTimer = (changeRotTimer + 1) % 30;
					if (changeRotTimer == 0) {
						forAllParts(function() {part.rotation = RandomRange(-30, 30);});
						if (head.currentFrame == 1) {head.rotation = 0; head.gotoAndStop(61);}
						else {head.rotation = -20; head.gotoAndStop(1);}
					}
					forAllParts(function() {part.shake(1);});
				}, function() {if (animMode != "angerShake") {return true;}});
			}
			else if (mode == "laughing") {
				head.gotoAndStop(1);
				forAllParts(function() {part.enableRotation = false;});
				var laughsound:BetterSoundChannel = SoundLibrary.play("laugh");
				new RepeatUntil(function() {
					forAllParts(function() {part.shake(0.75);});
					if (laughsound.position < 1000) {head.minRotation = -50;}
					else if (laughsound.position > 1000 && laughsound.position < 1500) {head.minRotation = 20; head.gotoAndStop(31);}
					else if (laughsound.position > 1500 && laughsound.position < 2000) {head.minRotation = -10; head.gotoAndStop(61);}
					else {head.minRotation = 15;}
					head.rotation = RandomRange(head.minRotation - 2, head.minRotation + 2);
				}, function() {if (animMode != "laughing") {return true;}});
			}
		}
		
		// Iterate a function for all parts
		public function forAllParts(fToDo:Function, excludeHead:Boolean = true):void {
			for each (part in parts) {
				// Exclude head if specified
				if (excludeHead == true) {
					if (part != head) {fToDo.call();}
				}
				else {
					fToDo.call();
				}
			}
			part = null;
		}
		
		// Destroy the object
		public function destroy():void {
			// Destroy all parts
			forAllParts(function() {part.destroy();}, false);
			part = null;
			parts = [];
			// Remove from the screen
			this.parent.removeChild(this);
			if (container) {delete container.children["spamton"];}
		}
	}
}
/*
	Date: 16-12-2021
	Description: Firing pipis from a cannon
*/

package scripts.attacks {
	import flash.geom.Point;
	import flash.geom.ColorTransform;
	import scripts.EnemyWave;
	import scripts.DialogueBubble;
	import scripts.SoundLibrary;
	import scripts.spam.Spamton;
	import scripts.spam.SpamtonPart;
	import scripts.utils.MovementVector;
	import scripts.utils.RepeatUntil;
	import scripts.utils.Wait;
	import scripts.utils.Input;
	import scripts.bullets.pipis
	
	public class PipisForYou extends EnemyWave {
		private var initialSpamX:Number;
		private var initialSpamY:Number;
		private var targetRot:Number;
		private var aimRandomizer:Boolean = false;
		private var pipisArray:Array = [];
		private var pipisFloor:Pixel;
		private var spamTwo:Spamton;
		
		// Constructor
		public function PipisForYou() {
			// Keep waveTimer infinite until Spamton stops talking
			waveTimer = int.MAX_VALUE;
			arenaConfig = {x: 246, y: 171, width: 150, height: 150};
			
			// Hold onto Spamton's initial position
			initialSpamX = Main.screen.spamton.x;
			initialSpamY = Main.screen.spamton.y;
			
			// Move spamton upwards
			new RepeatUntil(function() {
				Main.screen.spamton.y -= 5;
			}, function() {
				if (Main.screen.spamton.y < 200) {
					// Play a sound, animate Spamton, and end the RepeatUntil
					SoundLibrary.play("phone", 0.4);
					Main.screen.spamton.larm.rotateTo(150);
					new Wait(10, function() {Main.screen.spamton.larm.gotoAndStop("phone1");});
					new Wait(20, startDialogue);
					return true;
				}
			})
		}
		
		// Start intro dialogue
		private function startDialogue():void {
			// Stop his usual head animation
			Main.screen.spamton.head.gotoAndStop("default_HeadSwitch");
			
			// Create a DialogueBubble which runs startAttack() when it ends
			var bubble:DialogueBubble = new DialogueBubble(Main.dialogue.spamNeoPhone1, "voice_sneo", startAttack);
			bubble.x = 460;
			bubble.y = 100;
			// While the dialogue is typing, animate Spamton's head
			bubble.whileTyping = function() {
				if (bubble.bubbletext.length != 0) {
					Main.screen.spamton.head.rotation = 12 * Math.sin(timer / 60);
				}
			}
			// When we move the dialogue ahead, if we're at the last line, move the bubble and have Spamton point the phone at you
			bubble.onAdvance = function() {
				if (bubble.bubbletext.length == 0) {
					Main.screen.spamton.head.gotoAndStop(31);
					Main.screen.spamton.head.rotation = -16;
					bubble.x -= 20;
					bubble.y += 10;
					Main.screen.spamton.larm.rotateTo(80, false, 10);
					Main.screen.spamton.larm.gotoAndStop("phone2");
				}
			}
			addChild(bubble);
		}
		
		// Start the attack
		private function startAttack():void {
			// Change waveTimer
			waveTimer = 18000;
			// Move Spamton
			new RepeatUntil(function() {
				Main.screen.spamton.x += 7;
			}, function() {
				if (Main.screen.spamton.x > 700) {
					// Reset Spamton's animation once he's offscreen
					Main.screen.spamton.head.rotation = 0;
					Main.screen.spamton.setAnimMode("defaultIdle");
					Main.screen.spamton.larm.gotoAndStop("normal");
					Main.screen.spamton.larm.enableRotation = true;
					Main.screen.spamton.y = initialSpamY;
					return true;
				}
			});
			
			new Wait(20, function() {
				// The first pipis
				var firstPipis:pipis = new pipis(null);
				var location:Point = Main.screen.spamton.localToGlobal(new Point(Main.screen.spamton.larm.x - Main.screen.spamton.larm.height, Main.screen.spamton.larm.y));
				firstPipis.x = location.x;
				firstPipis.y = location.y;
				firstPipis.rotation = 90;
				addBullet(firstPipis);
				firstPipis.addLabel();
				pipisArray.push(firstPipis);
				
				// The floor
				pipisFloor = new Pixel();
				pipisFloor.width = 217;
				pipisFloor.height = 2;
				pipisFloor.x = 338;
				pipisFloor.y = 245;
				var tmp_color:ColorTransform = new ColorTransform();
				tmp_color.color = 0x00C000;
				pipisFloor.transform.colorTransform = tmp_color;
				pipisFloor.alpha = 0;
				addChild(pipisFloor);
				new RepeatUntil(function() {pipisFloor.alpha += 0.05;}, function() {if (pipisFloor.alpha >= 1) {return true;}});
			});
			
			new Wait(40, function() {
				// Spamton clone for the cannon firing
				spamTwo = new Spamton();
				spamTwo.x = 651;
				spamTwo.y = 344;
				spamTwo.scaleX = 2;
				spamTwo.scaleY = 2;
				for each (var part:SpamtonPart in spamTwo.parts) {part.enableRotation = false;}
				part = null;
				spamTwo.head.gotoAndStop(31);
				spamTwo.head.rotation -= 16;
				spamTwo.lleg.rotation -= 20;
				spamTwo.rleg.rotation -= 20;
				spamTwo.lwing.rotation -= 20;
				spamTwo.larm.rotation = 140;
				spamTwo.larm.gotoAndStop("cannon1");
				Main.screen.addChild(spamTwo);
				new RepeatUntil(function() {spamTwo.x -= 2.5;}, function() {if (spamTwo.x <= 601) {return true;}});
				changeTarget();
			});
		}
		
		// Every frame
		public override function update():void {
			// If the floor exists, check for collision with every pipis
			if (pipisFloor is Pixel) {
				for each (var ipipis:pipis in pipisArray) {
					// If the pipis collides, make it bounce (invert its vector's vertical component)
					if (pipisFloor.hitTestObject(ipipis) && ipipis.bounceDelay == 0) {
						var dim:Point = ipipis.vector.getDimensions();
						ipipis.vector = MovementVector.getVectorFromDimensions(dim.x, Math.min(4, -dim.y));
						ipipis.bounceDelay = 10;
					}
					// When the pipis collides with the arena, have it explode
					if (arena.hitTestObject(ipipis) && ipipis.exists) {
						var playerAngle:Number = MovementVector.getVectorFromDimensions(player.x - ipipis.x, ipipis.y - player.y).getAngle();
						ipipis.explode([playerAngle - 20, playerAngle + 20], 10, 7);
					}
				}
				ipipis = null;
			}
			
			// While the second Spamton exists,
			if (spamTwo is Spamton) {
				// Animate his flight and arm
				spamTwo.y = 10 * Math.sin(timer / 20) + 344;
				if (aimRandomizer) {
					spamTwo.larm.rotation = 3 * Math.sin(timer / 2) + targetRot;
				}
			}
		}
		
		// Pick a random rotation for the arm
		private function changeTarget():void {
			var newRot:Number = 45 * Math.random() + 120;
			// Move his arm towards that rotation
			if (newRot > spamTwo.larm.rotation) {spamTwo.larm.rotateTo(newRot, true, 15);}
			else {spamTwo.larm.rotateTo(newRot, false, 15);}
			// Store that target rotation
			targetRot = newRot;
			
			// When the arm is on target, start the process of firing a pipis
			new Wait(15, function() {
				new RepeatUntil(function() {if (waveTimer > 0) {spamTwo.larm.scaleX += 0.025;}}, function() {
					if (waveTimer > 0) {
						if (spamTwo.larm.scaleX >= 1.4) {
							// Change the arm sprite
							spamTwo.larm.scaleX = 1;
							spamTwo.larm.gotoAndStop("cannon2");
							// Randomize the rotation a little
							aimRandomizer = true;
							// Fire!
							new Wait(30, firepipis);
							return true;
						}
					}
				});
			});
		}
		
		// Fire a pipis
		private function firepipis():void {
			if (this.parent && pipis.pipisCount < 3) {
				// Reset his arm
				spamTwo.larm.gotoAndStop("cannon1");
				spamTwo.larm.scaleX = 1.4;
				new RepeatUntil(function() {spamTwo.larm.scaleX -= 0.05;}, function() {if (spamTwo.larm.scaleX <= 1) {return true;}});
				// Stop the shaking
				aimRandomizer = false;
				
				// Calculate the vector for the pipis
				var pipisVector:MovementVector = new MovementVector(-spamTwo.larm.rotation - 90, (((spamTwo.larm.rotation) % 360 - 110) / 8) + 3 * Math.random() + 1);
				// Limit the magnitude of the vector to prevent too much eccentricity
				pipisVector = MovementVector.getVectorFromDimensions(Math.max(-1.25, pipisVector.getDimensions().x), Math.min(5, pipisVector.getDimensions().y));
				// Create the pipis
				var newpipis:pipis = new pipis(pipisVector);
				// Position the pipis
				var pipisPoint:Point = new MovementVector(-spamTwo.larm.rotation - 90, 46).getDimensions();
				var armPoint:Point = spamTwo.localToGlobal(new Point(spamTwo.larm.x, spamTwo.larm.y));
				newpipis.x = armPoint.x + pipisPoint.x;
				newpipis.y = armPoint.y - pipisPoint.y;
				newpipis.rotation = spamTwo.larm.rotation;
				// Finalise its creation
				addBullet(newpipis);
				pipisArray.push(newpipis);
				
				// Wait a bit and start aiming again
				new Wait(15, changeTarget);
			}
			// If there are 3 pipis on the screen, wait until one is gone before firing again
			else if (pipis.pipisCount >= 3) {
				new Wait(3, firepipis);
			}
		}
		
		// Once the attack is finished,
		public override function cleanup(transition:Boolean):void {
			pipisArray = null;
			pipisFloor = null;
			// Move the second Spamton offscreen and destroy him
			if (spamTwo && transition) {
				new RepeatUntil(function() {spamTwo.x += 2.5;}, function() {
					if (spamTwo.x > 700) {
						spamTwo.destroy();
						spamTwo = null;
						return true;
					}
				});
			}
			else if (spamTwo) {
				spamTwo.destroy();
				spamTwo = null;
			}
			// Reposition the True Spamton
			new RepeatUntil(function() {Main.screen.spamton.x -= 7;}, function() {if (Main.screen.spamton.x <= initialSpamX) {return true;}});
		}
	}
}
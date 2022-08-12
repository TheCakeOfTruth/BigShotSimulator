/*
	File Name: PipisForYou.as
	Programmeur: William Mallette
	Date: 16-12-2021
	Description: L'attaque du canon de pipis
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
		
		// constructor
		public function PipisForYou() {
			// waveTimer infini jusqu'à temps que la dialogue est terminée
			waveTimer = int.MAX_VALUE;
			arenaConfig = {x: 246, y: 171, width: 150, height: 150};
			
			// Garder la position initial de Spamton
			initialSpamX = Main.screen.spamton.x;
			initialSpamY = Main.screen.spamton.y;
			
			// Bouger Spamton en haut
			new RepeatUntil(function() {
				Main.screen.spamton.y -= 5;
			}, function() {
				if (Main.screen.spamton.y < 200) {
					// Jouer un son, animer le bras de Spamton, arrêter ce RepeatUntil
					SoundLibrary.play("phone", 0.4);
					Main.screen.spamton.larm.rotateTo(150);
					new Wait(10, function() {Main.screen.spamton.larm.gotoAndStop("phone1");});
					new Wait(20, startDialogue);
					return true;
				}
			})
		}
		
		// Commencer le dialogue introductoire
		private function startDialogue():void {
			// Arrêter l'animation du tête de Spamton
			Main.screen.spamton.head.gotoAndStop("default_headswitch");
			
			// Créer un DialogueBubble qui effectue startAttack quand il est fini
			var bubble:DialogueBubble = new DialogueBubble(Main.dialogue.spamNeoPhone1, "voice_sneo", startAttack);
			bubble.x = 460;
			bubble.y = 100;
			// Pendant que le texte du DialogueBubble tape, 
			bubble.whileTyping = function() {
				if (bubble.bubbletext.length != 0) {
					// Animer le tête
					Main.screen.spamton.head.rotation = 12 * Math.sin(timer / 60);
				}
			}
			// Lorsqu'on avance le dialogue,
			bubble.onAdvance = function() {
				// Si on est au dernier texte du bulle, changer l'animation et bouger la bulle et le bras
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
		
		// Commencer l'attaque
		private function startAttack():void {
			// Changer waveTimer
			waveTimer = 26000;
			// Bouger Spamton
			new RepeatUntil(function() {
				Main.screen.spamton.x += 7;
			}, function() {
				if (Main.screen.spamton.x > 700) {
					// Reset l'animation de Spamton lorsqu'il est hors de l'écran
					Main.screen.spamton.head.rotation = 0;
					Main.screen.spamton.setAnimMode("defaultIdle");
					Main.screen.spamton.larm.gotoAndStop("normal");
					Main.screen.spamton.larm.enableRotation = true;
					Main.screen.spamton.y = initialSpamY;
					return true;
				}
			});
			
			// Après un délai
			new Wait(20, function() {
				// Créer le premier pipis
				var firstPipis:pipis = new pipis(null);
				var location:Point = Main.screen.spamton.localToGlobal(new Point(Main.screen.spamton.larm.x - Main.screen.spamton.larm.height, Main.screen.spamton.larm.y));
				firstPipis.x = location.x;
				firstPipis.y = location.y;
				firstPipis.rotation = 90;
				addBullet(firstPipis);
				firstPipis.addLabel();
				pipisArray.push(firstPipis);
				
				// Le plancher
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
			
			// Un autre délai, un peu plus longue
			new Wait(40, function() {
				// Créer le deuxième Spamton
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
		
		// À chaque frame
		public override function update():void {
			// Si le plancher existe, itérer pour les pipis pour vérifier la collision
			if (pipisFloor is Pixel) {
				for each (var ipipis:pipis in pipisArray) {
					// Si on est en collision avec le plancher, refléter la composante verticale du vecteur et avoir un délai avant de rebondir encore
					if (pipisFloor.hitTestObject(ipipis) && ipipis.bounceDelay == 0) {
						var dim:Point = ipipis.vector.getDimensions();
						ipipis.vector = MovementVector.getVectorFromDimensions(dim.x, Math.min(4, -dim.y));
						ipipis.bounceDelay = 10;
					}
					// Si on est en collision avec l'aréna, exploser
					if (arena.hitTestObject(ipipis) && ipipis.exists) {
						var playerAngle:Number = MovementVector.getVectorFromDimensions(player.x - ipipis.x, ipipis.y - player.y).getAngle();
						ipipis.explode([playerAngle - 20, playerAngle + 20], 10, 7);
					}
				}
				ipipis = null;
			}
			
			// Si le deuxième Spamton existe,
			if (spamTwo is Spamton) {
				// Animer le corps et (si nécessaire) le bras
				spamTwo.y = 10 * Math.sin(timer / 20) + 344;
				if (aimRandomizer) {
					spamTwo.larm.rotation = 3 * Math.sin(timer / 2) + targetRot;
				}
			}
		}
		
		// Sélectionner une rotation aléatoire pour le bras
		private function changeTarget():void {
			// Rotation aléatoire
			var newRot:Number = 45 * Math.random() + 120;
			// Bouger le bras vers cette rotation
			if (newRot > spamTwo.larm.rotation) {spamTwo.larm.rotateTo(newRot, true, 15);}
			else {spamTwo.larm.rotateTo(newRot, false, 15);}
			// Stocker la rotation sélectionnée
			targetRot = newRot;
			
			// Après que le bras est en position, commence à charger un pipis
			new Wait(15, function() {
				new RepeatUntil(function() {if (waveTimer > 0) {spamTwo.larm.scaleX += 0.025;}}, function() {
					if (waveTimer > 0) {
						if (spamTwo.larm.scaleX >= 1.4) {
							// Changer l'image du bras
							spamTwo.larm.scaleX = 1;
							spamTwo.larm.gotoAndStop("cannon2");
							// Agiter le rotation du bras
							aimRandomizer = true;
							// Lancer le pipis
							new Wait(30, firepipis);
							return true;
						}
					}
				});
			});
		}
		
		// Lancer un pipis
		private function firepipis():void {
			if (this.parent && pipis.pipisCount < 3) {
				// L'inverse de l'animation du chargement
				spamTwo.larm.gotoAndStop("cannon1");
				spamTwo.larm.scaleX = 1.4;
				new RepeatUntil(function() {spamTwo.larm.scaleX -= 0.05;}, function() {if (spamTwo.larm.scaleX <= 1) {return true;}});
				// Arrêter l'agitement
				aimRandomizer = false;
				
				// Calculer le vecteur du pipis
				var pipisVector:MovementVector = new MovementVector(-spamTwo.larm.rotation - 90, (((spamTwo.larm.rotation) % 360 - 110) / 8) + 3 * Math.random() + 1);
				// Limiter les composantes du vecteur pour éviter trop de difficulté
				pipisVector = MovementVector.getVectorFromDimensions(Math.max(-1.25, pipisVector.getDimensions().x), Math.min(5, pipisVector.getDimensions().y));
				// Créer le pipis
				var newpipis:pipis = new pipis(pipisVector);
				// Positionner le pipis
				var pipisPoint:Point = new MovementVector(-spamTwo.larm.rotation - 90, 46).getDimensions();
				var armPoint:Point = spamTwo.localToGlobal(new Point(spamTwo.larm.x, spamTwo.larm.y));
				newpipis.x = armPoint.x + pipisPoint.x;
				newpipis.y = armPoint.y - pipisPoint.y;
				newpipis.rotation = spamTwo.larm.rotation;
				// Finaliser le création du pipis
				addBullet(newpipis);
				pipisArray.push(newpipis);
				
				// Après un délai, changeTarget() encore
				new Wait(15, changeTarget);
			}
			// S'il y a 3 pipis sur l'écran, attendre un moment avant d'essayer de lancer un pipis encore
			// (Un pipis sera crée seulement s'il y a moins que 3 sur l'écran)
			else if (pipis.pipisCount >= 3) {
				new Wait(3, firepipis);
			}
		}
		
		// Lorsque l'attaque est fini
		public override function cleanup(transition:Boolean):void {
			pipisArray = null;
			pipisFloor = null;
			// Bouger le deuxième Spamton hors de l'écran et détrui-lui
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
			// Bouger le vrai Spamton à sa position initiale
			new RepeatUntil(function() {Main.screen.spamton.x -= 7;}, function() {if (Main.screen.spamton.x <= initialSpamX) {return true;}});
		}
	}
}
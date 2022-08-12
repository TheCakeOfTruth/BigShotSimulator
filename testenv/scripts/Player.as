/*
	File Name: Player.as
	Programmeur: William Mallette
	Date: 30-10-2021
	Description: Le coeur jaune, un objet essentiel.
*/

package scripts {
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.media.SoundTransform;
	import scripts.ui.UI;
	import scripts.ui.TPMeter;
	import scripts.utils.Wait;
	import scripts.utils.MovementVector;
	import scripts.utils.Input;
	import scripts.utils.BetterSoundChannel;
	import scripts.utils.GlobalListener;
	
	public class Player extends Sprite {
		// Variables statiques
		public static var instance:Player;
		public static var shots:Array = [];
		
		// Inputs et collision
		public var takeInput:Boolean = true;
		public var collisionPoints:Array = [];
		public var hitBox:Array = [];
		public var grazeBox:Array = [];
		public var collidingWalls:Array = [];
		public var grazingBullets:Array = [];
		public var iFrames:int = 0;
		private var zTimer:int = 0;		
		private var eventID:String;
		
		// Images
		public var bmpObj:Bitmap = new Bitmap();
		private var yellowHeart:YellowHeart = new YellowHeart(0,0);
		private var whiteHeart:WhiteHeart = new WhiteHeart(0,0);
		private var yellowdmg:DYellowHeart = new DYellowHeart(0,0);
		
		// Sons
		private var chargesound_channel:BetterSoundChannel;
		
		// Constructor
		public function Player() {
			// Créer une référence global dans la classe du document
			Player.instance = this;
			
			// Ajouter un eventListener
			eventID = "Player-" + String(Math.random());
			GlobalListener.addEvent(update, eventID);
			
			// Les points de collision pour les murs de l'aréna
			var d:Number = 10;
			collisionPoints.push(new Point(this.x+d, this.y+d));
			collisionPoints.push(new Point(this.x+d, this.y-d));
			collisionPoints.push(new Point(this.x-d, this.y+d));
			collisionPoints.push(new Point(this.x-d, this.y-d));
			
			// Pour la boite de collision du Player
			hitBox.push(new Point(this.x+1, this.y+1));
			hitBox.push(new Point(this.x+1, this.y-1));
			hitBox.push(new Point(this.x-1, this.y+1));
			hitBox.push(new Point(this.x-1, this.y-1));
			
			// Pour l'effet de graze
			grazeBox.push(new Point(this.x, this.y-25));
			grazeBox.push(new Point(this.x, this.y+25));
			grazeBox.push(new Point(this.x+25, this.y));
			grazeBox.push(new Point(this.x-25, this.y));
			grazeBox.push(new Point(this.x-25, this.y-25));
			grazeBox.push(new Point(this.x-25, this.y+25));
			grazeBox.push(new Point(this.x+12.5, this.y-12.5));
			grazeBox.push(new Point(this.x+12.5, this.y+12.5));
			
			// Utiliser un Bitmap pour faciliter le changement de l'image
			this.removeChildAt(1);
			this.addChild(bmpObj);
			swapImg(yellowHeart);
			bmpObj.x -= bmpObj.bitmapData.width/2;
			bmpObj.y -= bmpObj.bitmapData.height/2;
			
			// Enlever les events quand l'objet est détruit
			this.addEventListener(Event.REMOVED_FROM_STAGE, cleanup, false, 0, true);
		}
		
		// Dépendant du zTimer, lance un montant différent de Shot (ou un BigShot)
		private function fireShots(n:int):void {
			if (n > 45) {
				// BIG SHOT!
				createShot(true);
			}
			else if (n > 30) {
				// 3 Shot
				createShot();
				new Wait(4, function():void {createShot(); new Wait(4, function():void {createShot();});});
			}
			else if (n > 20) {
				// 2 Shot
				createShot();
				new Wait(4, function():void {createShot();});
			}
			else {
				// 1 Shot
				createShot();
			}
			// Reset l'image
			swapImg(yellowHeart);
		}
		
		// Fonction qui crée des Shots
		private function createShot(big:Boolean = false):void {
			if (big) {Main.screen.addChild(new BigShot(this.x, this.y)); SoundLibrary.play("bigfire");}
			else {Main.screen.addChild(new Shot(this.x, this.y)); SoundLibrary.play("fire");}
		}
		
		// Effectuer des changements à chaque frame
		private function update():void {
			// Gérer le chargement du BigShot
			if (takeInput && Input.getKey(90) == true) {zTimer++;}
			// Commencer le son et changer l'image
			if (zTimer == 20) {chargesound_channel = SoundLibrary.play("chargesound", 0, int.MAX_VALUE);}
			else if (zTimer == 45) {swapImg(whiteHeart);}
			// Augmenter le volume du son
			if (chargesound_channel) {
				if (chargesound_channel.soundTransform.volume < 0.5 && zTimer >= 5) {
					chargesound_channel.soundTransform = new SoundTransform(Math.pow((zTimer - 5) / 45, 2)/2);
				}
			}
			// Lorsqu'on release Z, fireShots
			if (takeInput && Input.getKey(90) == false && zTimer > 0) {
				fireShots(zTimer); 
				zTimer = 0; 
				if (chargesound_channel) {chargesound_channel.stop(); chargesound_channel = null;}
			}
		
			// Le mouvement
			// Créer un vecteur vide et ajouter des vecteurs de mouvement correspondant à les touches directionnels pressés
			var vector:MovementVector = new MovementVector()
			if (takeInput && Input.getKey(37) == true) {vector.add(new MovementVector(180, 2.75));}
			if (takeInput && Input.getKey(38) == true) {vector.add(new MovementVector(90, 2.75));}
			if (takeInput && Input.getKey(39) == true) {vector.add(new MovementVector(0, 2.75));}
			if (takeInput && Input.getKey(40) == true) {vector.add(new MovementVector(270, 2.75));}
			
			// Si on est en collision avec un mur (voir Wall), ajoute son vecteur
			for each (var obj:Wall in collidingWalls) {
				vector.add(obj.colliderVector);
			}
			obj = null;
			
			// Convertir le vecteur en ses composants, et boujer le Player et ses Points.
			var dim:Point = vector.getDimensions();
			move(dim.x, -dim.y);
			
			// Gérer l'effet de graze
			// S'il n'y a aucun Bullet en train de graze, fade out
			if (grazezone.alpha > 0 && grazingBullets.length == 0) {
				grazezone.alpha = grazezone.alpha - 0.2
			}
			
			// Gérer le dommage et l'immunité
			if (iFrames > 0) {
				iFrames--;
				if (bmpObj.bitmapData != whiteHeart) {
					if (iFrames % 10 == 0) {
						if (bmpObj.bitmapData == yellowHeart) {swapImg(yellowdmg);}
						else {swapImg(yellowHeart);}
					}
				}
			}
		}
		
		// Bouger le Player et ses points à un point spécifique
		public function moveTo(x:Number, y:Number):void {
			var deltaX:Number = x - this.x;
			var deltaY:Number = y - this.y;
		
			this.x = x;
			this.y = y;
			
			for each (var pt:Point in collisionPoints) {
				pt.x += deltaX;
				pt.y += deltaY;
			}
			pt = null;
			for each (var hpt:Point in hitBox) {
				hpt.x += deltaX;
				hpt.y += deltaY;
			}
			hpt = null;
			for each (var gpt:Point in grazeBox) {
				gpt.x += deltaX;
				gpt.y += deltaY;
			}
			gpt = null;
		}
		
		// Bouger le Player relatif à sa position actuelle
		public function move(x:Number, y:Number):void {
			moveTo(this.x + x, this.y + y);
		}
		
		// Changer l'image
		private function swapImg(newimg:BitmapData):void {
			bmpObj.bitmapData = newimg;
		}
		
		// Jouer le son de graze et montrer le contour
		public function graze():void {
			SoundLibrary.play("graze", 0.5);
			grazezone.alpha = 1;
		}
		
		// Endommager le Player
		public static function hurt(damageMultiplier:Number, bulletElement = null):Boolean {
			// Maths pour figurer le dommage (voir https://deltarune.fandom.com/wiki/Stats)
			var totaldamage:int;
			if (!Main.screen.spamton.bluelightMode) {
				// Dommage de base
				totaldamage = Main.screen.spamton.attack * damageMultiplier;
				// Pour chaque point de défense,
				for (var i:int = 0; i < Kris.instance.calculateDefense(); i++) {
					// Réduire le dommage par un montant proportionnel à la rapport entre totaldamage et maxhp (160)
					if (totaldamage > (1/5) * 160) {totaldamage -= 3;}
					else if (totaldamage > (1/8) * 160) {totaldamage -= 2;}
					else {totaldamage -= 1;}
				}
				// Si on a sélectionné "DEFEND," réduire totaldamage à 2/3
				if (Kris.instance.isDefending) {totaldamage = Math.ceil(totaldamage * (2/3));}
				// La résistence élémental (voir les armures)
				totaldamage = Math.ceil(totaldamage * Kris.instance.getResistPercent(bulletElement));
			}
			// Limiter le dommage à 11 pendant le bluelight specil
			else {totaldamage = 11;}
			var new_hp:Number = Math.max(0, UI.instance.hp - totaldamage);
			
			// Jouer un son
			SoundLibrary.play("hurt", 0.75);
			
			// GameOver
			if (new_hp == 0) {
				Main.gameOver();
				if (instance.chargesound_channel) {instance.chargesound_channel.stop(); instance.chargesound_channel = null;}
				// return true si le dommage tue le Player
				return true;
			}
			// Dommage normal
			else {
				// Activer l'immunité
				instance.iFrames = 60;
				// Annuler le graze
				for each (var b:Bullet in instance.grazingBullets) {
					instance.grazingBullets.splice(0, 1);
					b.grazeID = -1;
				}
				b = null;
				instance.grazezone.alpha = 0;
				// Changer l'HP montré
				UI.instance.setHP(new_hp);
				// Montrer le dommage
				new DamageNumber(totaldamage, Kris.instance);
				// Provoquer l'écran
				Main.screen.shakeScreen();
				// Changer l'animation de Kris
				Kris.instance.gotoAndPlay("hurt");
				return false;
			}
		}
		
		// Ajouter de l'HP au Player
		public static function heal(n:Number):void {
			// Déterminer le noveau HP
			var newhp:int = Math.min(UI.instance.hp + n, 160);
			// Déterminer quoi montrer dans DamageNumber
			var txt = n;
			if (newhp == 160) {txt = "max";}
			// Créer un DamageNumber
			new DamageNumber(txt, Kris.instance, "green");
			// Changer l'HP
			UI.instance.setHP(newhp);
			// Jouer un son
			SoundLibrary.play("heal", 0.5);
		}
		
		// Effacer tout qui pourrais causer un problème
		private function cleanup(e:Event):void {
			if (chargesound_channel) {chargesound_channel.stop(); chargesound_channel = null;}
			GlobalListener.removeEvent(eventID);
			this.removeEventListener(Event.REMOVED_FROM_STAGE, cleanup);
			instance = null;
		}
	}
}
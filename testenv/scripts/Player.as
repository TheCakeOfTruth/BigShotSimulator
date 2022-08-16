/*
	Date: 30-10-2021
	Description: * That's your SOUL, the very essence of your being!
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
		// Static stuff
		public static var instance:Player;
		public static var shots:Array = [];
		
		// Inputs and collision
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
		
		// Sounds
		private var chargesound_channel:BetterSoundChannel;
		
		// Constructor
		public function Player() {
			// Keep a global reference
			Player.instance = this;
			
			// Add an eventListener
			eventID = "Player-" + String(Math.random());
			GlobalListener.addEvent(update, eventID);
			
			// Collision points for the arena
			var d:Number = 10;
			collisionPoints.push(new Point(this.x+d, this.y+d));
			collisionPoints.push(new Point(this.x+d, this.y-d));
			collisionPoints.push(new Point(this.x-d, this.y+d));
			collisionPoints.push(new Point(this.x-d, this.y-d));
			
			// Collision points for bullets
			hitBox.push(new Point(this.x+1, this.y+1));
			hitBox.push(new Point(this.x+1, this.y-1));
			hitBox.push(new Point(this.x-1, this.y+1));
			hitBox.push(new Point(this.x-1, this.y-1));
			
			// Collision points for grazing
			grazeBox.push(new Point(this.x, this.y-25));
			grazeBox.push(new Point(this.x, this.y+25));
			grazeBox.push(new Point(this.x+25, this.y));
			grazeBox.push(new Point(this.x-25, this.y));
			grazeBox.push(new Point(this.x-25, this.y-25));
			grazeBox.push(new Point(this.x-25, this.y+25));
			grazeBox.push(new Point(this.x+12.5, this.y-12.5));
			grazeBox.push(new Point(this.x+12.5, this.y+12.5));
			
			// Bitmap setup for changing the image
			this.removeChildAt(1);
			this.addChild(bmpObj);
			swapImg(yellowHeart);
			bmpObj.x -= bmpObj.bitmapData.width/2;
			bmpObj.y -= bmpObj.bitmapData.height/2;
			
			// Remove events when the object is destroyed
			this.addEventListener(Event.REMOVED_FROM_STAGE, cleanup, false, 0, true);
		}
		
		// zTimer influences the type(s) of shots fired
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
			// Reset the image
			swapImg(yellowHeart);
		}
		
		// Function to create shots
		private function createShot(big:Boolean = false):void {
			if (big) {Main.screen.addChild(new BigShot(this.x, this.y)); SoundLibrary.play("bigfire");}
			else {Main.screen.addChild(new Shot(this.x, this.y)); SoundLibrary.play("fire");}
		}
		
		// Each frame
		private function update():void {
			// Charge big shots
			if (takeInput && Input.getKey(90) == true) {zTimer++;}
			// Start sound and change image
			if (zTimer == 20) {chargesound_channel = SoundLibrary.play("chargesound", 0, int.MAX_VALUE);}
			else if (zTimer == 45) {swapImg(whiteHeart);}
			// Gradually increase volume
			if (chargesound_channel) {
				if (chargesound_channel.soundTransform.volume < 0.5 && zTimer >= 5) {
					chargesound_channel.soundTransform = new SoundTransform(Math.pow((zTimer - 5) / 45, 2)/2);
				}
			}
			// Release Z and fire the shot(s)
			if (takeInput && Input.getKey(90) == false && zTimer > 0) {
				fireShots(zTimer); 
				zTimer = 0; 
				if (chargesound_channel) {chargesound_channel.stop(); chargesound_channel = null;}
			}
		
			// Movement
			// Start with an empty vector and add corresponding directions
			var vector:MovementVector = new MovementVector()
			if (takeInput && Input.getKey(37) == true) {vector.add(new MovementVector(180, 2.75));}
			if (takeInput && Input.getKey(38) == true) {vector.add(new MovementVector(90, 2.75));}
			if (takeInput && Input.getKey(39) == true) {vector.add(new MovementVector(0, 2.75));}
			if (takeInput && Input.getKey(40) == true) {vector.add(new MovementVector(270, 2.75));}
			
			// If we're colliding with a wall, add the wall's vector
			for each (var obj:Wall in collidingWalls) {
				vector.add(obj.colliderVector);
			}
			obj = null;
			
			// Move along the vector
			var dim:Point = vector.getDimensions();
			move(dim.x, -dim.y);
			
			// Grazing
			// If no bullets grazing, fade out
			if (grazezone.alpha > 0 && grazingBullets.length == 0) {
				grazezone.alpha = grazezone.alpha - 0.2
			}
			
			// Handle damage and immunity
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
		
		// Move the player and its points to a specific location
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
		
		// Move relative to current location
		public function move(x:Number, y:Number):void {
			moveTo(this.x + x, this.y + y);
		}
		
		// Change image
		private function swapImg(newimg:BitmapData):void {
			bmpObj.bitmapData = newimg;
		}
		
		// Play graze sound and show outline
		public function graze():void {
			SoundLibrary.play("graze", 0.5);
			grazezone.alpha = 1;
		}
		
		// Damage the player
		public static function hurt(damageMultiplier:Number, bulletElement = null):Boolean {
			// Math (voir https://deltarune.fandom.com/wiki/Stats)
			var totaldamage:int;
			if (!Main.screen.spamton.bluelightMode) {
				// Base dmg
				totaldamage = Main.screen.spamton.attack * damageMultiplier;
				// For every defense point
				for (var i:int = 0; i < Kris.instance.calculateDefense(); i++) {
					// Reduce damage by a number proportional to the ratio between totaldamage and maxhp (160)
					if (totaldamage > (1/5) * 160) {totaldamage -= 3;}
					else if (totaldamage > (1/8) * 160) {totaldamage -= 2;}
					else {totaldamage -= 1;}
				}
				// DEFEND reduces damage to 2/3
				if (Kris.instance.isDefending) {totaldamage = Math.ceil(totaldamage * (2/3));}
				// Elemental resistance
				totaldamage = Math.ceil(totaldamage * Kris.instance.getResistPercent(bulletElement));
			}
			// Limit damage during bluelight mode
			else {totaldamage = 11;}
			var new_hp:Number = Math.max(0, UI.instance.hp - totaldamage);
			
			// Play sound
			SoundLibrary.play("hurt", 0.75);
			
			// GameOver
			if (new_hp == 0) {
				Main.gameOver();
				if (instance.chargesound_channel) {instance.chargesound_channel.stop(); instance.chargesound_channel = null;}
				// return true if damage kills the player
				return true;
			}
			// Normal damage
			else {
				// Activate immunity
				instance.iFrames = 60;
				// Cancel graze
				for each (var b:Bullet in instance.grazingBullets) {
					instance.grazingBullets.splice(0, 1);
					b.grazeID = -1;
				}
				b = null;
				instance.grazezone.alpha = 0;
				// Change HP
				UI.instance.setHP(new_hp);
				// Show damage
				new DamageNumber(totaldamage, Kris.instance);
				// Shake screen
				Main.screen.shakeScreen();
				// Change animation
				Kris.instance.gotoAndPlay("hurt");
				return false;
			}
		}
		
		// Add HP
		public static function heal(n:Number):void {
			// Determine new HP
			var newhp:int = Math.min(UI.instance.hp + n, 160);
			// Figure out what to show in the DamageNumber
			var txt = n;
			if (newhp == 160) {txt = "max";}
			// Make a DamageNumber
			new DamageNumber(txt, Kris.instance, "green");
			// Change HP
			UI.instance.setHP(newhp);
			// Play a sound
			SoundLibrary.play("heal", 0.5);
		}
		
		// Remove everything
		private function cleanup(e:Event):void {
			if (chargesound_channel) {chargesound_channel.stop(); chargesound_channel = null;}
			GlobalListener.removeEvent(eventID);
			this.removeEventListener(Event.REMOVED_FROM_STAGE, cleanup);
			instance = null;
		}
	}
}
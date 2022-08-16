/*
	Date: 01-11-2021
	Description: pipis -> "An invasive species of freshwater clam."
*/

package scripts.bullets {
	import flash.geom.Point;
	import flash.display.Bitmap;
	import scripts.Bullet;
	import scripts.BigShot;
	import scripts.EnemyWave;
	import scripts.SoundLibrary;
	import scripts.ui.TPMeter;
	import scripts.utils.MovementVector;

	public class pipis extends Bullet {
		public static var pipisCount:int = 0;
	
		public var vector:MovementVector;
		public var bounceDelay:Number = 0;
		
		private var rotSpeed:Number;
		private var gravityStrength:Number;
		private var label:Bitmap;
		
		// Constructor
		public function pipis(v:MovementVector = null, gravity:Number = 0.09) {
			// Track total pipis population
			pipisCount++;
			
			shootable = true;
			destroyBigShot = false;
			element = 6;
			
			// Initiate movement variables
			if (v) {vector = v;}
			else {vector = new MovementVector(180, 1.5)}
			rotSpeed = 10 * Math.random() + 5;
			gravityStrength = gravity;
		}
		
		// Label for "pipis"
		public function addLabel():void {
			// Makes the "pipis" bitmap
			label = new Bitmap(new pipisLabelLAT(0,0));
			label.x = this.x - 45;
			label.y = this.y + 25;
			this.parent.addChild(label);
		}
		
		// Explodes the pipis and frees the Spamlings
		public function explode(range:Array = null, amount:int = 15, minSpeed:Number = 2):void {
			// Play a sound
			SoundLibrary.play("bomb", 0.25);
			// Make the heads
			for (var i:int = 0; i < amount; i++) {
				var head:pipisHead = new pipisHead(range, minSpeed);
				head.x = this.x;
				head.y = this.y;
				EnemyWave.currentWave.addBullet(head);
			}
			// Destroy the pipis
			destroy();
		}
		
		// Every frame
		public override function update():void {
			// Reduce bounceDelay to 0
			if (bounceDelay > 0) {bounceDelay--;}
			
			// Enact gravity
			vector.add(new MovementVector(270, gravityStrength));
			// Move the pipis
			var dim:Point = vector.getDimensions();
			this.x += dim.x;
			this.y -= dim.y;
			// Rotation
			this.rotation -= rotSpeed;
			// Move the label
			if (label) {
				label.x = this.x - 45;
				label.y = this.y + 25;
			}
		}
		
		// When the pipis is gone :(
		public override function cleanup():void {
			// Destroy label
			if (label) {if (label.parent) {label.parent.removeChild(label);}}
			label = null;
			// Reduce pipisCount
			pipisCount--;
		}
		
		// Shot
		public override function onShot(shot):void {
			// BigShots add TP and instantly destroy pipis
			if (shot is BigShot) {
				TPMeter.instance.addTP(3);
				this.gotoAndStop(5);
			}
			// Regular shots advance damage by 1
			else {this.gotoAndStop(this.currentFrame + 1);}
			// Play a sound
			SoundLibrary.play("enemydamage", 0.4);
		}
	}
}
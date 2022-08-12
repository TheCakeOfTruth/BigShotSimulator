/*
	File Name: pipis.as
	Programmeur: William Mallette
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
		
		// constructor
		public function pipis(v:MovementVector = null, gravity:Number = 0.09) {
			// Garder en note le montant de pipis qui existe
			pipisCount++;
			
			shootable = true;
			destroyBigShot = false;
			element = 6;
			
			// Initier des valeurs de mouvement
			if (v) {vector = v;}
			else {vector = new MovementVector(180, 1.5)}
			rotSpeed = 10 * Math.random() + 5;
			gravityStrength = gravity;
		}
		
		// Montrer le signe de "pipis"
		public function addLabel():void {
			// Créer le bitmap du signe de "pipis"
			label = new Bitmap(new pipisLabelLAT(0,0));
			label.x = this.x - 45;
			label.y = this.y + 25;
			this.parent.addChild(label);
		}
		
		// Exploser le pipis et libérer les têtes de Spamton
		public function explode(range:Array = null, amount:int = 15, minSpeed:Number = 2):void {
			// Jouer un son
			SoundLibrary.play("bomb", 0.25);
			// Créer les têtes
			for (var i:int = 0; i < amount; i++) {
				var head:pipisHead = new pipisHead(range, minSpeed);
				head.x = this.x;
				head.y = this.y;
				EnemyWave.currentWave.addBullet(head);
			}
			// Détruire le pipis
			destroy();
		}
		
		// À chaque frame,
		public override function update():void {
			// Réduire bounceDelay jusqu'à 0
			if (bounceDelay > 0) {bounceDelay--;}
			
			// La gravité
			vector.add(new MovementVector(270, gravityStrength));
			// Le mouvement
			var dim:Point = vector.getDimensions();
			this.x += dim.x;
			this.y -= dim.y;
			// La rotation
			this.rotation -= rotSpeed;
			// Le signe de "pipis"
			if (label) {
				label.x = this.x - 45;
				label.y = this.y + 25;
			}
		}
		
		// Lorsqu'on détruit le pipis
		public override function cleanup():void {
			// Détruire le label
			if (label) {if (label.parent) {label.parent.removeChild(label);}}
			label = null;
			// Réduire pipisCount
			pipisCount--;
		}
		
		// Lorsqu'on frappe le pipis avec un Shot ou BigShot
		public override function onShot(shot):void {
			// Un BigShot ajoute du TP et détruit le pipis immédiatement
			if (shot is BigShot) {
				TPMeter.instance.addTP(3);
				this.gotoAndStop(5);
			}
			// Un Shot avance l'état de dommage du pipis par 1
			else {this.gotoAndStop(this.currentFrame + 1);}
			// Jouer un son
			SoundLibrary.play("enemydamage", 0.4);
		}
	}
}
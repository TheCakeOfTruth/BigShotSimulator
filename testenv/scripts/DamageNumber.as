/*
	File Name: DamageNumber.as
	Programmeur: William Mallette
	Date: 10-11-2021
	Description: Les nombres qui apparaissent quand un personnage est endommagé ou guérit
*/

package scripts {
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	
	public class DamageNumber extends Sprite {
		// Positionnement et des images/couleurs qui peuvent être accédés par tous instances de ce classe.
		private static var numNumbers:uint = 0;
		private static var numbers:Array = [new DMN0(0,0), new DMN1(0,0), new DMN2(0,0), new DMN3(0,0), new DMN4(0,0), new DMN5(0,0), new DMN6(0,0), new DMN7(0,0), new DMN8(0,0), new DMN9(0,0)];
		private static var maxsign:DMNMax = new DMNMax(0,0);
		private static var colorBlue:ColorTransform = new ColorTransform(0.505);
		private static var colorGreen:ColorTransform = new ColorTransform(0, 1, 0);
		private static var colorYellow:ColorTransform = new ColorTransform(1, 0.961, 0.263);
		
		private var timer:uint = 0;
		private var initialX:Number;
		private var initialY:Number;
		
		// constructor
		public function DamageNumber(n, t:DisplayObject, c:String = "white", yoffset:Number = 0, xoffset:Number = 0) {
			// Si on utilise un numéro, sépare les caractères.
			if (typeof(n) == "number") {
				var chiffres:Array = String(n).split("");
				// Pour chaque caractère, créer un Bitmap du chiffre correspondant et addChild.
				for each (var chiffre:String in chiffres) {
					var bmp:Bitmap = new Bitmap(numbers[int(chiffre)]);
					this.addChild(bmp);
					// Positionner l'image correctement.
					if (this.numChildren > 1) {
						var lastn:DisplayObject = this.getChildAt(this.getChildIndex(bmp) - 1);
						bmp.x = lastn.x + lastn.width;
					}
					bmp.y -= bmp.height;
				}
				chiffre = null;
			} 
			// Parfois on veut utiliser un autre image, comme "MAX".
			else if (n == "max") {
				var bmpmax:Bitmap = new Bitmap(maxsign);
				this.addChild(bmpmax);
				bmpmax.y -= bmpmax.height;
			}
			
			// Positionner l'objet
			this.x = t.x + xoffset;;
			this.y = t.y - 25 * numNumbers + yoffset;
			
			// Montrer l'objet
			Main.screen.addChild(this);
			
			// Garder les positions initials de l'objet (monter l'objet s'il y a déjà quelques-uns).
			initialX = this.x
			initialY = this.y;
			
			// Augmenter numNumbers pour montrer le nouveau montant d'instances de ce classe.
			numNumbers++;
			
			// Ajouter un eventListener.
			this.addEventListener(Event.ENTER_FRAME, update, false, 0, true);
			
			// Changer le couleur si nécessaire.
			switch (c) {
				case "blue":
					this.transform.colorTransform = colorBlue;
					break;
				case "green":
					this.transform.colorTransform = colorGreen;
					break;
				case "yellow":
					this.transform.colorTransform = colorYellow;
					break;
			}
		}
		
		// Changer l'image à chaque frame.
		private function update(e:Event):void {
			timer++;
			// Bouger l'objet de façon parabolique.
			if (this.x < initialX + 50) {
				this.x += 2.4;
				this.y = initialY + 0.02 * (x - initialX) * (x - (initialX + 50));
			}
			// Animation de disparition.
			else if (timer > 60) {
				this.height += (timer - 60)/10;
				this.alpha -= 0.05;
			}
			// Détruire l'objet quand ce n'est plus visible.
			if (this.alpha <= 0) {this.destroy();}
		}
		
		// Détruire l'objet
		private function destroy():void {
			numNumbers--;
			this.removeEventListener(Event.ENTER_FRAME, update);
			this.parent.removeChild(this);
		}
	}
}
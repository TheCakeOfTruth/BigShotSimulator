/*
	File Name: HPText.as
	Programmeur: William Mallette
	Date: 05-11-2021
	Description: Le texte pour l'HP de l'UI. J'ai fait ceci car le font que j'ai téléchargé ne fonctionnait pas.
*/

package scripts.ui {
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	
	public class HPText extends Sprite {
		// Pour une raison ou une autre, je ne peux pas faire ces variables static.
		private var numbers:Array = [new UIN0(0,0), new UIN1(0,0), new UIN2(0,0), new UIN3(0,0), new UIN4(0,0), new UIN5(0,0), new UIN6(0,0), new UIN7(0,0), new UIN8(0,0), new UIN9(0,0)];
		private var none:BitmapData = new UINN(0,0);
		private var bitmaps:Array = [];
		
		// constructor
		public function HPText() {
			// remplacer les images de l'éditeur avec des bitmaps modifiables
			for (var i:int = 0; i < this.numChildren; i++) {
				var child:DisplayObject = getChildAt(i);
				var x:Number = child.x;
				var y:Number = child.y;
				var bitmap:Bitmap = new Bitmap();
				
				this.removeChildAt(i);
				this.addChildAt(bitmap, 0);
				bitmap.x = x;
				bitmap.y = y;
				
				bitmaps.push(bitmap);
			}
		}
		
		// Changer le nombre montré
		public function setHP(n:int):void {
			// Convertir le nombre en array, ajouter des caractères vides pour assurer que chaque Bitmap a un image à montrer
			var chiffres:Array = String(n).split("");
			if (chiffres.length < 3) {do {chiffres.splice(0, 0, "n")} while (chiffres.length < 3);}
			// Remplacer les Bitmaps
			for (var i:int = 0; i < chiffres.length; i++) {
				if (chiffres[i] == "n") {bitmaps[i].bitmapData = none;}
				else {bitmaps[i].bitmapData = numbers[int(chiffres[i])];}
			}
		}
	}
}
/*
	Date: 04-08-2023
	Description: Like HPText but for max HP
*/

package scripts.ui {
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	
	public class MaxHPText extends HPText {
		// These can't be static for reasons I cannot comprehend
		private var numbers:Array = [new UIN0(0,0), new UIN1(0,0), new UIN2(0,0), new UIN3(0,0), new UIN4(0,0), new UIN5(0,0), new UIN6(0,0), new UIN7(0,0), new UIN8(0,0), new UIN9(0,0)];
		private var none:BitmapData = new UINN(0,0);
		private var bitmaps:Array = [];
		
		// Constructor
		public function MaxHPText() {
			// Modifiable bitmaps
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
		
		// Change the displayed number
		public function setMaxHP(n:int):void {
			// Convert digits to an array, add blank characters to make sure every bitmap shows something
			var chiffres:Array = String(n).split("");
			if (chiffres.length < 3) {do {chiffres.push("n")} while (chiffres.length < 3);}
			chiffres.reverse();
			// Replace the bitmaps
			for (var i:int = 0; i < chiffres.length; i++) {
				if (chiffres[i] == "n") {bitmaps[i].bitmapData = none;}
				else {bitmaps[i].bitmapData = numbers[int(chiffres[i])];}
			}
		}
	}
}
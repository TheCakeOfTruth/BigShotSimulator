/*
	Date: 10-11-2021
	Description: Numbers that appear when damage/healing
*/

package scripts {
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	
	public class DamageNumber extends Sprite {
		// Static variables for numbers and colors
		private static var numNumbers:uint = 0;
		private static var numbers:Array = [new DMN0(0,0), new DMN1(0,0), new DMN2(0,0), new DMN3(0,0), new DMN4(0,0), new DMN5(0,0), new DMN6(0,0), new DMN7(0,0), new DMN8(0,0), new DMN9(0,0)];
		private static var maxsign:DMNMax = new DMNMax(0,0);
		private static var colorBlue:ColorTransform = new ColorTransform(0.505);
		private static var colorGreen:ColorTransform = new ColorTransform(0, 1, 0);
		private static var colorYellow:ColorTransform = new ColorTransform(1, 0.961, 0.263);
		
		private var timer:uint = 0;
		private var initialX:Number;
		private var initialY:Number;
		
		// Constructor
		public function DamageNumber(n, t:DisplayObject, c:String = "white", yoffset:Number = 0, xoffset:Number = 0) {
			// Separate characters for numbers
			if (typeof(n) == "number") {
				var chiffres:Array = String(n).split("");
				// For each character, create the corresponding Bitmap and add it as a child to this object
				for each (var chiffre:String in chiffres) {
					var bmp:Bitmap = new Bitmap(numbers[int(chiffre)]);
					this.addChild(bmp);
					// Position the number
					if (this.numChildren > 1) {
						var lastn:DisplayObject = this.getChildAt(this.getChildIndex(bmp) - 1);
						bmp.x = lastn.x + lastn.width;
					}
					bmp.y -= bmp.height;
				}
				chiffre = null;
			} 
			// Other damage text (like MAX)
			else if (n == "max") {
				var bmpmax:Bitmap = new Bitmap(maxsign);
				this.addChild(bmpmax);
				bmpmax.y -= bmpmax.height;
			}
			
			// Position the object
			this.x = t.x + xoffset;;
			this.y = t.y - 25 * numNumbers + yoffset;
			
			// Show the object
			Main.screen.addChild(this);
			
			// Keep initial position
			initialX = this.x
			initialY = this.y;
			
			// Track how many number objects exist
			numNumbers++;
			
			// Add eventListener
			this.addEventListener(Event.ENTER_FRAME, update, false, 0, true);
			
			// Change the color
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
		
		// On every frame
		private function update(e:Event):void {
			timer++;
			// Move the object
			if (this.x < initialX + 50) {
				this.x += 2.4;
				this.y = initialY + 0.02 * (x - initialX) * (x - (initialX + 50));
			}
			// Disappear animation
			else if (timer > 60) {
				this.height += (timer - 60)/10;
				this.alpha -= 0.05;
			}
			// Destroy object when no longer visible
			if (this.alpha <= 0) {this.destroy();}
		}
		
		// Destroy the object
		private function destroy():void {
			numNumbers--;
			this.removeEventListener(Event.ENTER_FRAME, update);
			this.parent.removeChild(this);
		}
	}
}
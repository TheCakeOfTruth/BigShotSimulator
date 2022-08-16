/*
	Date: 30-11-2021
	Description: Rollercoaster attack
*/

package scripts.attacks {
	import scripts.EnemyWave;
	import scripts.bullets.CartRail;
	import scripts.bullets.Cungadero;
	import scripts.utils.Wait;
	
	public class RollerCoaster extends EnemyWave {
		// Various preconfigurations
		private static var settings1:Array = [["h", "m", "m", "m", "m"],
											  60,
		                                      ["m", "m", "h", "b", "m"],
											  60,
											  ["m", "m", "b", "h", "m"],
											  60,
											  ["m", "m", "h", "h", "m"],
											  ["m", "m", "h", "h", "m"],
											  ["m", "m", "h", "h", "m"],
											  ["m", "m", "h", "h", "m"],
											  60,
											  ["h", "m", "m", "m", "m"],
											  60,
											  ["m", "m", "m", "h", "m"],
											  60,
											  ["m", "h", "m", "b", "m"],
											  60,
											  ["m", "m", "h", "h", "m"],
											  ["m", "m", "h", "h", "m"],
											  ["m", "m", "h", "h", "m"],
											  ["m", "m", "h", "h", "m"]];
		
		private var carts:Array = [];
		
		// Constructor
		public function RollerCoaster() {
			// Setup
			waveTimer = 12750;
			arenaConfig = {x: 305, y: 171, width: 250, height: 172};
			
			// Make the CartRail
			var rail:CartRail = new CartRail();
			rail.x = 320;
			rail.y = 304;
			this.addChild(rail);
			
			createCarts(settings1);
		}
		
		// Create carts from the settings arrays
		private function createCarts(mode:Array):void {
			var delay:int = 40;
			for (var i:int = 0; i < mode.length; i++) {
				// Get the object at the index
				var cart = mode[i];
				// If it's an array, create a Cungadero object with that configuration
				if (cart is Array) {
					var newcart:Cungadero = new Cungadero(cart);
					this.addChild(newcart);
					carts.push(newcart);
					newcart.startWait(5 + delay);
					delay += 10;
				}
				// If it's a number, delay the next cart by that many frames
				else if (cart is int) {
					delay += cart;
				}
			}
		}
		
		// Every frame
		public override function update():void {
			for each (var b:Cungadero in carts) {
				if (b.isMoving) {
					// Move each cart with a variable speed
					var xvel:Number = 2 * (-Math.cos(((Math.PI * b.x) / 320) - 160 * Math.PI) - 2.5);
					b.x += xvel;
				}
			}
			b = null;
		}
		
		public override function cleanup(transition:Boolean):void {carts = null;}
	}
}
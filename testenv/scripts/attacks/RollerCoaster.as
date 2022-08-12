/*
	File Name: RollerCoaster.as
	Programmeur: William Mallette
	Date: 30-11-2021
	Description: Le deuxième attaque
*/

package scripts.attacks {
	import scripts.EnemyWave;
	import scripts.bullets.CartRail;
	import scripts.bullets.Cungadero;
	import scripts.utils.Wait;
	
	public class RollerCoaster extends EnemyWave {
		// Voici l'array bidimensionnel.
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
		
		// constructor
		public function RollerCoaster() {
			// Setup le wave
			waveTimer = 12750;
			arenaConfig = {x: 305, y: 171, width: 250, height: 172};
			
			// Créer le CartRail
			var rail:CartRail = new CartRail();
			rail.x = 320;
			rail.y = 304;
			this.addChild(rail);
			
			createCarts(settings1);
		}
		
		// Créer chaque cart dans l'array bidimensionnel spécifié
		private function createCarts(mode:Array):void {
			var delay:int = 40;
			for (var i:int = 0; i < mode.length; i++) {
				// Obtenir l'objet à l'index
				var cart = mode[i];
				// Si c'est un array, crée un Cungadero avec ces objets (après le délai)
				if (cart is Array) {
					var newcart:Cungadero = new Cungadero(cart);
					this.addChild(newcart);
					carts.push(newcart);
					newcart.startWait(5 + delay);
					delay += 10;
				}
				// Si c'est un nombre, change le délai à ce nombre
				else if (cart is int) {
					delay += cart;
				}
			}
		}
		
		// À chaque frame
		public override function update():void {
			for each (var b:Cungadero in carts) {
				if (b.isMoving) {
					// Bouger chaque cart avec une vitesse variable
					var xvel:Number = 2 * (-Math.cos(((Math.PI * b.x) / 320) - 160 * Math.PI) - 2.5);
					b.x += xvel;
				}
			}
			b = null;
		}
		
		public override function cleanup(transition:Boolean):void {carts = null;}
	}
}
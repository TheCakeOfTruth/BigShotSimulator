/*
	Date: 01-11-2021
	Description: Base class for enemy projectiles
*/

package scripts {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import scripts.ui.TPMeter;
	import scripts.utils.GlobalListener;

	public class Bullet extends MovieClip {
		public var exists:Boolean = true;
		public var shootable:Boolean = false;
		public var destroyBigShot:Boolean = false;
		public var damageMultiplier:Number = 5;
		public var destroyOnHit:Boolean = true;
		public var grazeTP:Number = 1;
		public var grazeID:int = -1;
		public var hasGrazed:Boolean = false;
		public var element = 0;
		private var eventID:String;
		
		// Constructor
		public function Bullet() {
			eventID = "Bullet-" + String(Math.random());
			GlobalListener.addEvent(updateBullet, eventID);
			addEventListener(Event.REMOVED_FROM_STAGE, destroy, false, 0, true);
		}
		
		// Each frame
		private function updateBullet():void {
			if (exists) {
				// Only run if the bullet interacts with shots
				if (shootable) {
					// Check to see if the bullet is colliding with a shot
					for each (var shot in Player.shots) {
						for each (var pt:Point in shot.hitPoints) {
							if (hitTestPoint(pt.x, pt.y, true)) {
								// Run onShot() if shot
								onShot(shot);
								// Destroy the shot if specified
								if ((shot is BigShot && destroyBigShot) || (shot is Shot)) {
									shot.destroy();
								}
								break;
							}
						}
						pt = null;
					}
					shot = null;
				}
				
				if (Player.instance) {
					// Check for Player-Bullet collision
					// Destroys the Bullet if specified
					if (this.hitTestObject(Player.instance)) {
						for each (var hpt:Point in Player.instance.hitBox) {
							if (hitTestPoint(hpt.x, hpt.y, true)) {
								var isfatal:Boolean;
								if (Player.instance.iFrames == 0) {isfatal = Player.hurt(damageMultiplier, element);}
								if (destroyOnHit && !isfatal) {destroy();}
							}
						}
						hpt = null;
					}
					
					// Only run if the player isn't invincible
					if (Player.instance.iFrames == 0) {
						var checkGraze:Boolean = false;
						// Check for a graze
						if (this.hitTestObject(Player.instance)) {
							for each (var gpt:Point in Player.instance.grazeBox) {
								if (hitTestPoint(gpt.x, gpt.y, true)) {
									if (grazeID == -1) {
										// Add Bullet to Player.grazingBullets
										grazeID = Player.instance.grazingBullets.push(this) - 1;
										// Add TP
										if (hasGrazed == false) {TPMeter.instance.addTP(grazeTP);}
										// Do the graze
										Player.instance.graze();
										hasGrazed = true;
									} 
									else if (hasGrazed) {TPMeter.instance.addTP(grazeTP / 40);}
									// Check if we're still grazing the bullet
									checkGraze = true;
									break;
								}
							}
							gpt = null;
						}
						// Remove from the graze list if no longer grazing
						if (checkGraze == false && grazeID != -1) {
							removeFromGrazeList();
						}
					}
					
					// Destroy offscreen bullets
					if (this.x < -300 || this.x > 940 || this.y < -300 || this.y > 780) {destroy();}
				}
				else {
					// Remove from graze list if the object is destroyed
					if (grazeID != -1) {removeFromGrazeList();}
				}
			}
			
			// Run update()
			update();
		}
		
		// Override function for when you get shot
		public function onShot(shot):void {}
		
		// Override function for frame-by-frame action
		public function update():void {}
		
		// Override function for deleting the object
		public function cleanup():void {}
		
		// Remove from graze list and adjust grazeID
		private function removeFromGrazeList():void {
			if (Player.instance) {
				Player.instance.grazingBullets.splice(grazeID, 1);
				for each (var otherBullet:Bullet in Player.instance.grazingBullets) {
					if (otherBullet.grazeID > grazeID) {
						otherBullet.grazeID--;
					}
				}
				otherBullet = null;
				grazeID = -1;
			}
		}
		
		// Destroy the object
		public function destroy(e:Event = null):void {
			if (exists) {
				stop();
				cleanup();
				if (grazeID != -1) {removeFromGrazeList();}
				GlobalListener.removeEvent(eventID);
				this.removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
				if (this.parent) {this.parent.removeChild(this);}
			}
			exists = false;
		}
	}
}
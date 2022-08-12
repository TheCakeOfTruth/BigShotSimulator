/*
	File Name: Bullet.as
	Programmeur: William Mallette
	Date: 01-11-2021
	Description: Classe de base pour les projectiles de l'ennemi.
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
		
		// constructor
		public function Bullet() {
			eventID = "Bullet-" + String(Math.random());
			GlobalListener.addEvent(updateBullet, eventID);
			addEventListener(Event.REMOVED_FROM_STAGE, destroy, false, 0, true);
		}
		
		// Effectuer des changements à chaque frame
		private function updateBullet():void {
			if (exists) {
				// Effectuer seulement si l'objet peut intéragir avec les balles
				if (shootable) {
					// Algorithme de recherche pour vérifier si le Bullet est Shot
					// Itérer pour chaque Shot ou BigShot dans Player.shots
					for each (var shot in Player.shots) {
						// Vérifier pour une collision entre les points du Shot et le Bullet
						for each (var pt:Point in shot.hitPoints) {
							if (hitTestPoint(pt.x, pt.y, true)) {
								// Exéctuer la fonction stockée
								onShot(shot);
								// Si on peut détruire la balle, détruit-la et break pour éviter une erreur
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
					// Algorithme de recherche pour vérifier le collision entre le Player et le Bullet
					// Vérifier le collision et endommager le Player/détruire le Bullet si nécessaire
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
					
					// Seulement si le Player n'est pas invincible
					if (Player.instance.iFrames == 0) {
						var checkGraze:Boolean = false;
						// Algorithme de recherche pour vérifier si le Player graze le Bullet
						// Quand le Player est assez proche à un Bullet, fait l'effet de graze.
						// Vérifie une collision entre les points du grazeBox du Player et le Bullet
						if (this.hitTestObject(Player.instance)) {
							for each (var gpt:Point in Player.instance.grazeBox) {
								if (hitTestPoint(gpt.x, gpt.y, true)) {
									if (grazeID == -1) {
										// Ajoute le Bullet à Player.grazingBullets
										grazeID = Player.instance.grazingBullets.push(this) - 1;
										// Ajoute un peu de TP
										if (hasGrazed == false) {TPMeter.instance.addTP(grazeTP);}
										// Fait l'effet de graze
										Player.instance.graze();
										hasGrazed = true;
									} 
									else if (hasGrazed) {TPMeter.instance.addTP(grazeTP / 40);}
									// Vérifier si on graze encore ce Bullet
									checkGraze = true;
									break;
								}
							}
							gpt = null;
						}
						// Si le Bullet est dans grazingBullets et n'est pas dans le zone de graze, enlève-la de l'array et adjuste les autres grazeID.
						if (checkGraze == false && grazeID != -1) {
							removeFromGrazeList();
						}
					}
					
					// Détruire un Bullet s'il est trop hors de l'écran
					if (this.x < -300 || this.x > 940 || this.y < -300 || this.y > 780) {destroy();}
				}
				else {
					// Essayer d'enlever du graze list si le Bullet n'existe pas
					if (grazeID != -1) {removeFromGrazeList();}
				}
			}
			
			// Faire update()
			update();
		}
		
		// Définition vide de la méthode onShot(), supposé d'être utilisé comme un "override" dans des classes héritées
		public function onShot(shot):void {}
		
		// Définition vide de la méthode update(), supposé d'être utilisé comme un "override" dans des classes héritées
		public function update():void {}
		
		// Définition vide de la méthode cleanup(), supposé d'être utilisé comme un "override" dans des classes héritées
		public function cleanup():void {}
		
		// Enlever le Bullet de Player.grazingBullets et adjuster les autres grazeID
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
		
		// Détruire l'objet
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
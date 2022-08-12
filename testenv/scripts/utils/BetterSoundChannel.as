/*
	File Name: BetterSoundChannel.as
	Programmeur: William Mallette
	Date: 13-12-2021
	Description: Un SoundChannel qui peut être mieux géré
*/

package scripts.utils {
	import flash.display.Bitmap;
	import flash.system.System;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.events.Event;
	
	public class BetterSoundChannel extends Bitmap {
		public static var playingSounds:Array = [];
		public var arrayID:int;
		private var storedSound:Sound;
		private var channel:SoundChannel;
		private var loopsRemaining:int;
		private var _soundTransform:SoundTransform;

		// constructor
		public function BetterSoundChannel(snd:Sound, loops:int = 0, transform:SoundTransform = null) {
			// Stocker des variables
			storedSound = snd;
			if (transform) {_soundTransform = transform;}
			else {_soundTransform = new SoundTransform()};
			loopsRemaining = loops;
			// Jouer le son, ajouter l'eventListener
			channel = snd.play(0, 0, transform);
			addEventListener(Event.ENTER_FRAME, checkTime, false, 0, true);
			// Stocker le BetterSoundChannel dans l'array
			arrayID = playingSounds.push(this) - 1;
			// Si le son a failli à s'initier, effacer l'objet
			if (channel == null) {removeSound();}
		}
		
		// Je ne pouvais pas utiliser Event.SOUND_COMPLETE puisqu'il y aura trop d'un délai avant le loop, donc j'utilise Event.ENTER_FRAME
		private function checkTime(e:Event):void {
			// Loop lorsqu'on est à environ 240 millisecondes avant le fin du son
			if (channel.position > storedSound.length - 240) {
				tryLoop();
			}
		}
		
		// Essayer un loop
		private function tryLoop():void {
			// S'il y a encore des loop à faire
			if (loopsRemaining > 1) {
				// Réduire le montant de loops, et "recommencer" (jouer un autre instance) du son
				loopsRemaining--;
				channel = storedSound.play(0, 0, _soundTransform);
			}
			// Sinon,
			else {
				removeSound();
			}
		}
		
		// Voici la raison pourquoi j'ai créé cette classe: SoundChannel.stop() ne cause pas un Event.SOUND_COMPLETE
		// Alors, quand je voulais arrêter un son avec SoundChannel.stop(), il ne serait jamais supprimé
		// Donc, j'ai essayé de limiter le montant de loops et de mettre le volume à 0
		// Cela fonctionnait, jusqu'à temps qu'il y avait environ 32 instances du même son qui jouait, et là aucun autre son jouait
		// Donc, j'ai créé cette classe pour que je puisse supprimer proprement un son qui loop.
		public function stop():void {
			// Mettre le volume à 0
			channel.soundTransform = new SoundTransform(0);
			// Le prochaine tryLoop supprimera le son
			loopsRemaining = 0;
		}
		
		// Enlever le BetterSoundChannel de l'array
		private function removeSound():void {
			// Enlever l'eventListener et le BetterSoundChannel de l'array
			removeEventListener(Event.ENTER_FRAME, checkTime);
			playingSounds.splice(arrayID, 1);
			for each (var otherSound:BetterSoundChannel in playingSounds) {
				if (otherSound.arrayID > arrayID) {
					otherSound.arrayID--;
				}
			}
			otherSound = null;
			arrayID = -1;
			// GC pour libérer les ressources antérieurement occupés par cette son
			System.gc();
		}
		
		// Fade out le son
		public function fadeOut(interval:Number = 0.0025):void {
			new RepeatUntil(function() {
				channel.soundTransform = new SoundTransform(channel.soundTransform.volume - interval);
			}, function() {
				if (channel.soundTransform.volume <= 0) {
					stop();
					return true;
				}
			});
		}
		
		// Le soundTransform (imiter SoundChannel.soundTransform)
		public function get soundTransform():SoundTransform {return channel.soundTransform;}
		public function set soundTransform(value:SoundTransform):void {
			_soundTransform = value;
			channel.soundTransform = value;
		}
		
		public function get position():Number {return channel.position;}
	}
}
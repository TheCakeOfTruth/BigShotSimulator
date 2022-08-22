/*
	Date: 13-12-2021
	Description: SoundChannel but better
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

		// Constructor
		public function BetterSoundChannel(snd:Sound, loops:int = 0, transform:SoundTransform = null) {
			// Store the variables
			storedSound = snd;
			if (transform) {_soundTransform = transform;}
			else {_soundTransform = new SoundTransform()};
			loopsRemaining = loops;
			// Play the sound and add an eventListener
			channel = snd.play(0, 0, transform);
			addEventListener(Event.ENTER_FRAME, checkTime, false, 0, true);
			// Store the BetterSoundChannel in an array
			arrayID = playingSounds.push(this) - 1;
			// If the sound fails to initiate (there is a sound limit), destroy the object
			if (channel == null) {removeSound();}
		}
		
		// I couldn't use Event.SOUND_COMPLETE to loop because it caused too much of a delay, so I use Event.ENTER_FRAME and start the next sound a certain amount of time before it ends
		private function checkTime(e:Event):void {
			// Loop once the sound is at about 240 ms before it ends
			if (channel.position > storedSound.length - 240) {
				tryLoop();
			}
		}
		
		// Try to loop
		private function tryLoop():void {
			// If there are still loops to be done
			if (loopsRemaining > 1) {
				// Reduce loopsRemaining and "restart" (play another instance of) the sound
				loopsRemaining--;
				channel = storedSound.play(0, 0, _soundTransform);
			}
			// Otherwise,
			else {
				removeSound();
			}
		}
		
		// Behold why I am doing this: SoundChannel.stop() doesn't trigger an Event.SOUND_COMPLETE
		// So, when I wanted to stop a looping sound with SoundChannel.stop(), it could never be deleted
		// So, I tried to limit the amount of loops and set the volume to 0
		// That worked for a time, until there were around 32 instances of the same sound playing, then no other instance could be created
		// So, I made this class so that I could properly delete looping sounds
		public function stop():void {
			// Set volume to 0
			channel.soundTransform = new SoundTransform(0);
			// The next tryLoop will delete the sound
			loopsRemaining = 0;
		}
		
		// Remove the BetterSoundChannel from the array
		private function removeSound():void {
			// Remove the eventListener too
			removeEventListener(Event.ENTER_FRAME, checkTime);
			playingSounds.splice(arrayID, 1);
			for each (var otherSound:BetterSoundChannel in playingSounds) {
				if (otherSound.arrayID > arrayID) {
					otherSound.arrayID--;
				}
			}
			otherSound = null;
			arrayID = -1;
			// GC to free up the resources previously occupied by this sound
			System.gc();
		}
		
		// Fade out the sound
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
		
		// The soundTransform (imitates SoundChannel.soundTransform)
		public function get soundTransform():SoundTransform {return channel.soundTransform;}
		public function set soundTransform(value:SoundTransform):void {
			_soundTransform = value;
			channel.soundTransform = value;
		}
		
		public function get position():Number {return channel.position;}
	}
}
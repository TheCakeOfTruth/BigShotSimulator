/*
	Date: 04-12-2021
	Description: "new" sounds increase memory usage which can't be retrieved. So, load one instance of each sound at the beginning, and make a new sound system to handle them.
*/

package scripts {
	import flash.utils.Dictionary;
	import flash.media.SoundTransform;
	import scripts.utils.BetterSoundChannel;
	
	public class SoundLibrary {
		public static var dict:Dictionary = new Dictionary();
		
		// Constructor initiates the sounds, only use once
		public function SoundLibrary() {
			dict["mus_bigshot"] = new MusBigShot();
			dict["mus_defeat"] = new MusGameOver();
			dict["mus_darkness"] = new MusDarkness();
			dict["mus_menu"] = new MusMenu();
			dict["mus_gonewrong"] = new MusGoneWrong();
			dict["intronoise"] = new IntroNoise();
			dict["bigfire"] = new ChargeFire();
			dict["chargesound"] = new Charge();
			dict["critswing"] = new CritSwing();
			dict["defaultvoice"] = new DefaultVoice();
			dict["enemydamage"] = new DamageSound();
			dict["fire"] = new ShotFire();
			dict["graze"] = new GrazeNoise();
			dict["heal"] = new HealSound();
			dict["healspell"] = new HealingSpellSound();
			dict["hurt"] = new PlayerHurt();
			dict["menumove"] = new MenuMove();
			dict["menuselect"] = new MenuSelect();
			dict["bell"] = new DingSound();
			dict["bomb"] = new BombSound();
			dict["bombbeep"] = new BombBeep();
			dict["voice_sneo"] = new SpamtonVoice();
			dict["swing"] = new SwingSound();
			dict["xslash"] = new XSlashSound();
			dict["phone"] = new PhoneRing();
			dict["break1"] = new FirstBreak();
			dict["break2"] = new SecondBreak();
			dict["err"] = new ErrorSound();
			dict["specil"] = new SpecilSound();
			dict["laugh"] = new SpamtonLaugh();
			dict["switch"] = new SwitchNoise();
			dict["iceshock"] = new IceShockSound();
			dict["carhonk"] = new CarHonkSound();
		}
		
		// Play a sound
		public static function play(sound:String, volume:Number = 0.5, loops:int = 0):BetterSoundChannel {
			// Play the sound
			var newsnd:BetterSoundChannel = new BetterSoundChannel(dict[sound], loops, new SoundTransform(volume));
			return newsnd;
		}
	}
}
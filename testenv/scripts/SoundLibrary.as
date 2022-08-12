/*
	File Name: SoundLibrary.as
	Programmeur: William Mallette
	Date: 04-12-2021
	Description: Les sons chargés par 'new', même s'ils sont déjà chargés, occupent du mémoire qui ne peut pas être récupérer. Alors, j'instancie chaque son ici au commencement, et utilise seulement SoundLibrary.play() dans le futur.
*/

package scripts {
	import flash.utils.Dictionary;
	import flash.media.SoundTransform;
	import scripts.utils.BetterSoundChannel;
	
	public class SoundLibrary {
		public static var dict:Dictionary = new Dictionary();
		
		// constructor initie les sons, faut seulement exécuter une fois
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
		}
		
		// Jouer un son
		public static function play(sound:String, volume:Number = 0.5, loops:int = 0):BetterSoundChannel {
			// Jouer le son
			var newsnd:BetterSoundChannel = new BetterSoundChannel(dict[sound], loops, new SoundTransform(volume));
			return newsnd;
		}
	}
}
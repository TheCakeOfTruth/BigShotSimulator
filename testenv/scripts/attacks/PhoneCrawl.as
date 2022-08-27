/*
	Date: 24-08-2022
	Description: The attack with the horrifying crawling head thing
*/

package scripts.attacks {
	import scripts.EnemyWave;
	import scripts.utils.Wait;
	import scripts.utils.RepeatUntil;
	import scripts.utils.Input;
	import scripts.bullets.*;
	
	public class PhoneCrawl extends EnemyWave {
		private var monster:CrawlyHead;
		private var moving:Boolean = false;
		private var startedAt:int;
	
		// Constructor
		public function PhoneCrawl() {
			// Parameters
			waveTimer = int.MAX_VALUE; // 10000
			arenaConfig = {x: 311, y: 179, width: 240, height: 112};
			
			monster = new CrawlyHead();
			monster.x = 460;
			monster.y = 165;
			monster.alpha = 0;
			addChild(monster);
			
			new RepeatUntil(function() {
				Main.screen.spamton.container.alpha -= 0.025;
			}, function() {
				if (Main.screen.spamton.container.alpha <= 0) {
					new Wait(5, function() {
						new Wait(10, function() {startWave();});
						new RepeatUntil(function() {
							monster.alpha += 0.025;
						}, function() {if (monster.alpha >= 1) {return true;}});});
						return true;
				}
			});
		}
		
		private function startWave():void {
			startedAt = timer;
			moving = true;
			new Wait(10, function() {monster.head.gotoAndPlay("open");});
		}
		
		// Every frame
		public override function update():void {
			if (moving) {
				monster.moveHeadTo(0, 30 * Math.sin((timer - startedAt) / 30));
			}
		}
		
		// Make sure the objects can be properly removed
		public override function cleanup(transition:Boolean):void {
			new RepeatUntil(function() {Main.screen.spamton.container.alpha += 0.05;}, function() {if (Main.screen.spamton.container.alpha >= 1) {return true;}});
		}
	}
}
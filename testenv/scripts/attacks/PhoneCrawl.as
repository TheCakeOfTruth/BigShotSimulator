/*
	Date: 24-08-2022
	Description: The attack with the horrifying crawling head thing
*/

package scripts.attacks {
	import flash.geom.Point;
	import scripts.EnemyWave;
	import scripts.utils.Wait;
	import scripts.utils.RepeatUntil;
	import scripts.utils.Input;
	import scripts.bullets.*;
	
	public class PhoneCrawl extends EnemyWave {
		public static var difficulty:int = 0;
		private var monster:CrawlyHead;
		private var moving:Boolean = false;
		private var startedAt:int;
	
		// Constructor
		public function PhoneCrawl() {
			// Parameters
			waveTimer = int.MAX_VALUE; // 10000
			arenaConfig = {x: 311, y: 179, width: 240, height: 112};
			
			monster = new CrawlyHead();
			monster.x = 480;
			monster.y = 179;
			monster.alpha = 0;
			addChild(monster);
			
			new RepeatUntil(function() {
				Main.screen.spamton.container.alpha -= 0.025;
			}, function() {
				if (Main.screen.spamton.container.alpha <= 0) {
					new Wait(5, function() {
						new Wait(10, function() {new Wait(30, function() {monster.head.gotoAndPlay("open");});});
						new RepeatUntil(function() {
							monster.alpha += 0.025;
						}, function() {if (monster.alpha >= 1) {return true;}});});
						return true;
				}
			});
		}
		
		// Every frame
		public override function update():void {
			// Shot reaction
			if (monster.hspeed > 0) {
				monster.x += monster.hspeed;
				if (monster.localToGlobal(new Point(monster.head.x, 0)).x >= 460) {monster.x = 460 - monster.head.x;}
				monster.hspeed -= monster.friction;
			}
			else {monster.hspeed = 0;}
			
			// Move up and down differently depending on difficulty
			if (difficulty == 0) {monster.moveHeadTo(monster.head.x, Math.sin(timer / 16) * 40);}
			else if (difficulty == 1 || difficulty == 2) {monster.moveHeadTo(monster.head.x, Math.sin(timer / 20) * 60);}
			
			
			// The crawl
			if (difficulty < 2) {
				// Top hand
				if (Math.sin(timer / 10) < 0) {
					monster.moveHandTo(monster.uphone, monster.uphone.x + (Math.sin(timer / 10) * 4)/2, monster.uphone.y + (Math.cos(timer / 10) * 4));
					monster.ufarm.x += Math.sin(timer / 10) * 2;
					monster.ufarm.y += Math.cos(timer / 10) * 2;
				}
				
				// Bottom hand
				if (Math.cos((timer / 10) + Math.PI/2) < 0) {
					monster.moveHandTo(monster.dphone, monster.dphone.x + (Math.cos((timer / 10) + Math.PI/2) * 4)/2, Math.max(60, monster.dphone.y + (Math.sin((timer / 10) + Math.PI/2) * 4)));
					monster.dfarm.x += Math.cos(timer / 10 + Math.PI/2) * 2;
					monster.dfarm.y += Math.sin(timer / 10 + Math.PI/2) * 2;
				}
			}
			
			// Move the rest of the body (by moving the head)
			if (difficulty < 2) {monster.moveHeadTo(monster.head.x + (monster.uphone.x + 70 - monster.head.x) * 0.2, monster.head.y);}
			else {monster.moveHeadTo(monster.head.x - 0.5, monster.head.y);}
		}
		
		// Make sure the objects can be properly removed
		public override function cleanup(transition:Boolean):void {
			new RepeatUntil(function() {Main.screen.spamton.container.alpha += 0.05;}, function() {if (Main.screen.spamton.container.alpha >= 1) {return true;}});
		}
	}
}
/*
	Date: 04-08-2023
	Description: base class for party member menus
*/

package scripts.ui {
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import scripts.party.*;
	import scripts.utils.*;
	
	public class PartyMemberMenu extends MovieClip {
		private static var dontColor:Array = ["kris0", "noelle0", "ralsei0", "susie0"];
		private static var blankColor:ColorTransform = new ColorTransform();
		private static var yellowtxtColor:ColorTransform = new ColorTransform(1, 1, 0);
		private static var redtxtColor:ColorTransform = new ColorTransform(1, 0, 0);

		public var linkedMember:PartyMember;
		public var refID:String = "menu" + Math.random();
		public var active:Boolean = true;
		public var btn2;
		public var btnArray:Array = [];
		public var selectedButton:int = 0;
		
		public var bars:Array = [];
		private var barspeed:Number = 0.25;
		private var barfade:Number = 1/120;
		
		// Constructor
		public function PartyMemberMenu(member:PartyMember) {
			// Pair the menu with a party member
			linkedMember = member;
			linkedMember.battleMenu = this;
			
			// Use party member data to change some sprites/colors
			menu.transform.colorTransform = linkedMember.colors.hpbar;
			info.hpbar.transform.colorTransform = linkedMember.colors.hpbar;
			setIcon(linkedMember.startingIcon);
			info.cname.gotoAndStop(linkedMember.cname);
			bars.push(bar0, bar1, bar2, bar3, bar4, bar5);
			for each (var bar in bars) {bar.transform.colorTransform = linkedMember.colors.hpbar;}
			
			// Set up buttons (including the creation of btn2)
			if (linkedMember.button2 == "act") {btn2 = new ActBtn();}
			else {btn2 = new MagicBtn();}
			btn2.x = -49.5; btn2.y = -16;
			buttons.addChild(btn2);
			
			btnArray.push(buttons.fight, btn2, buttons.item, buttons.spare, buttons.defend);
			
			// Set up the HP texts
			updateHP();
			info.maxhp.setMaxHP(linkedMember.maxhp);
			
			// Set up & handle the bar animations
			bar1.alpha = 2/3; bar4.alpha = 2/3; bar2.alpha = 1/3; bar5.alpha = 1/3;
			GlobalListener.addEvent(function() {
				for each (bar in bars) {
					if (active) {
							 if (bar.x < 0) {bar.x += barspeed; if (bar.alpha <= 0) {bar.x = -103, bar.alpha = 1;}}
						else if (bar.x > 0) {bar.x -= barspeed; if (bar.alpha <= 0) {bar.x = 104,  bar.alpha = 1;}}
						bar.alpha -= barfade;
					}
				}
			}, refID + "bars");
			
			// Compact
			deactivate(true);
		}
		
		// Changing the action icon
		public function setIcon(frame:String):void {
			info.icon.gotoAndStop(frame);
			if (dontColor.indexOf(frame) == -1) {info.icon.transform.colorTransform = linkedMember.colors.icon;}
			else {info.icon.transform.colorTransform = blankColor;}
		}
		
		// Updating the HP display
		public function updateHP():void {
			info.hptext.setHP(linkedMember.hp);
			info.hpbar.width = Math.floor(76 * linkedMember.hp / linkedMember.maxhp);
			info.hpbar.visible = true;
			linkedMember.downed = false;
			
			// Make text yellow when HP is less than 1/5 of maxhp & red when downed
			var colorToSet:ColorTransform;
			if (linkedMember.hp <= 0) {
				colorToSet = redtxtColor;
				info.hpbar.visible = false;
				linkedMember.downed = true;
				// Change icon to downed icon here
			}
			else if (linkedMember.hp <= 0.2 * linkedMember.maxhp) {colorToSet = yellowtxtColor;}
			else {colorToSet = blankColor;}
			info.hptext.transform.colorTransform = colorToSet;
			info.maxhp.transform.colorTransform = colorToSet;
		}
		
		// Compact forme
		public function deactivate(fast:Boolean = false):void {
			if (active) {
				active = false;
				menu.visible = false;
				if (!fast) {
					var moveTimer:int = 0;
					new RepeatUntil(function() {info.y = 8 * moveTimer - 63; menu.y = 8 * moveTimer - 38; moveTimer++;}, function() {return (moveTimer == 5);});
				} else {
					info.y = -31;
					menu.y = -6;
				}
			}
		}
		
		// Normal forme
		public function activate(fast:Boolean = false):void {
			if (!active) {
				active = true;
				menu.visible = true;
				if (!fast) {
					var moveTimer:int = 0;
					new RepeatUntil(function() {info.y = -8 * moveTimer - 31; menu.y = -8 * moveTimer - 6; moveTimer++;}, function() {return (moveTimer == 5);});
				} else {
					info.y = -63;
					menu.y = -38;
				}
			}
		}
	}
}
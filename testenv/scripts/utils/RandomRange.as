/*
	Date: 28-12-2021
	Description: Finally made a function to get a random number between two numbers because I was tired of doing it manually every time
*/

package scripts.utils {
	public function RandomRange(min:Number, max:Number, numDecimals:Number = 9):Number {
		var n:Number = BetterRound((max - min) * Math.random() + min, numDecimals);
		return n;
	}
}
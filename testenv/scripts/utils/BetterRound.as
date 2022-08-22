/*
	Date: 13/09/2021
	Description: Math.round() but with decimals. Due to the nature of floating-point numbers, can be slightly inaccurate sometimes
*/

package scripts.utils {
	public function BetterRound(n:Number, n_decimals:int=0):Number {
		// Calculate a factor that isolates the desired decimals, isolate and round, recombine, then return
		var facteur:int = Math.pow(10, n_decimals);
		var decimal:Number = Math.round((n - int(n)) * facteur) / facteur;
		var new_n:Number = int(n) + decimal;
		return new_n;
	}
}
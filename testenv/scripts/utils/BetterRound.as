/*
	File Name: BetterRound.as
	Programmeur: William Mallette
	Date: 13/09/2021
	Description: Math.round() mais ça peut fonctionner avec des positions décimaux
				 Peut être parfois inexacte à cause de la nature des floating-point numbers
*/

package scripts.utils {
	public function BetterRound(n:Number, n_decimals:int=0):Number {
		// Calculer un facteur pour isoler les décimaux désirés, isoler et arrondir, recombiner, et return
		var facteur:int = Math.pow(10, n_decimals);
		var decimal:Number = Math.round((n - int(n)) * facteur) / facteur;
		var new_n:Number = int(n) + decimal;
		return new_n;
	}
}
/*
	File Name: RandomRange.as
	Programmeur: William Mallette
	Date: 28-12-2021
	Description: J'ai finalement décidé d'ajouter une méthode pour obtenir un nombre aléatoire entre deux autres nombres, au lieu de taper cette équation mille fois
*/

package scripts.utils {
	public function RandomRange(min:Number, max:Number, numDecimals:Number = 9):Number {
		var n:Number = BetterRound((max - min) * Math.random() + min, numDecimals);
		return n;
	}
}
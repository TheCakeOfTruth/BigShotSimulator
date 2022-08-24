/*
	Date: 23-08-2022
	Description: Converts HSV values (Deltarune's main color system) to RGB (Flash's main color system)
*/

package scripts.utils {
	import flash.geom.ColorTransform;
	
	// Explanations pulled from: https://www.had2know.org/technology/hsv-rgb-conversion-formula-calculator.html
	public function HSVToRGB(H:Number, S:Number, V:Number):ColorTransform {
		// Given the values of H, S, and V, you can first compute m and M with the equations
		var max:Number = 255 * V;
		var min:Number = max * (1 - S);
		// Now compute another number, z, defined by the equation
		var z:Number = (max - min) * (1 - Math.abs(((H / 60) % 2) - 1));
		
		var r:Number;
		var g:Number;
		var b:Number;
		// Now you can compute R, G, and B according to the angle measure of H. There are six cases. When 0 ≤ H < 60,
		if (0 <= H && H < 60) {
			r = max;
			g = z + min;
			b = min;
		}
		// If 60 ≤ H < 120,
		else if (60 <= H && H < 120) {
			r = z + min;
			g = max;
			b = min;
		}
		// If 120 ≤ H < 180,
		else if (120 <= H && H < 180) {
			r = min;
			g = max;
			b = z + min;
		}
		// When 180 ≤ H < 240,
		else if (180 <= H && H < 240) {
			r = min;
			g = z + min;
			b = max;
		}
		// When 240 ≤ H < 300,
		else if (240 <= H && H < 300) {
			r = z + min;
			g = min;
			b = max;
		}
		// And if 300 ≤ H < 360,
		else {
			r = max;
			g = min;
			b = z + min;
		}
		return new ColorTransform(r/255, g/255, b/255);
	}
}
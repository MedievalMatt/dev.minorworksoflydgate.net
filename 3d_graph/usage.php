<?php

include __DIR__ . DIRECTORY_SEPARATOR . "mix_tint_tone_shade.php";

// base color
$base_color = "#FF0000";

echo "<P style='color:" . $base_color . "'>Base Color<BR>";
echo "<P style='color:" . tint($base_color) . "'>Tint Color<BR>";
echo "<P style='color:" . tone($base_color) . "'>Tone Color<BR>";
echo "<P style='color:" . shade($base_color) . "'>Shade Color<BR>";
echo "</P><br>";

echo "Base Color<BR>";
print_r($base_color);
echo "<BR>";

// -----

// test hex2rgb
Echo "Hex2RGB<BR>";
print_r(hex2rgb($base_color));
echo "<BR>";

// -----


// test rgb2hex
echo "RGB2Hex<BR>";
print_r(rgb2hex(hex2rgb($base_color)));
echo "<BR>";

// -----

// test tint (hex)
echo "tint(hex)<BR>";
print_r(tint($base_color));
echo "<BR>";

// test tint (rgb)
echo "tint(rgb)<BR>";
print_r(tint(hex2rgb($base_color)));
echo "<BR>";

// -----

// test tone (hex)
echo "tone(hex)<BR>";
print_r(tone($base_color));
echo "<BR>";

// test tone (rgb)
echo "tone(rgb)<BR>";
print_r(tone(hex2rgb($base_color)));
echo "<BR>";

// -----

// test shade (hex)
echo "shade(hex)<BR>";
print_r(shade($base_color));
echo "<BR>";

// test shade (rgb)
echo "shade(rgb)<BR>";
print_r(shade(hex2rgb($base_color)));
echo "<BR>";

// -----
?>

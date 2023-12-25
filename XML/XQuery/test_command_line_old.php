<?php

$line=htmlspecialchars($_GET["line"]);
$zone=htmlspecialchars($_GET["zone"]);
$collection=htmlspecialchars($_GET["collection"]);

/*
echo "<ul>";
echo "<li>" . $line . "</li>";
echo "<li>" . $zone . "</li>";
echo "<li>" . $collection . "</li>";
echo "</ul>";
*/

$unique=microtime(true) . mt_rand(1,5000000000);

$filename=$unique . ".xml";
$html=$unique . ".html";

//$command = "java -Xms128m -Xmx1024m -XX:+UseCompressedOops -cp saxon9he.jar net.sf.saxon.Query -t -q:test.xq -o:$filename line=$line zone=$zone collection=file:/home/matrygg/minorworksoflydgate.net/XML/$collection";
$test = "java -Xms128m -Xmx1024m -XX:+UseCompressedOops -cp saxon9he.jar net.sf.saxon.Query -t -q:test.xq -o:$filename line=$line zone=$zone collection=file:/home/matrygg/minorworksoflydgate.net/XML/$collection";
echo "<script>console.log( 'Debug Objects: " . $test . "' );</script>";
$text = exec ("java -Xms128m -Xmx1024m -XX:+UseCompressedOops -cp saxon9he.jar net.sf.saxon.Query -t -q:test.xq -o:$filename line=$line zone=$zone collection=file:/home/matrygg/minorworksoflydgate.net/XML/$collection");
echo $text;

$transform = exec ("java -jar saxon9he.jar -s:$filename -xsl:comparison.xsl -o:$html");
/*
$xml = new DOMDocument;
$xml->loadXML($text);

$xsl = new DOMDocument;
$xsl->load('comparison.xsl');

// Configure the transformer
$proc = new XSLTProcessor;
$proc->importStyleSheet($xsl); // attach the xsl rules

echo $proc->transformToXML($xml);
*/

$test = file_get_contents($html);
echo $test;

unlink($filename);
unlink($html);

?>

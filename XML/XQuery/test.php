<?php
header('Content-Type:text/html charset=utf-8');

$line="l.6";
$zone="EETS.QD.8";
$collection="Quis_Dabit";

echo $line . "<BR>";
echo $zone . "<BR>";
echo $collection . "<BR>";

$text = exec ("java -Xms128m -Xmx1024m -XX:+UseCompressedOops -cp saxon9he.jar net.sf.saxon.Query -t -q:test.xq line=$line zone=$zone collection=file:/home/matrygg/minorworksoflydgate.net/XML/$collection");


$xml = new DOMDocument;
$xml->loadXML($text);

$xsl = new DOMDocument;
$xsl->load('comparison.xsl');

// Configure the transformer
$proc = new XSLTProcessor;
$proc->importStyleSheet($xsl); // attach the xsl rules

echo $proc->transformToXML($xml);




?>
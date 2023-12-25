<?php

$file= $_GET['witness'] . '_' . $_GET['work'] . '.xml';

//echo $_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI'];

$test="java -Xms128m -Xmx1024m -XX:+UseCompressedOops -cp oxygen-patched-xerces-25.1.0.2.jar:saxon-he-12.3.jar net.sf.saxon.Transform -t -xi -s:../" . $_GET['work'] . "/" . $file . " -xsl:identity.xsl -o:" .$file;

$java= exec ("java -Xms128m -Xmx1024m -XX:+UseCompressedOops -cp oxygen-patched-xerces-25.1.0.2.jar:saxon-he-12.3.jar net.sf.saxon.Transform -t -xi -s:../" . $_GET['work'] . "/" . $file . " -xsl:identity.xsl -o:" .$file);
echo $java;

if (file_exists($file))
    {
    header('Content-Description: File Transfer');
    header('Content-Type: application/octet-stream');
    header('Content-Disposition: attachment; filename='.basename($file));
    header('Expires: 0');
    header('Cache-Control: must-revalidate');
    header('Pragma: public');
    header('Content-Length: ' . filesize($file));
    ob_clean();
    flush();
    readfile($file);
    unlink($file);
    exit;
    }

?>


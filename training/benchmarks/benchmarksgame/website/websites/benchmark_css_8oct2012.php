<?php
ob_start('ob_gzhandler');
header('Pragma: public');
header("Cache-Control: maxage=33659650,public");
header("Expires: Sat, 04 Jul 2015 13:07:21 GMT");
header('Content-type: text/css');
readfile('benchmark.css');
?>

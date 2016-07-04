<?php
//header('Content-type: application/json');

$cmd = 'python myScript.py ' . escapeshellarg(10);
$ret = shell_exec($cmd);

echo "\n";
echo "Return raw:\n";
print_r($ret);
echo "\n";



echo "\n";

?>


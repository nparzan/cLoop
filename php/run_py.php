<?php
//header('Content-type: application/json');

// Setup parameters
$servername = "mysqlsrv.cs.tau.ac.il";
$username = "noamp1";
$password = "noa7811";
$dbname = "noamp1";
$low = $_POST["LowID"];
$high = $_POST["HighID"];

// Create connection
$conn = new mysqli($servername, $username, $password,$dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
} 

// Construct query
$sql = "SELECT * FROM test where id >= $low AND id <= $high";
$result = $conn->query($sql);
if ($result->num_rows > 0) {
    // output data of each row
	$arr = array();
    while($row = $result->fetch_assoc()) {
		$arr[] = $row;
        //echo "ID: " . $row["id"]. " - Name: " . $row["name"]. "<br>";
    }
} else {
    echo "0 results";
}

//$j_arr = json_encode($arr);
$cmd = 'python myScript.py ' . escapeshellarg(json_encode($arr));
$ret = shell_exec($cmd);

echo "\n";
echo "Return raw:\n";
print_r($ret);
echo "\n";
// Decode the result
$resultData = json_decode($ret, true);

// This will contain: array('status' => 'Yes!')
echo "About to print return value12323\n";
var_dump($resultData);

//print_r($out);

echo "\n";

$conn->close();

?>


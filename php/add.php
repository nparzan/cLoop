<?php
//header('Content-type: application/json');

// Setup parameters
$servername = "mysqlsrv.cs.tau.ac.il";
$username = "noamp1";
$password = "noa7811";
$dbname = "noamp1";
$id = $_POST["id"];
$name = $_POST["name"];

// Create connection
$conn = new mysqli($servername, $username, $password,$dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
} 

// Construct query
$sql = "insert into test values($id, '$name')";
if ($conn->query($sql) === TRUE) {
    echo "New record created successfully";
} else {
    echo "Error: " . $sql . "<br>" . $conn->error;
}

//echo json_encode($arr);

$conn->close();

?>


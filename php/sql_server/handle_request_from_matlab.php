<?php
header('Content-type: application/json');
require_once("connect.php");
require_once("../session_add.php");

$ret = 0;
$ret_arr = array();
$ret_arr["ret"] = 0;

// Try to decode input
if ($_SERVER['REQUEST_METHOD'] == 'POST')
{
    $data = json_decode(file_get_contents("php://input"),true);
}

// If input can not be decoded, exit with error code
if ($data == NULL){
    $ret_arr["ret"] = -1;
    $ret_arr["error"] = "JSON recieved is empty";
}
    
if ($ret_arr["ret"] != 0){
    echo json_encode($ret_arr);
    exit($ret_arr["ret"]);
}

// If input properly decoded, connect to SQL server
$call_conn = connect();
$conn = $call_conn["conn"];

if ($call_conn["ret"] != 0){
    $ret_arr["ret"] = $call_conn["ret"];
    $ret_arr["error"] = $call_conn["error"];
    $conn->close();
    echo json_encode($ret_arr);
    exit($ret_arr["ret"]);
}

// Handle add session request
if ($data["action"] == "SESSION_ADD"){
    $response = session_add($data["data"],$conn);
    echo json_encode($response);
    exit($response["ret"]);
}

?>

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
    //echo json_encode($data["data"]);
    //exit(0);
    $response = session_add($data["data"],$conn);
    echo json_encode($response);
    exit($response["ret"]);
}

/*
// Get fields and values for query
$parsed_array = parse_arguments_from_matlab($session_data);

$fields = $parsed_array["fields"];
$values = $parsed_array["values"];

// Construct query
$sql = "INSERT INTO `cloop_session` ($fields) VALUES ($values)";

$err = "";
if ($conn->query($sql) === TRUE) {
    $last_id = $conn->insert_id;
    $ret_arr["ret"] = 0;
    $ret_arr["session_id"] = $last_id;
} else {
    $err = "Query: ". $sql . "\n Returned Error: " . $conn->error;
    $ret_arr["ret"] = -1;
    $ret_arr["error"] = $err;
}

if ($ret_arr["ret"] != 0){
    echo json_encode($ret_arr);
    $conn->close();
    exit($ret_arr["ret"]);
}

// Close the connection, print output
$conn->close();
echo json_encode($ret_arr);
exit($ret_arr["ret"]);
*/

/* Parse specific parameters
$subject_id = $data["subject_id"];
$experimenter_id = $data["experimenter_id"];
$task = $data["task"];
$objective_activity_band = $data["objective_activity_band"];
$objective_activity_value = $data["objective_activity_value"];
$electrode_placement = $data["electrode_placement"];
$comment = $data["comment"];

$sql = "INSERT INTO `cloop_session` (`subject_id`, `experimenter_id`, `task`, `objective_activity_band`, `objective_activity_value`, `electrode_placement`, `comment`) VALUES ($subject_id, $experimenter_id, '$task', '$objective_activity_band', $objective_activity_value, '$electrode_placement', '$comment')";*/

?>

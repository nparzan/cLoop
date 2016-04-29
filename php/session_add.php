<?php
//header('Content-type: application/json');
require_once("sql_server/connect.php");

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

$fields = "";
$values = "";

// Handle add session request
if ($data["action"] == "SESSION_ADD"){
    $session_data = $data["data"];
}

// Seperate into fields and values
foreach($session_data as $key=>$value){
    $delim = "";
    if (is_string($value)){
        $delim = "\"";
    }
    $fields .= '`'.$key.'`, ';
    $values .= $delim.$value.$delim.', ';
}

// Remove last comma
$fields = trim($fields, " \t,");
$values = trim($values, " \t,");

// Construct query
$sql = "INSERT INTO `cloop_session` ($fields) VALUES ($values)";

$err = "";
if ($conn->query($sql) === TRUE) {
    $last_id = $conn->insert_id;
    $ret_arr["ret"] = 0;
    $ret_arr["session_id"] = $last_id;
} else {
    $err = "Query: ". $sql . "\n Returned Error: " . $conn->error;
    $ret_arr["ret"] = 1;
    $ret_arr["error"] = $err;
}

if ($ret_arr["ret"] != 0){
    echo json_encode($ret_arr);
    exit($ret_arr["ret"]);
}

// Close the connection, print output
$conn->close();
echo json_encode($ret_arr);
exit($ret_arr["ret"]);

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

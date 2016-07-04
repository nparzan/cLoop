<?php
header('Content-type: application/json');
require_once("connect.php");
require_once("log_event.php");
require_once("sql_add_data_from_matlab.php");
require_once("get_data_from_sql.php");
require_once("../model_update.php");
require_once("../model_get.php");
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

$session_id = $data["data"]["session_id"];

// Add data to sql server
if ($data["action"] == "EEG_ACTIVITY_ADD" || $data["action"] == "SESSION_ADD" || $data["action"] == "STIMULATION_ADD" || $data["action"] == "REGRESSION_MODEL_ADD"){
    $response = sql_add_data_from_matlab($data["data"],$data["table"],$data["action"],$conn);
}

if ($data["action"] == "EEG_ACTIVITY_AND_STIMULATION_GET"){
    $response = get_eeg_activity_and_stimulation_from_sql($data,$conn);
}

if ($data["action"] == "REGRESSION_MODEL_GET"){
    $response = model_get($data,$conn);
}

if ($data["action"] == "REGRESSION_MODEL_UPDATE"){
    $response = model_update($data,$conn);
    $data["data"]["user"] = "SCRUBBED";
    $data["data"]["password"] = "SCRUBBED";
}

if ($response["ret"] == 0){
    $passfail = "PASS";
    if ($data["action"] == "SESSION_ADD"){
        $session_id = $response["session_id"];
    }
}
else{
    $passfail = "FAIL";
    if ($data["action"] == "SESSION_ADD"){
        $session_id = 1;
    }
}

$log_ret = log_event($session_id,$response,$data["action"],$data["data"],$passfail,$conn);
$response["log_ret"] = $log_ret["ret"];
if ($log_ret["ret"] != 0){
    $response["log_error"] = $log_ret["error"];    
}

echo json_encode($response);

// Close the connection
$conn->close();
exit($response["ret"]);

?>


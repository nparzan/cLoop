<?php
function log_event($session_id,$data,$event_type,$details,$passfail,$conn){

    // Init return value
    $ret_arr = array();
    $ret_arr["ret"] = 0;
    $sql = "";
    
    if (is_array($details)){
        $details = implode(", ",$details);
    }
    // Construct entry
    if ($data["ret"] != 0){
        $details = $data["error"]." $details";    
    }

    // Remove bad chars from log entry details
    $details = preg_replace('/[^a-zA-Z0-9_ %\,\[\]\.\(\)%&-]/s', '', $details);
    $sql = "INSERT INTO `cloop_log` (`session_id`, `type`,`details`,`status`) VALUES ($session_id, '$event_type', '$details','$passfail')";

    $err = "";
    // If query was successful
    if ($conn->query($sql) === TRUE) {
        $ret_arr["ret"] = 0;
    // Query unsuccessful, return error details
    } else {
        $err = "Query: ". $sql . "\n Returned Error: " . $conn->error;
        $ret_arr["ret"] = -1;
        $ret_arr["error"] = $err;
    }

    return $ret_arr;
}

?>

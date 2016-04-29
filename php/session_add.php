<?php
function session_add($data,$conn){
    require_once("sql_server/parse_arguments_from_matlab.php");

    // Init return value
    $ret_arr = array();
    $ret_arr["ret"] = 0;
    
    // Get fields and values for query
    $parsed_array = parse_arguments_from_matlab($data);
    
    $fields = $parsed_array["fields"];
    $values = $parsed_array["values"];

    // Construct query
    $sql = "INSERT INTO `cloop_session` ($fields) VALUES ($values)";

    $err = "";

    // If query was successful, get id of new session
    if ($conn->query($sql) === TRUE) {
        $last_id = $conn->insert_id;
        $ret_arr["ret"] = 0;
        $ret_arr["session_id"] = $last_id;
    // Query unsuccessful, return error details
    } else {
        $err = "Query: ". $sql . "\n Returned Error: " . $conn->error;
        $ret_arr["ret"] = -1;
        $ret_arr["error"] = $err;
    }

    return $ret_arr;
}

?>

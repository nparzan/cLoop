<?php
function sql_add_data_from_matlab($data,$table,$action,$conn){
    require_once("parse_arguments_from_matlab.php");

    // Init return value
    $ret_arr = array();
    $ret_arr["ret"] = 0;
    
    // Get fields and values for query
    $parsed_array = parse_arguments_from_matlab($data);
    
    $fields = $parsed_array["fields"];
    $values = $parsed_array["values"];
    $table = strtolower($table);
    // Construct query
    $sql = "INSERT INTO `$table` ($fields) VALUES ($values)";

    $err = "";

    // If query was successful, get id of new session
    if ($conn->query($sql) === TRUE) {
        $last_id = $conn->insert_id;
        // When creating a new session we return the new session_id
        if ($action == "SESSION_ADD"){
            $ret_arr["session_id"] = $last_id;
        }
        // Otherwise, we return the current session_id
        else{
            $ret_arr["session_id"] = $data["session_id"];   
            $ret_arr["entry_id"] = $last_id;
        }
        
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

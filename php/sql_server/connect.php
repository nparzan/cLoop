<?php


function connect(){
    //header('Content-type: application/json');
    $ret_arr = array();

    // Setup server parameters
    $servername = "mysqlsrv.cs.tau.ac.il";
    $username = "noamp1";
    $password = "noa7811";
    $dbname = "noamp1";

    // Create connection
    $conn = new mysqli($servername, $username, $password, $dbname);
    $ret_arr["conn"] = $conn;

    // Check connection
    if ($conn->connect_error) {
        $err = "Connection failed: " . $conn->connect_error;
        $ret_arr["ret"] = -1;
        $ret_arr["error"] = $err;
    }
    else {
        $ret_arr["ret"] = 0;
    }

    return $ret_arr;
}

?>


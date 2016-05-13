<?php


function connect(){
    require_once("connect_tokens.php");
    //header('Content-type: application/json');
    $ret_arr = array();

    // Setup server parameters
    $sql_server_tokens = get_sql_server_tokens();
    $servername = $sql_server_tokens["servername"];
    $username = $sql_server_tokens["username"];
    $password = $sql_server_tokens["password"];
    $dbname = $sql_server_tokens["dbname"];

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


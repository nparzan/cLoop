<?php
function model_update($data,$conn){
    include_once('Net/SSH2.php');

    // Init return value
    $ret_arr = array();
    $ret_arr["ret"] = 0;

    // Parse input variables
    $session_id = $data['data']['session_id'];
    $user = $data['data']['user'];
    $pass = $data['data']['password'];

    // FIXME: Currently only running model for amplitude
    if ($data['data']['update_amplitude'] == 1){
        $parameter_for_fitting = 1;
    }


    // Connect to python station
    $ssh = new Net_SSH2('fermat-10.cs.tau.ac.il');
    if (!$ssh->login($user, $pass)) {
        exit('Login Failed');
    }

    // Run model update
    $cmd = "python html/cLoop/regression/test.py $session_id $parameter_for_fitting";
    $result = $ssh->exec($cmd);
    $slashed_result = addslashes($result);

    // FIXME: Currently only updating model for amplitude
    $sql = "INSERT into cloop_regression_model (session_id, amplitude_model) VALUES ($session_id, \"$slashed_result\")";
    $err = "";
    if ($conn->query($sql) === TRUE){
        $last_id = $conn->insert_id;
        //return $last_id;
        $ret_arr["session_id"] = $session_id;   
        $ret_arr["entry_id"] = $last_id;
        $ret_arr["ret"] = 0;
    }
    else{
        $err = "Query: ". $sql . "\n Returned Error: " . $conn->error;
        $ret_arr["ret"] = -1;
        $ret_arr["error"] = $err;
    }

    return $ret_arr;    
}

?>
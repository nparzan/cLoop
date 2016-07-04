<?php
function get_eeg_activity_and_stimulation_from_sql($data,$conn){

    // Init return value
    $ret_arr = array();
    $ret_arr["ret"] = 0;
    $sess = $data["data"]["session_id"];
    $ret_arr["session_id"] = $sess;

    // Construct EEG Activity Query
    $sql = <<<EOT
    SELECT  cloop_eeg_activity.eeg_activity_id, cloop_eeg_activity.stimulation_id, cloop_eeg_activity.delta_activity,
            cloop_eeg_activity.theta_activity, cloop_eeg_activity.alpha_activity, 
            cloop_eeg_activity.beta_activity, cloop_eeg_activity.gamma_activity
            FROM cloop_eeg_activity
            WHERE cloop_eeg_activity.session_id=$sess;
EOT;

    // Run first query for EEG Activity
    $type = "EEG_ACTIVITY";
    $ret_query = single_query($conn,$sql,$sess,$type);

    // Quit if error
    if ($ret_query["ret"] != 0){
        $ret_arr["error"] = $ret_query["error"];
        return $ret_arr;
    }

    // Copy query data if everything ran smoothly
    $ret_arr["data"]["$type"] = $ret_query["data"]["$type"];

    // Construct Stimulation History Query
    $sql = <<<EOT
    SELECT  cloop_stimulation.stimulation_id, cloop_stimulation.eeg_activity_id, cloop_stimulation.stimulation_duration,
            cloop_stimulation.stimulation_amplitude, cloop_stimulation.stimulation_frequency
            FROM cloop_stimulation
            WHERE cloop_stimulation.session_id=$sess;
EOT;

    // Run second query for Stimulation History
    $type = "STIMULATION";    
    $ret_query = single_query($conn,$sql,$sess,$type);

    // Quit if error
    if ($ret_query["ret"] != 0){
        $ret_arr["error"] = $ret_query["error"];
        return $ret_arr;
    }

    // Copy query data if everything ran smoothly
    $ret_arr["data"]["$type"] = $ret_query["data"]["$type"];

    // Finished successfully
    return $ret_arr;
}

function single_query($conn,$sql,$sess,$type){
    $err = "";

    // If query was successful, retrieve data
    if ($q_res = $conn->query($sql)) {
        $rows = array();
        while($r = $q_res->fetch_assoc()) {
            $rows[] = $r;
        }
        $q_res->free();
        $ret_arr["data"]["$type"] = $rows;
        $ret_arr["ret"] = 0;
    // Query unsuccessful, return error details
    } else {
        $err = "Query: " . $sql . "\n Returned Error: " . $conn->error;
        $ret_arr["ret"] = -1;
        $ret_arr["error"] = $err;
    }

    return $ret_arr;
}
?>

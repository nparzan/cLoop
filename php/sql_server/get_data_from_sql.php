<?php
function get_eeg_activity_and_stimulation_from_sql($data,$conn){

    // Init return value
    $ret_arr = array();
    $ret_arr["ret"] = 0;
    $sess = $data["data"]["session_id"];
    $ret_arr["session_id"] = $sess;
    // Construct query
    $sql = <<<EOT
    SELECT cloop_stimulation.eeg_activity_id,cloop_stimulation.session_id,cloop_stimulation.stimulation_duration, cloop_eeg_activity.band_for_improvement, cloop_session.experimenter_id FROM cloop_stimulation INNER JOIN cloop_eeg_activity INNER JOIN cloop_session ON cloop_stimulation.eeg_activity_id=cloop_eeg_activity.eeg_activity_id WHERE cloop_stimulation.session_id=$sess and cloop_session.session_id=$sess;

EOT;

    $err = "";

    // If query was successful, retrieve data
    if ($q_res = $conn->query($sql)) {
        $rows = array();
        while($r = $q_res->fetch_assoc()) {
            $rows[] = $r;
        }
        $q_res->free();
        $ret_arr["data"] = $rows;
    // Query unsuccessful, return error details
    } else {
        $err = "Query: ". $sql . "\n Returned Error: " . $conn->error;
        $ret_arr["ret"] = -1;
        $ret_arr["error"] = $err;
    }

    return $ret_arr;
}

?>

<?php
function model_get($data,$conn){
    require_once("../sql_server/get_data_from_sql.php");
    // Init return value
    $ret_arr = array();
    $ret_arr["ret"] = 0;

    // Parse input variables
    $session_id = $data['data']['session_id'];

    // FIXME: Currently only running model for amplitude
    if ($data['data']['model_type'] == "AMPLITUDE_MODEL"){
            $sql = <<<EOT
            SELECT  cloop_regression_model.amplitude_model
            FROM cloop_regression_model
            WHERE cloop_regression_model.session_id=$session_id;
EOT;
    }
    return single_query($conn,$sql,$session_id,"REGRESSION_MODEL");
}

?>

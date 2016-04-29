<?php
function parse_arguments_from_matlab($data){
    $fields = "";
    $values = "";
    // Seperate into fields and values
    foreach($data as $key=>$value){
        $delim = "";
        if (is_string($value)){
            $delim = "\"";
        }
        $fields .= '`'.$key.'`, ';
        $values .= $delim.$value.$delim.', ';
    }

    // Remove last comma
    $fields = trim($fields, " \t,");
    $values = trim($values, " \t,");    
    $ret = array('fields' => $fields, 'values' => $values);
    return $ret;
}

?>
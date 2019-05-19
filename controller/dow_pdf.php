<?php

    header("Content-type: application/pdf");
    header("Content-Transfer-Encoding: Binary");
    header("Content-disposition: attachment; filename=\"emp_info.pdf\""); 

    $email = $_GET['email'];

    $conn = oci_connect('proiect', 'PROIECT') or die;

    $plsql_exec = 
    "begin 
        :emp_blob := get_emp_pdf_by_email('%s'); 
    end;";
    $plsql_exec = sprintf($plsql_exec, $email);
    var_dump($plsql_exec);

    $stmt = oci_parse($conn, $plsql_exec);
    
    $emp_blob = oci_new_descriptor($conn, OCI_D_LOB);
    oci_bind_by_name($stmt, ":emp_blob", $emp_blob, -1, OCI_B_BLOB);
    oci_execute($stmt);
    
    echo $emp_blob->load();

    oci_close($conn);
    

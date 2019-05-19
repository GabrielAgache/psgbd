<?php

    require 'C:\Users\g_aga\vendor\autoload.php';

    $username = $_POST['username'];
    $password = $_POST['password'];

    $conn = oci_connect('proiect', 'PROIECT') or die;

    $plsql_exec = 
    "begin 
        :full_name := get_emp_fullname_by_email('%s'); 
        :salary    := get_emp_salary_by_email('%s');
        :hire_date := get_emp_hiredate_by_email('%s');
    end;";

    $plsql_exec = sprintf($plsql_exec, $username, $username, $username);
    
    $stmt = oci_parse($conn, $plsql_exec);
    oci_bind_by_name($stmt, ":full_name", $full_name, 50);
    oci_bind_by_name($stmt, ":salary", $salary, 50);
    oci_bind_by_name($stmt, ":hire_date", $hire_date, 50);
    oci_execute($stmt);
    oci_close($conn);

    $loader = new Twig_Loader_Filesystem('../views');
    $twig = new Twig_Environment($loader);

    setcookie('cookie', $username);

    echo $twig->render('index.html', array(
        'full_name' => $full_name,
        'email' => $username,
        'salary' => $salary,
        'hire_date' => $hire_date
    ));




    
?>
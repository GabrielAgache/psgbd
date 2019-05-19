<?php

    require 'C:\Users\Gabriel\vendor\autoload.php';


    $full_name  = $_POST['full_name'];
    $password   = $_POST['password'];
    $birth_date = $_POST['birth_date'];
    $d_or_e     = $_POST['driver_or_emp'];
    $email      = "";

    if (isset($_POST['email'])) {
        $email = $_POST['email'];
    }

    $con = oci_connect('proiect', "PROIECT") or die;

    $plsql_exec = "";
    if ($d_or_e == "employee") {
        $plsql_exec =
            "begin
                insert_emp(:full_name, :password, :birth_date);
            end;";
    } else {
        $plsql_exec =
            "begin
                insert_driver(:full_name, '$email', :password, :birth_date);
            end;";
    }

    $stmt = oci_parse($con, $plsql_exec);
    oci_bind_by_name($stmt, ":full_name", $full_name, 50);
    oci_bind_by_name($stmt, ":password", $password, 50);
    oci_bind_by_name($stmt, ":birth_date",$birth_date, 50);

    oci_execute($stmt);
    oci_close($con);

    $loader = new Twig_Loader_Filesystem('../views');
    $twig = new Twig_Environment($loader);

    $email_2_show = "";
    if (isset($_POST['email'])) {
        $email_2_show = strtolower( str_replace(' ', '.', $full_name).'@transporter.com' );
    } else {
        $email_2_show = $email;
    }

    if ($d_or_e == "employee") {
        echo $twig->render('index.html', array(
            'full_name' => $full_name,
            'email' => $email_2_show,
            'salary' => "Undecided yet",
            'hire_date' => date('d-m-Y')
        ));
    } else {
        echo $twig->render('index.html', array(
            'full_name' => $full_name,
            'email' => $email_2_show,
            'salary' => "Undecided yet",
            'hire_date' => date('d-m-Y')
        ));
    }


    



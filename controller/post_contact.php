<?php

require 'C:\Users\g_aga\vendor\autoload.php';

$loader = new Twig_Loader_Filesystem('../views');
$twig = new Twig_Environment($loader);

$email = $_COOKIE['cookie'];
$text = $_POST['text'];


$conn = oci_connect('proiect', 'PROIECT') or die;

$sql = "INSERT INTO CONTACT_FORMS VALUES ('{$email}', '{$text}')";

$stmt = oci_parse($conn, $sql);
oci_execute($stmt);

oci_close($conn);

echo $twig->render('post_contact.html', array(
'email' => $email,
));
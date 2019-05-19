<?php

require 'C:\Users\g_aga\vendor\autoload.php';

$email = $_COOKIE['cookie'];

$loader = new Twig_Loader_Filesystem('../views');
$twig = new Twig_Environment($loader);



echo $twig->render('newroute.html', array(
    'full_name' => 'page1',
    'email' => $email,
    'salary' => 123,
    'hire_date' => 'page1'
));    
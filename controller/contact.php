<?php

require 'C:\Users\g_aga\vendor\autoload.php';

$loader = new Twig_Loader_Filesystem('../views');
$twig = new Twig_Environment($loader);

$email = $_COOKIE['cookie'];



echo $twig->render('contact.html', array(
    'email' => $email,
));
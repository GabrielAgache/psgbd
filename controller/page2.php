<?php

require 'C:\Users\Gabriel\vendor\autoload.php';

$email = $_GET['email'];

$loader = new Twig_Loader_Filesystem('../views');
$twig = new Twig_Environment($loader);

echo $twig->render('index.html', array(
    'full_name' => 'page2',
    'email' => $email,
    'salary' => 123,
    'hire_date' => 'page2'
));    
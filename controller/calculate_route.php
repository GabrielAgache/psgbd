<?php

require 'C:\Users\Gabriel\vendor\autoload.php';
require '../model/AtomicRoute.php';


$startLocation = $_GET['start'];
$endLocation = $_GET['end'];
$max_load = $_GET['max_load'];
$email = $_COOKIE['cookie'];

$stops_array = array();

if (isset($_GET['stops'])) {
    $stops_array = $_GET['stops'];
}

$stops_transform_get = "";
foreach ($stops_array as $stop) {
    $stops_transform_get = $stops_transform_get."&stops[]={$stop}";
}

array_push($stops_array, $endLocation);
array_unshift($stops_array, $startLocation);

$conn = oci_connect('proiect', 'PROIECT', "", 'AL32UTF8') or die;

$stmt = oci_parse($conn,"begin ROUTE_CONTROLLER.CALCULATE_ITINERARY(:cities, :max_load); end;");

oci_bind_array_by_name($stmt, ":cities",
    $stops_array, 100,
    20, SQLT_CHR);
ocibindbyname($stmt, ":max_load", $max_load, 10);

oci_execute($stmt);

$n = count($stops_array);

$total_dist = $stops_array[$n - 1];
$price = $stops_array[$n - 2];
$car = $stops_array[$n - 3];

$atomic_routes = array();
$n = $n - 3;

$half = intdiv($n, 2);

for ($i=0; $i < $half; $i++)
{
    $start = $stops_array[$i];
    $end = $stops_array[$i + 1];
    array_push($atomic_routes, new AtomicRoute($start, $end));
}

for ($i=$half+1; $i<$n ; $i++)
{
    $dist = $stops_array[$i];
    $atomic_routes[$i - $half - 1]->setDistance($dist);
}

if (!isset($_GET['accept'])) {

    $loader = new Twig_Loader_Filesystem('../views');
    $twig = new Twig_Environment($loader);

    echo $twig->render('route_result.html', array(
        'max_load' => $max_load,
        'start' => $startLocation,
        'end' => $endLocation,
        'stops' => $stops_transform_get,
        'email' => $email,
        'car' => $car,
        'price' => $price,
        'distance' => $total_dist,
        'routes' => $atomic_routes
    ));

} else {
    $sqlres = oci_parse($conn,"begin :route_blob := ROUTE_CONTROLLER.insert_route(:stops_array, :maxi_load, :veh_name); end;");
    oci_bind_array_by_name($sqlres, ":stops_array",
        $stops_array, 100,
        30, SQLT_CHR);
    ocibindbyname($sqlres, ":maxi_load", $max_load, 10);
    ocibindbyname($sqlres, ":veh_name", $stops_array[count($stops_array) - 3], 20);

    $route_blob = oci_new_descriptor($conn, OCI_D_LOB);
    oci_bind_by_name($sqlres, ":route_blob", $route_blob, -1, OCI_B_BLOB);

    oci_execute($sqlres);

    header("Content-type: application/text");
    header("Content-Transfer-Encoding: Binary");
    header("Content-disposition: attachment; filename=\"emp_info.pdf\"");

    echo $route_blob->load();
}
oci_close($conn);



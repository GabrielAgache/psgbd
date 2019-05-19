<?php

$orase = array(
 'Alba Iulia', 'Arad',
 'Piteşti', 'Bacău',
 'Oradea', 'Bistriţa',
 'Botoşani', 'Braşov',
 'Brăila', 'Buzău',
 'Reşiţa', 'Călăraşi',
 'Cluj Napoca', 'Constanţa',
 'Sfântu Gheorghe', 'Târgovişte',
 'Craiova', 'Galaţi',
 'Giurgiu', 'Târgu Jiu',
 'Miercurea Ciuc', 'Deva',
 'Slobozia', 'Iaşi',
 'Bucuresti', 'Baia Mare',
 'Drobeta Turnu Severin', 'Târgu Mureş',
 'Piatra Neamţ', 'Slatina',
 'Ploieşti', 'Satu Mare',
 'Zalău', 'Sibiu',
 'Suceava', 'Timişoara', 'Tulcea',
 'Vaslui', 'Râmnicu Vâlcea',
 'Focşani'
);


set_time_limit(1000);

$conn = oci_connect('proiect', 'PROIECT', "", 'AL32UTF8') or die;

$sql = "INSERT INTO DISTANCE VALUES (:ID , :CITY1, :CITY2, :DIST)";

$stmt = oci_parse($conn, $sql);


function insert_db($stmt, $id, $city1, $city2, $distance) {
    oci_bind_by_name($stmt, ":ID", $id, 50);
    oci_bind_by_name($stmt, ":CITY1", $city1, 50);
    oci_bind_by_name($stmt, ":CITY2", $city2, 50);
    oci_bind_by_name($stmt, ":DIST", $distance, 50);

    oci_execute($stmt);
}




$size = count($orase);

for ($i = 0; $i < $size-1 ; $i++)
{
    $base_url = 'https://www.distance24.org/route.json?stops='.$orase[$i].'|';
    for ($j = $i+1; $j < $size ; $j++) {
        $api_url = $base_url . $orase[$j];
        $api_url = str_replace(' ', '%20', $api_url);
        $api_content = file_get_contents($api_url);
        $api_json = json_decode($api_content);
        $distance = $api_json->distance;
        $id = ($size * $i) + $j;
        insert_db($stmt, $id, $orase[$i], $orase[$j], $distance);

    }
}

oci_commit($conn);

oci_close($conn);

echo 'finish';
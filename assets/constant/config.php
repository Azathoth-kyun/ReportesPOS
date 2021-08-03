<?php
//Conexión a la BD
$host = "localhost"; /* Host name */
$user = "root"; /* User */
$password = "12345678"; /* Password */
$dbname = "sis_ventas"; /* Database name */

$con = mysqli_connect($host, $user, $password,$dbname);
// Check connection
if (!$con) {
 die("Connection failed: " . mysqli_connect_error());
}

if (!function_exists('ejecutarConsulta')) {
	Function ejecutarConsulta($sql){ 
global $con;
$query=$con->query($sql);
return $query;

	}

	function ejecutarConsultaSimpleFila($sql){
global $con;
$query=$con->query($sql);
$row=$query->fetch_assoc();
return $row;
	}
function ejecutarConsulta_retornarID($sql){
global $con;
$query=$con->query($sql);
return $con->insert_id;
}

function limpiarCadena($str){
global $con;
$str=mysqli_real_escape_string($con,trim($str));
return htmlspecialchars($str);
}

}
?>
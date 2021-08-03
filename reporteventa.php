<?php 
    //Session para mantener conectado
	session_start();
	
	include "assets/constant/config.php";

	// Checa el user si esta logeado o no
	if(!isset($_SESSION['uname'])){
    	header('Location: index.php');
	}

	// Cerrar sesión
	if(isset($_POST['but_logout'])){
    	session_destroy();
    	header('Location: index.php');
  }
  
  if(isset($_POST['clean'])){
    header('Location: reporteventa.php');
  }

  if(isset($_POST['btn_query'])){
    $fecha_inicio = mysqli_real_escape_string($con,(strip_tags($_POST["inicio_filtro"],ENT_QUOTES)));//Escanpando caracteres 
    $fecha_fin = mysqli_real_escape_string($con,(strip_tags($_POST["fin_filtro"],ENT_QUOTES)));//Escanpando caracteres 
    $nro_comprobante = mysqli_real_escape_string($con,(strip_tags($_POST["nro_comprobante_xd"],ENT_QUOTES)));//Escanpando caracteres 
    if($nro_comprobante == "" || $nro_comprobante == null){
      $query = "SELECT CV.numero_comprobante as nro_comprobante, CV.fecha_hora_venta as fecha, CLI.nombre_razon as cliente, CONCAT(USHER.nombre,' ',USHER.apellido) as usuario, FORMAT(CV.totalpagado,2) as total FROM comprobante_venta CV INNER JOIN cliente CLI ON CV.idcliente = CLI.idCliente INNER JOIN usuario USHER ON CV.idUsuario_caja = USHER.idusuario WHERE STR_TO_DATE(CONCAT(substr(CV.fecha_hora_venta,1,4),',',substr(CV.fecha_hora_venta,6,2),',',substr(CV.fecha_hora_venta,9,2)),'%Y,%m,%d') BETWEEN '$fecha_inicio' AND '$fecha_fin';";
      $result_query = ejecutarConsulta($query);
      //Consulta de los ingresos
      $query_suma = "SELECT FORMAT(SUM(CV.totalpagado),2) as total FROM comprobante_venta CV INNER JOIN cliente CLI ON CV.idcliente = CLI.idCliente INNER JOIN usuario USHER ON CV.idUsuario_caja = USHER.idusuario WHERE STR_TO_DATE(CONCAT(substr(CV.fecha_hora_venta,1,4),',',substr(CV.fecha_hora_venta,6,2),',',substr(CV.fecha_hora_venta,9,2)),'%Y,%m,%d') BETWEEN '$fecha_inicio' AND '$fecha_fin'";
      $query_contado = "SELECT FORMAT(SUM(CV.totalpagado),2) as contado FROM comprobante_venta CV INNER JOIN cliente CLI ON CV.idcliente = CLI.idCliente INNER JOIN usuario USHER ON CV.idUsuario_caja = USHER.idusuario WHERE CV.idtipomoneda=1 AND STR_TO_DATE(CONCAT(substr(CV.fecha_hora_venta,1,4),',',substr(CV.fecha_hora_venta,6,2),',',substr(CV.fecha_hora_venta,9,2)),'%Y,%m,%d') BETWEEN '$fecha_inicio' AND '$fecha_fin'";
      $query_credito = "SELECT FORMAT(SUM(CV.totalpagado),2) as credito FROM comprobante_venta CV INNER JOIN cliente CLI ON CV.idcliente = CLI.idCliente INNER JOIN usuario USHER ON CV.idUsuario_caja = USHER.idusuario WHERE (CV.idtipomoneda=5 OR CV.idtipomoneda=4) AND STR_TO_DATE(CONCAT(substr(CV.fecha_hora_venta,1,4),',',substr(CV.fecha_hora_venta,6,2),',',substr(CV.fecha_hora_venta,9,2)),'%Y,%m,%d') BETWEEN '$fecha_inicio' AND '$fecha_fin'";
      //Caja A
      $query_suma_A = $query_suma . " AND CV.numero_comprobante LIKE 'A%'";
      $query_contado_A = $query_contado . " AND CV.numero_comprobante LIKE 'A%'";
      $query_credito_A = $query_credito . " AND CV.numero_comprobante LIKE 'A%'";
      $result_query_suma_A = ejecutarConsulta($query_suma_A);
      $result_query_credito_A = ejecutarConsulta($query_credito_A);
      $result_query_contado_A = ejecutarConsulta($query_contado_A);
      $row_suma_A = mysqli_fetch_assoc($result_query_suma_A);
      $row_credito_A = mysqli_fetch_assoc($result_query_credito_A);
      $row_contado_A = mysqli_fetch_assoc($result_query_contado_A);
      $totalisimo_A = $row_suma_A['total'];
      $contadisimo_A = $row_contado_A['contado'];
      $creditisimo_A = $row_credito_A['credito'];
      //Caja B
      $query_suma_B = $query_suma . " AND CV.numero_comprobante LIKE 'B%'";
      $query_contado_B = $query_contado . " AND CV.numero_comprobante LIKE 'B%'";
      $query_credito_B = $query_credito . " AND CV.numero_comprobante LIKE 'B%'";
      $result_query_suma_B = ejecutarConsulta($query_suma_B);
      $result_query_credito_B = ejecutarConsulta($query_credito_B);
      $result_query_contado_B = ejecutarConsulta($query_contado_B);
      $row_suma_B = mysqli_fetch_assoc($result_query_suma_B);
      $row_credito_B = mysqli_fetch_assoc($result_query_credito_B);
      $row_contado_B = mysqli_fetch_assoc($result_query_contado_B);
      $totalisimo_B = $row_suma_B['total'];
      $contadisimo_B = $row_contado_B['contado'];
      $creditisimo_B = $row_credito_B['credito'];
      //Caja C
      $query_suma_C = $query_suma . " AND CV.numero_comprobante LIKE 'C%'";
      $query_contado_C = $query_contado . " AND CV.numero_comprobante LIKE 'C%'";
      $query_credito_C = $query_credito . " AND CV.numero_comprobante LIKE 'C%'";
      $result_query_suma_C = ejecutarConsulta($query_suma_C);
      $result_query_credito_C = ejecutarConsulta($query_credito_C);
      $result_query_contado_C = ejecutarConsulta($query_contado_C);
      $row_suma_C = mysqli_fetch_assoc($result_query_suma_C);
      $row_credito_C = mysqli_fetch_assoc($result_query_credito_C);
      $row_contado_C = mysqli_fetch_assoc($result_query_contado_C);
      $totalisimo_C = $row_suma_C['total'];
      $contadisimo_C = $row_contado_C['contado'];
      $creditisimo_C = $row_credito_C['credito'];
      //Caja D
      $query_suma_D = $query_suma . " AND CV.numero_comprobante LIKE 'D%'";
      $query_contado_D = $query_contado . " AND CV.numero_comprobante LIKE 'D%'";
      $query_credito_D =$query_credito . " AND CV.numero_comprobante LIKE 'D%'";
      $result_query_suma_D = ejecutarConsulta($query_suma_D);
      $result_query_credito_D = ejecutarConsulta($query_credito_D);
      $result_query_contado_D = ejecutarConsulta($query_contado_D);
      $row_suma_D = mysqli_fetch_assoc($result_query_suma_D);
      $row_credito_D = mysqli_fetch_assoc($result_query_credito_D);
      $row_contado_D = mysqli_fetch_assoc($result_query_contado_D);
      $totalisimo_D = $row_suma_D['total'];
      $contadisimo_D = $row_contado_D['contado'];
      $creditisimo_D = $row_credito_D['credito'];
      //Ejecuccion de consultas de ingresos
      $result_query_suma = ejecutarConsulta($query_suma);
      $result_query_credito = ejecutarConsulta($query_credito);
      $result_query_contado = ejecutarConsulta($query_contado);
      $row_suma = mysqli_fetch_assoc($result_query_suma);
      $row_credito = mysqli_fetch_assoc($result_query_credito);
      $row_contado = mysqli_fetch_assoc($result_query_contado);
      $totalisimo = $row_suma['total'];
      $contadisimo = $row_contado['contado'];
      $creditisimo = $row_credito['credito'];
    }else{
      $query = "SELECT CV.numero_comprobante as nro_comprobante, CV.fecha_hora_venta as fecha, CLI.nombre_razon as cliente, CONCAT(USHER.nombre,' ',USHER.apellido) as usuario, FORMAT(CV.totalpagado,2) as total FROM comprobante_venta CV INNER JOIN cliente CLI ON CV.idcliente = CLI.idCliente INNER JOIN usuario USHER ON CV.idUsuario_caja = USHER.idusuario WHERE CV.numero_comprobante LIKE '%$nro_comprobante%' AND STR_TO_DATE(CONCAT(substr(CV.fecha_hora_venta,1,4),',',substr(CV.fecha_hora_venta,6,2),',',substr(CV.fecha_hora_venta,9,2)),'%Y,%m,%d') BETWEEN '$fecha_inicio' AND '$fecha_fin';";
      $result_query = ejecutarConsulta($query);
      //Consulta de los ingresos
      $query_suma = "SELECT FORMAT(SUM(CV.totalpagado),2) as total FROM comprobante_venta CV INNER JOIN cliente CLI ON CV.idcliente = CLI.idCliente INNER JOIN usuario USHER ON CV.idUsuario_caja = USHER.idusuario WHERE CV.numero_comprobante LIKE '%$nro_comprobante%' AND STR_TO_DATE(CONCAT(substr(CV.fecha_hora_venta,1,4),',',substr(CV.fecha_hora_venta,6,2),',',substr(CV.fecha_hora_venta,9,2)),'%Y,%m,%d') BETWEEN '$fecha_inicio' AND '$fecha_fin'";
      $query_contado = "SELECT FORMAT(SUM(CV.totalpagado),2) as contado FROM comprobante_venta CV INNER JOIN cliente CLI ON CV.idcliente = CLI.idCliente INNER JOIN usuario USHER ON CV.idUsuario_caja = USHER.idusuario WHERE CV.idtipomoneda=1 AND CV.numero_comprobante LIKE '%$nro_comprobante%' AND STR_TO_DATE(CONCAT(substr(CV.fecha_hora_venta,1,4),',',substr(CV.fecha_hora_venta,6,2),',',substr(CV.fecha_hora_venta,9,2)),'%Y,%m,%d') BETWEEN '$fecha_inicio' AND '$fecha_fin'";
      $query_credito = "SELECT FORMAT(SUM(CV.totalpagado),2) as credito FROM comprobante_venta CV INNER JOIN cliente CLI ON CV.idcliente = CLI.idCliente INNER JOIN usuario USHER ON CV.idUsuario_caja = USHER.idusuario WHERE (CV.idtipomoneda=5 OR CV.idtipomoneda=4) AND CV.numero_comprobante LIKE '%$nro_comprobante%' AND STR_TO_DATE(CONCAT(substr(CV.fecha_hora_venta,1,4),',',substr(CV.fecha_hora_venta,6,2),',',substr(CV.fecha_hora_venta,9,2)),'%Y,%m,%d') BETWEEN '$fecha_inicio' AND '$fecha_fin'";
      //Caja A
      $query_suma_A = $query_suma . " AND CV.numero_comprobante LIKE 'A%'";
      $query_contado_A = $query_contado . " AND CV.numero_comprobante LIKE 'A%'";
      $query_credito_A = $query_credito . " AND CV.numero_comprobante LIKE 'A%'";
      $result_query_suma_A = ejecutarConsulta($query_suma_A);
      $result_query_credito_A = ejecutarConsulta($query_credito_A);
      $result_query_contado_A = ejecutarConsulta($query_contado_A);
      $row_suma_A = mysqli_fetch_assoc($result_query_suma_A);
      $row_credito_A = mysqli_fetch_assoc($result_query_credito_A);
      $row_contado_A = mysqli_fetch_assoc($result_query_contado_A);
      $totalisimo_A = $row_suma_A['total'];
      $contadisimo_A = $row_contado_A['contado'];
      $creditisimo_A = $row_credito_A['credito'];
      //Caja B
      $query_suma_B = $query_suma . " AND CV.numero_comprobante LIKE 'B%'";
      $query_contado_B = $query_contado . " AND CV.numero_comprobante LIKE 'B%'";
      $query_credito_B = $query_credito . " AND CV.numero_comprobante LIKE 'B%'";
      $result_query_suma_B = ejecutarConsulta($query_suma_B);
      $result_query_credito_B = ejecutarConsulta($query_credito_B);
      $result_query_contado_B = ejecutarConsulta($query_contado_B);
      $row_suma_B = mysqli_fetch_assoc($result_query_suma_B);
      $row_credito_B = mysqli_fetch_assoc($result_query_credito_B);
      $row_contado_B = mysqli_fetch_assoc($result_query_contado_B);
      $totalisimo_B = $row_suma_B['total'];
      $contadisimo_B = $row_contado_B['contado'];
      $creditisimo_B = $row_credito_B['credito'];
      //Caja C
      $query_suma_C = $query_suma . " AND CV.numero_comprobante LIKE 'C%'";
      $query_contado_C = $query_contado . " AND CV.numero_comprobante LIKE 'C%'";
      $query_credito_C = $query_credito . " AND CV.numero_comprobante LIKE 'C%'";
      $result_query_suma_C = ejecutarConsulta($query_suma_C);
      $result_query_credito_C = ejecutarConsulta($query_credito_C);
      $result_query_contado_C = ejecutarConsulta($query_contado_C);
      $row_suma_C = mysqli_fetch_assoc($result_query_suma_C);
      $row_credito_C = mysqli_fetch_assoc($result_query_credito_C);
      $row_contado_C = mysqli_fetch_assoc($result_query_contado_C);
      $totalisimo_C = $row_suma_C['total'];
      $contadisimo_C = $row_contado_C['contado'];
      $creditisimo_C = $row_credito_C['credito'];
      //Caja D
      $query_suma_D = $query_suma . " AND CV.numero_comprobante LIKE 'D%'";
      $query_contado_D = $query_contado . " AND CV.numero_comprobante LIKE 'D%'";
      $query_credito_D =$query_credito . " AND CV.numero_comprobante LIKE 'D%'";
      $result_query_suma_D = ejecutarConsulta($query_suma_D);
      $result_query_credito_D = ejecutarConsulta($query_credito_D);
      $result_query_contado_D = ejecutarConsulta($query_contado_D);
      $row_suma_D = mysqli_fetch_assoc($result_query_suma_D);
      $row_credito_D = mysqli_fetch_assoc($result_query_credito_D);
      $row_contado_D = mysqli_fetch_assoc($result_query_contado_D);
      $totalisimo_D = $row_suma_D['total'];
      $contadisimo_D = $row_contado_D['contado'];
      $creditisimo_D = $row_credito_D['credito'];
      //Ejecuccion de consultas de ingresos
      $result_query_suma = ejecutarConsulta($query_suma);
      $result_query_credito = ejecutarConsulta($query_credito);
      $result_query_contado = ejecutarConsulta($query_contado);
      $row_suma = mysqli_fetch_assoc($result_query_suma);
      $row_credito = mysqli_fetch_assoc($result_query_credito);
      $row_contado = mysqli_fetch_assoc($result_query_contado);
      $totalisimo = $row_suma['total'];
      $contadisimo = $row_contado['contado'];
      $creditisimo = $row_credito['credito'];
    }
  }
  else{
    $query = "SELECT CV.numero_comprobante as nro_comprobante, CV.fecha_hora_venta as fecha, CLI.nombre_razon as cliente, CONCAT(USHER.nombre,' ',USHER.apellido) as usuario, FORMAT(CV.totalpagado,2) as total FROM comprobante_venta CV INNER JOIN cliente CLI ON CV.idcliente = CLI.idCliente INNER JOIN usuario USHER ON CV.idUsuario_caja = USHER.idusuario;";
    $result_query = ejecutarConsulta($query);
    //Consulta de los ingresos
    $query_suma = "SELECT FORMAT(SUM(CV.totalpagado),2) as total FROM comprobante_venta CV INNER JOIN cliente CLI ON CV.idcliente = CLI.idCliente INNER JOIN usuario USHER ON CV.idUsuario_caja = USHER.idusuario";
    $query_contado = "SELECT FORMAT(SUM(CV.totalpagado),2) as contado FROM comprobante_venta CV INNER JOIN cliente CLI ON CV.idcliente = CLI.idCliente INNER JOIN usuario USHER ON CV.idUsuario_caja = USHER.idusuario WHERE CV.idtipomoneda=1";
    $query_credito = "SELECT FORMAT(SUM(CV.totalpagado),2) as credito FROM comprobante_venta CV INNER JOIN cliente CLI ON CV.idcliente = CLI.idCliente INNER JOIN usuario USHER ON CV.idUsuario_caja = USHER.idusuario WHERE (CV.idtipomoneda=5 OR CV.idtipomoneda=4)";
    //Caja A
    $query_suma_A = $query_suma . " AND CV.numero_comprobante LIKE 'A%'";
    $query_contado_A = $query_contado . " AND CV.numero_comprobante LIKE 'A%'";
    $query_credito_A = $query_credito . " AND CV.numero_comprobante LIKE 'A%'";
    $result_query_suma_A = ejecutarConsulta($query_suma_A);
    $result_query_credito_A = ejecutarConsulta($query_credito_A);
    $result_query_contado_A = ejecutarConsulta($query_contado_A);
    $row_suma_A = mysqli_fetch_assoc($result_query_suma_A);
    $row_credito_A = mysqli_fetch_assoc($result_query_credito_A);
    $row_contado_A = mysqli_fetch_assoc($result_query_contado_A);
    $totalisimo_A = $row_suma_A['total'];
    $contadisimo_A = $row_contado_A['contado'];
    $creditisimo_A = $row_credito_A['credito'];
    //Caja B
    $query_suma_B = $query_suma . " AND CV.numero_comprobante LIKE 'B%'";
    $query_contado_B = $query_contado . " AND CV.numero_comprobante LIKE 'B%'";
    $query_credito_B = $query_credito . " AND CV.numero_comprobante LIKE 'B%'";
    $result_query_suma_B = ejecutarConsulta($query_suma_B);
    $result_query_credito_B = ejecutarConsulta($query_credito_B);
    $result_query_contado_B = ejecutarConsulta($query_contado_B);
    $row_suma_B = mysqli_fetch_assoc($result_query_suma_B);
    $row_credito_B = mysqli_fetch_assoc($result_query_credito_B);
    $row_contado_B = mysqli_fetch_assoc($result_query_contado_B);
    $totalisimo_B = $row_suma_B['total'];
    $contadisimo_B = $row_contado_B['contado'];
    $creditisimo_B = $row_credito_B['credito'];
    //Caja C
    $query_suma_C = $query_suma . " AND CV.numero_comprobante LIKE 'C%'";
    $query_contado_C = $query_contado . " AND CV.numero_comprobante LIKE 'C%'";
    $query_credito_C = $query_credito . " AND CV.numero_comprobante LIKE 'C%'";
    $result_query_suma_C = ejecutarConsulta($query_suma_C);
    $result_query_credito_C = ejecutarConsulta($query_credito_C);
    $result_query_contado_C = ejecutarConsulta($query_contado_C);
    $row_suma_C = mysqli_fetch_assoc($result_query_suma_C);
    $row_credito_C = mysqli_fetch_assoc($result_query_credito_C);
    $row_contado_C = mysqli_fetch_assoc($result_query_contado_C);
    $totalisimo_C = $row_suma_C['total'];
    $contadisimo_C = $row_contado_C['contado'];
    $creditisimo_C = $row_credito_C['credito'];
    //Caja D
    $query_suma_D = $query_suma . " AND CV.numero_comprobante LIKE 'D%'";
    $query_contado_D = $query_contado . " AND CV.numero_comprobante LIKE 'D%'";
    $query_credito_D =$query_credito . " AND CV.numero_comprobante LIKE 'D%'";
    $result_query_suma_D = ejecutarConsulta($query_suma_D);
    $result_query_credito_D = ejecutarConsulta($query_credito_D);
    $result_query_contado_D = ejecutarConsulta($query_contado_D);
    $row_suma_D = mysqli_fetch_assoc($result_query_suma_D);
    $row_credito_D = mysqli_fetch_assoc($result_query_credito_D);
    $row_contado_D = mysqli_fetch_assoc($result_query_contado_D);
    $totalisimo_D = $row_suma_D['total'];
    $contadisimo_D = $row_contado_D['contado'];
    $creditisimo_D = $row_credito_D['credito'];
    //Ejecuccion de consultas de ingresos
    $result_query_suma = ejecutarConsulta($query_suma);
    $result_query_credito = ejecutarConsulta($query_credito);
    $result_query_contado = ejecutarConsulta($query_contado);
    $row_suma = mysqli_fetch_assoc($result_query_suma);
    $row_credito = mysqli_fetch_assoc($result_query_credito);
    $row_contado = mysqli_fetch_assoc($result_query_contado);
    $totalisimo = $row_suma['total'];
    $contadisimo = $row_contado['contado'];
    $creditisimo = $row_credito['credito'];
  }
?>
<!doctype html>
<html lang="en">
  <head>
  	<title>Ventas - Reportes Libertad</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

    <link href="https://fonts.googleapis.com/css?family=Poppins:300,400,500,600,700,800,900" rel="stylesheet">
    <link rel="shortcut icon" type="image/png" href="assets/images/icon_nav.png"/>
		<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css">
		<link rel="stylesheet" href="assets/css/style.css">

    <!-- Fontfaces CSS-->
    <link href="assets/css/font-face.css" rel="stylesheet" media="all">
    <link href="assets/vendor/font-awesome-4.7/css/font-awesome.min.css" rel="stylesheet" media="all">
    <link href="assets/vendor/font-awesome-5/css/fontawesome-all.min.css" rel="stylesheet" media="all">
    <link href="assets/vendor/mdi-font/css/material-design-iconic-font.min.css" rel="stylesheet" media="all">

    <!-- Bootstrap CSS-->
    <link href="assets/vendor/bootstrap-4.1/bootstrap.min.css" rel="stylesheet" media="all">

    <!-- Vendor CSS-->
    <link href="assets/vendor/animsition/animsition.min.css" rel="stylesheet" media="all">
    <link href="assets/vendor/bootstrap-progressbar/bootstrap-progressbar-3.3.4.min.css" rel="stylesheet" media="all">
    <link href="assets/vendor/wow/animate.css" rel="stylesheet" media="all">
    <link href="assets/vendor/css-hamburgers/hamburgers.min.css" rel="stylesheet" media="all">
    <link href="assets/vendor/slick/slick.css" rel="stylesheet" media="all">
    <link href="assets/vendor/select2/select2.min.css" rel="stylesheet" media="all">
    <link href="assets/vendor/perfect-scrollbar/perfect-scrollbar.css" rel="stylesheet" media="all">
    <link href="assets/vendor/vector-map/jqvmap.min.css" rel="stylesheet" media="all">

    <!-- DataTables CSS -->
    <link href="assets/css/dataTables.bootstrap4.min.css" rel="stylesheet" media="all">
    <link href="assets/css/responsive.bootstrap4.min.css" rel="stylesheet" media="all">

    <!-- Main CSS-->
    <link href="assets/css/theme.css" rel="stylesheet" media="all">
  </head>
  <body>
		<div class="wrapper d-flex align-items-stretch">
			<nav id="sidebar" class="active">
				<div class="custom-menu">
					<button type="button" id="sidebarCollapse" class="btn btn-primary">
	          <i class="fa fa-bars"></i>
	          <span class="sr-only">Menu</span>
	        </button>
        </div>
				<div class="p-4">
		  		<h1><a href="main.php" class="logo">Menu </a></h1>
	        <ul class="list-unstyled components mb-5">
	          <li>
	            <a href="main.php"><span class="fa fa-home mr-3"></span> Inicio</a>
	          </li>
	          <li class="active">
	              <a href="reporteventa.php"><span class="fa fa-usd mr-3"></span> Reportes de Ventas</a>
	          </li>
	          <li>
              <a href="reportecompra.php"><span class="fa fa-calculator mr-3"></span> Reporte de Compras</a>
	          </li>
	          <li>
              <a href="stock.php"><span class="fa fa-archive mr-3"></span> Stock</a>
	          </li>
	          <li>
              <a href="statxday.php"><span class="fa fa-calendar mr-3"></span> Datos por Día</a>
	          </li>
            <li>
              <a href="graphmonth.php"><span class="fa fa-signal mr-3"></span> Gráficos por Mes</a>
	          </li>
            <li>
              <a href="graphdate.php"><span class="fa fa-signal mr-3"></span> Gráficos por Fecha</a>
	          </li>
	        </ul>

		  </div>
		  
	  	<div class="text-center">
		  <form method='post' action="">
            <input type="submit" value="Salir" name="but_logout" class="btn btn-outline-light"></input>
          </form>
		<!-- <button class="">Salir</button> -->
	  	</div>
    	</nav>

        <!-- Page Content  -->
      <div id="content" class="p-4 p-md-5 pt-5">
        <h1 class="mb-4 text-center">Reporte de Ventas:</h1>
        <hr />
        <div class="container-fluid">
        <a class="btn btn-light text-left" style="width:100%;" data-toggle="collapse" href="#collapseExample2" role="button" aria-expanded="false" aria-controls="collapseExample2">
          Ingresos
          <i class="fa fa-folder-open" aria-hidden="true"></i>
        </a>
        </div>
        <div class="collapse" id="collapseExample2">
        <div class="card card-body mt-2">
        <div class="container-fluid">
          <div class="row">
            <div class="col-sm-1"></div>
            <div class="col-sm d-inline-flex">
              <h4>Total:</h4>
              &nbsp; S/. <?php 
                if($totalisimo != "" || $totalisimo != null){
                  echo $totalisimo;
                }else{
                  echo '0.00';
                }
              ?>
            </div>
            <div class="col-sm d-inline-flex">
              <h4>Contado:</h4>
              &nbsp; S/. <?php 
              if($contadisimo != "" || $contadisimo != null){
                echo $contadisimo;
              }else{
                echo '0.00';
              }
              ?>
            </div>
            <div class="col-sm d-inline-flex">
              <h4>Tarjeta:</h4>
              &nbsp; S/. <?php 
              if($creditisimo != "" || $creditisimo != null){
                echo $creditisimo;
              }else{
                echo '0.00';
              }
              ?>
            </div>
          </div>
          <div class="text-center">
            <button style="width:40%;" class="btn btn-info mt-4" data-toggle="modal" data-target="#exampleModalLong">
              CAJAS
            </button>
          </div>

        <!-- Modal -->
        <div class="modal fade" id="exampleModalLong" tabindex="-1" role="dialog" aria-labelledby="exampleModalLongTitle" aria-hidden="true">
          <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
              <div class="modal-header">
                <h4 class="modal-title text-center" id="exampleModalLongTitle">Ingresos por Caja</h4>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                  <span aria-hidden="true">&times;</span>
                </button>
              </div>
              <div class="modal-body">
                <h5><u>Caja 1</u>:</h5>
                <div class="card card-body  mt-2">
                <div class="row mt-2">
                  <div class="col-sm-1"></div>
                  <div class="col-sm d-inline-flex">
                    <h5>Total:</h5>
                    <label style="font-size:13.5px;">
                    &nbsp; S/. <?php 
                      if($totalisimo_A != "" || $totalisimo_A != null){
                        echo $totalisimo_A;
                      }else{
                        echo '0.00';
                      }
                    ?>
                    </label>
                  </div>
                  <div class="col-sm d-inline-flex">
                    <h5>Contado:</h5>
                    <label style="font-size:13.5px;">
                    &nbsp; S/. <?php 
                    if($contadisimo_A != "" || $contadisimo_A != null){
                      echo $contadisimo_A;
                    }else{
                      echo '0.00';
                    }
                    ?>
                    </label>
                  </div>
                  <div class="col-sm d-inline-flex">
                    <h5>Tarjeta:</h5>
                    <label style="font-size:13.5px;">
                    &nbsp; S/. <?php 
                    if($creditisimo_A != "" || $creditisimo_A != null){
                      echo $creditisimo_A;
                    }else{
                      echo '0.00';
                    }
                    ?>
                    </label>
                  </div>
                  </div>
                </div>
                <h5><u>Caja 2</u>:</h5>
                <div class="card card-body  mt-2">
                <div class="row mt-2">
                  <div class="col-sm-1"></div>
                  <div class="col-sm d-inline-flex">
                    <h5>Total:</h5>
                    <label style="font-size:13.5px;">
                    &nbsp; S/. <?php 
                      if($totalisimo_B != "" || $totalisimo_B != null){
                        echo $totalisimo_B;
                      }else{
                        echo '0.00';
                      }
                    ?>
                    </label>
                  </div>
                  <div class="col-sm d-inline-flex">
                    <h5>Contado:</h5>
                    <label style="font-size:13.5px;">
                    &nbsp; S/. <?php 
                    if($contadisimo_B != "" || $contadisimo_B != null){
                      echo $contadisimo_B;
                    }else{
                      echo '0.00';
                    }
                    ?>
                    </label>
                  </div>
                  <div class="col-sm d-inline-flex">
                    <h5>Tarjeta:</h5>
                    <label style="font-size:13.5px;">
                    &nbsp; S/. <?php 
                    if($creditisimo_B != "" || $creditisimo_B != null){
                      echo $creditisimo_B;
                    }else{
                      echo '0.00';
                    }
                    ?>
                    </label>
                  </div>
                </div>
                </div>
                <h5><u>Caja 3</u>:</h5>
                <div class="card card-body  mt-2">
                <div class="row mt-2">
                  <div class="col-sm-1"></div>
                  <div class="col-sm d-inline-flex">
                    <h5>Total:</h5>
                    <label style="font-size:13.5px;">
                    &nbsp; S/. <?php 
                      if($totalisimo_C != "" || $totalisimo_C != null){
                        echo $totalisimo_C;
                      }else{
                        echo '0.00';
                      }
                    ?>
                    </label>
                  </div>
                  <div class="col-sm d-inline-flex">
                    <h5>Contado:</h5>
                    <label style="font-size:13.5px;">
                    &nbsp; S/. <?php 
                    if($contadisimo_C != "" || $contadisimo_C != null){
                      echo $contadisimo_C;
                    }else{
                      echo '0.00';
                    }
                    ?>
                    </label>
                  </div>
                  <div class="col-sm d-inline-flex">
                    <h5>Tarjeta:</h5>
                    <label style="font-size:13.5px;">
                    &nbsp; S/. <?php 
                    if($creditisimo_C != "" || $creditisimo_C != null){
                      echo $creditisimo_C;
                    }else{
                      echo '0.00';
                    }
                    ?>
                    </label>
                  </div>
                </div>
                </div>
                <h5><u>Caja 4</u>:</h5>
                <div class="card card-body  mt-2">
                <div class="row">
                  <div class="col-sm-1"></div>
                  <div class="col-sm d-inline-flex">
                    <h5>Total:</h5>
                    <label style="font-size:13.5px;">
                    &nbsp; S/. <?php 
                      if($totalisimo_D != "" || $totalisimo_D != null){
                        echo $totalisimo_D;
                      }else{
                        echo '0.00';
                      }
                    ?>
                    </label>
                  </div>
                  <div class="col-sm d-inline-flex">
                    <h5>Contado:</h5>
                    <label style="font-size:13.5px;">
                    &nbsp; S/. <?php 
                    if($contadisimo_D != "" || $contadisimo_D != null){
                      echo $contadisimo_D;
                    }else{
                      echo '0.00';
                    }
                    ?>
                    </label>
                  </div>
                  <div class="col-sm d-inline-flex">
                    <h5>Tarjeta:</h5>
                    <label style="font-size:13.5px;">
                    &nbsp; S/. <?php 
                    if($creditisimo_D != "" || $creditisimo_D != null){
                      echo $creditisimo_D;
                    }else{
                      echo '0.00';
                    }
                    ?>
                    </label>
                  </div>
                </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        </div>
        </div>
        </div>
        <hr />
        <!-- Inicio de Filtro -->
        <div class="text-right">
          <div class="btn-group mb-2" role="group" aria-label="First group">
          <form method='post' style="max-width: 110px;">
          <button type="submit" name="clean" class="btn btn-info"><i class="fa fa-refresh" aria-hidden="true"></i>&nbsp;Limpiar</button>
          </form>
          <a class="btn btn-primary" data-toggle="collapse" href="#collapseExample" role="button" aria-expanded="false" aria-controls="collapseExample">
          <i class="fa fa-filter"></i>
          Filtro:
          </a>
          </div>
        </div>
        <div class="collapse" id="collapseExample">
          <form method="post">
            <div class="card card-body">
            <div class="d-inline">
            <div class="row">
                <div class="col-md-1">
                </div>
                <div class="col-md-5 form-group-row">
                    <label for="fecha_inicio" class="col-sm-5 col-form-label" style="font-size: 18px;">Fecha Inicio:</label>
                    <div class="col-sm-7">
                        <input type="date" class="form-control" style="max-width:175px;" id="fecha_inicio" name="inicio_filtro" min="2020-01-01">
                    </div>
                </div>
                <div class="col-md-1">
                </div>
                <div class="col-md-5 form-group-row">
                    <label for="fecha_fin" class="col-sm-5 col-form-label" style="font-size: 18px;">Fecha Fin:</label>
                    <div class="col-sm-7">
                    <input type="date" class="form-control" style="max-width:175px;" id="fecha_fin" name="fin_filtro" min="2020-01-01">
                    </div>
                </div>
            </div>
        </div>
        <div class="d-inline">
            <div class="row">
                <div class="col-md-1">
                </div>
                <div class="col-md-6 form-group">
                    <label for="nro_comprobante" class="col-form-label" style="font-size: 18px; padding-left: 15px;">Nro Comprobante:</label>
                    <div style="padding-left: 15px;">
                    <input style="border: 0; outline: 0; background: transparent; border-bottom: 1px solid black; width: 300px;" type="text" id="nro_comprobante" name="nro_comprobante_xd" placeholder="Ingrese el número">
                    </div>
                </div>
                <div class="col-md-5">
                </div>
            </div>
        </div>
        <div class="text-center" style="margin-top:20px;">
            <button type="submit" name="btn_query" id="btn_query" class="btn btn-primary">Consultar</button>
        </div>
            </div>
        </form>
        </div>
        <!-- Fin de Filtro -->

        <!-- Inicio de Tabla -->

        <div class="table-responsive">
          <table id="ventas_list" class="table table-striped table-bordered dt-responsive nowrap" style="width:100%">
            <thead>
              <tr>
                <td>Nro. Comprobante</td>
                <td>Fecha y Hora</td>
                <td>Cliente</td>
                <td>Usuario</td>
                <td>Total</td>
                <td>Detalles</td>
              </tr>
            </thead>
            <tbody>
              <?php 
                if($result_query){
                  while($row = mysqli_fetch_array($result_query)){
                    echo '
                      <tr>
                        <td>'.$row["nro_comprobante"].'</td>
                        <td>'.$row["fecha"].'</td>
                        <td>'.$row["cliente"].'</td>
                        <td>'.$row["usuario"].'</td>
                        <td>'.$row["total"].'</td>
                        <td><a href="detalleventa.php?idventa='.$row["nro_comprobante"].'">Observar&nbsp;</a><i class="fa fa-eye" aria-hidden="true"></i></td>
                      </tr>
                    ';
                  }
                }
              ?>
            </tbody>
          </table>
        </div>

        <!-- Fin de Tabla -->
        
        <!-- <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>
        <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p> -->
        <!-- Footer -->
        <footer style="margin-top: 100px; position: relative;" class="page-footer font-small">

        <!-- Copyright -->
        <div class="footer-copyright text-center py-3">© 2020 Realizado por: 
            <a> Ceintec.RN</a>
        </div>
        <!-- Copyright -->

        </footer>
        <!-- Footer -->  
    </div>

		</div>

    <script src="assets/js/jquery.min.js"></script>
    <script src="assets/js/popper.js"></script>
    <!-- <script src="assets/js/bootstrap.min.js"></script> -->
    <script src="assets/js/main.js"></script>
        <!-- Jquery JS-->
        <script src="assets/vendor/jquery-3.2.1.min.js"></script>
    <!-- Bootstrap JS-->
    <script src="assets/vendor/bootstrap-4.1/popper.min.js"></script>
    <script src="assets/vendor/bootstrap-4.1/bootstrap.min.js"></script>
    <!-- Vendor JS       -->
    <script src="assets/vendor/slick/slick.min.js">
    </script>
    <script src="assets/vendor/wow/wow.min.js"></script>
    <script src="assets/vendor/animsition/animsition.min.js"></script>
    <script src="assets/vendor/bootstrap-progressbar/bootstrap-progressbar.min.js">
    </script>
    <script src="assets/vendor/counter-up/jquery.waypoints.min.js"></script>
    <script src="assets/vendor/counter-up/jquery.counterup.min.js">
    </script>
    <script src="assets/vendor/circle-progress/circle-progress.min.js"></script>
    <script src="assets/vendor/perfect-scrollbar/perfect-scrollbar.js"></script>
    <script src="assets/vendor/chartjs/Chart.bundle.min.js"></script>
    <script src="assets/vendor/select2/select2.min.js">
    </script>
    <script src="assets/vendor/vector-map/jquery.vmap.js"></script>
    <script src="assets/vendor/vector-map/jquery.vmap.min.js"></script>
    <script src="assets/vendor/vector-map/jquery.vmap.sampledata.js"></script>
    <script src="assets/vendor/vector-map/jquery.vmap.world.js"></script>

    <!-- Main JS-->
    <script src="assets/js/main2.js"></script>

    <!-- Data Table -->
    <script src="assets/js/jquery.dataTables.min.js"></script>
    <script src="assets/js/dataTables.bootstrap4.min.js"></script>
    <script src="assets/js/dataTables.responsive.min.js"></script>
    <script src="assets/js/responsive.bootstrap4.min.js"></script>

    <script>
        var now = new Date();
        var day = ("0" + now.getDate()).slice(-2);
        var month = ("0" + (now.getMonth() + 1)).slice(-2);
        var today = now.getFullYear()+"-"+(month)+"-"+(day) ;
        document.getElementById("fecha_inicio").value = today;
        document.getElementById("fecha_fin").value = today;
        $("#fecha_inicio").change(function(){
            document.getElementById("fecha_fin").value = document.getElementById("fecha_inicio").value;
        })

        $(document).ready(function() {
          $('#ventas_list').DataTable({
            language: {
                "sProcessing":     "Procesando...",
                "sLengthMenu":     "Mostrar _MENU_ registros",
                "sZeroRecords":    "No se encontraron resultados",
                "sEmptyTable":     "Ningún dato disponible en esta tabla =(",
                "sInfo":           "Mostrando registros del _START_ al _END_ de un total de _TOTAL_ registros",
                "sInfoEmpty":      "Mostrando registros del 0 al 0 de un total de 0 registros",
                "sInfoFiltered":   "(filtrado de un total de _MAX_ registros)",
                "sInfoPostFix":    "",
                "sSearch":         "Buscar:",
                "sUrl":            "",
                "sInfoThousands":  ",",
                "sLoadingRecords": "Cargando...",
                "oPaginate": {
                    "sFirst":    "Primero",
                    "sLast":     "Último",
                    "sNext":     "Siguiente",
                    "sPrevious": "Anterior"
                },
                "oAria": {
                    "sSortAscending":  ": Activar para ordenar la columna de manera ascendente",
                    "sSortDescending": ": Activar para ordenar la columna de manera descendente"
                },
                "buttons": {
                    "copy": "Copiar",
                    "colvis": "Visibilidad"
                }
              }
          });
        } );

    </script>
  </body>
</html>
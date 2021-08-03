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
        header('Location: graphmonth.php');
      }
    
    if(isset($_POST['btn_query'])){
        $anio = mysqli_real_escape_string($con,(strip_tags($_POST["startyear"],ENT_QUOTES)));//Escanpando caracteres
        $query_enero="SELECT SUM(totalpagado) as total_causa FROM comprobante_venta WHERE SUBSTR(fecha_hora_venta,1,7) = '$anio-01'";
        $query_febrero="SELECT SUM(totalpagado) as total_causa FROM comprobante_venta WHERE SUBSTR(fecha_hora_venta,1,7) = '$anio-02'";
        $query_marzo="SELECT SUM(totalpagado) as total_causa FROM comprobante_venta WHERE SUBSTR(fecha_hora_venta,1,7) = '$anio-03'";
        $query_abril="SELECT SUM(totalpagado) as total_causa FROM comprobante_venta WHERE SUBSTR(fecha_hora_venta,1,7) = '$anio-04'";
        $query_mayo="SELECT SUM(totalpagado) as total_causa FROM comprobante_venta WHERE SUBSTR(fecha_hora_venta,1,7) = '$anio-05'";
        $query_junio="SELECT SUM(totalpagado) as total_causa FROM comprobante_venta WHERE SUBSTR(fecha_hora_venta,1,7) = '$anio-06'";
        $query_julio="SELECT SUM(totalpagado) as total_causa FROM comprobante_venta WHERE SUBSTR(fecha_hora_venta,1,7) = '$anio-07'";
        $query_agosto="SELECT SUM(totalpagado) as total_causa FROM comprobante_venta WHERE SUBSTR(fecha_hora_venta,1,7) = '$anio-08'";
        $query_septiembre="SELECT SUM(totalpagado) as total_causa FROM comprobante_venta WHERE SUBSTR(fecha_hora_venta,1,7) = '$anio-09'";
        $query_octubre="SELECT SUM(totalpagado) as total_causa FROM comprobante_venta WHERE SUBSTR(fecha_hora_venta,1,7) = '$anio-10'";
        $query_noviembre="SELECT SUM(totalpagado) as total_causa FROM comprobante_venta WHERE SUBSTR(fecha_hora_venta,1,7) = '$anio-11'";
        $query_diciembre="SELECT SUM(totalpagado) as total_causa FROM comprobante_venta WHERE SUBSTR(fecha_hora_venta,1,7) = '$anio-12'";
        $result_query_enero = ejecutarConsulta($query_enero);
        $result_query_febrero = ejecutarConsulta($query_febrero);
        $result_query_marzo = ejecutarConsulta($query_marzo);    
        $result_query_abril = ejecutarConsulta($query_abril);
        $result_query_mayo = ejecutarConsulta($query_mayo);
        $result_query_junio = ejecutarConsulta($query_junio);  
        $result_query_julio = ejecutarConsulta($query_julio);
        $result_query_agosto = ejecutarConsulta($query_agosto);
        $result_query_septiembre = ejecutarConsulta($query_septiembre);  
        $result_query_octubre = ejecutarConsulta($query_octubre);
        $result_query_noviembre = ejecutarConsulta($query_noviembre);
        $result_query_diciembre = ejecutarConsulta($query_diciembre);  
    }else{
        $anio = date("Y");
        $query_enero="SELECT SUM(totalpagado) as total_causa FROM comprobante_venta WHERE SUBSTR(fecha_hora_venta,1,7) = '$anio-01'";
        $query_febrero="SELECT SUM(totalpagado) as total_causa FROM comprobante_venta WHERE SUBSTR(fecha_hora_venta,1,7) = '$anio-02'";
        $query_marzo="SELECT SUM(totalpagado) as total_causa FROM comprobante_venta WHERE SUBSTR(fecha_hora_venta,1,7) = '$anio-03'";
        $query_abril="SELECT SUM(totalpagado) as total_causa FROM comprobante_venta WHERE SUBSTR(fecha_hora_venta,1,7) = '$anio-04'";
        $query_mayo="SELECT SUM(totalpagado) as total_causa FROM comprobante_venta WHERE SUBSTR(fecha_hora_venta,1,7) = '$anio-05'";
        $query_junio="SELECT SUM(totalpagado) as total_causa FROM comprobante_venta WHERE SUBSTR(fecha_hora_venta,1,7) = '$anio-06'";
        $query_julio="SELECT SUM(totalpagado) as total_causa FROM comprobante_venta WHERE SUBSTR(fecha_hora_venta,1,7) = '$anio-07'";
        $query_agosto="SELECT SUM(totalpagado) as total_causa FROM comprobante_venta WHERE SUBSTR(fecha_hora_venta,1,7) = '$anio-08'";
        $query_septiembre="SELECT SUM(totalpagado) as total_causa FROM comprobante_venta WHERE SUBSTR(fecha_hora_venta,1,7) = '$anio-09'";
        $query_octubre="SELECT SUM(totalpagado) as total_causa FROM comprobante_venta WHERE SUBSTR(fecha_hora_venta,1,7) = '$anio-10'";
        $query_noviembre="SELECT SUM(totalpagado) as total_causa FROM comprobante_venta WHERE SUBSTR(fecha_hora_venta,1,7) = '$anio-11'";
        $query_diciembre="SELECT SUM(totalpagado) as total_causa FROM comprobante_venta WHERE SUBSTR(fecha_hora_venta,1,7) = '$anio-12'";
        $result_query_enero = ejecutarConsulta($query_enero);
        $result_query_febrero = ejecutarConsulta($query_febrero);
        $result_query_marzo = ejecutarConsulta($query_marzo);    
        $result_query_abril = ejecutarConsulta($query_abril);
        $result_query_mayo = ejecutarConsulta($query_mayo);
        $result_query_junio = ejecutarConsulta($query_junio);  
        $result_query_julio = ejecutarConsulta($query_julio);
        $result_query_agosto = ejecutarConsulta($query_agosto);
        $result_query_septiembre = ejecutarConsulta($query_septiembre);  
        $result_query_octubre = ejecutarConsulta($query_octubre);
        $result_query_noviembre = ejecutarConsulta($query_noviembre);
        $result_query_diciembre = ejecutarConsulta($query_diciembre);  
    }
    
    
?>
<!doctype html>
<html lang="en">
  <head>
  	<title>Graficos - Reportes Libertad</title>
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

    <!-- Main CSS-->
    <link href="assets/css/theme.css" rel="stylesheet" media="all">

    <!--Chartist-->
    <link rel="stylesheet"
          href="assets/css/chartist.min.css">
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
	          <li>
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
            <li class="active">
              <a href="graphmonth.php"><span class="fa fa-signal mr-3"></span> Gráficos por Mes</a>
	          </li>
            <li >
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
        <h1 class="mb-4 text-center">Gráfico de Ventas por Mes en <?php echo $anio; ?></h1>
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
            <div class="col-md-1"></div>
            <div class="col-md row">
                <div class="col-md-2">
                <label for="startyear" class="col-form-label" style="font-size: 18px;">Año:</label>
                </div>
                <div class="col-md-4">
                <select class="form-control" name="startyear">
                    <?php
                    for ($year = (int)date('Y'); 2019 <= $year; $year--): ?>
                        <option value="<?=$year;?>"><?=$year;?></option>
                    <?php endfor; ?>
                </select>
                </div>
                <div class="col-md"></div>
            </div>
            <div class="col-md"></div>
        </div>
        </div>
        <div class="text-center" style="margin-top:20px;">
            <button type="submit" name="btn_query" id="btn_query" class="btn btn-primary">Consultar</button>
        </div>
        </div>
        </form>
        </div>
        <div id="chart1" class="ct-chart" style="height: 350px; margin-top: 40px; min-width:310px;" ></div>
        
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

    <!-- Chartist -->
    <script src="assets/js/chartist.min.js"></script>

    <!-- Main JS-->
    <script src="assets/js/main2.js"></script>

    <script>
    new Chartist.Line('.ct-chart', {
    labels: ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'],
    series: [
    [<?php  
    $row_enero = mysqli_fetch_assoc($result_query_enero);
    echo $row_enero['total_causa'];
    ?>, 
    <?php  
    $row_febrero = mysqli_fetch_assoc($result_query_febrero);
    echo $row_febrero['total_causa'];
    ?>,
    <?php  
    $row_marzo = mysqli_fetch_assoc($result_query_marzo);
    echo $row_marzo['total_causa'];
    ?>,
    <?php  
    $row_abril = mysqli_fetch_assoc($result_query_abril);
    echo $row_abril['total_causa'];
    ?>, 
    <?php  
    $row_mayo = mysqli_fetch_assoc($result_query_mayo);
    echo $row_mayo['total_causa'];
    ?>,
    <?php  
    $row_junio = mysqli_fetch_assoc($result_query_junio);
    echo $row_junio['total_causa'];
    ?>,
    <?php  
    $row_julio = mysqli_fetch_assoc($result_query_julio);
    echo $row_julio['total_causa'];
    ?>, 
    <?php  
    $row_agosto = mysqli_fetch_assoc($result_query_agosto);
    echo $row_agosto['total_causa'];
    ?>,
    <?php  
    $row_septiembre = mysqli_fetch_assoc($result_query_septiembre);
    echo $row_septiembre['total_causa'];
    ?>,
    <?php  
    $row_octubre = mysqli_fetch_assoc($result_query_octubre);
    echo $row_octubre['total_causa'];
    ?>, 
    <?php  
    $row_noviembre = mysqli_fetch_assoc($result_query_noviembre);
    echo $row_noviembre['total_causa'];
    ?>,
    <?php  
    $row_diciembre = mysqli_fetch_assoc($result_query_diciembre);
    echo $row_diciembre['total_causa'];
    ?>,]
    ]
    }, {
    low: 0,
    showArea: true
    });
    </script>
  </body>
</html>
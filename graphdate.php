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
        $fecha_inicio = mysqli_real_escape_string($con,(strip_tags($_POST["inicio_filtro"],ENT_QUOTES)));//Escanpando caracteres
        $fecha_fin = mysqli_real_escape_string($con,(strip_tags($_POST["fin_filtro"],ENT_QUOTES)));//Escanpando caracteres
        $result_query_F=query_skere($fecha_inicio,$fecha_fin);
        $result_query_G=$result_query_F;
    }else{
        $fecha_fin=date('Y-m-d');
        $fecha_inicio=Date('Y-m-d', strtotime("-30 days"));
        $result_query_F=query_skere($fecha_inicio,$fecha_fin);
        $result_query_G=$result_query_F;
    }
    
    function query_skere($fecha_inicio,$fecha_fin){
        $query="SELECT SUBSTR(CV.fecha_hora_venta,1,10) as fecha ,SUM(CV.totalpagado) as total FROM comprobante_venta CV WHERE STR_TO_DATE(CONCAT(substr(CV.fecha_hora_venta,1,4),',',substr(CV.fecha_hora_venta,6,2),',',substr(CV.fecha_hora_venta,9,2)),'%Y,%m,%d') BETWEEN '$fecha_inicio' AND '$fecha_fin' GROUP BY SUBSTR(CV.fecha_hora_venta,1,10) ORDER BY SUBSTR(CV.fecha_hora_venta,1,10) ASC  LIMIT 30";
        $result_query = ejecutarConsulta($query);
        return $result_query;
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
              <li>
              <a href="graphmonth.php"><span class="fa fa-signal mr-3"></span> Gráficos por Mes</a>
	          </li>
              <li class="active">
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
        <h1 class="mb-4 text-center">Gráfico de Ventas por Fecha</h1>
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
        <div class="text-center" style="margin-top:20px;">
            <button type="submit" name="btn_query" id="btn_query" class="btn btn-primary">Consultar</button>
        </div>
            </div>
        </form>
        </div>
        <!-- Fin de Filtro -->
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
    labels: [<?php 
        $series = array();
        while($row = mysqli_fetch_array($result_query_F)){
            echo '"'.$row["fecha"].'",';
            array_push($series,$row["total"]);
        }
     ?>],
    series: [
    [<?php
        for ($i=0; $i < count($series) ; $i++) { 
            echo $series[$i];
            echo ',';
        }
     ?>]
    ]
    }, {
    low: 0,
    showArea: true
    });
    </script>
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
    </script>
  </body>
</html>
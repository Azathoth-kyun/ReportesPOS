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
  
  if(isset($_GET['idventa'])){
    $idventa = $_GET['idventa'];
    $select_query = "SELECT P.descripcion as descripcion, DV.cantidad as cantidad, UM.unidad as unidad, FORMAT(DV.precioventaunitario,2) as precio FROM detalle_venta DV INNER JOIN producto P ON DV.idproducto = P.idproducto INNER JOIN unidad_medida UM ON P.idunidad_medida = UM.idunidadmedida WHERE DV.numero_comprobante = '$idventa';";
    $result_query = ejecutarConsulta($select_query);
  }
?>
<!doctype html>
<html lang="en">
  <head>
  	<title>Detalle Venta - Reportes Libertad</title>
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
        <h1 class="mb-4 text-center">Detalle de Venta: <?php echo $idventa ?></h1>
        <hr />
        
        <!-- Inicio de Tabla -->

        <div class="table-responsive">
          <table id="ventas_list_detail" class="table table-striped table-bordered dt-responsive nowrap" style="width:100%">
            <thead>
              <tr>
                <td>Nro. Item</td>
                <td>Descripcion</td>
                <td>Cantidad</td>
                <td>Unidad Medida</td>
                <td>Precio</td>
              </tr>
            </thead>
            <tbody>
              <?php 
                if($result_query){
                  $iterator = 0;
                  while($row = mysqli_fetch_array($result_query)){
                    $iterator ++;
                    echo '
                      <tr>
                        <td>'.$iterator.'</td>
                        <td>'.$row["descripcion"].'</td>
                        <td>'.$row["cantidad"].'</td>
                        <td>'.$row["unidad"].'</td>
                        <td>'.$row["precio"].'</td>
                      </tr>
                    ';
                  }
                }
              ?>
            </tbody>
          </table>
        </div>

      <!-- Fin de Tabla -->
        <!-- Boton de regreso -->

        <div class="text-center mt-5">
          <a role="button" href="<?php if(isset($_GET['detalledia'])){
            $dia = $_GET['detalledia'];
            echo 'detalledia.php?dia='.$dia.'';
          }else{
            echo 'reporteventa.php';
          }?>" class="btn btn-primary"><i class="fa fa-arrow-left" aria-hidden="true"></i>&nbsp;Volver a Reportes</a>
        </div>

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
      $(document).ready(function() {
          $('#ventas_list_detail').DataTable({
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
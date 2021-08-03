-- phpMyAdmin SQL Dump
-- version 4.9.0.1
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost
-- Tiempo de generación: 28-02-2020 a las 14:32:31
-- Versión del servidor: 8.0.17
-- Versión de PHP: 7.3.9

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `sis_ventas`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Actualizar_Nro_Comprobante` (IN `vtipocomprobante` VARCHAR(50) CHARSET utf8)  begin

  declare _longitud_serie int;
  declare _longitud_correlativo int;
  declare _serie int;
  declare _correlativo bigint;
  declare _idtipocomprobante int;

  select idtipoComprobante from tipocomprobante where tipo_comprobante = CONVERT(vtipocomprobante using utf8) collate utf8_spanish_ci into _idtipocomprobante;

  if (_idtipocomprobante = 1) then
    select cast(dato as unsigned) from datos where descripcion = 'boleta_cantidad_serie' into _longitud_serie;
    select cast(dato as unsigned)
    from datos
    where descripcion = 'boleta_cantidad_correlativo' into _longitud_correlativo;
    select cast(dato as unsigned) from datos where descripcion = 'boleta_serie' into _serie;
    select cast(dato as unsigned) from datos where descripcion = 'boleta_correlativo' into _correlativo;

    if (_correlativo+1 = pow(10, _longitud_correlativo)) then
      set _correlativo = 1;
      set _serie = _serie+1;
    else
      set _correlativo = _correlativo+1;
    end if;

    update datos set dato=_correlativo where descripcion = 'boleta_correlativo';
    update datos set dato=_serie where descripcion = 'boleta_serie';
    end if ;
  if (_idtipocomprobante = 2) then
    select cast(dato as unsigned) from datos where descripcion = 'factura_cantidad_serie' into _longitud_serie;
    select cast(dato as unsigned)
    from datos
    where descripcion = 'factura_cantidad_correlativo' into _longitud_correlativo;
    select cast(dato as unsigned) from datos where descripcion = 'factura_serie' into _serie;
    select cast(dato as unsigned) from datos where descripcion = 'factura_correlativo' into _correlativo;

    if (_correlativo+1 = pow(10, _longitud_correlativo)) then
      set _correlativo = 1;
      set _serie = _serie+1;
    else
      set _correlativo = _correlativo+1;
    end if;

    update datos set dato=_correlativo where descripcion = 'factura_correlativo';
    update datos set dato=_serie where descripcion = 'factura_serie';
    end if ;
  if (_idtipocomprobante = 3) then
    select cast(dato as unsigned) from datos where descripcion = 'notacompra_correlativo' into _correlativo;
    set _correlativo=_correlativo+1;

    update datos set dato=_correlativo where descripcion = 'notacompra_correlativo';
  end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Actualizar_Total_Subtotal` (IN `vcomprobante` VARCHAR(20), IN `vtipo` INT)  begin
  if (vtipo = 0) then
    if ((select count(*)
         from comprobante_venta cv
                inner join detalle_venta dv on cv.numero_comprobante = dv.numero_comprobante
         where cv.numero_comprobante = CONVERT(vcomprobante using utf8) collate utf8_spanish_ci)=0) then
      update comprobante_venta set subtotal=0, totalpagado=0 where numero_comprobante = vcomprobante;
      else
      select sum(cantidad * precioventaunitario) as total,
           ((sum(cantidad * precioventaunitario)) -
            ((sum(cantidad * precioventaunitario)) * (select dato from datos where descripcion = 'igv') /
             100))                             as subtotal
    from detalle_venta dv
           inner join comprobante_venta cv
                      on cv.numero_comprobante = dv.numero_comprobante and
                         cv.numero_comprobante = vcomprobante into @total, @subtotal;
    if ((select idtipoComprobante from comprobante_venta where comprobante_venta.numero_comprobante = CONVERT(vcomprobante using utf8) collate utf8_spanish_ci) =
        3) then
      update comprobante_venta set subtotal=@total, totalpagado=@total where numero_comprobante = CONVERT(vcomprobante using utf8) collate utf8_spanish_ci;
    else
      update comprobante_venta set subtotal=@subtotal, totalpagado=@total where numero_comprobante = CONVERT(vcomprobante using utf8) collate utf8_spanish_ci;
    end if;
    end if;


  else
    select sum(cantidad * preciocompraunitario) as total,
           ((sum(cantidad * preciocompraunitario)) -
            ((sum(cantidad * preciocompraunitario)) * (select dato from datos where descripcion = 'igv') /
             100))                              as subtotal
    from detalle_compra dv
           inner join comprobante_compra cv
                      on cv.numero_comprobante = dv.numero_comprobante and cv.numero_comprobante = vcomprobante
           inner join producto_lote pl on dv.idproducto_lote = pl.idproducto_lote into @total,@subtotal;
    update comprobante_compra set subtotal=@subtotal, totalpagado=@total where numero_comprobante = CONVERT(vcomprobante using utf8) collate utf8_spanish_ci;
  end if;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Actualizar_Total_Subtotal_Compra` (IN `vnumComprobante` VARCHAR(20) CHARSET utf8)  begin
  declare _subtotal double;
  declare _total double;

  select sum(cantidad * preciocompraunitario),
         sum(cantidad * preciocompraunitario) +
         (sum(cantidad * preciocompraunitario)) *
         (select cast(dato as decimal(9, 2)) from datos where descripcion = 'igv') / 100 as total
  into _subtotal,_total
  from comprobante_compra
         inner join detalle_compra
         inner join producto_lote pl on detalle_compra.idproducto_lote = pl.idproducto_lote
  where detalle_compra.numero_comprobante = comprobante_compra.numero_comprobante
    and detalle_compra.numero_comprobante = CONVERT(vnumComprobante using utf8) collate utf8_spanish_ci;

  update comprobante_compra set subtotal=_subtotal, totalpagado=_total where numero_comprobante = CONVERT(vnumComprobante using utf8) collate utf8_spanish_ci;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Actualizar_Total_Subtotal_Venta` (IN `vcomprobante` VARCHAR(20))  begin
  declare _total double;
  declare _subtotal double;

  select sum(cantidad * precioventaunitario),
         (sum(cantidad * precioventaunitario) +
          (sum(cantidad * precioventaunitario) * (select dato from datos where descripcion = 'igv') / 100))
  from detalle_venta
  where numero_comprobante = CONVERT(vcomprobante using utf8) collate utf8_spanish_ci into _subtotal,_total;

  if(_subtotal is null) then
    set _total=0;
    set _subtotal=0;
  end if;

  update comprobante_venta set totalpagado=_total, subtotal=_subtotal where numero_comprobante = CONVERT(vcomprobante using utf8) collate utf8_spanish_ci;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_AgregarClientes` (IN `vnombre_razon` VARCHAR(100), IN `vdocumento` VARCHAR(20), IN `vtipo_doc_usuario` VARCHAR(30), IN `vfecha_nacimiento` VARCHAR(20), IN `vdireccion` VARCHAR(150), IN `vemail` VARCHAR(50), IN `vtelefono` VARCHAR(20), IN `vobservacion` VARCHAR(300), IN `vidtipo_cliente` INT)  begin
  declare vidtipo_doc_usuario int;
  select tipo_doc_usuario.idtipo_doc_usuario
  from tipo_doc_usuario
  where tipo_doc_usuario.nombre = CONVERT(vtipo_doc_usuario using utf8) collate utf8_spanish_ci into vidtipo_doc_usuario;

  insert into cliente(nombre_razon, documento, idtipo_doc_usuario, fecha_nacimiento,
                      direccion, email, telefono, observacion, idtipo_cliente)
  values (CONVERT(vnombre_razon using utf8) collate utf8_spanish_ci, CONVERT(vdocumento using utf8) collate utf8_spanish_ci, CONVERT(vidtipo_doc_usuario using utf8) collate utf8_spanish_ci, CONVERT(vfecha_nacimiento using utf8) collate utf8_spanish_ci, CONVERT(vdireccion using utf8) collate utf8_spanish_ci, CONVERT(vemail using utf8) collate utf8_spanish_ci, CONVERT(vtelefono using utf8) collate utf8_spanish_ci, CONVERT(vobservacion using utf8) collate utf8_spanish_ci,
          CONVERT(vidtipo_cliente using utf8) collate utf8_spanish_ci);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_AgregarDireccionProveedor` (IN `vdireccion` VARCHAR(300), IN `vruc` VARCHAR(20))  begin
  declare vidproveedor int;
  select proveedor.codigoProv from proveedor where proveedor.ruc = CONVERT(vruc using utf8) collate utf8_spanish_ci into vidproveedor;
  insert into direccionproveedor(direccion, codigoProv) values (vdireccion, vidproveedor);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_AgregarLinea` (IN `vnombrelinea` VARCHAR(50))  begin
  insert into linea(nombreLinea) values (vnombrelinea);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_AgregarMarca` (IN `vnombremarca` VARCHAR(50))  begin
  insert into marca (nombremarca) values (vnombremarca);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_AgregarProveedor` (IN `vnombreProv` VARCHAR(20), IN `vrazon_social` VARCHAR(100), IN `vruc` VARCHAR(20), IN `vemail` VARCHAR(50), IN `vcontacto` VARCHAR(50), IN `vtelefonocontacto` VARCHAR(20))  begin
  insert into proveedor (nombreProv, razon_social, ruc, email, contacto, telefonocontacto) values (vnombreProv, vrazon_social, vruc, vemail, vcontacto, vtelefonocontacto);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_AgregarTelefonosProveedor` (IN `vnumeroTelefono` VARCHAR(20), IN `vnombreTipoTelefono` VARCHAR(150), IN `vruc` VARCHAR(20))  begin
  declare vidproveedor int;
  declare vidtipotelefono int;
  select proveedor.codigoProv from proveedor where proveedor.ruc = CONVERT(vruc using utf8) collate utf8_spanish_ci into vidproveedor;
  select tipotelefono.idTipoTelefono from tipotelefono where tipotelefono.nombreTipoTelefono = CONVERT(vnombreTipoTelefono using utf8) collate utf8_spanish_ci into vidtipotelefono;
  insert into telefonoproveedor(numeroTelefono, idTipoTelefono, codigoProv) values (vnumeroTelefono, vidtipotelefono, vidproveedor);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Agregar_Categoria_Linea` (IN `vnombrelinea` VARCHAR(50), IN `vnombreCategoria` VARCHAR(50))  begin
  declare vidlinea varchar(50);
  select linea.idlinea from linea where linea.nombreLinea = CONVERT(vnombrelinea using utf8) collate utf8_spanish_ci into vidlinea;
  INSERT INTO categoria(nombreCategoria, idlinea) values (vnombreCategoria, vidlinea);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Agregar_Empresa` (IN `vnombreEmpresa` VARCHAR(100), IN `vrazonSocial` VARCHAR(100), IN `vruc` VARCHAR(100), IN `vdireccion` VARCHAR(150), IN `vtelefono` VARCHAR(15), IN `vemail` VARCHAR(50), IN `vslogan` VARCHAR(200), IN `vabreviatura` VARCHAR(1500), IN `valias` VARCHAR(100))  begin
  insert into empresa(nombreEmpresa, razonSocial, ruc, direccion, telefono, email, slogan, abreviatura, alias)
  values (vnombreEmpresa, vrazonSocial, vruc, vdireccion, vtelefono, vemail, vslogan, vabreviatura, valias);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Agregar_Producto` (IN `vcodigoBarras` VARCHAR(20), IN `vdescripcion` VARCHAR(80), IN `vunidad_medida` VARCHAR(30), IN `vcategoria` VARCHAR(50), IN `vmarca` VARCHAR(50), IN `vpreciosugerido` DOUBLE)  begin
  DECLARE cantidadCategoriaProducto int;
  DECLARE existeProducto int;

  select count(*) from producto where descripcion = CONVERT(vdescripcion using utf8) collate utf8_spanish_ci into existeProducto;
  if (existeProducto = 0) then
    select count(*)
    from producto
           inner join categoria c on producto.idcategoria = c.idcategoria
           inner join linea l on c.idlinea = l.idlinea
    where nombreCategoria = CONVERT(vcategoria using utf8) collate utf8_spanish_ci into cantidadCategoriaProducto;
    if (vcodigoBarras = '') then
      insert into producto(codigoBarras, descripcion, idunidad_medida, idcategoria, idmarca, preciosugerido)
      VALUES ('',
              vdescripcion,
              (select idunidadmedida from unidad_medida where unidad = CONVERT(vunidad_medida using utf8) collate utf8_spanish_ci),
              (select idcategoria from categoria where nombreCategoria = CONVERT(vcategoria using utf8) collate utf8_spanish_ci),
              (select idmarca from marca where nombremarca = CONVERT(vmarca using utf8) collate utf8_spanish_ci),
              vpreciosugerido);

      update producto
      set codigoBarras=concat('',idproducto),
      preciosugerido = vpreciosugerido
      where descripcion = CONVERT(vdescripcion using utf8) collate utf8_spanish_ci;
    else
      insert into producto(codigoBarras, descripcion, idunidad_medida, idcategoria, idmarca, preciosugerido)
      VALUES (vcodigoBarras,
              vdescripcion,
              (select idunidadmedida from unidad_medida where unidad = CONVERT(vunidad_medida using utf8) collate utf8_spanish_ci),
              (select idcategoria from categoria where nombreCategoria = CONVERT(vcategoria using utf8) collate utf8_spanish_ci),
              (select idmarca from marca where nombremarca = CONVERT(vmarca using utf8) collate utf8_spanish_ci),
              vpreciosugerido);
      update producto
      set preciosugerido = vpreciosugerido
      where descripcion = CONVERT(vdescripcion using utf8) collate utf8_spanish_ci;
    end if;
  else
    update producto
    set preciosugerido = vpreciosugerido,
        idmarca=(select idmarca from marca where nombremarca = CONVERT(vmarca using utf8) collate utf8_spanish_ci),
        idcategoria=(select idcategoria from categoria where nombreCategoria = CONVERT(vcategoria using utf8) collate utf8_spanish_ci)
    where descripcion = CONVERT(vdescripcion using utf8) collate utf8_spanish_ci;
  end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Agregar_Producto_Ingreso_stock` (IN `vcodigoBarras` VARCHAR(20), IN `vdescripcion` VARCHAR(80), IN `vunidad_medida` VARCHAR(30), IN `vcategoria` VARCHAR(50), IN `vmarca` VARCHAR(50), IN `vpreciosugerido` DOUBLE, IN `vstock` INT)  begin
  if (vcodigoBarras = '') then
    insert into producto(descripcion, idunidad_medida, idcategoria, idmarca, preciosugerido, stock)
    VALUES (vdescripcion,
            (select idunidadmedida from unidad_medida where unidad = CONVERT(vunidad_medida using utf8) collate utf8_spanish_ci),
            (select idcategoria from categoria where nombreCategoria = CONVERT(vcategoria using utf8) collate utf8_spanish_ci),
            (select idmarca from marca where nombremarca = CONVERT(vmarca using utf8) collate utf8_spanish_ci),
            vpreciosugerido, vstock);
  else
    insert into producto(codigoBarras, descripcion, idunidad_medida, idcategoria, idmarca, preciosugerido, stock)
    VALUES (vcodigoBarras,
            vdescripcion,
            (select idunidadmedida from unidad_medida where unidad = CONVERT(vunidad_medida using utf8) collate utf8_spanish_ci),
            (select idcategoria from categoria where nombreCategoria = CONVERT(vcategoria using utf8) collate utf8_spanish_ci),
            (select idmarca from marca where nombremarca = CONVERT(vmarca using utf8) collate utf8_spanish_ci),
            vpreciosugerido, vstock);
  end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Agregar_Unidad_Medida` (IN `vunidad` VARCHAR(30))  begin 
  insert into unidad_medida(unidad) values (vunidad);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Asignar_acceso_sistema` (IN `vdocumento` VARCHAR(20), IN `vusername` VARCHAR(80), IN `vpassword` VARCHAR(80), IN `vestado` VARCHAR(2))  NO SQL
    DETERMINISTIC
insert into user_pass (idusuario, username, password,estado)
    value ((select idusuario from usuario where documento = CONVERT(vdocumento using utf8) collate utf8_spanish_ci), vusername, vpassword,vestado)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_BuscarClienteExiste` (IN `vdocumento` VARCHAR(20))  begin
  select count(*) from cliente where cliente.documento = CONVERT(vdocumento using utf8) collate utf8_spanish_ci;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_BuscarDoc` (IN `vdocumento` VARCHAR(20))  NO SQL
SELECT COUNT(*) FROM usuario WHERE CONVERT(vdocumento using utf8) collate utf8_spanish_ci = usuario.documento$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_BuscarProveedorNombre` (IN `vnombre` VARCHAR(20))  begin
  select count(*) from proveedor where proveedor.nombreProv=CONVERT(vnombre using utf8) collate utf8_spanish_ci;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_BuscarProveedorRazonSocial` (IN `vrs` VARCHAR(100))  begin
  select count(*) from proveedor where proveedor.razon_social=CONVERT(vrs using utf8) collate utf8_spanish_ci;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_BuscarProveedorRUC` (IN `vruc` VARCHAR(20))  begin
  select count(*) from proveedor where proveedor.ruc = CONVERT(vruc using utf8) collate utf8_spanish_ci;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Buscar_Categoria` (IN `vnombreCategoria` VARCHAR(50))  begin 
  select count(*) from categoria where nombreCategoria=CONVERT(vnombreCategoria using utf8) collate utf8_spanish_ci;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Buscar_Categoria_Duplicidad` (IN `vnombreCategoria` VARCHAR(50), IN `vnombreCategoriaAntiguo` VARCHAR(50))  begin
  declare vidlinea int;
  declare vicategoria int;
  select categoria.idlinea from categoria inner join linea where linea.idlinea=categoria.idlinea and CONVERT(vnombreCategoriaAntiguo using utf8) collate utf8_spanish_ci=categoria.nombreCategoria into vidlinea;
  select categoria.idcategoria from categoria where CONVERT(vnombreCategoriaAntiguo using utf8) collate utf8_spanish_ci=categoria.nombreCategoria into vicategoria;
  select count(*) from categoria where nombreCategoria=CONVERT(vnombreCategoria using utf8) collate utf8_spanish_ci and idlinea=vidlinea and idcategoria=CONVERT(vicategoria using utf8) collate utf8_spanish_ci;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Buscar_Username` (IN `vusername` VARCHAR(50))  NO SQL
SELECT COUNT(*) FROM user_pass WHERE CONVERT(vusername using utf8) collate utf8_spanish_ci = user_pass.username$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Categoria_Ingresar` (IN `vlinea` VARCHAR(50), IN `vcategoria` VARCHAR(50))  begin
  insert into categoria(nombreCategoria, idlinea) VALUES (vcategoria,(select idlinea from linea where nombreLinea=CONVERT(vlinea using utf8) collate utf8_spanish_ci));
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_CodigoExiste` (IN `vcodigo` VARCHAR(20) CHARSET utf8)  begin
  select count(*) from producto where producto.codigoBarras = CONVERT(vcodigo using utf8) collate utf8_spanish_ci;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_DatosClienteVenta` (IN `vdocumento` VARCHAR(20))  begin
  select cliente.nombre_razon, cliente.direccion from cliente
  where cliente.documento = CONVERT(vdocumento using utf8) collate utf8_spanish_ci;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_DatosExisteProveedor` (IN `vrazonsocial` VARCHAR(100))  begin
  select proveedor.codigoProv, proveedor.razon_social, proveedor.ruc from proveedor where proveedor.razon_social = CONVERT(vrazonsocial using utf8) collate utf8_spanish_ci;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_DatosproductoCodigo` (IN `vcodigo` VARCHAR(20) CHARSET utf8)  begin
  select producto.idproducto, producto.codigoBarras,
       producto.descripcion, producto.stock, producto.preciosugerido
  from producto where producto.codigoBarras = CONVERT(vcodigo using utf8) collate utf8_spanish_ci;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_DocCompra_ListarFecha` (IN `VFechaInicio` VARCHAR(30), IN `VFechaFinal` VARCHAR(30))  SELECT cc.numero_comprobante as 'Nmr Comprobante',
tc.tipo_comprobante as 'Tipo Comprobante',
p2.nombreProv as 'Nombre proveedor',
cc.estado as 'Estado de pago',
fdp.nombreforma_pago as 'Forma de pago' ,
cc.fecha_hora_compra as 'Fecha y hora',
u.nombre as 'Nombre usuario',
p.descripcion as 'Nombre producto',
pl.cantidad as 'Cantidad lote',

dc.preciocompraunitario as 'Precio compra unitario',
cc.subtotal as 'Subtotal',
cc.DatoIGV as 'IGV',
cc.totalpagado as 'Total pagado',
tm.tipo as 'Tipo moneda'
FROM comprobante_compra as cc inner join detalle_compra as dc on cc.numero_comprobante=dc.numero_comprobante
inner join tipocomprobante as tc ON cc.idtipoComprobante=tc.idtipoComprobante
  inner join forma_de_pago fdp on cc.idforma_pago = fdp.idforma_pago
inner join  proveedor p2 on cc.codigoProv = p2.codigoProv
inner join producto_lote pl on dc.idproducto_lote = pl.idproducto_lote
  inner join producto p on pl.idproducto = p.idproducto
inner join usuario u on cc.idusuario = u.idusuario
inner join tipo_moneda tm on cc.tipomoneda = tm.idtipomoneda
WHERE
date(cc.fecha_hora_compra) between str_to_date(VFechaInicio,'%d/%m/%Y') and str_to_date(VFechaFinal,'%d/%m/%Y')$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_DocVenta_ListarFecha` (IN `vFechaInicio` VARCHAR(30), IN `vFechaFinal` VARCHAR(30))  SELECT cv.numero_comprobante,
tc.tipo_comprobante as 'Tipo Comprobante',
c.nombre_razon as 'Nombre o razón',
cv.estado as 'Estado de pagado',
cv.fecha_hora_venta as 'Fecha y hora',
p.descripcion as 'Nombre producto',
dv.cantidad as 'Cantidad',
dv.precioventaunitario as 'Precio Unitario',
cv.subtotal as 'Sub Total', 
cv.DatoIGV as 'IGV',
cv.totalpagado as 'Total pagado',
tm.tipo as 'Tipo de moneda',
u.nombre as 'Nombre usuario caja',
u.nombre as 'Nombre usuario venta'
FROM comprobante_venta as cv inner join detalle_venta as dv on cv.numero_comprobante=dv.numero_comprobante
inner join tipocomprobante as tc ON cv.idtipoComprobante=tc.idtipoComprobante
inner join  cliente c on cv.idcliente = c.idCliente
inner join producto p on dv.idproducto = p.idproducto
inner join usuario u on cv.idUsuario_caja = u.idusuario and cv.idUsuario_venta=u.idusuario
inner join tipo_moneda tm on cv.idtipomoneda = tm.idtipomoneda where  date(cv.fecha_hora_venta) between str_to_date(vFechaInicio,'%d/%m/%Y')  and str_to_date(vFechaFinal,'%d/%m/%Y')$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_DV_ObtenerUltimoDoc` (IN `VidtipoComprobante` INT, IN `VLetra` VARCHAR(1) CHARSET utf8)  NO SQL
SELECT numero_comprobante FROM `comprobante_venta` WHERE idtipoComprobante=VidtipoComprobante and LEFT(numero_comprobante,1)=CONVERT(VLetra using utf8) collate utf8_spanish_ci ORDER BY numero_comprobante DESC LIMIT 1$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_DV_ObtenerUltimoDoc_Compra` (IN `VidtipoComprobante` INT, IN `VLetra` VARCHAR(1) CHARSET utf8)  NO SQL
SELECT numero_comprobante FROM `comprobante_compra` WHERE idtipoComprobante=VidtipoComprobante and LEFT(numero_comprobante,1)=CONVERT(VLetra using utf8) collate utf8_spanish_ci ORDER BY numero_comprobante DESC LIMIT 1$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_EliminarDireccionProveedor` (IN `vdireccion` VARCHAR(300), IN `vruc` VARCHAR(20))  begin
  declare vidproveedor int;
  declare viddireccion int;
  select codigoProv from proveedor p where p.ruc = CONVERT(vruc using utf8) collate utf8_spanish_ci into vidproveedor;
  select iddireccionProveedor from direccionproveedor where direccion = CONVERT(vdireccion using utf8) collate utf8_spanish_ci into viddireccion;
  update direccionproveedor set estado = '99'
  where direccionproveedor.iddireccionProveedor = CONVERT(viddireccion using utf8) collate utf8_spanish_ci and direccionproveedor.codigoProv = CONVERT(vidproveedor using utf8) collate utf8_spanish_ci;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_EliminarTelefonosProveedor` (IN `vnumeroTelefono` VARCHAR(20), IN `vnombreTipoTelefono` VARCHAR(150), IN `vruc` VARCHAR(20))  begin
  declare vidproveedor int;
  declare vidtelefono int;
  declare vitipotelefono int;
  select codigoProv from proveedor p where p.ruc = CONVERT(vruc using utf8) collate utf8_spanish_ci into vidproveedor;
  select telefonoproveedor.idtelefonoProveedor from telefonoproveedor where telefonoproveedor.numeroTelefono = CONVERT(vnumeroTelefono using utf8) collate utf8_spanish_ci into vidtelefono;
  select tipotelefono.idTipoTelefono from tipotelefono where tipotelefono.nombreTipoTelefono = CONVERT(vnombreTipoTelefono using utf8) collate utf8_spanish_ci into  vitipotelefono;
  update telefonoproveedor set estado = '99'
  where telefonoproveedor.codigoProv = vidproveedor
    and telefonoproveedor.idtelefonoProveedor = vidtelefono
    and telefonoproveedor.idTipoTelefono = vitipotelefono;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Eliminar_Cargo` (IN `vidcargo` INT)  NO SQL
DELETE from cargos WHERE cargos.idcargo=CONVERT(vidcargo using utf8) collate utf8_spanish_ci$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Eliminar_Comprobante_Compra` (IN `vcomprobante` VARCHAR(20))  begin
  declare _cantidad_productos int;
  declare _idproducto int;
  declare _stock int;
  declare _stock_anterior int;
  DECLARE fin INTEGER DEFAULT 0;

  DECLARE runners_cursor CURSOR FOR
    select idproducto, cantidad
    from detalle_compra
           inner join producto_lote pl on detalle_compra.idproducto_lote = pl.idproducto_lote
    where numero_comprobante = CONVERT(vcomprobante using utf8) collate utf8_spanish_ci;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin = 1;

  select count(*)
  from detalle_compra
         inner join producto_lote pl on detalle_compra.idproducto_lote = pl.idproducto_lote
  where numero_comprobante = CONVERT(vcomprobante using utf8) collate utf8_spanish_ci into _cantidad_productos;

  OPEN runners_cursor;
  get_runners:
    LOOP
      FETCH runners_cursor INTO _idproducto, _stock;
      IF fin = 1 THEN
        LEAVE get_runners;
      END IF;
      select stock
      from producto
      where idproducto = _idproducto into _stock_anterior;
            update producto set stock=_stock_anterior-_stock where idproducto=_idproducto;

    END LOOP get_runners;

  CLOSE runners_cursor;
  update comprobante_compra set estado='Devuelto' where numero_comprobante = CONVERT(vcomprobante using utf8) collate utf8_spanish_ci;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Eliminar_Detalle_Compra` (IN `vidprodlote` INT, IN `vnumcomprobante` VARCHAR(20))  begin
  DECLARE _idproducto int;
  DECLARE _cantidad int;

  delete FROM detalle_compra where idproducto_lote = vidprodlote and numero_comprobante = CONVERT(vnumcomprobante using utf8) collate utf8_spanish_ci;
  select idproducto, cantidad
  from producto_lote
  where idproducto_lote = vidprodlote into _idproducto,_cantidad;
  delete from producto_lote where idproducto_lote = vidprodlote;
  update producto
  set stock = stock - _cantidad
  where idproducto = _idproducto;
  call Proc_Actualizar_Total_Subtotal_Compra(CONVERT(vnumcomprobante using utf8) collate utf8_spanish_ci);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Eliminar_Detalle_Venta` (IN `viddetalleventa` INT)  begin

  declare _nroComprobante varchar(20);
  declare _idproducto int;
  declare _cantidad int;

  select numero_comprobante, idproducto, cantidad
  from detalle_venta
  where iddetalle_venta = viddetalleventa into _nroComprobante,_idproducto,_cantidad;

  update producto set  stock = stock+_cantidad where idproducto=_idproducto;

  delete from detalle_venta where iddetalle_venta=viddetalleventa;

  call Proc_Actualizar_Total_Subtotal_Venta(CONVERT(_nroComprobante using utf8) collate utf8_spanish_ci);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Eliminar_Detalle_Venta1` (IN `viddetalleventa` INT)  begin

  declare _nroComprobante varchar(20);
  declare _idproducto int;
  declare _cantidad int;

  select numero_comprobante, idproducto, cantidad
  from detalle_venta
  where iddetalle_venta = viddetalleventa into _nroComprobante,_idproducto,_cantidad;

  update producto set  stock = stock+_cantidad where idproducto=_idproducto;

  delete from detalle_venta where iddetalle_venta=viddetalleventa;

  call Proc_Actualizar_Total_Subtotal(CONVERT(_nroComprobante using utf8) collate utf8_spanish_ci, 0);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_ExisteDireccion` (IN `vruc` VARCHAR(20), IN `vdireccion` VARCHAR(300))  begin
  select count(*) from direccionproveedor inner join Proveedor
  where Proveedor.codigoProv = direccionproveedor.codigoProv
    and direccionproveedor.direccion = CONVERT(vdireccion using utf8) collate utf8_spanish_ci and Proveedor.ruc = CONVERT(vruc using utf8) collate utf8_spanish_ci;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_ExisteProveedor` (IN `vrazonsocial` VARCHAR(100))  begin
  select count(*) from proveedor where proveedor.razon_social = CONVERT(vrazonsocial using utf8) collate utf8_spanish_ci;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_IngresarUsuario` (IN `vnombre` VARCHAR(80), IN `vapellido` VARCHAR(80), IN `vdocumento` VARCHAR(20), IN `vtipodoc` INT, IN `vfecha_nac` VARCHAR(20), IN `vcargo` INT, IN `vdireccion` VARCHAR(150), IN `vobservacion` VARCHAR(300), IN `vestado` VARCHAR(2))  NO SQL
    DETERMINISTIC
BEGIN
        IF(vobservacion = '') THEN
    INSERT INTO usuario(
        nombre,
        apellido,
        documento,
        idtipo_doc_usuario,
        fecha_nac,
        idcargo,
        direccion,
         estado,	
        fecha_registro
    )
VALUE
    (
        vnombre,
        vapellido,
        vdocumento,
        vtipodoc,
        vfecha_nac,
        vcargo,
        vdireccion,
        vestado,
        CAST(NOW() AS DATE));
        ELSE
    INSERT INTO usuario(
        nombre,
        apellido,
        documento,
        idtipo_doc_usuario,
        fecha_nac,
        idcargo,
        direccion,
       estado,
        observacion,
        fecha_registro
    )
VALUE
    (
        vnombre,
        vapellido,
        vdocumento,
        vtipodoc,
        vfecha_nac,
        vcargo,
        vdireccion,
     vestado,
        vobservacion,
        CAST(NOW() AS DATE));
    END IF;
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Ingresar_ComprobanteCompra` (IN `vcomprobanteCompra` VARCHAR(20), IN `vidtipocomprobante` VARCHAR(50), IN `vrazon` VARCHAR(100), IN `vidusuario` INT, IN `vformadepago` VARCHAR(80), IN `vigv` DOUBLE, IN `vtipomoneda` VARCHAR(30))  begin
  insert into comprobante_compra(numero_comprobante, idtipoComprobante, codigoProv, fecha_hora_compra, idusuario,
                                 totalpagado, idforma_pago, subtotal, DatoIGV, tipomoneda)
  values (vcomprobanteCompra,
          (select idtipoComprobante from tipocomprobante where tipo_comprobante = CONVERT(vidtipocomprobante using utf8) collate utf8_spanish_ci),
          (select codigoProv from proveedor where razon_social = CONVERT(vrazon using utf8) collate utf8_spanish_ci),
          now(),
          vidusuario,
          0,
          (select idforma_pago from forma_de_pago where nombreforma_pago = CONVERT(vformadepago using utf8) collate utf8_spanish_ci),
          0,
          vigv,
          (select idtipomoneda from tipo_moneda where tipo = CONVERT(vtipomoneda using utf8) collate utf8_spanish_ci));
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Ingresar_ComprobanteVenta` (IN `vnumComprobante` VARCHAR(20), IN `vidtipoComprobante` VARCHAR(50), IN `vdocumento_cliente` VARCHAR(20), IN `vidusuario_caja` INT, IN `vidusuario_venta` INT, IN `vtipomoneda` VARCHAR(30), IN `vigv` DOUBLE)  begin
  
if((select count(*) from comprobante_venta where numero_comprobante=CONVERT(vnumComprobante using utf8) collate utf8_spanish_ci)=0) then 
  insert into comprobante_venta(numero_comprobante, idtipoComprobante, idcliente, fecha_hora_venta, totalpagado,
                                idUsuario_caja, idUsuario_venta, subtotal, idtipomoneda, DatoIGV)
  values (vnumComprobante,
          (select idtipoComprobante from tipocomprobante where tipo_comprobante = CONVERT(vidtipoComprobante using utf8) collate utf8_spanish_ci),
          (select idcliente from cliente where documento = CONVERT(vdocumento_cliente using utf8) collate utf8_spanish_ci),
          now(),
          0,
          (select idusuario from user_pass where iduser_pass=vidusuario_caja),
          (select idusuario from user_pass where iduser_pass=vidusuario_venta),
          0,
          (select idtipomoneda from tipo_moneda where tipo = CONVERT(vtipomoneda using utf8) collate utf8_spanish_ci),
          vigv);
end if;
  
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Ingresar_ComprobanteVenta_R` (IN `vnumComprobante` VARCHAR(20), IN `vidtipoComprobante` VARCHAR(50), IN `vdocumento_cliente` VARCHAR(20), IN `vidusuario_caja` INT, IN `vidusuario_venta` INT, IN `vtipomoneda` VARCHAR(30), IN `vigv` DOUBLE, IN `totalpagado` DOUBLE, IN `subtotal` DOUBLE)  begin
  
if((select count(*) from comprobante_venta where numero_comprobante=vnumComprobante)=0) then
  insert into comprobante_venta(numero_comprobante, idtipoComprobante, idcliente, fecha_hora_venta, totalpagado,
                                idUsuario_caja, idUsuario_venta, subtotal, idtipomoneda, DatoIGV)
  values (vnumComprobante,
          (select idtipoComprobante from tipocomprobante where tipo_comprobante = CONVERT(vidtipoComprobante using utf8) collate utf8_spanish_ci),
          (select idcliente from cliente where documento = CONVERT(vdocumento_cliente using utf8) collate utf8_spanish_ci),
          now(),
          totalpagado,
          (select idusuario from user_pass where iduser_pass=vidusuario_caja),
          (select idusuario from user_pass where iduser_pass=vidusuario_venta),
          subtotal,
          (select idtipomoneda from tipo_moneda where tipo = CONVERT(vtipomoneda using utf8) collate utf8_spanish_ci),
          vigv);
end if;
  
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Ingreso_Cliente` (IN `vnombre_ruc` VARCHAR(20), IN `vdocumento` VARCHAR(20), IN `vtipodocusuario` VARCHAR(20), IN `vdireccion` VARCHAR(300), IN `vobservacion` VARCHAR(300), IN `vemail` VARCHAR(150), IN `vtelefono` VARCHAR(30), IN `vidtipocliente` INT)  begin
  insert into cliente (nombre_razon, documento, idtipo_doc_usuario, direccion, observacion, email,
                       telefono, idtipo_cliente)
  values (vnombre_ruc, vdocumento, (select idtipo_doc_usuario from tipo_doc_usuario where nombre = CONVERT(vtipodocusuario using utf8) collate utf8_spanish_ci),
          vdireccion, vobservacion, vemail, vtelefono, vidtipocliente);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Ingreso_Compra_Detalle` (IN `vcodBarra` VARCHAR(20), IN `vcantidadLote` INT, IN `vcantidadPresentacion` INT, IN `vpreciounitario` DOUBLE, IN `vnumerocomprobante` VARCHAR(20), IN `vunidadmedida` VARCHAR(30), IN `vfecha_vencimiento` VARCHAR(15), IN `vpreciosugerido` DOUBLE)  begin
  declare _idproducto int;
  declare _idproductolote int;
  declare _subtotal double;
  declare _totalpagado double;
  declare _stock int;
  declare _igv double;
  declare _cantidad int;

  select idproducto_lote
  from producto_lote
  order by idproducto_lote desc
  limit 1 into _idproductolote;

  set _cantidad=vcantidadPresentacion*vcantidadLote;
  set _idproductolote = _idproductolote+1;

  insert into producto_lote(idproducto_lote, idproducto, cantidad, fechavencimiento, cantidadLote, cantidadPresentacion,idunidadmedida)
  values (_idproductolote, (select idproducto from producto where codigoBarras = CONVERT(vcodBarra using utf8) collate utf8_spanish_ci),
          _cantidad, vfecha_vencimiento,vcantidadLote,vcantidadPresentacion,(select idunidadmedida from unidad_medida where unidad=CONVERT(vunidadmedida using utf8) collate utf8_spanish_ci));

  select idproducto from producto_lote where idproducto_lote = _idproductolote into _idproducto;
  select stock from producto where idproducto = _idproducto into _stock;
  select subtotal, totalpagado, DatoIGV
  from comprobante_compra
  where numero_comprobante = CONVERT(vnumerocomprobante using utf8) collate utf8_spanish_ci into _subtotal,_totalpagado,_igv;


  insert into detalle_compra(idproducto_lote, preciocompraunitario, numero_comprobante)
  VALUES (_idproductolote, vpreciounitario, vnumerocomprobante);

  update producto set stock=_stock + _cantidad, preciosugerido=vpreciosugerido where idproducto = _idproducto;

  update comprobante_compra
  set subtotal=round((_subtotal + (_cantidad * vpreciounitario)), 2),
      totalpagado =round((_totalpagado + (_cantidad * vpreciounitario + (_cantidad * vpreciounitario * _igv / 100))), 2)
  where numero_comprobante = CONVERT(vnumerocomprobante using utf8) collate utf8_spanish_ci;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Ingreso_Producto_Lote` (IN `vdescripcion` VARCHAR(80), IN `vcantidad` INT, IN `vfecha_vencimiento` VARCHAR(20), IN `vcantidadPresentacion` INT, IN `vidunidadmedida` VARCHAR(30), IN `vcantidadLote` INT)  begin
  declare a int;
  select stock from producto where descripcion=CONVERT(vdescripcion using utf8) collate utf8_spanish_ci limit 1 into a;
  set a=a+vcantidad;
  insert into producto_lote (idproducto, cantidad, fechavencimiento,cantidadLote,cantidadPresentacion,idunidadmedida)
  values ((select idproducto from producto where descripcion = CONVERT(vdescripcion using utf8) collate utf8_spanish_ci),
          vcantidad,
          vfecha_vencimiento,
         vcantidadLote,vcantidadPresentacion,
         (SELECT idunidadmedida from unidad_medida WHERE unidad=CONVERT(vidunidadmedida using utf8) collate utf8_spanish_ci));

  update producto set stock = a where descripcion=CONVERT(vdescripcion using utf8) collate utf8_spanish_ci;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Ingreso_Venta_Detalle` (IN `vcodBarra` VARCHAR(20), IN `vcantidad` INT, IN `vprecioventa` DOUBLE, IN `vnumerocomprobante` VARCHAR(20))  begin

  declare _getStock int;
  declare _subtotal double;
  declare _totalpagado double;
  declare _igv double;
  declare _idproducto int;
  declare _existe int;
  declare _cantidad_anterior int;

  select idproducto from producto where codigoBarras = CONVERT(vcodBarra using utf8) collate utf8_spanish_ci into _idproducto;

  select stock from producto where idproducto = _idproducto into _getStock;

  update producto set stock=_getStock - vcantidad where idproducto = _idproducto;

  select count(*)
  from detalle_venta
  where idproducto = _idproducto
    and numero_comprobante = CONVERT(vnumerocomprobante using utf8) collate utf8_spanish_ci into _existe;

  if(_existe=0) then
    insert into detalle_venta(numero_comprobante, idproducto, cantidad, precioventaunitario)
  values (vnumerocomprobante, _idproducto, vcantidad, vprecioventa);
  else
    select cantidad from detalle_venta where idproducto = _idproducto
    and numero_comprobante = CONVERT(vnumerocomprobante using utf8) collate utf8_spanish_ci into _cantidad_anterior;
    update detalle_venta set cantidad= _cantidad_anterior+vcantidad, precioventaunitario=vprecioventa where idproducto = _idproducto
    and numero_comprobante = CONVERT(vnumerocomprobante using utf8) collate utf8_spanish_ci;
  end if;


  select subtotal, totalpagado, DatoIGV
  from comprobante_venta
  where numero_comprobante = CONVERT(vnumerocomprobante using utf8) collate utf8_spanish_ci into _subtotal,_totalpagado,_igv;
  set _subtotal = _subtotal + (vcantidad * vprecioventa);
  if ((select idtipoComprobante from comprobante_venta where numero_comprobante = CONVERT(vnumerocomprobante using utf8) collate utf8_spanish_ci) =
      (select idtipoComprobante from tipocomprobante where tipo_comprobante = 'Nota de venta')) then

    set _totalpagado = round((_totalpagado + (vcantidad * vprecioventa)), 2);
  else
    set _totalpagado = round((_totalpagado +
                              (vcantidad * vprecioventa + (vcantidad * vprecioventa * (select DatoIGV
                                                                                       from comprobante_venta
                                                                                       where numero_comprobante = CONVERT(vnumerocomprobante using utf8) collate utf8_spanish_ci) /
                                                           100))), 2);
  end if;
  update comprobante_venta
  set totalpagado=_totalpagado, subtotal=_subtotal
  where numero_comprobante = CONVERT(vnumerocomprobante using utf8) collate utf8_spanish_ci;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Ingreso_Venta_Detalle1` (IN `vcodBarra` VARCHAR(20), IN `vcantidad` INT, IN `vprecioventa` DOUBLE, IN `vnumerocomprobante` VARCHAR(20))  begin

  declare _getStock int;
  declare _idproducto int;
  declare _existe int;
  declare _cantidad_anterior int;

  select idproducto from producto where codigoBarras = CONVERT(vcodBarra using utf8) collate utf8_spanish_ci into _idproducto;

  select stock from producto where idproducto = _idproducto into _getStock;

  update producto set stock=_getStock - vcantidad where idproducto = _idproducto;

  select count(*)
  from detalle_venta
  where idproducto = _idproducto
    and numero_comprobante = CONVERT(vnumerocomprobante using utf8) collate utf8_spanish_ci into _existe;

  if(_existe=0) then
    insert into detalle_venta(numero_comprobante, idproducto, cantidad, precioventaunitario)
  values (vnumerocomprobante, _idproducto, vcantidad, vprecioventa);
  else
    select cantidad from detalle_venta where idproducto = _idproducto
    and numero_comprobante = CONVERT(vnumerocomprobante using utf8) collate utf8_spanish_ci into _cantidad_anterior;
    update detalle_venta set cantidad= _cantidad_anterior+vcantidad, precioventaunitario=vprecioventa where idproducto = _idproducto
    and numero_comprobante = CONVERT(vnumerocomprobante using utf8) collate utf8_spanish_ci;
  end if;


  call Proc_Actualizar_Total_Subtotal(CONVERT(vnumerocomprobante using utf8) collate utf8_spanish_ci, 0);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Ingreso_Venta_Detalle_2` (IN `vcodBarra` VARCHAR(20), IN `vcantidad` INT, IN `vprecioventa` DOUBLE, IN `vnumerocomprobante` VARCHAR(20))  BEGIN DECLARE _getStock INT; DECLARE _idproducto INT; DECLARE _existe INT; DECLARE _cantidad_anterior INT;
SELECT
    idproducto
FROM
    producto
WHERE
    codigoBarras = CONVERT(vcodBarra using utf8) collate utf8_spanish_ci
INTO
    _idproducto;
SELECT
    stock
FROM
    producto
WHERE
    idproducto = _idproducto
INTO
    _getStock;
UPDATE
    producto
SET
    stock = _getStock - vcantidad
WHERE
    idproducto = _idproducto;
SELECT
    COUNT(*)
FROM
    detalle_venta
WHERE
    idproducto = _idproducto AND numero_comprobante = CONVERT(vnumerocomprobante using utf8) collate utf8_spanish_ci
INTO
    _existe; IF(_existe = 0) THEN
INSERT
INTO
    detalle_venta(
        numero_comprobante,
        idproducto,
        cantidad,
        precioventaunitario
    )
VALUES(
    vnumerocomprobante,
    _idproducto,
    vcantidad,
    vprecioventa
); ELSE
SELECT
    cantidad
FROM
    detalle_venta
WHERE
    idproducto = _idproducto AND numero_comprobante = CONVERT(vnumerocomprobante using utf8) collate utf8_spanish_ci
INTO
    _cantidad_anterior;
UPDATE
    detalle_venta
SET
    cantidad = _cantidad_anterior + vcantidad,
    precioventaunitario = vprecioventa
WHERE
    idproducto = _idproducto AND numero_comprobante = CONVERT(vnumerocomprobante using utf8) collate utf8_spanish_ci;
UPDATE
    producto
SET
    stock = 1000
WHERE
    codigoBarras = '000'; END IF;
CALL
    Proc_Actualizar_Total_Subtotal(CONVERT(vnumerocomprobante using utf8) collate utf8_spanish_ci, 0); END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Ingreso_Venta_Detalle_R` (IN `Vnumero_comprobante` VARCHAR(20) CHARSET utf8, IN `VcodigoBarras` VARCHAR(20) CHARSET utf8, IN `Vcantidad` INT, IN `Vprecioventaunitario` DOUBLE)  NO SQL
INSERT INTO detalle_venta(numero_comprobante, idproducto, cantidad, precioventaunitario)
VALUES (Vnumero_comprobante
        ,(select idproducto from producto where codigoBarras = CONVERT(VcodigoBarras using utf8) collate utf8_spanish_ci)
        ,Vcantidad
        ,Vprecioventaunitario)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Insertar_Cargo` (IN `vnombre` VARCHAR(30))  NO SQL
    DETERMINISTIC
INSERT INTO cargos(nombre) VALUES (vnombre)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Insertar_FuncionxCargo` (IN `vidcargo` INT, IN `vidfuncion` INT)  insert into funciones_por_cargo (idcargo, idfuncion) values (vidcargo,vidfuncion)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Linea_Ingresar` (IN `vlinea` VARCHAR(50))  begin
  insert into linea(nombreLinea) values (vlinea);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_ListarClientes` ()  begin
  select cliente.idCliente,
         cliente.nombre_razon,
         cliente.documento,
         tipo_doc_usuario.nombre,
         cliente.fecha_nacimiento,
         cliente.direccion,
         cliente.email,
         cliente.telefono,
         cliente.observacion,
         tipo_cliente.tipo
  from cliente
  inner join tipo_doc_usuario ON cliente.idtipo_doc_usuario = tipo_doc_usuario.idtipo_doc_usuario
  inner join tipo_cliente ON cliente.idtipo_cliente = tipo_cliente.idtipo_cliente;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_ListarClientesPorTipo` (IN `vidtipocliente` INT)  begin
  select cliente.idCliente,
         cliente.nombre_razon,
         cliente.documento,
         tipo_doc_usuario.nombre,
         cliente.fecha_nacimiento,
         cliente.direccion,
         cliente.email,
         cliente.telefono,
         cliente.observacion
  from cliente inner join tipo_doc_usuario inner join tipo_cliente
  where cliente.idtipo_doc_usuario = tipo_doc_usuario.idtipo_doc_usuario and cliente.idtipo_cliente = tipo_cliente.idtipo_cliente and  cliente.idtipo_cliente = vidtipocliente;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_ListarDireccionProveedor` (IN `vruc` VARCHAR(20))  begin
  declare vidproveedor int;
  select proveedor.codigoProv from proveedor where proveedor.ruc = CONVERT(vruc using utf8) collate utf8_spanish_ci into vidproveedor;
  select dP.iddireccionProveedor, dP.direccion
  from direccionproveedor dP inner join proveedor p2 on dP.codigoProv = p2.codigoProv
  where p2.codigoProv = vidproveedor and dP.codigoProv = vidproveedor and dP.estado = '00';
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_ListarFunciones` ()  NO SQL
SELECT c.nombre, f.nombre from cargos c INNER JOIN funciones_por_cargo fc on c.idcargo=fc.idcargo INNER JOIN funciones f ON  f.idfuncion=fc.idfuncion$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_ListarLinea` ()  begin
  select idlinea, nombreLinea from linea;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_ListarMarca` ()  begin
  SELECT idmarca as id,nombremarca as nombre from marca;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_ListarproductoStock` ()  begin
  select producto.idproducto, producto.codigoBarras,
       producto.descripcion, producto.stock, producto.preciosugerido
  from producto;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_ListarTelefonoProveedor` (IN `vruc` VARCHAR(20))  begin
  declare vidproveedor int;
  select proveedor.codigoProv from proveedor where proveedor.ruc = CONVERT(vruc using utf8) collate utf8_spanish_ci into vidproveedor;
  select tF.idtelefonoProveedor, tF.numeroTelefono, tT.nombreTipoTelefono
  from telefonoproveedor tF inner join tipotelefono tT on tF.idTipoTelefono = tT.idTipoTelefono
  inner join proveedor p on tF.codigoProv = p.codigoProv
  where p.codigoProv = vidproveedor AND  tF.estado = '00';
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_ListarTipoMoneda` ()  begin
  select tipo_moneda.idtipomoneda, tipo_moneda.tipo from tipo_moneda;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_ListarTipoTelefonoProveedor` ()  begin
  select idTipoTelefono, nombreTipoTelefono from tipotelefono;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Listar_Categoria` ()  begin
  select idcategoria as id,nombreCategoria as nombre from categoria;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Listar_Categoria_Linea` (IN `vnombrelinea` VARCHAR(50))  begin
  declare vidlinea varchar(50);
  select linea.idlinea from linea where linea.nombreLinea = CONVERT(vnombrelinea using utf8) collate utf8_spanish_ci into vidlinea;
  select categoria.idcategoria, categoria.nombreCategoria from categoria where categoria.idlinea = vidlinea;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Listar_DatosPorId` (IN `vidato` INT)  begin
  select datos.iddatos, datos.descripcion, datos.dato from datos where datos.iddatos = vidato;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Listar_Detalle_compra` (IN `vnumcomprobante` VARCHAR(30))  SELECT cc.numero_comprobante             as 'Nmr Comprobante',
       p2.nombreProv                     as 'Nombre proveedor',
       p.descripcion                     as 'Nombre producto',
       pl.cantidad                       as 'Cantidad lote',
       dc.preciocompraunitario           as 'Precio compra unitario',
       p.preciosugerido                  as 'Precio sugerido',
       (cantidad * preciocompraunitario) as Importe,
       pl.idproducto_lote                as idLote,
       pl.cantidadLote                   as 'Cantidad Lote',
       pl.cantidadPresentacion           as 'Cantidad Presentacion',
       um.unidad                         as 'Unidad Medida',
       p.codigoBarras                    as 'Cod. Barras'

FROM comprobante_compra as cc
       inner join detalle_compra as dc
       inner join tipocomprobante as tc ON cc.idtipoComprobante = tc.idtipoComprobante
       inner join forma_de_pago fdp on cc.idforma_pago = fdp.idforma_pago
       inner join proveedor p2 on cc.codigoProv = p2.codigoProv
       inner join producto_lote pl on dc.idproducto_lote = pl.idproducto_lote
       inner join producto p on pl.idproducto = p.idproducto
       inner join tipo_moneda tm on cc.tipomoneda = tm.idtipomoneda
       inner join unidad_medida um on p.idunidad_medida = um.idunidadmedida
where cc.numero_comprobante = dc.numero_comprobante
  and dc.numero_comprobante = CONVERT(vnumcomprobante using utf8) collate utf8_spanish_ci$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Listar_Detalle_venta` (IN `vnumcomprobante` VARCHAR(20))  begin 
  select codigoBarras,descripcion,cantidad,precioventaunitario,(cantidad*precioventaunitario) as Importe,iddetalle_venta
from comprobante_venta
       inner join detalle_venta
inner join producto p on detalle_venta.idproducto = p.idproducto
where detalle_venta.numero_comprobante = comprobante_venta.numero_comprobante
  and detalle_venta.numero_comprobante = CONVERT(vnumcomprobante using utf8) collate utf8_spanish_ci;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Listar_Empresas` ()  begin
  SELECT empresa.idEmpresa, empresa.nombreEmpresa, empresa.razonSocial, empresa.ruc, empresa.direccion, empresa.telefono, empresa.email, empresa.slogan, empresa.abreviatura, empresa.alias from empresa;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Listar_FuncionxCargo` (IN `vidcargo` INT, IN `vEstado` VARCHAR(2))  NO SQL
SELECT fc.idcargo,
		fc.idfuncion, 
        c.nombre,
        f.nombre 
from cargos as c 
inner join funciones as f 
inner join funciones_por_cargo as fc
where c.idcargo=fc.idcargo and f.idfuncion=fc.idfuncion and c.idcargo=vidcargo and fc.estado=CONVERT(vEstado using utf8) collate utf8_spanish_ci$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Listar_Linea_Categoria` ()  begin 
select c.idlinea,idcategoria,nombreLinea,nombreCategoria
from linea inner join categoria c on linea.idlinea = c.idlinea;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Listar_Producto` (IN `vtipoLista` INT)  begin
  if vtipoLista = 0 then
    select p.idproducto,
           codigoBarras,
           descripcion,
           unidad          as UnidadMedida,
           cantidad,
           nombreCategoria as Categoria,
           nombremarca     as Marca,
           preciosugerido,
           fechavencimiento,
           idproducto_lote
    from producto p
           inner join categoria c on p.idcategoria = c.idcategoria
           inner join marca m on p.idmarca = m.idmarca
           inner join unidad_medida um on p.idunidad_medida = um.idunidadmedida
           inner join linea l on c.idlinea = l.idlinea
           inner join producto_lote pl on p.idproducto = pl.idproducto
    order by l.nombreLinea, Categoria, descripcion, fechavencimiento;
  else
    select p.idproducto,
           codigoBarras,
           descripcion,
           unidad          as UnidadMedida,
           cantidad,
           nombreCategoria as Categoria,
           nombremarca     as Marca,
           preciosugerido,
           fechavencimiento,
           idproducto_lote
    from producto p
           inner join categoria c on p.idcategoria = c.idcategoria
           inner join marca m on p.idmarca = m.idmarca
           inner join unidad_medida um on p.idunidad_medida = um.idunidadmedida
           inner join producto_lote pl on p.idproducto = pl.idproducto
           inner join linea l on c.idlinea = l.idlinea
    where cantidad > 0
    order by l.nombreLinea, Categoria, descripcion, fechavencimiento;
  end if;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Listar_Producto_Compras` (IN `vtipoLista` INT)  begin
  if vtipoLista = 0 then
  select p.idproducto,
           p.codigoBarras,
           p.descripcion,
           um.unidad          as UnidadMedida,
           p.stock,
           c.nombreCategoria as Categoria,
           m.nombremarca     as Marca,
           p.preciosugerido
          
    from producto p
           inner join categoria c on p.idcategoria = c.idcategoria
           inner join marca m on p.idmarca = m.idmarca
           inner join unidad_medida um on p.idunidad_medida = um.idunidadmedida
           inner join linea l on c.idlinea = l.idlinea
           
    order by l.nombreLinea, c.nombreCategoria, p.descripcion;
  else
   select p.idproducto,
           p.codigoBarras,
           p.descripcion,
           um.unidad          as UnidadMedida,
           p.stock,
           c.nombreCategoria as Categoria,
           m.nombremarca     as Marca,
           p.preciosugerido
     from producto p
           inner join categoria c on p.idcategoria = c.idcategoria
           inner join marca m on p.idmarca = m.idmarca
           inner join unidad_medida um on p.idunidad_medida = um.idunidadmedida
           inner join linea l on c.idlinea = l.idlinea
    where p.stock > 0
    order by l.nombreLinea, c.nombreCategoria, p.descripcion;
  end if;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Listar_Proveedores` ()  begin
  select codigoProv, nombreProv, razon_social, ruc, email, contacto, telefonocontacto from proveedor;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Listar_Tipo_Doc_Usuario_Persona` ()  begin
  select tipo_doc_usuario.idtipo_doc_usuario, tipo_doc_usuario.nombre from tipo_doc_usuario;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Listar_Unidad_Medida` ()  begin
  select unidad_medida.idunidadmedida, unidad_medida.unidad from unidad_medida;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Listar_UserPass` (IN `VestadoUser` VARCHAR(2))  NO SQL
SELECT u.idusuario
  , concat(u.nombre,' ',u.apellido) as nombres
        ,u.documento
         ,tdu.nombre as 'tipo documento'
        ,u.idcargo
        ,c.nombre as 'cargo'
        ,u.direccion
        ,u.observacion
      
        ,up.idUser_pass
        ,up.username
        ,up.password
        
       
    FROM usuario AS u
INNER JOIN cargos AS c ON u.idcargo = c.idcargo
INNER JOIN tipo_doc_usuario AS tdu ON u.idtipo_doc_usuario=tdu.idtipo_doc_usuario
inner join user_pass up
 on u.idusuario=up.idusuario where up.estado=CONVERT(VestadoUser using utf8) collate utf8_spanish_ci$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Listar_usser` (IN `Vestado` VARCHAR(2))  NO SQL
SELECT u.idusuario
		, concat(u.nombre,' ',u.apellido) as nombres
        ,u.documento
         ,tdu.nombre as 'tipo documento'
        ,c.nombre as 'cargo'
        ,u.direccion
        ,u.observacion
        ,up.idUser_pass
        ,up.username
        ,up.password
        ,up.estado
    FROM usuario AS u
INNER JOIN cargos AS c ON u.idcargo = c.idcargo
INNER JOIN tipo_doc_usuario AS tdu ON u.idtipo_doc_usuario=tdu.idtipo_doc_usuario
inner join user_pass up
	on u.idusuario=up.idusuario where up.estado=CONVERT(Vestado using utf8) collate utf8_spanish_ci$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Listar_Usuario` (IN `vestado` VARCHAR(2))  NO SQL
SELECT u.idusuario
		,u.nombre
        ,u.apellido
        ,u.documento
        ,tdu.nombre as 'tipo documento'
        ,u.fecha_nac
        ,c.nombre as 'cargo'
        ,u.direccion
        ,u.observacion

FROM usuario AS u
INNER JOIN cargos AS c ON u.idcargo = c.idcargo
INNER JOIN tipo_doc_usuario AS tdu ON u.idtipo_doc_usuario=tdu.idtipo_doc_usuario where u.estado=CONVERT(vestado using utf8) collate utf8_spanish_ci$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_ModificarDireccionProveedor` (IN `vdireccionModificar` VARCHAR(300), IN `vruc` VARCHAR(20), IN `vdireccion` VARCHAR(300))  begin
  declare vidproveedor int;
  declare viddirecciones int;
  select proveedor.codigoProv from proveedor where proveedor.ruc = CONVERT(vruc using utf8) collate utf8_spanish_ci into vidproveedor;
  select dP2.iddireccionProveedor from direccionproveedor dP2 where dP2.direccion = CONVERT(vdireccion using utf8) collate utf8_spanish_ci into viddirecciones;
  update direccionproveedor set  direccionproveedor.direccion = CONVERT(vdireccionModificar using utf8) collate utf8_spanish_ci
  where codigoProv = vidproveedor and iddireccionProveedor = viddirecciones;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_ModificarLinea` (IN `vnombrelinea` VARCHAR(50), IN `vnombrelineaantiguo` VARCHAR(50))  begin
  declare vidlinea int;
  select linea.idlinea from linea where linea.nombreLinea=CONVERT(vnombrelineaantiguo using utf8) collate utf8_spanish_ci into vidlinea;
  update linea
  set linea.nombreLinea=vnombrelinea
    where linea.idlinea = vidlinea;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_ModificarTelefonosProveedor` (IN `vnumeroTelefonoModificar` VARCHAR(20), IN `vnombreTipoTelefonoModificar` VARCHAR(150), IN `vruc` VARCHAR(20), IN `vnumeroTelefono` VARCHAR(20))  begin
  declare vidproveedor int;
  declare vidtipotelefono int;
  declare vidnumero int;

  select proveedor.codigoProv from proveedor
  where proveedor.ruc = CONVERT(vruc using utf8) collate utf8_spanish_ci into vidproveedor;

  select tipotelefono.idTipoTelefono from tipotelefono
  where tipotelefono.nombreTipoTelefono = CONVERT(vnombreTipoTelefonoModificar using utf8) collate utf8_spanish_ci into vidtipotelefono;

  select idtelefonoProveedor from telefonoproveedor
  where telefonoproveedor.numeroTelefono = CONVERT(vnumeroTelefono using utf8) collate utf8_spanish_ci into vidnumero;

  update telefonoproveedor set  numeroTelefono = vnumeroTelefonoModificar, idTipoTelefono = vidtipotelefono
  where codigoProv = vidproveedor and  idtelefonoProveedor = vidnumero;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Modificar_Cargo` (IN `vidcargo` INT, IN `vnombre` VARCHAR(20))  NO SQL
UPDATE cargos SET cargos.nombre=CONVERT(vnombre using utf8) collate utf8_spanish_ci WHERE cargos.idcargo=vidcargo$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Modificar_Categoria` (IN `vnombreCategoria` VARCHAR(50), IN `vnombreCategoriaAntiguo` VARCHAR(50))  begin
  declare vidlinea int;
  declare vicategoria int;
  select categoria.idlinea from categoria where CONVERT(vnombreCategoriaAntiguo using utf8) collate utf8_spanish_ci=categoria.nombreCategoria into vidlinea;
  select categoria.idcategoria from categoria where CONVERT(vnombreCategoriaAntiguo using utf8) collate utf8_spanish_ci=categoria.nombreCategoria into vicategoria;
  update categoria
  set categoria.nombreCategoria = vnombreCategoria, categoria.idlinea = vidlinea
    where categoria.idcategoria=vicategoria;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Modificar_Cliente` (IN `vnombre_razon` VARCHAR(100), IN `vdocumento` VARCHAR(20), IN `vtipo_doc_usuario` VARCHAR(30), IN `vfecha_nacimiento` VARCHAR(20), IN `vdireccion` VARCHAR(150), IN `vemail` VARCHAR(50), IN `vtelefono` VARCHAR(20), IN `vobservacion` VARCHAR(300), IN `vidtipo_cliente` INT, IN `vdocumentoantiguo` VARCHAR(20))  begin
  declare vidcliente int;
  declare vidtipo_doc_usuario int;

  select tipo_doc_usuario.idtipo_doc_usuario
  from tipo_doc_usuario
  where tipo_doc_usuario.nombre = CONVERT(vtipo_doc_usuario using utf8) collate utf8_spanish_ci into vidtipo_doc_usuario;

  select cliente.idCliente
  from cliente
  where cliente.documento = CONVERT(vdocumentoantiguo using utf8) collate utf8_spanish_ci into vidcliente;

  update cliente
  set nombre_razon = vnombre_razon, documento = vdocumento, idtipo_doc_usuario = vidtipo_doc_usuario,
      fecha_nacimiento = vfecha_nacimiento, direccion = vdireccion, email = vemail, telefono = vtelefono,
      observacion = vobservacion, idtipo_cliente = vidtipo_cliente
    where cliente.idCliente = vidcliente;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Modificar_ComprobanteCompra` (IN `vcomprobanteCompra` VARCHAR(20), IN `vcomprobanteCompra_anterior` VARCHAR(20), IN `vidtipocomprobante` VARCHAR(50), IN `vcodProv` VARCHAR(100), IN `vformadepago` VARCHAR(80), IN `vigv` DOUBLE, IN `vtipomoneda` VARCHAR(30))  begin

  declare _nroComprobante varchar(20);

  if (vcomprobanteCompra_anterior = vcomprobanteCompra) then
    set _nroComprobante = CONVERT(vcomprobanteCompra_anterior using utf8) collate utf8_spanish_ci;
  else
    set _nroComprobante = vcomprobanteCompra;
    update detalle_compra
    set numero_comprobante=_nroComprobante
    where numero_comprobante = CONVERT(vcomprobanteCompra_anterior using utf8) collate utf8_spanish_ci;
    update comprobante_compra
    set numero_comprobante=_nroComprobante
    where numero_comprobante = CONVERT(vcomprobanteCompra_anterior using utf8) collate utf8_spanish_ci;

  end if;

  update comprobante_compra
  set idforma_pago=(select idforma_pago from forma_de_pago where nombreforma_pago = CONVERT(vformadepago using utf8) collate utf8_spanish_ci),
      idtipoComprobante=(select tipocomprobante.idtipoComprobante
                         from tipocomprobante
                         where tipo_comprobante = CONVERT(vidtipocomprobante using utf8) collate utf8_spanish_ci),
      codigoProv=(select codigoProv from proveedor where razon_social = CONVERT(vcodProv using utf8) collate utf8_spanish_ci),
      tipomoneda=(select idtipomoneda from tipo_moneda where tipo = CONVERT(vtipomoneda using utf8) collate utf8_spanish_ci),
      DatoIGV=vigv
  where numero_comprobante = CONVERT(_nroComprobante using utf8) collate utf8_spanish_ci;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Modificar_DatosPorId` (IN `viddato` INTEGER, IN `vnombredato` VARCHAR(200), IN `vvalordato` VARCHAR(50))  begin
  update datos
  set datos.descripcion = vnombredato, datos.dato = vvalordato
    where datos.iddatos = viddato;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Modificar_Detalle_Compra` (IN `vidproducto_lote` INT, IN `vcantidadLote` INT, IN `vcantidadPresentacion` INT, IN `vcodBarra` VARCHAR(20), IN `vunidadmedida` VARCHAR(30), IN `vpreciounitario` DOUBLE, IN `vnumerocomprobante` VARCHAR(20), IN `vfecha_vencimiento` VARCHAR(15), IN `vpreciosugerido` DOUBLE)  begin
  declare _stock int;
  declare _cantidad int;
  declare _idproducto int;

  select stock, cantidad, producto_lote.idproducto
  from producto_lote
         inner join producto p on producto_lote.idproducto = p.idproducto
  where producto_lote.idproducto_lote = vidproducto_lote into _stock,_cantidad,_idproducto;

  update producto set stock=_stock - _cantidad where idproducto = _idproducto;

  update producto_lote
  set idproducto=(select idproducto from producto where codigoBarras = CONVERT(vcodBarra using utf8) collate utf8_spanish_ci),
      cantidadLote=vcantidadLote,
      cantidadPresentacion=vcantidadPresentacion,
      idunidadmedida=(select idunidadmedida from unidad_medida where unidad = CONVERT(vunidadmedida using utf8) collate utf8_spanish_ci),
      fechavencimiento=vfecha_vencimiento
  where idproducto_lote = vidproducto_lote;

  update producto_lote
  set cantidad = cantidadPresentacion * cantidadLote
  where idproducto_lote = vidproducto_lote;

  select stock, cantidad, producto_lote.idproducto
  from producto_lote
         inner join producto p on producto_lote.idproducto = p.idproducto
  where producto_lote.idproducto_lote = vidproducto_lote into _stock,_cantidad,_idproducto;

  update producto set stock=_stock + _cantidad, preciosugerido=vpreciosugerido where idproducto = _idproducto;

  update detalle_compra
  set preciocompraunitario=vpreciounitario
  where idproducto_lote = vidproducto_lote
    and numero_comprobante = CONVERT(vnumerocomprobante using utf8) collate utf8_spanish_ci;

  call Proc_Actualizar_Total_Subtotal_Compra(CONVERT(vnumerocomprobante using utf8) collate utf8_spanish_ci);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Modificar_Detalle_Venta` (IN `vcodBarra` VARCHAR(20), IN `vcantidad` INT, IN `vcantidad_anterior` INT, IN `vprecioventa` DOUBLE, IN `vnumerocomprobante` VARCHAR(20), IN `vcodBarra_anterior` VARCHAR(20), IN `vprecioventa_anterior` DOUBLE)  begin

  declare _idproducto_anterior int;
  declare _stock int;
  declare _detalleventa int;

  select idproducto, stock from producto where codigoBarras = CONVERT(vcodBarra_anterior using utf8) collate utf8_spanish_ci into _idproducto_anterior,_stock;
  update producto set stock=_stock - vcantidad_anterior where idproducto = _idproducto_anterior;

  select iddetalle_venta
  from detalle_venta
  where numero_comprobante = CONVERT(vnumerocomprobante using utf8) collate utf8_spanish_ci
    and idproducto = _idproducto_anterior
    and cantidad = vcantidad_anterior
    and precioventaunitario = vprecioventa_anterior into _detalleventa;

  update detalle_venta
  set idproducto=(select idproducto from producto where codigoBarras = CONVERT(vcodBarra using utf8) collate utf8_spanish_ci),
      cantidad=vcantidad,
      precioventaunitario=vprecioventa
  where iddetalle_venta = _detalleventa;
  select idproducto, stock from producto where codigoBarras = CONVERT(vcodBarra using utf8) collate utf8_spanish_ci into _idproducto_anterior,_stock;
  update producto set stock=_stock + vcantidad where idproducto=_idproducto_anterior;

  call Proc_Actualizar_Total_Subtotal_Venta(CONVERT(vnumerocomprobante using utf8) collate utf8_spanish_ci);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Modificar_Detalle_Venta1` (IN `vcodBarra` VARCHAR(20), IN `vcantidad` INT, IN `vcantidad_anterior` INT, IN `vprecioventa` DOUBLE, IN `vnumerocomprobante` VARCHAR(20), IN `vcodBarra_anterior` VARCHAR(20), IN `vprecioventa_anterior` DOUBLE)  begin

  declare _idproducto_anterior int;
  declare _stock int;
  declare _detalleventa int;

  select idproducto, stock from producto where codigoBarras = CONVERT(vcodBarra_anterior using utf8) collate utf8_spanish_ci into _idproducto_anterior,_stock;
  update producto set stock=_stock - vcantidad_anterior where idproducto = _idproducto_anterior;

  select iddetalle_venta
  from detalle_venta
  where numero_comprobante = CONVERT(vnumerocomprobante using utf8) collate utf8_spanish_ci
    and idproducto = _idproducto_anterior
    and cantidad = vcantidad_anterior
    and precioventaunitario = vprecioventa_anterior into _detalleventa;

  update detalle_venta
  set idproducto=(select idproducto from producto where codigoBarras = CONVERT(vcodBarra using utf8) collate utf8_spanish_ci),
      cantidad=vcantidad,
      precioventaunitario=vprecioventa
  where iddetalle_venta = _detalleventa;
  select idproducto, stock from producto where codigoBarras = CONVERT(vcodBarra using utf8) collate utf8_spanish_ci into _idproducto_anterior,_stock;
  update producto set stock=_stock + vcantidad where idproducto=_idproducto_anterior;

  call Proc_Actualizar_Total_Subtotal(CONVERT(vnumerocomprobante using utf8) collate utf8_spanish_ci, 0);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Modificar_Empresa_Por_Codigo` (IN `vidempresa` INT, IN `vnombreEmpresa` VARCHAR(100), IN `vrazonSocial` VARCHAR(100), IN `vruc` VARCHAR(100), IN `vdireccion` VARCHAR(150), IN `vtelefono` VARCHAR(15), IN `vemail` VARCHAR(50), IN `vslogan` VARCHAR(200), IN `vabreviatura` VARCHAR(1500), IN `valias` VARCHAR(100))  begin
  update empresa
  set empresa.nombreEmpresa = vnombreEmpresa, empresa.razonSocial = vrazonSocial, empresa.ruc = vruc, empresa.direccion = vdireccion, empresa.telefono = vtelefono, empresa.email = vemail, empresa.slogan = vslogan, empresa.abreviatura = vabreviatura, empresa.alias = valias
    where empresa.idEmpresa = vidempresa;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Modificar_Marca` (IN `vnombremarca` VARCHAR(50), IN `vnombremarcaantiguo` VARCHAR(50))  begin
  declare vidmarca int;
  select idmarca from marca where marca.nombreMarca=CONVERT(vnombremarcaantiguo using utf8) collate utf8_spanish_ci into vidmarca;
  update marca
  set marca.nombreMarca=vnombremarca
    where marca.idmarca = vidmarca;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Modificar_Producto` (IN `vidProducto` INT, IN `vcodigoBarras` VARCHAR(20), IN `vdescripcion` VARCHAR(80), IN `vunidad_medida` VARCHAR(30), IN `vcategoria` VARCHAR(50), IN `vmarca` VARCHAR(50), IN `vpreciosugerido` DOUBLE)  begin
  update producto set 
                      codigoBarras=vcodigoBarras,
                      descripcion=vdescripcion,
                      idunidad_medida=(select idunidadmedida from unidad_medida where unidad=CONVERT(vunidad_medida using utf8) collate utf8_spanish_ci),
                      idcategoria=(select idcategoria from categoria where nombreCategoria=CONVERT(vcategoria using utf8) collate utf8_spanish_ci),
                      idmarca=(select idmarca from marca where nombremarca=CONVERT(vmarca using utf8) collate utf8_spanish_ci),
                      preciosugerido=vpreciosugerido
  where idproducto=vidProducto;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Modificar_Producto_Lote` (IN `vidproducto_lote` INT, IN `vcantidad` INT, IN `vfecha_vencimiento` VARCHAR(20), IN `vcantidadLote` INT, IN `vcantidadPresentacion` INT, IN `vunidadmedida` VARCHAR(30))  begin
  update producto_lote set cantidad = vcantidad,
                           fechavencimiento=vfecha_vencimiento,
  cantidadLote=vcantidadLote,
                           cantidadPresentacion=vcantidadPresentacion,
                           idunidadmedida=(select idunidadmedida from unidad_medida where unidad=CONVERT(vunidadmedida using utf8) collate utf8_spanish_ci)
  where idproducto_lote = vidproducto_lote;
  update producto set stock = (select sum(cantidad) from producto_lote where idproducto=(select idproducto from producto_lote where idproducto_lote=vidproducto_lote))
    where idproducto=(select idproducto from producto_lote where idproducto_lote=vidproducto_lote);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Modificar_Proveedor` (IN `vrazon_social` VARCHAR(100), IN `vruc` VARCHAR(20), IN `vemail` VARCHAR(50), IN `vcontacto` VARCHAR(50), IN `vtelefonocontacto` VARCHAR(20), IN `vnombreProv` VARCHAR(20), IN `vruc_antiguo` VARCHAR(20))  begin
  update proveedor
  set razon_social=vrazon_social,
      ruc=vruc,
      email=vemail,
      contacto=vcontacto,
      telefonocontacto=vtelefonocontacto,
      nombreProv= vnombreProv
    where proveedor.codigoProv = (select codigoProv from proveedor where proveedor.ruc = CONVERT(vruc_antiguo using utf8) collate utf8_spanish_ci);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Modificar_Unidad_Medida` (IN `vunidad` VARCHAR(30), IN `vunidadantiguo` VARCHAR(30))  begin
  declare vidunidadmedida int;
  select idunidadmedida from unidad_medida where unidad=CONVERT(vunidadantiguo using utf8) collate utf8_spanish_ci into vidunidadmedida;
  update unidad_medida
  set unidad_medida.unidad=vunidad
    where unidad_medida.idunidadmedida=vidunidadmedida;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Modificar_User` (IN `vidusuario` INT(11), IN `vusernuevo` VARCHAR(50), IN `vpassword` VARCHAR(50))  NO SQL
UPDATE user_pass SET user_pass.username=vusernuevo, user_pass.password=vpassword where user_pass.idusuario=vidusuario$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Modificar_Usuario` (IN `vidusuario` INT, IN `vnombre` VARCHAR(80), IN `vapellido` VARCHAR(80), IN `vdocumento` VARCHAR(20), IN `vtipodoc` INT, IN `vfecha_nacimiento` VARCHAR(20), IN `vcargo` INT, IN `vdireccion` VARCHAR(150), IN `vobservacion` VARCHAR(300), IN `vestado` VARCHAR(2))  NO SQL
UPDATE usuario SET 
usuario.nombre=vnombre,
usuario.apellido=vapellido,
usuario.documento=vdocumento,
usuario.idtipo_doc_usuario=vtipodoc,
usuario.fecha_nac=vfecha_nacimiento,
usuario.idcargo=vcargo,
usuario.direccion=vdireccion,
usuario.observacion=vobservacion, 
usuario.estado=vestado
WHERE usuario.idusuario=vidusuario$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Obtenerdatos_por_Producto` (IN `vidproductolote` INT)  begin
select p.idproducto,
           codigoBarras,
           descripcion,
           unidad          as UnidadMedida,
           pl.cantidad,
           nombreCategoria as Categoria,
           nombremarca     as Marca,
           preciosugerido,
       fechavencimiento,
       pl.idproducto_lote,
       stock,
       cantidadPresentacion,
       cantidadLote
    from producto p
           inner join categoria c on p.idcategoria = c.idcategoria
           inner join marca m on p.idmarca = m.idmarca
           inner join unidad_medida um on p.idunidad_medida = um.idunidadmedida
inner join producto_lote pl on p.idproducto = pl.idproducto where pl.idproducto_lote=vidproductolote;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Obtenerdatos_por_Producto_C` (IN `vidproducto` INT)  begin
select 		p.idproducto,
           	p.codigoBarras,
           	p.descripcion,
           	um.unidad as UnidadMedida,
           	'',
           	c.nombreCategoria as Categoria,
           	m.nombremarca     as Marca,
           	p.preciosugerido,
       		'',
       		'',
       		p.stock,
       		'',
       		''
    from producto p
           inner join categoria c on p.idcategoria = c.idcategoria
           inner join marca m on p.idmarca = m.idmarca
           inner join unidad_medida um on p.idunidad_medida = um.idunidadmedida
			where p.idproducto=vidproducto;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_ObtenerIGV` ()  begin
  select cast(dato as DECIMAL(9, 2)) as igv
  from datos
  where descripcion = 'igv';
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_ObtenerNroFact` (IN `Vparametro` VARCHAR(20))  NO SQL
SELECT `id`, `parametro`, `registro` FROM `parametros` WHERE parametro=CONVERT(Vparametro using utf8) collate utf8_spanish_ci$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_ObtenerTotal_subtotal` (IN `vnumeroComprobante` VARCHAR(20), IN `tipo` INT)  begin
  if (tipo = 1) then
    select format(totalpagado,2), format(subtotal,2)
    from comprobante_venta
    where numero_comprobante = CONVERT(vnumeroComprobante using utf8) collate utf8_spanish_ci;
  else
    select format(totalpagado,2), format(subtotal,2)
    from comprobante_compra
    where numero_comprobante = CONVERT(vnumeroComprobante using utf8) collate utf8_spanish_ci;
  end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Obtener_nro_comprobante_venta` (IN `vtipocomprobante` VARCHAR(50))  begin
  select Func_GenerarNumeroComprobante_Venta(
             (select idtipoComprobante from tipocomprobante where tipo_comprobante = CONVERT(vtipocomprobante using utf8) collate utf8_spanish_ci));
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Stock_disponible` (IN `vcodBarra` VARCHAR(20))  begin
  select stock
  from producto
  where vcodBarra = CONVERT(vcodBarra using utf8) collate utf8_spanish_ci;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_User_ActualizarEstado` (IN `VEstadoUser` VARCHAR(2), IN `VNuevoEstado` VARCHAR(2), IN `VIdUsuario` INT)  NO SQL
    DETERMINISTIC
UPDATE user_pass
SET user_pass.estado=VNuevoEstado
WHERE user_pass.estado=CONVERT(VEstadoUser using utf8) collate utf8_spanish_ci
        AND user_pass.idusuario=VIdUsuario$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_Usuario_ActualizarEstado` (IN `VEstadoUsuario` VARCHAR(2), IN `VNuevoEstado` VARCHAR(2), IN `VIdUsuario` INT)  NO SQL
UPDATE usuario
SET usuario.estado=VNuevoEstado
WHERE usuario.estado=CONVERT(VEstadoUsuario using utf8) collate utf8_spanish_ci
        AND usuario.idusuario=VIdUsuario$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Proc_VerDatosEmpresa` (IN `vidempresa` INT)  begin
  select empresa.idEmpresa, empresa.nombreEmpresa, empresa.razonSocial, empresa.ruc, empresa.direccion, empresa.telefono, empresa.email, empresa.slogan, empresa.abreviatura, empresa.alias from empresa where empresa.idEmpresa=vidempresa;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Pro_ListarUnidadMedida` ()  begin
  select idunidadmedida as id,unidad as nombre
from unidad_medida;
end$$

--
-- Funciones
--
CREATE DEFINER=`root`@`localhost` FUNCTION `Func_GenerarNumeroComprobante_Venta` (`vtipocomprobante` INT) RETURNS VARCHAR(30) CHARSET utf8 begin
declare _longitud_corre int;
declare _longitud_serie int;
declare _serie int;
declare _correlativo bigint;
declare a int;
declare a1 int;
declare _nro_comprobante varchar(20);
declare _correlativo_str varchar(20);
set _nro_comprobante = '';
set _correlativo_str = '';
    
    IF (vtipocomprobante = 1) THEN
		select cast((select dato from datos where descripcion = 'boleta_cantidad_correlativo') as
						unsigned) into _longitud_corre;
		select cast((select dato from datos where descripcion = 'boleta_cantidad_serie') as
						unsigned) into _longitud_serie;
		set _longitud_serie = _longitud_serie -1;
		select cast((select dato from datos where descripcion = 'boleta_serie') as unsigned) into _serie;
		select cast((select dato from datos where descripcion = 'boleta_correlativo') as unsigned) into _correlativo;

		select concat('B', _nro_comprobante) into _nro_comprobante;
		set a = _longitud_serie - (select length(dato) from datos where descripcion = 'boleta_serie');
		
		my_loop_serie:
		LOOP
			select concat(_nro_comprobante, '0') into _nro_comprobante;
			IF a = 0 THEN
				LEAVE my_loop_serie;
			END IF;
			SET a = a - 1;
		END LOOP my_loop_serie;
    
		select concat(_nro_comprobante, _serie) into _nro_comprobante;
		select concat(_nro_comprobante, '-') into _nro_comprobante;

		set a1 = _longitud_corre - (select length(dato) from datos where descripcion = 'boleta_correlativo');
		
		my_loop_correl:
		LOOP
			select concat(_correlativo_str, '0') into _correlativo_str;
			IF a1 = 0 THEN
				LEAVE my_loop_correl;
			END IF;
			SET a1 = a1 - 1;
		END LOOP my_loop_correl;
		
		select substr(_correlativo_str, 2, length(_correlativo_str)) into _correlativo_str;
		select concat(_nro_comprobante, _correlativo_str) into _nro_comprobante;
		select concat(_nro_comprobante, _correlativo) into _nro_comprobante;
		
	ELSEIF (vtipocomprobante = 2) THEN
		select cast((select dato from datos where descripcion = 'factura_cantidad_correlativo') as
						unsigned) into _longitud_corre;
		select cast((select dato from datos where descripcion = 'factura_cantidad_serie') as
						unsigned) into _longitud_serie;
		set _longitud_serie = _longitud_serie -1;
		select cast((select dato from datos where descripcion = 'factura_serie') as unsigned) into _serie;
		select cast((select dato from datos where descripcion = 'factura_correlativo') as unsigned) into _correlativo;

		select concat('F', _nro_comprobante) into _nro_comprobante;
		set a = _longitud_serie - (select length(dato) from datos where descripcion = 'factura_serie');
		
		my_loop_serie:
		LOOP
			select concat(_nro_comprobante, '0') into _nro_comprobante;
			IF a = 0 THEN
				LEAVE my_loop_serie;
			END IF;
			SET a = a - 1;
		END LOOP my_loop_serie;
    
		select concat(_nro_comprobante, _serie) into _nro_comprobante;
		select concat(_nro_comprobante, '-') into _nro_comprobante;

		set a1 = _longitud_corre - (select length(dato) from datos where descripcion = 'factura_correlativo');

		my_loop_correl:
		LOOP
			select concat(_correlativo_str, '0') into _correlativo_str;
			IF a1 = 0 THEN
				LEAVE my_loop_correl;
			END IF;
			SET a1 = a1 - 1;
		END LOOP my_loop_correl;
		
		select substr(_correlativo_str, 2, length(_correlativo_str)) into _correlativo_str;
		select concat(_nro_comprobante, _correlativo_str) into _nro_comprobante;
		select concat(_nro_comprobante, _correlativo) into _nro_comprobante;

	ELSE
		select cast((select dato from datos where descripcion = 'notacompra_cantidad') as
						unsigned) into _longitud_corre;
		set a1 = _longitud_corre - (select length(dato) from datos where descripcion = 'notacompra_correlativo');
		select cast((select dato from datos where descripcion = 'notacompra_correlativo') as unsigned) into _correlativo;
    
		my_loop_note:
		LOOP
			select concat(_nro_comprobante, '0') into _nro_comprobante;
			IF a1 = 0 THEN
				LEAVE my_loop_note;
			END IF;
			SET a1 = a1 - 1;
		END LOOP my_loop_note;
		select concat(_nro_comprobante, _correlativo) into _nro_comprobante;
	END IF;
  return _nro_comprobante;
end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cargos`
--

CREATE TABLE `cargos` (
  `idcargo` int(11) NOT NULL,
  `nombre` varchar(30) COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `cargos`
--

INSERT INTO `cargos` (`idcargo`, `nombre`) VALUES
(1, 'administrador'),
(6, 'almacenero'),
(7, 'Cajero'),
(8, 'Vendedor'),
(9, 'SEGURIDAD'),
(10, 'supervisor'),
(11, 'ESPECIAL');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categoria`
--

CREATE TABLE `categoria` (
  `idcategoria` int(11) NOT NULL,
  `nombreCategoria` varchar(50) COLLATE utf8_spanish_ci NOT NULL,
  `idlinea` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `categoria`
--

INSERT INTO `categoria` (`idcategoria`, `nombreCategoria`, `idlinea`) VALUES
(7, 'COCINA', 6),
(8, 'JUGUETES', 7),
(9, 'UTILES ESCOLARES', 7),
(10, 'BAÑO', 6),
(11, 'ACCESORIOS DE LIMPIEZA', 6),
(12, 'ACCESORIOS DEL HOGAR', 6),
(13, 'TOMATODOS', 7),
(14, 'BELLEZA', 9),
(15, 'ACCESORIOS CELULAR', 8),
(16, 'GENERAL', 10);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente`
--

CREATE TABLE `cliente` (
  `idCliente` int(11) NOT NULL,
  `nombre_razon` varchar(100) COLLATE utf8_spanish_ci NOT NULL,
  `documento` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `idtipo_doc_usuario` int(11) NOT NULL,
  `direccion` varchar(150) COLLATE utf8_spanish_ci DEFAULT NULL,
  `estado` varchar(2) COLLATE utf8_spanish_ci DEFAULT '00',
  `observacion` varchar(300) COLLATE utf8_spanish_ci DEFAULT NULL,
  `email` varchar(50) COLLATE utf8_spanish_ci DEFAULT NULL,
  `telefono` varchar(20) COLLATE utf8_spanish_ci DEFAULT NULL,
  `fecha_nacimiento` varchar(20) COLLATE utf8_spanish_ci DEFAULT NULL,
  `idtipo_cliente` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `cliente`
--

INSERT INTO `cliente` (`idCliente`, `nombre_razon`, `documento`, `idtipo_doc_usuario`, `direccion`, `estado`, `observacion`, `email`, `telefono`, `fecha_nacimiento`, `idtipo_cliente`) VALUES
(5, 'CLIENTE UNIVERSAL', '87654321', 1, NULL, '00', NULL, NULL, NULL, NULL, 1),
(6, 'CENTRO DE INNOVACION TECNOLOGICA RN SAC', '20604497567', 6, 'TRUJILLO', '00', '-', '-', '-', '13/11/2019', 1),
(7, 'HERNA ROBERTO', '41008669', 1, '-', '00', '', '', '', '13/11/2019', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comprobante_compra`
--

CREATE TABLE `comprobante_compra` (
  `numero_comprobante` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `idtipoComprobante` int(11) NOT NULL,
  `codigoProv` int(11) NOT NULL,
  `fecha_hora_compra` varchar(30) COLLATE utf8_spanish_ci NOT NULL,
  `idusuario` int(11) NOT NULL,
  `totalpagado` double NOT NULL,
  `idforma_pago` int(11) NOT NULL,
  `estado` varchar(50) COLLATE utf8_spanish_ci NOT NULL DEFAULT 'Cancelado',
  `subtotal` double NOT NULL,
  `DatoIGV` double NOT NULL,
  `tipomoneda` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `comprobante_compra`
--

INSERT INTO `comprobante_compra` (`numero_comprobante`, `idtipoComprobante`, `codigoProv`, `fecha_hora_compra`, `idusuario`, `totalpagado`, `idforma_pago`, `estado`, `subtotal`, `DatoIGV`, `tipomoneda`) VALUES
('B010-001121', 2, 1, '2020-02-22 12:56:12', 20, 118, 1, 'Cancelado', 100, 18, 1),
('B012-00112', 2, 1, '2020-02-22 13:28:22', 20, 118, 1, 'Cancelado', 100, 18, 1),
('B012-00113', 2, 1, '2020-02-22 13:55:00', 1, 118, 1, 'Cancelado', 100, 18, 1),
('B012-00114', 2, 1, '2020-02-22 14:14:24', 20, 472, 1, 'Cancelado', 400, 18, 1),
('B025-004765', 2, 1, '2020-02-22 12:54:43', 20, 118, 1, 'Cancelado', 100, 18, 1),
('B028-0004751', 2, 1, '2020-02-22 12:51:38', 20, 118, 1, 'Cancelado', 100, 18, 1),
('B030-0004750', 2, 1, '2020-02-22 12:39:14', 1, 177, 1, 'Cancelado', 150, 18, 1),
('E001-105', 2, 1, '2019-11-27 17:27:11', 1, 70.8, 1, 'Cancelado', 60, 18, 1),
('E001-196', 2, 1, '2019-11-27 17:38:41', 1, 59, 1, 'Cancelado', 50, 18, 1),
('E001-201', 2, 1, '2019-11-27 20:56:19', 1, 472, 1, 'Cancelado', 400, 18, 1),
('E001-202', 2, 1, '2019-11-27 21:29:19', 1, 59, 1, 'Cancelado', 50, 18, 1),
('F001-0025', 2, 1, '2020-02-21 18:04:28', 1, 295, 1, 'Cancelado', 250, 18, 1),
('I0000000001', 3, 1, '2020-02-23 16:58:19', 1, 22.42, 1, 'Cancelado', 19, 18, 1),
('I0000000002', 3, 1, '2020-02-23 17:12:12', 1, 59, 1, 'Cancelado', 50, 18, 1),
('I0000000003', 3, 1, '2020-02-23 17:31:41', 1, 118, 1, 'Cancelado', 100, 18, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comprobante_venta`
--

CREATE TABLE `comprobante_venta` (
  `numero_comprobante` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `idtipoComprobante` int(11) NOT NULL,
  `idcliente` int(11) NOT NULL,
  `estado` varchar(50) COLLATE utf8_spanish_ci NOT NULL DEFAULT 'Cancelado',
  `fecha_hora_venta` varchar(30) COLLATE utf8_spanish_ci NOT NULL,
  `totalpagado` double NOT NULL,
  `idUsuario_caja` int(11) NOT NULL,
  `idUsuario_venta` int(11) NOT NULL,
  `subtotal` double NOT NULL,
  `idtipomoneda` int(11) NOT NULL,
  `DatoIGV` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `comprobante_venta`
--

INSERT INTO `comprobante_venta` (`numero_comprobante`, `idtipoComprobante`, `idcliente`, `estado`, `fecha_hora_venta`, `totalpagado`, `idUsuario_caja`, `idUsuario_venta`, `subtotal`, `idtipomoneda`, `DatoIGV`) VALUES
('A0000000001', 3, 5, 'Cancelado', '2019-11-26 15:39:09', 50, 1, 1, 50, 1, 18),
('A0000000002', 3, 5, 'Cancelado', '2019-11-26 15:45:08', 50, 1, 1, 50, 1, 18),
('A0000000003', 3, 6, 'Cancelado', '2020-02-21 18:12:31', 2, 1, 1, 1.69, 1, 0.31),
('A0000000004', 3, 5, 'Cancelado', '2020-02-21 18:19:57', 3, 1, 1, 2.54, 1, 0.46),
('A0000000005', 3, 5, 'Cancelado', '2020-02-21 23:01:37', 4, 1, 1, 3.39, 1, 0.61),
('A0000000006', 3, 5, 'Cancelado', '2020-02-23 10:31:11', 6, 1, 1, 5.08, 1, 0.92),
('A0000000007', 3, 5, 'Cancelado', '2020-02-27 10:39:02', 20, 1, 1, 16.95, 1, 3.05),
('C0000000001', 3, 5, 'Cancelado', '2019-11-18 10:09:02', 5, 1, 1, 4.24, 1, 0.76),
('D0000000001', 3, 5, 'Cancelado', '2019-11-16 11:42:53', 1, 1, 1, 0.85, 1, 0.15),
('D0000000002', 3, 5, 'Cancelado', '2019-11-16 11:45:16', 3, 1, 1, 2.54, 1, 0.46),
('D0000000003', 3, 5, 'Cancelado', '2019-11-18 15:39:52', 6, 1, 1, 5.08, 1, 0.92),
('D0000000004', 3, 5, 'Cancelado', '2020-02-25 06:07:56', 5, 1, 1, 4.24, 4, 0.76),
('D0000000005', 3, 5, 'Cancelado', '2020-02-25 06:55:15', 1.5, 1, 1, 1.27, 5, 0.23),
('D0000000006', 3, 5, 'Cancelado', '2020-02-25 06:56:27', 1.5, 1, 1, 1.27, 1, 0.23);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `datos`
--

CREATE TABLE `datos` (
  `iddatos` int(11) NOT NULL,
  `dato` varchar(50) COLLATE utf8_spanish_ci NOT NULL,
  `descripcion` varchar(200) COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `datos`
--

INSERT INTO `datos` (`iddatos`, `dato`, `descripcion`) VALUES
(1, '18', 'igv'),
(2, '1', 'factura_serie'),
(3, '1', 'factura_correlativo'),
(4, '1', 'boleta_serie'),
(5, '1', 'boleta_correlativo'),
(6, '1', 'notacompra_correlativo'),
(7, '1', 'factura_cantidad_correlativo'),
(8, '1', 'boleta_cantidad_correlativo'),
(9, '10', 'notacompra_cantidad'),
(10, '3', 'boleta_cantidad_serie'),
(11, '3', 'factura_cantidad_serie');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_compra`
--

CREATE TABLE `detalle_compra` (
  `iddetalle_compra` int(11) NOT NULL,
  `idproducto_lote` int(11) NOT NULL,
  `preciocompraunitario` double NOT NULL,
  `numero_comprobante` varchar(20) COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `detalle_compra`
--

INSERT INTO `detalle_compra` (`iddetalle_compra`, `idproducto_lote`, `preciocompraunitario`, `numero_comprobante`) VALUES
(1, 396, 0.5, 'E001-105'),
(2, 397, 0.5, 'E001-196'),
(3, 398, 2, 'E001-201'),
(4, 399, 0.5, 'E001-202'),
(5, 400, 1.5, 'F001-0025'),
(6, 402, 0.5, 'B030-0004750'),
(7, 403, 1, 'B030-0004750'),
(8, 404, 1, 'B028-0004751'),
(9, 405, 1, 'B025-004765'),
(10, 406, 1, 'B010-001121'),
(11, 407, 1, 'B012-00112'),
(12, 408, 1, 'B012-00113'),
(13, 409, 1, 'B012-00114'),
(14, 410, 2, 'B012-00114'),
(15, 411, 1, 'B012-00114'),
(16, 414, 0.5, 'I0000000001'),
(17, 415, 1, 'I0000000001'),
(18, 416, 1, 'I0000000001'),
(19, 417, 0.5, 'I0000000002'),
(20, 418, 1, 'I0000000003'),
(21, 419, 1, 'F001-0025');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_venta`
--

CREATE TABLE `detalle_venta` (
  `iddetalle_venta` int(11) NOT NULL,
  `numero_comprobante` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `idproducto` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precioventaunitario` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `detalle_venta`
--

INSERT INTO `detalle_venta` (`iddetalle_venta`, `numero_comprobante`, `idproducto`, `cantidad`, `precioventaunitario`) VALUES
(1, 'D0000000002', 300, 1, 1),
(2, 'D0000000002', 302, 1, 2),
(3, 'C0000000001', 302, 1, 2),
(4, 'C0000000001', 304, 1, 3),
(5, 'D0000000003', 300, 1, 1),
(6, 'D0000000003', 302, 1, 2),
(7, 'D0000000003', 304, 1, 3),
(8, 'A0000000001', 299, 1, 50),
(9, 'A0000000002', 299, 1, 50),
(10, 'A0000000003', 359, 1, 2),
(11, 'A0000000004', 359, 1, 2),
(12, 'A0000000004', 300, 1, 1),
(13, 'A0000000005', 359, 2, 4),
(14, 'A0000000006', 300, 3, 3),
(15, 'A0000000006', 301, 2, 3),
(16, 'D0000000004', 359, 1, 2),
(17, 'D0000000004', 304, 1, 3),
(18, 'D0000000005', 301, 1, 1.5),
(19, 'D0000000005', 301, 1, 1.5),
(20, 'D0000000006', 301, 1, 1.5),
(21, 'A0000000007', 359, 10, 20);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `direccionproveedor`
--

CREATE TABLE `direccionproveedor` (
  `iddireccionProveedor` int(11) NOT NULL,
  `codigoProv` int(11) NOT NULL,
  `direccion` varchar(300) NOT NULL,
  `tipo_direccion` varchar(20) DEFAULT NULL,
  `estado` varchar(2) NOT NULL DEFAULT '00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empresa`
--

CREATE TABLE `empresa` (
  `idEmpresa` int(11) NOT NULL,
  `nombreEmpresa` varchar(100) NOT NULL,
  `razonSocial` varchar(100) NOT NULL,
  `ruc` varchar(100) NOT NULL,
  `direccion` varchar(150) NOT NULL,
  `telefono` varchar(15) NOT NULL,
  `email` varchar(50) NOT NULL,
  `slogan` varchar(200) DEFAULT NULL,
  `abreviatura` varchar(30) DEFAULT NULL,
  `alias` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `empresa`
--

INSERT INTO `empresa` (`idEmpresa`, `nombreEmpresa`, `razonSocial`, `ruc`, `direccion`, `telefono`, `email`, `slogan`, `abreviatura`, `alias`) VALUES
(1, 'CentroComercial', 'CentroComercial S.A.C', '15485926', 'Av España 375', '242523', 'cc@gmail.com', 'Todo a 1 sol', 'C&C', 'cc1');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `facturasunatcab`
--

CREATE TABLE `facturasunatcab` (
  `CODIGO` varchar(15) COLLATE utf8_spanish_ci NOT NULL,
  `A0` varchar(8) COLLATE utf8_spanish_ci NOT NULL,
  `A01` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `A02` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `A1` varchar(2) COLLATE utf8_spanish_ci NOT NULL,
  `A2` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `A3` varchar(2) COLLATE utf8_spanish_ci NOT NULL,
  `A4` varchar(1) COLLATE utf8_spanish_ci NOT NULL,
  `A5` varchar(15) COLLATE utf8_spanish_ci NOT NULL,
  `A6` varchar(800) COLLATE utf8_spanish_ci NOT NULL,
  `A7` varchar(3) COLLATE utf8_spanish_ci NOT NULL,
  `A8` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `A9` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `A10` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `A11` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `A12` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `A13` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `A14` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `A15` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `A16` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `A17` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `DIRECCION` varchar(800) COLLATE utf8_spanish_ci NOT NULL,
  `FINICIO` varchar(15) COLLATE utf8_spanish_ci NOT NULL,
  `FFINAL` varchar(15) COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `facturasunatdet`
--

CREATE TABLE `facturasunatdet` (
  `CODIGO` varchar(15) COLLATE utf8_spanish_ci NOT NULL,
  `D1` varchar(3) COLLATE utf8_spanish_ci NOT NULL,
  `D2` varchar(2) COLLATE utf8_spanish_ci NOT NULL,
  `D3` varchar(2) COLLATE utf8_spanish_ci NOT NULL,
  `D4` varchar(2) COLLATE utf8_spanish_ci NOT NULL,
  `D5` varchar(800) COLLATE utf8_spanish_ci NOT NULL,
  `D6` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `D7` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `D8` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `D9` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `D10` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `D11` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `D12` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `D13` varchar(10) COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `facturasunatdetnot`
--

CREATE TABLE `facturasunatdetnot` (
  `CODIGO` varchar(15) COLLATE utf8_spanish_ci NOT NULL,
  `N1` varchar(3) COLLATE utf8_spanish_ci NOT NULL,
  `N2` varchar(2) COLLATE utf8_spanish_ci NOT NULL,
  `N3` varchar(2) COLLATE utf8_spanish_ci NOT NULL,
  `N4` varchar(2) COLLATE utf8_spanish_ci NOT NULL,
  `N5` varchar(800) COLLATE utf8_spanish_ci NOT NULL,
  `N6` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `N7` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `N8` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `N9` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `N10` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `N11` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `N12` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `N13` varchar(10) COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `facturasunatnot`
--

CREATE TABLE `facturasunatnot` (
  `CODIGO` varchar(15) COLLATE utf8_spanish_ci NOT NULL,
  `N0` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `N1` varchar(15) COLLATE utf8_spanish_ci NOT NULL,
  `N2` varchar(2) COLLATE utf8_spanish_ci NOT NULL,
  `N3` varchar(50) COLLATE utf8_spanish_ci NOT NULL,
  `N4` varchar(4) COLLATE utf8_spanish_ci NOT NULL,
  `N5` varchar(15) COLLATE utf8_spanish_ci NOT NULL,
  `N6` varchar(2) COLLATE utf8_spanish_ci NOT NULL,
  `N7` varchar(15) COLLATE utf8_spanish_ci NOT NULL,
  `N8` varchar(800) COLLATE utf8_spanish_ci NOT NULL,
  `N9` varchar(3) COLLATE utf8_spanish_ci NOT NULL,
  `N10` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `N11` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `N12` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `N13` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `N14` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `N15` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `N16` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `N17` varchar(10) COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `forma_de_pago`
--

CREATE TABLE `forma_de_pago` (
  `idforma_pago` int(11) NOT NULL,
  `nombreforma_pago` varchar(80) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `forma_de_pago`
--

INSERT INTO `forma_de_pago` (`idforma_pago`, `nombreforma_pago`) VALUES
(1, 'Contado');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `funciones`
--

CREATE TABLE `funciones` (
  `idfuncion` int(11) NOT NULL,
  `nombre` varchar(30) CHARACTER SET latin1 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `funciones`
--

INSERT INTO `funciones` (`idfuncion`, `nombre`) VALUES
(1, 'Usuarios'),
(2, 'Acceso al Sistema'),
(3, 'Cargos'),
(4, 'Proveedores'),
(5, 'Productos'),
(6, 'Línea'),
(7, 'Marca'),
(8, 'Categoría'),
(9, 'Todos'),
(10, 'Unidad de medida'),
(11, 'Empresa'),
(12, 'Datos'),
(13, 'Cliente'),
(14, 'Ventas'),
(15, 'Compras'),
(16, 'Reportes Ventas'),
(17, 'Reportes Compras'),
(18, 'Producto Compra'),
(19, 'Modificar Venta'),
(20, 'Modificar Compra'),
(21, 'Venta rapida');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `funciones_por_cargo`
--

CREATE TABLE `funciones_por_cargo` (
  `idcargo` int(11) NOT NULL,
  `idfuncion` int(11) NOT NULL,
  `estado` varchar(2) CHARACTER SET latin1 NOT NULL DEFAULT '00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `funciones_por_cargo`
--

INSERT INTO `funciones_por_cargo` (`idcargo`, `idfuncion`, `estado`) VALUES
(1, 9, '00'),
(6, 5, '00'),
(6, 6, '00'),
(6, 7, '00'),
(6, 8, '00'),
(6, 10, '00'),
(6, 10, '00'),
(7, 13, '00'),
(7, 14, '00'),
(7, 16, '00'),
(7, 19, '00'),
(10, 5, '00'),
(10, 6, '00'),
(10, 7, '00'),
(10, 8, '00'),
(10, 10, '00'),
(10, 13, '00'),
(10, 14, '00'),
(10, 15, '00'),
(10, 16, '00'),
(10, 17, '00'),
(10, 18, '00'),
(10, 19, '00'),
(10, 20, '00'),
(11, 5, '00'),
(11, 6, '00'),
(11, 7, '00'),
(11, 8, '00'),
(11, 10, '00'),
(11, 13, '00'),
(11, 14, '00'),
(11, 16, '00'),
(11, 19, '00'),
(7, 21, '00'),
(10, 21, '00'),
(11, 21, '00'),
(6, 5, '00'),
(6, 6, '00'),
(6, 7, '00'),
(6, 8, '00'),
(6, 10, '00'),
(6, 15, '00'),
(6, 18, '00'),
(6, 4, '00'),
(6, 5, '00'),
(6, 6, '00'),
(6, 7, '00'),
(6, 8, '00'),
(6, 10, '00'),
(6, 15, '00'),
(6, 18, '00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `linea`
--

CREATE TABLE `linea` (
  `idlinea` int(11) NOT NULL,
  `nombreLinea` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `linea`
--

INSERT INTO `linea` (`idlinea`, `nombreLinea`) VALUES
(6, 'HOGAR'),
(7, 'NIÑOS'),
(8, 'ACCESORIOS CELULAR'),
(9, 'ACCESORIOS PARA DAMA'),
(10, 'GENERAL');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `lote`
--

CREATE TABLE `lote` (
  `idlote` int(11) NOT NULL,
  `fecha_vencimiento` varchar(20) DEFAULT NULL,
  `fecha_ingreso` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `marca`
--

CREATE TABLE `marca` (
  `idmarca` int(11) NOT NULL,
  `nombremarca` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `marca`
--

INSERT INTO `marca` (`idmarca`, `nombremarca`) VALUES
(12, 'MAV');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `parametros`
--

CREATE TABLE `parametros` (
  `id` int(11) NOT NULL,
  `parametro` varchar(800) COLLATE utf8_spanish_ci NOT NULL,
  `registro` varchar(800) COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `parametros`
--

INSERT INTO `parametros` (`id`, `parametro`, `registro`) VALUES
(1, 'serie', '1'),
(2, 'boleta', '1'),
(3, 'factura', '1'),
(4, 'ImpreElec', 'PDFCreator'),
(5, 'ruc_electronico', '20604497567'),
(6, 'datos_electronicos', 'c:\\sunat_archivos\\sfs\\DATA'),
(7, 'igv', '18'),
(8, 'ImpreMec', 'PDFCreator'),
(9, 'tienda', '1'),
(10, 'N001', '1');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto`
--

CREATE TABLE `producto` (
  `idproducto` int(11) NOT NULL,
  `codigoBarras` varchar(20) DEFAULT NULL,
  `descripcion` varchar(80) NOT NULL,
  `idunidad_medida` int(11) NOT NULL,
  `stock` int(11) NOT NULL DEFAULT '0',
  `idcategoria` int(11) NOT NULL,
  `idmarca` int(11) NOT NULL,
  `preciosugerido` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `producto`
--

INSERT INTO `producto` (`idproducto`, `codigoBarras`, `descripcion`, `idunidad_medida`, `stock`, `idcategoria`, `idmarca`, `preciosugerido`) VALUES
(299, '000', 'VARIOS', 1, 989, 16, 12, 1),
(300, '0001', 'PROD. DE 1 SOL', 1, 1297, 16, 12, 1),
(301, '001.5', 'PROD. DE 1.5 SOLES', 1, 1195, 16, 12, 1.5),
(302, '0002', 'PROD. DE 2 SOLES', 1, 1500, 16, 12, 2),
(303, '002.5', 'PROD. DE 2.5 SOLES', 1, 1000, 16, 12, 2.5),
(304, '0003', 'PROD. DE 3 SOLES', 1, 1099, 16, 12, 3),
(305, '003.5', 'PROD. DE 3.5 SOLES', 1, 1000, 16, 12, 3.5),
(306, '0004', 'PROD. DE 4 SOLES', 1, 1100, 16, 12, 4),
(307, '004.5', 'PROD. DE 4.5 SOLES', 1, 1000, 16, 12, 4.5),
(308, '0005', 'PROD. DE 5 SOLES', 1, 1000, 16, 12, 5),
(309, '005.5', 'PROD. DE 5.5 SOLES', 1, 1000, 16, 12, 5.5),
(310, '0006', 'PROD. DE 6 SOLES', 1, 1000, 16, 12, 6),
(311, '006.5', 'PROD. DE 6.5 SOLES', 1, 1000, 16, 12, 6.5),
(312, '0007', 'PROD. DE 7 SOLES', 1, 1000, 16, 12, 7),
(313, '007.5', 'PROD. DE 7.5 SOLES', 1, 1000, 16, 12, 7.5),
(314, '0008', 'PROD. DE 8 SOLES', 1, 1000, 16, 12, 8),
(315, '008.5', 'PROD. DE 8.5 SOLES', 1, 1000, 16, 12, 8.5),
(316, '0009', 'PROD. DE 9 SOLES', 1, 1000, 16, 12, 9),
(317, '009.5', 'PROD. DE 9.5 SOLES', 1, 1000, 16, 12, 9.5),
(318, '0010', 'PROD. DE 10 SOLES', 1, 1000, 16, 12, 10),
(319, '0011', 'PROD. DE 11 SOLES', 1, 1000, 16, 12, 11),
(320, '0012', 'PROD. DE 12 SOLES', 1, 1000, 16, 12, 12),
(321, '0013', 'PROD. DE 13 SOLES', 1, 1000, 16, 12, 13),
(322, '0014', 'PROD. DE 14 SOLES', 1, 1000, 16, 12, 14),
(323, '0015', 'PROD. DE 15 SOLES', 1, 1000, 16, 12, 15),
(324, '0016', 'PROD. DE 16 SOLES', 1, 1000, 16, 12, 16),
(325, '0017', 'PROD. DE 17 SOLES', 1, 1000, 16, 12, 17),
(326, '0018', 'PROD. DE 18 SOLES', 1, 1000, 16, 12, 18),
(327, '0019', 'PROD. DE 19 SOLES', 1, 1000, 16, 12, 19),
(328, '0020', 'PROD. DE 20 SOLES', 1, 1000, 16, 12, 20),
(329, '0021', 'PROD. DE 21 SOLES', 1, 1000, 16, 12, 21),
(330, '0022', 'PROD. DE 22 SOLES', 1, 1000, 16, 12, 22),
(331, '0023', 'PROD. DE 23 SOLES', 1, 1000, 16, 12, 23),
(332, '0024', 'PROD. DE 24 SOLES', 1, 1000, 16, 12, 24),
(333, '0025', 'PROD. DE 25 SOLES', 1, 1000, 16, 12, 25),
(334, '0026', 'PROD. DE 26 SOLES', 1, 1000, 16, 12, 26),
(335, '0027', 'PROD. DE 27 SOLES', 1, 1000, 16, 12, 27),
(336, '0028', 'PROD. DE 28 SOLES', 1, 1000, 16, 12, 28),
(337, '0029', 'PROD. DE 29 SOLES', 1, 1000, 16, 12, 29),
(338, '0030', 'PROD. DE 30 SOLES', 1, 1000, 16, 12, 30),
(339, '0031', 'PROD. DE 31 SOLES', 1, 1000, 16, 12, 31),
(340, '0032', 'PROD. DE 32 SOLES', 1, 1000, 16, 12, 32),
(341, '0033', 'PROD. DE 33 SOLES', 1, 1000, 16, 12, 33),
(342, '0034', 'PROD. DE 34 SOLES', 1, 1000, 16, 12, 34),
(343, '0035', 'PROD. DE 35 SOLES', 1, 1000, 16, 12, 35),
(344, '0036', 'PROD. DE 36 SOLES', 1, 1000, 16, 12, 36),
(345, '0037', 'PROD. DE 37 SOLES', 1, 1000, 16, 12, 37),
(346, '0038', 'PROD. DE 38 SOLES', 1, 1000, 16, 12, 38),
(347, '0039', 'PROD. DE 39 SOLES', 1, 1000, 16, 12, 39),
(348, '0040', 'PROD. DE 40 SOLES', 1, 1000, 16, 12, 40),
(349, '0041', 'PROD. DE 41 SOLES', 1, 1000, 16, 12, 41),
(350, '0042', 'PROD. DE 42 SOLES', 1, 1000, 16, 12, 42),
(351, '0043', 'PROD. DE 43 SOLES', 1, 1000, 16, 12, 43),
(352, '0044', 'PROD. DE 44 SOLES', 1, 1000, 16, 12, 44),
(353, '0045', 'PROD. DE 45 SOLES', 1, 1000, 16, 12, 45),
(354, '0046', 'PROD. DE 46 SOLES', 1, 1000, 16, 12, 46),
(355, '0047', 'PROD. DE 47 SOLES', 1, 1000, 16, 12, 47),
(356, '0048', 'PROD. DE 48 SOLES', 1, 1000, 16, 12, 48),
(357, '0049', 'PROD. DE 49 SOLES', 1, 1000, 16, 12, 49),
(358, '0050', 'PROD. DE 50 SOLES', 1, 1000, 16, 12, 50),
(359, 'AB001', 'CUCHARAS', 1, 90, 7, 12, 2),
(360, 'AB002', 'PRUEBA', 1, 0, 16, 12, 2),
(361, '750082028548', 'LAPIZ OLEO PASTEL', 1, 6, 9, 12, 1),
(362, '750082003408', 'COLA SINTETICA SICK ARTESCO', 1, 16, 9, 12, 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto_lote`
--

CREATE TABLE `producto_lote` (
  `idproducto_lote` int(11) NOT NULL,
  `idproducto` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `fechavencimiento` varchar(15) DEFAULT NULL,
  `cantidadLote` int(11) DEFAULT NULL,
  `cantidadPresentacion` int(11) DEFAULT NULL,
  `idunidadmedida` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `producto_lote`
--

INSERT INTO `producto_lote` (`idproducto_lote`, `idproducto`, `cantidad`, `fechavencimiento`, `cantidadLote`, `cantidadPresentacion`, `idunidadmedida`) VALUES
(336, 300, 1000, '', 1000, 1, 1),
(337, 301, 1000, '', 1000, 1, 1),
(338, 302, 1000, '', 1000, 1, 1),
(339, 303, 1000, '', 1000, 1, 1),
(340, 304, 1000, '', 1000, 1, 1),
(341, 305, 1000, '', 1000, 1, 1),
(342, 306, 1000, '', 1000, 1, 1),
(343, 307, 1000, '', 1000, 1, 1),
(344, 308, 1000, '', 1000, 1, 1),
(345, 309, 1000, '', 1000, 1, 1),
(346, 310, 1000, '', 1000, 1, 1),
(347, 311, 1000, '', 1000, 1, 1),
(348, 312, 1000, '', 1000, 1, 1),
(349, 313, 1000, '', 1000, 1, 1),
(350, 314, 1000, '', 1000, 1, 1),
(351, 315, 1000, '', 1000, 1, 1),
(352, 316, 1000, '', 1000, 1, 1),
(353, 317, 1000, '', 1000, 1, 1),
(354, 318, 1000, '', 1000, 1, 1),
(355, 319, 1000, '', 1000, 1, 1),
(356, 320, 1000, '', 1000, 1, 1),
(357, 321, 1000, '', 1000, 1, 1),
(358, 322, 1000, '', 1000, 1, 1),
(359, 323, 1000, '', 1000, 1, 1),
(360, 324, 1000, '', 1000, 1, 1),
(361, 325, 1000, '', 1000, 1, 1),
(362, 326, 1000, '', 1000, 1, 1),
(363, 327, 1000, '', 1000, 1, 1),
(364, 328, 1000, '', 1000, 1, 1),
(365, 329, 1000, '', 1000, 1, 1),
(366, 330, 1000, '', 1000, 1, 1),
(367, 331, 1000, '', 1000, 1, 1),
(368, 332, 1000, '', 1000, 1, 1),
(369, 333, 1000, '', 1000, 1, 1),
(370, 334, 1000, '', 1000, 1, 1),
(371, 335, 1000, '', 1000, 1, 1),
(372, 336, 1000, '', 1000, 1, 1),
(373, 337, 1000, '', 1000, 1, 1),
(374, 338, 1000, '', 1000, 1, 1),
(375, 339, 1000, '', 1000, 1, 1),
(376, 340, 1000, '', 1000, 1, 1),
(377, 341, 1000, '', 1000, 1, 1),
(378, 342, 1000, '', 1000, 1, 1),
(379, 343, 1000, '', 1000, 1, 1),
(380, 344, 1000, '', 1000, 1, 1),
(381, 345, 1000, '', 1000, 1, 1),
(382, 346, 1000, '', 1000, 1, 1),
(383, 347, 1000, '', 1000, 1, 1),
(384, 348, 1000, '', 1000, 1, 1),
(385, 349, 1000, '', 1000, 1, 1),
(386, 350, 1000, '', 1000, 1, 1),
(387, 351, 1000, '', 1000, 1, 1),
(388, 352, 1000, '', 1000, 1, 1),
(389, 353, 1000, '', 1000, 1, 1),
(390, 354, 1000, '', 1000, 1, 1),
(391, 355, 1000, '', 1000, 1, 1),
(392, 356, 1000, '', 1000, 1, 1),
(393, 357, 1000, '', 1000, 1, 1),
(394, 358, 1000, '', 1000, 1, 1),
(395, 359, 0, '', 0, 1, 1),
(396, 359, 120, '', 120, 1, 1),
(397, 359, 100, '', 100, 1, 1),
(398, 359, 200, '', 100, 2, 1),
(399, 359, 100, '', 100, 1, 1),
(400, 359, 100, '', 100, 1, 1),
(401, 360, 0, '', 0, 1, 1),
(402, 300, 100, '', 100, 1, 1),
(403, 300, 100, '', 100, 1, 1),
(404, 301, 100, '', 100, 1, 1),
(405, 302, 100, '', 100, 1, 1),
(406, 302, 100, '', 100, 1, 1),
(407, 302, 100, '', 100, 1, 1),
(408, 302, 100, '', 100, 1, 1),
(409, 302, 100, '', 100, 1, 1),
(410, 306, 100, '', 100, 1, 1),
(411, 304, 100, '', 100, 1, 1),
(412, 361, 0, '', 0, 1, 1),
(413, 362, 0, '', 0, 1, 1),
(414, 361, 6, '', 6, 1, 1),
(415, 362, 6, '', 6, 1, 2),
(416, 362, 10, '', 10, 1, 1),
(417, 300, 100, '', 100, 1, 1),
(418, 301, 100, '', 100, 1, 1),
(419, 359, 100, '', 100, 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedor`
--

CREATE TABLE `proveedor` (
  `codigoProv` int(11) NOT NULL,
  `razon_social` varchar(100) NOT NULL,
  `ruc` varchar(20) NOT NULL,
  `email` varchar(50) DEFAULT NULL,
  `contacto` varchar(50) NOT NULL,
  `telefonocontacto` varchar(20) NOT NULL,
  `nombreProv` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `proveedor`
--

INSERT INTO `proveedor` (`codigoProv`, `razon_social`, `ruc`, `email`, `contacto`, `telefonocontacto`, `nombreProv`) VALUES
(1, 'CENTRO DE INNOVACION TECNOLOGICA RN S.A.C.', '20604497567', 'ceintec.rn@gmail.com', 'Roberto Herna', '960881366', 'CEINTEC,RN');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `telefonoproveedor`
--

CREATE TABLE `telefonoproveedor` (
  `idtelefonoProveedor` int(11) NOT NULL,
  `numeroTelefono` varchar(20) NOT NULL,
  `idTipoTelefono` int(11) NOT NULL,
  `codigoProv` int(11) NOT NULL,
  `estado` varchar(2) NOT NULL DEFAULT '00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipocomprobante`
--

CREATE TABLE `tipocomprobante` (
  `idtipoComprobante` int(11) NOT NULL,
  `tipo_comprobante` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `tipocomprobante`
--

INSERT INTO `tipocomprobante` (`idtipoComprobante`, `tipo_comprobante`) VALUES
(1, 'Boleta'),
(2, 'Factura'),
(3, 'Nota de venta');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipotelefono`
--

CREATE TABLE `tipotelefono` (
  `idTipoTelefono` int(11) NOT NULL,
  `nombreTipoTelefono` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `tipotelefono`
--

INSERT INTO `tipotelefono` (`idTipoTelefono`, `nombreTipoTelefono`) VALUES
(1, 'Principal'),
(2, 'Sucursal');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_cliente`
--

CREATE TABLE `tipo_cliente` (
  `idtipo_cliente` int(11) NOT NULL,
  `tipo` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `tipo_cliente`
--

INSERT INTO `tipo_cliente` (`idtipo_cliente`, `tipo`) VALUES
(1, 'Persona Natural'),
(2, 'Empresa');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_doc_usuario`
--

CREATE TABLE `tipo_doc_usuario` (
  `idtipo_doc_usuario` int(11) NOT NULL,
  `nombre` varchar(30) CHARACTER SET latin1 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `tipo_doc_usuario`
--

INSERT INTO `tipo_doc_usuario` (`idtipo_doc_usuario`, `nombre`) VALUES
(1, 'DNI'),
(2, 'OTRO1'),
(3, 'pasaporte'),
(4, 'cedula de extranjeria'),
(5, 'OTRO2'),
(6, 'RUC');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_moneda`
--

CREATE TABLE `tipo_moneda` (
  `idtipomoneda` int(11) NOT NULL,
  `tipo` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `tipo_moneda`
--

INSERT INTO `tipo_moneda` (`idtipomoneda`, `tipo`) VALUES
(1, 'Soles'),
(2, 'Dólares'),
(3, 'Euros'),
(4, 'Tarjeta Visa'),
(5, 'Tarjeta Mastercard');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `unidad_medida`
--

CREATE TABLE `unidad_medida` (
  `idunidadmedida` int(11) NOT NULL,
  `unidad` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `unidad_medida`
--

INSERT INTO `unidad_medida` (`idunidadmedida`, `unidad`) VALUES
(1, 'UND'),
(2, 'CAJA'),
(3, 'PQTE'),
(4, 'DOC');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `user_pass`
--

CREATE TABLE `user_pass` (
  `iduser_pass` int(11) NOT NULL,
  `idusuario` int(11) NOT NULL,
  `username` varchar(50) CHARACTER SET latin1 DEFAULT NULL,
  `password` varchar(50) CHARACTER SET latin1 DEFAULT NULL,
  `estado` varchar(2) CHARACTER SET latin1 DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `user_pass`
--

INSERT INTO `user_pass` (`iduser_pass`, `idusuario`, `username`, `password`, `estado`) VALUES
(1, 1, 'admin', '159753', '00'),
(2, 2, 'samuel97', '1234', '00'),
(16, 36, 'usuario', '1234', '00'),
(17, 38, 'zvargasc', '22508916', '00'),
(18, 37, 'narteagah', '4703', '00'),
(19, 43, 'jhosue29', '9530', '00'),
(20, 44, 'ALMA', '123456', '00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `idusuario` int(11) NOT NULL,
  `nombre` varchar(80) CHARACTER SET latin1 NOT NULL,
  `apellido` varchar(80) CHARACTER SET latin1 NOT NULL,
  `documento` varchar(20) CHARACTER SET latin1 NOT NULL,
  `idtipo_doc_usuario` int(11) NOT NULL,
  `fecha_nac` varchar(20) CHARACTER SET latin1 DEFAULT NULL,
  `idcargo` int(11) NOT NULL,
  `direccion` varchar(150) CHARACTER SET latin1 NOT NULL,
  `estado` varchar(2) CHARACTER SET latin1 DEFAULT '00',
  `observacion` varchar(300) CHARACTER SET latin1 DEFAULT NULL,
  `fecha_registro` varchar(20) CHARACTER SET latin1 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`idusuario`, `nombre`, `apellido`, `documento`, `idtipo_doc_usuario`, `fecha_nac`, `idcargo`, `direccion`, `estado`, `observacion`, `fecha_registro`) VALUES
(1, 'administrador', '', '', 1, '', 1, '', '00', '', '28/02/2019'),
(2, 'SAMUEL', 'VARGAS CAMACHO', '135129142', 3, '03/07/1997', 10, 'jiron jose galvez', '00', '', '2019-03-08'),
(36, 'USUARIO', 'USUARIO', '87654321', 1, '20/03/2019', 6, 'CC.Valentina', '00', NULL, '2019-03-20'),
(37, 'NAIROBIS', 'ARTEAGA HERRERA', '22508747', 4, '15/01/1995', 11, 'Los Jazmines', '00', '', '2019-03-21'),
(38, 'ZARIBET YISEL', 'VARGAS CAMACHO', '135512933', 3, '25/03/1995', 7, 'Jiron José Galvez', '00', NULL, '2019-03-21'),
(39, 'YENIFER ALEJANDRA', 'CASTILLO ORELLANA', '28571657', 4, '17/01/2001', 8, 'Jose Inclan Urb. Sta. Maria 5ta Etapa 244', '00', NULL, '2019-03-21'),
(40, 'MARILYN STEFANY', 'LOZANO REYNA', '74952832', 1, '02/08/1998', 8, 'Lopez Abujar 239', '00', NULL, '2019-03-21'),
(41, 'MIRIAM', 'CAMPOS', '71717119', 1, '10/03/2000', 8, 'Cajamarca Catabamba', '00', NULL, '2019-03-21'),
(42, 'EMERSON DAVID', 'PORRAS BELISARIO', '22011235', 4, '01/03/1995', 9, 'LOS JAZMINES', '00', NULL, '2019-03-21'),
(43, 'JOSUE', 'YARANGA ALEGRIA', '71549249', 1, '21/03/2019', 1, '', '00', '', '2019-03-21'),
(44, 'ALMAC', 'ALMA', '12378965', 1, '22/02/2020', 6, '', '00', NULL, '2020-02-22');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `cargos`
--
ALTER TABLE `cargos`
  ADD PRIMARY KEY (`idcargo`);

--
-- Indices de la tabla `categoria`
--
ALTER TABLE `categoria`
  ADD PRIMARY KEY (`idcategoria`),
  ADD KEY `fk_categoria_linea` (`idlinea`);

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`idCliente`),
  ADD KEY `fk_cliente_tipo_cliente` (`idtipo_cliente`),
  ADD KEY `fk_cliente_tipo_doc_usuario` (`idtipo_doc_usuario`);

--
-- Indices de la tabla `comprobante_compra`
--
ALTER TABLE `comprobante_compra`
  ADD PRIMARY KEY (`numero_comprobante`),
  ADD KEY `fk_comprobante_compra_tipoComprobante` (`idtipoComprobante`),
  ADD KEY `fk_comprobante_compra_proveedor` (`codigoProv`),
  ADD KEY `fk_comprobante_compra_usuario` (`idusuario`),
  ADD KEY `fk_comprobante_compra_forma_pago` (`idforma_pago`),
  ADD KEY `fk_comprobante_compra_tipo_moneda` (`tipomoneda`);

--
-- Indices de la tabla `comprobante_venta`
--
ALTER TABLE `comprobante_venta`
  ADD PRIMARY KEY (`numero_comprobante`),
  ADD KEY `fk_venta_usuario_vendedor` (`idUsuario_venta`),
  ADD KEY `fk_venta_usuario_caja` (`idUsuario_caja`),
  ADD KEY `fk_venta_cliente` (`idcliente`),
  ADD KEY `fk_venta_tipo_moneda` (`idtipomoneda`),
  ADD KEY `fk_venta_tipo_comprobante` (`idtipoComprobante`);

--
-- Indices de la tabla `datos`
--
ALTER TABLE `datos`
  ADD PRIMARY KEY (`iddatos`);

--
-- Indices de la tabla `detalle_compra`
--
ALTER TABLE `detalle_compra`
  ADD PRIMARY KEY (`iddetalle_compra`),
  ADD KEY `fk_detalle_compra_producto_lote` (`idproducto_lote`),
  ADD KEY `fk_detalle_compra_comprobante_compra` (`numero_comprobante`);

--
-- Indices de la tabla `detalle_venta`
--
ALTER TABLE `detalle_venta`
  ADD PRIMARY KEY (`iddetalle_venta`),
  ADD KEY `fk_detalle_venta_comprobante_venta` (`numero_comprobante`),
  ADD KEY `fk_detalle_venta_producto_lote` (`idproducto`);

--
-- Indices de la tabla `direccionproveedor`
--
ALTER TABLE `direccionproveedor`
  ADD PRIMARY KEY (`iddireccionProveedor`),
  ADD KEY `fk_direccionProveedor_proveedor` (`codigoProv`);

--
-- Indices de la tabla `empresa`
--
ALTER TABLE `empresa`
  ADD PRIMARY KEY (`idEmpresa`);

--
-- Indices de la tabla `forma_de_pago`
--
ALTER TABLE `forma_de_pago`
  ADD PRIMARY KEY (`idforma_pago`);

--
-- Indices de la tabla `funciones`
--
ALTER TABLE `funciones`
  ADD PRIMARY KEY (`idfuncion`);

--
-- Indices de la tabla `funciones_por_cargo`
--
ALTER TABLE `funciones_por_cargo`
  ADD KEY `fk_funciones_por_cargo_cargo` (`idcargo`),
  ADD KEY `fk_funciones_por_cargo_funcion` (`idfuncion`);

--
-- Indices de la tabla `linea`
--
ALTER TABLE `linea`
  ADD PRIMARY KEY (`idlinea`);

--
-- Indices de la tabla `lote`
--
ALTER TABLE `lote`
  ADD PRIMARY KEY (`idlote`);

--
-- Indices de la tabla `marca`
--
ALTER TABLE `marca`
  ADD PRIMARY KEY (`idmarca`);

--
-- Indices de la tabla `parametros`
--
ALTER TABLE `parametros`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `producto`
--
ALTER TABLE `producto`
  ADD PRIMARY KEY (`idproducto`),
  ADD KEY `fk_producto_unidad_medida` (`idunidad_medida`),
  ADD KEY `fk_producto_marca` (`idmarca`),
  ADD KEY `fk_producto_categoria` (`idcategoria`);

--
-- Indices de la tabla `producto_lote`
--
ALTER TABLE `producto_lote`
  ADD PRIMARY KEY (`idproducto_lote`),
  ADD KEY `fk_producto_lote_producto` (`idproducto`),
  ADD KEY `fk_producto_lote_unidad_medida` (`idunidadmedida`);

--
-- Indices de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  ADD PRIMARY KEY (`codigoProv`);

--
-- Indices de la tabla `telefonoproveedor`
--
ALTER TABLE `telefonoproveedor`
  ADD PRIMARY KEY (`idtelefonoProveedor`),
  ADD KEY `fk_telefonoProveedor_proveedor` (`codigoProv`),
  ADD KEY `fk_telefonoProveedor_tipoTelefono` (`idTipoTelefono`);

--
-- Indices de la tabla `tipocomprobante`
--
ALTER TABLE `tipocomprobante`
  ADD PRIMARY KEY (`idtipoComprobante`);

--
-- Indices de la tabla `tipotelefono`
--
ALTER TABLE `tipotelefono`
  ADD PRIMARY KEY (`idTipoTelefono`);

--
-- Indices de la tabla `tipo_cliente`
--
ALTER TABLE `tipo_cliente`
  ADD PRIMARY KEY (`idtipo_cliente`);

--
-- Indices de la tabla `tipo_doc_usuario`
--
ALTER TABLE `tipo_doc_usuario`
  ADD PRIMARY KEY (`idtipo_doc_usuario`);

--
-- Indices de la tabla `tipo_moneda`
--
ALTER TABLE `tipo_moneda`
  ADD PRIMARY KEY (`idtipomoneda`);

--
-- Indices de la tabla `unidad_medida`
--
ALTER TABLE `unidad_medida`
  ADD PRIMARY KEY (`idunidadmedida`);

--
-- Indices de la tabla `user_pass`
--
ALTER TABLE `user_pass`
  ADD PRIMARY KEY (`iduser_pass`),
  ADD KEY `fk_user_pass_usuario` (`idusuario`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`idusuario`),
  ADD UNIQUE KEY `documento` (`documento`),
  ADD KEY `fk_usuario_cargo` (`idcargo`),
  ADD KEY `fk_usuario_tipo_doc_usuario` (`idtipo_doc_usuario`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `cargos`
--
ALTER TABLE `cargos`
  MODIFY `idcargo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `categoria`
--
ALTER TABLE `categoria`
  MODIFY `idcategoria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT de la tabla `cliente`
--
ALTER TABLE `cliente`
  MODIFY `idCliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `datos`
--
ALTER TABLE `datos`
  MODIFY `iddatos` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `detalle_compra`
--
ALTER TABLE `detalle_compra`
  MODIFY `iddetalle_compra` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT de la tabla `detalle_venta`
--
ALTER TABLE `detalle_venta`
  MODIFY `iddetalle_venta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT de la tabla `direccionproveedor`
--
ALTER TABLE `direccionproveedor`
  MODIFY `iddireccionProveedor` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `empresa`
--
ALTER TABLE `empresa`
  MODIFY `idEmpresa` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `forma_de_pago`
--
ALTER TABLE `forma_de_pago`
  MODIFY `idforma_pago` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `funciones`
--
ALTER TABLE `funciones`
  MODIFY `idfuncion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT de la tabla `linea`
--
ALTER TABLE `linea`
  MODIFY `idlinea` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `lote`
--
ALTER TABLE `lote`
  MODIFY `idlote` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `marca`
--
ALTER TABLE `marca`
  MODIFY `idmarca` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `parametros`
--
ALTER TABLE `parametros`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `producto`
--
ALTER TABLE `producto`
  MODIFY `idproducto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=363;

--
-- AUTO_INCREMENT de la tabla `producto_lote`
--
ALTER TABLE `producto_lote`
  MODIFY `idproducto_lote` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=420;

--
-- AUTO_INCREMENT de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  MODIFY `codigoProv` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `telefonoproveedor`
--
ALTER TABLE `telefonoproveedor`
  MODIFY `idtelefonoProveedor` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tipocomprobante`
--
ALTER TABLE `tipocomprobante`
  MODIFY `idtipoComprobante` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `tipotelefono`
--
ALTER TABLE `tipotelefono`
  MODIFY `idTipoTelefono` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `tipo_cliente`
--
ALTER TABLE `tipo_cliente`
  MODIFY `idtipo_cliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `tipo_doc_usuario`
--
ALTER TABLE `tipo_doc_usuario`
  MODIFY `idtipo_doc_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `tipo_moneda`
--
ALTER TABLE `tipo_moneda`
  MODIFY `idtipomoneda` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `unidad_medida`
--
ALTER TABLE `unidad_medida`
  MODIFY `idunidadmedida` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `user_pass`
--
ALTER TABLE `user_pass`
  MODIFY `iduser_pass` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `idusuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `categoria`
--
ALTER TABLE `categoria`
  ADD CONSTRAINT `fk_categoria_linea` FOREIGN KEY (`idlinea`) REFERENCES `linea` (`idlinea`);

--
-- Filtros para la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD CONSTRAINT `fk_cliente_tipo_cliente` FOREIGN KEY (`idtipo_cliente`) REFERENCES `tipo_cliente` (`idtipo_cliente`),
  ADD CONSTRAINT `fk_cliente_tipo_doc_usuario` FOREIGN KEY (`idtipo_doc_usuario`) REFERENCES `tipo_doc_usuario` (`idtipo_doc_usuario`);

--
-- Filtros para la tabla `comprobante_compra`
--
ALTER TABLE `comprobante_compra`
  ADD CONSTRAINT `fk_comprobante_compra_forma_pago` FOREIGN KEY (`idforma_pago`) REFERENCES `forma_de_pago` (`idforma_pago`),
  ADD CONSTRAINT `fk_comprobante_compra_proveedor` FOREIGN KEY (`codigoProv`) REFERENCES `proveedor` (`codigoProv`),
  ADD CONSTRAINT `fk_comprobante_compra_tipoComprobante` FOREIGN KEY (`idtipoComprobante`) REFERENCES `tipocomprobante` (`idtipoComprobante`),
  ADD CONSTRAINT `fk_comprobante_compra_tipo_moneda` FOREIGN KEY (`tipomoneda`) REFERENCES `tipo_moneda` (`idtipomoneda`),
  ADD CONSTRAINT `fk_comprobante_compra_usuario` FOREIGN KEY (`idusuario`) REFERENCES `user_pass` (`iduser_pass`);

--
-- Filtros para la tabla `comprobante_venta`
--
ALTER TABLE `comprobante_venta`
  ADD CONSTRAINT `fk_venta_cliente` FOREIGN KEY (`idcliente`) REFERENCES `cliente` (`idCliente`),
  ADD CONSTRAINT `fk_venta_tipo_comprobante` FOREIGN KEY (`idtipoComprobante`) REFERENCES `tipocomprobante` (`idtipoComprobante`),
  ADD CONSTRAINT `fk_venta_tipo_moneda` FOREIGN KEY (`idtipomoneda`) REFERENCES `tipo_moneda` (`idtipomoneda`);

--
-- Filtros para la tabla `detalle_compra`
--
ALTER TABLE `detalle_compra`
  ADD CONSTRAINT `fk_detalle_compra_producto_lote` FOREIGN KEY (`idproducto_lote`) REFERENCES `producto_lote` (`idproducto_lote`);

--
-- Filtros para la tabla `detalle_venta`
--
ALTER TABLE `detalle_venta`
  ADD CONSTRAINT `fk_detalle_venta_producto` FOREIGN KEY (`idproducto`) REFERENCES `producto` (`idproducto`);

--
-- Filtros para la tabla `direccionproveedor`
--
ALTER TABLE `direccionproveedor`
  ADD CONSTRAINT `fk_direccionProveedor_proveedor` FOREIGN KEY (`codigoProv`) REFERENCES `proveedor` (`codigoProv`);

--
-- Filtros para la tabla `producto`
--
ALTER TABLE `producto`
  ADD CONSTRAINT `fk_producto_categoria` FOREIGN KEY (`idcategoria`) REFERENCES `categoria` (`idcategoria`),
  ADD CONSTRAINT `fk_producto_marca` FOREIGN KEY (`idmarca`) REFERENCES `marca` (`idmarca`),
  ADD CONSTRAINT `fk_producto_unidad_medida` FOREIGN KEY (`idunidad_medida`) REFERENCES `unidad_medida` (`idunidadmedida`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `producto_lote`
--
ALTER TABLE `producto_lote`
  ADD CONSTRAINT `fk_producto_lote_producto` FOREIGN KEY (`idproducto`) REFERENCES `producto` (`idproducto`),
  ADD CONSTRAINT `fk_producto_lote_unidad_medida` FOREIGN KEY (`idunidadmedida`) REFERENCES `unidad_medida` (`idunidadmedida`);

--
-- Filtros para la tabla `telefonoproveedor`
--
ALTER TABLE `telefonoproveedor`
  ADD CONSTRAINT `fk_telefonoProveedor_proveedor` FOREIGN KEY (`codigoProv`) REFERENCES `proveedor` (`codigoProv`),
  ADD CONSTRAINT `fk_telefonoProveedor_tipoTelefono` FOREIGN KEY (`idTipoTelefono`) REFERENCES `tipotelefono` (`idTipoTelefono`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

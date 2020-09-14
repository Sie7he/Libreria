-- phpMyAdmin SQL Dump
-- version 4.9.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 14-09-2020 a las 04:03:02
-- Versión del servidor: 10.4.8-MariaDB
-- Versión de PHP: 7.3.11

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `libreria`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `ACTUALIZAR_LIBRO` (IN `_ID` INT, IN `_NOMBRE` VARCHAR(250), IN `_AUTOR` VARCHAR(100), IN `_IMAGEN` VARCHAR(250), IN `_SINOPSIS` TEXT, IN `_PRECIO` INT, IN `_STOCK` INT(3), IN `_ISBN` VARCHAR(14))  BEGIN

UPDATE libros 
SET 
 NOMBRE  = _NOMBRE,
 AUTOR   = _AUTOR,
 IMAGEN  = _IMAGEN,
 SINOPSIS = _SINOPSIS,
 PRECIO  = _PRECIO,
 STOCK   = _STOCK,
 ISBN    = _ISBN
WHERE ID = _ID;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ACTUALIZAR_USUARIO` (IN `_RUT` VARCHAR(13), IN `_NOMBRE` VARCHAR(50), IN `_APELLIDO` VARCHAR(50), IN `_CORREO` VARCHAR(100), IN `_DIRECCION` VARCHAR(100), IN `_ROL` INT(1), IN `_RUTADM` VARCHAR(13), IN `_COMUNA` INT(100))  BEGIN

IF (VALIDAR_ADM(_RUTADM)=0) THEN
     SIGNAL SQLSTATE '40004' 
     SET MESSAGE_TEXT = 'NO TIENE PERMISO';
ELSE

UPDATE usuarios 

SET NOMBRE    = _NOMBRE ,
    APELLIDO  = _APELLIDO,
    COMUNA    = _COMUNA,
    DIRECCION = _DIRECCION
    WHERE RUT = _RUT;
    
UPDATE registro_usuarios

SET 
    CORREO   = _CORREO,
    ROL      = _ROL
    WHERE RUT_USUARIO = _RUT ;

END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AGREGAR_LIBROS` (IN `_AUTOR` VARCHAR(100), IN `_IMAGEN` VARCHAR(250), IN `_NOMBRE` VARCHAR(250), IN `_PRECIO` INT(7), IN `_STOCK` INT(3), IN `_SINOPSIS` TEXT, IN `_ISBN` VARCHAR(14))  BEGIN
 IF (BUSCAR_LIBRO(_ISBN)=1) THEN SIGNAL SQLSTATE '40004'SET MESSAGE_TEXT = 'LIBRO DUPLICADO'; 
ELSE INSERT INTO libros 
(NOMBRE,AUTOR,PRECIO,STOCK,SINOPSIS,IMAGEN,ISBN,ESTADO)
VALUES (_NOMBRE,_AUTOR,_PRECIO,_STOCK,_SINOPSIS,_IMAGEN,_ISBN,1); 
END IF; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AGREGAR_USUARIO` (IN `_RUT` VARCHAR(13), IN `_NOMBRE` VARCHAR(50), IN `_APELLIDO` VARCHAR(50), IN `_CORREO` VARCHAR(100), IN `_DIRECCION` VARCHAR(100), IN `_ROL` INT(1), IN `_PASS` VARCHAR(250), IN `RUT_ADM` VARCHAR(13), IN `_COMUNA` VARCHAR(100))  BEGIN

IF(VALIDAR_ADM(RUT_ADM)=0)THEN
    SIGNAL SQLSTATE '40004'SET MESSAGE_TEXT = 'NO TIENE PERMISO';
    ELSEIF(BUSCAR_USUARIO(_RUT)=1) THEN
    SIGNAL SQLSTATE '40004'SET MESSAGE_TEXT = 'ESTE USUARIO YA EXISTE';
    ELSE
    INSERT INTO usuarios (RUT,NOMBRE,APELLIDO,COMUNA,DIRECCION)
    VALUES (_RUT,_NOMBRE,_APELLIDO,_COMUNA,_DIRECCION);
    
   INSERT INTO registro_usuarios (RUT_USUARIO,CORREO,PASS,ROL)
   VALUES (_RUT,_CORREO,_PASS,_ROL);

END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DESCONTAR_STOCK` (IN `_ID` INT, IN `_STOCK` INT)  BEGIN

DECLARE ST INT DEFAULT 0;
Select STOCK into ST from libros where ID = _ID;

IF(_STOCK> ST) THEN

SIGNAL SQLSTATE '30003' SET MESSAGE_TEXT = 'Producto Sin Stock';

ELSE

UPDATE libros SET
STOCK = STOCK - _STOCK   WHERE ID = _ID;

END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ELIMINAR_USUARIO` (`ADM` VARCHAR(13), `_RUT` VARCHAR(13))  BEGIN

IF(VALIDAR_ADM(ADM)=0) THEN 

SIGNAL SQLSTATE '40004' SET MESSAGE_TEXT = 'NO TIENE PERMISO';

ELSE

UPDATE registro_usuarios SET estado = 0 where RUT_USUARIO = _RUT;

END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PEDIDO` (`_ID` INT, `_RUT` VARCHAR(13))  BEGIN

INSERT INTO pedido (ID,RUT_USUARIO,FECHA) 
VALUES
(_ID,_RUT,CURDATE());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `REGISTRAR_CLIENTE` (IN `_RUT` VARCHAR(10), IN `_NOMBRE` VARCHAR(50), IN `_APELLIDO` VARCHAR(50), IN `_CORREO` VARCHAR(100), IN `_DIRECCION` VARCHAR(100), IN `_PASS` VARCHAR(250), IN `_COMUNA` INT(3))  BEGIN

IF(BUSCAR_USUARIO(_RUT)=1) THEN

   SIGNAL SQLSTATE '40004'SET MESSAGE_TEXT = 'ESTE USUARIO YA EXISTE';
    ELSE
   INSERT INTO usuarios (RUT,NOMBRE,APELLIDO,COMUNA,DIRECCION)
    VALUES (_RUT,_NOMBRE,_APELLIDO,_COMUNA,_DIRECCION);
    
   INSERT INTO registro_usuarios (RUT_USUARIO,CORREO,PASS,ROL)
   VALUES (_RUT,_CORREO,_PASS,'3');
   
   END IF;
END$$

--
-- Funciones
--
CREATE DEFINER=`root`@`localhost` FUNCTION `BUSCAR_LIBRO` (`_ISBN` VARCHAR(150)) RETURNS INT(11) BEGIN

DECLARE CONTADOR INT DEFAULT 0;

SELECT COUNT(*) INTO CONTADOR
FROM libros WHERE ISBN = _ISBN;

RETURN CONTADOR;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `BUSCAR_USUARIO` (`RUT_U` VARCHAR(10)) RETURNS INT(11) BEGIN

DECLARE CONTADOR INT DEFAULT 0;

SELECT COUNT(*) INTO CONTADOR 
FROM usuarios WHERE RUT = RUT_U;

RETURN CONTADOR;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `VALIDAR_ADM` (`RUT_U` VARCHAR(10)) RETURNS INT(1) BEGIN

DECLARE CONTADOR INT DEFAULT 0;
DECLARE _ROL INT DEFAULT 0;

SELECT ROL INTO _ROL
FROM registro_usuarios WHERE RUT_USUARIO=RUT_U;

IF(_ROL=1) THEN

SET CONTADOR = 1;

END IF;

RETURN CONTADOR;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comunas`
--

CREATE TABLE `comunas` (
  `ID` int(10) NOT NULL,
  `NOMBRE` varchar(255) NOT NULL,
  `REGION_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `comunas`
--

INSERT INTO `comunas` (`ID`, `NOMBRE`, `REGION_ID`) VALUES
(1, 'Arica', 1),
(2, 'Camarones', 1),
(3, 'General Lagos', 1),
(4, 'Putre', 1),
(5, 'Alto Hospicio', 2),
(6, 'Iquique', 2),
(7, 'Camiña', 2),
(8, 'Colchane', 2),
(9, 'Huara', 2),
(10, 'Pica', 2),
(11, 'Pozo Almonte', 2),
(12, 'Antofagasta', 3),
(13, 'Mejillones', 3),
(14, 'Sierra Gorda', 3),
(15, 'Taltal', 3),
(16, 'Calama', 3),
(17, 'Ollague', 3),
(18, 'San Pedro de Atacama', 3),
(19, 'María Elena', 3),
(20, 'Tocopilla', 3),
(21, 'Chañaral', 4),
(22, 'Diego de Almagro', 4),
(23, 'Caldera', 4),
(24, 'Copiapó', 4),
(25, 'Tierra Amarilla', 4),
(26, 'Alto del Carmen', 4),
(27, 'Freirina', 4),
(28, 'Huasco', 4),
(29, 'Vallenar', 4),
(30, 'Canela', 5),
(31, 'Illapel', 5),
(32, 'Los Vilos', 5),
(33, 'Salamanca', 5),
(34, 'Andacollo', 5),
(35, 'Coquimbo', 5),
(36, 'La Higuera', 5),
(37, 'La Serena', 5),
(38, 'Paihuaco', 5),
(39, 'Vicuña', 5),
(40, 'Combarbalá', 5),
(41, 'Monte Patria', 5),
(42, 'Ovalle', 5),
(43, 'Punitaqui', 5),
(44, 'Río Hurtado', 5),
(45, 'Isla de Pascua', 6),
(46, 'Calle Larga', 6),
(47, 'Los Andes', 6),
(48, 'Rinconada', 6),
(49, 'San Esteban', 6),
(50, 'La Ligua', 6),
(51, 'Papudo', 6),
(52, 'Petorca', 6),
(53, 'Zapallar', 6),
(54, 'Hijuelas', 6),
(55, 'La Calera', 6),
(56, 'La Cruz', 6),
(57, 'Limache', 6),
(58, 'Nogales', 6),
(59, 'Olmué', 6),
(60, 'Quillota', 6),
(61, 'Algarrobo', 6),
(62, 'Cartagena', 6),
(63, 'El Quisco', 6),
(64, 'El Tabo', 6),
(65, 'San Antonio', 6),
(66, 'Santo Domingo', 6),
(67, 'Catemu', 6),
(68, 'Llaillay', 6),
(69, 'Panquehue', 6),
(70, 'Putaendo', 6),
(71, 'San Felipe', 6),
(72, 'Santa María', 6),
(73, 'Casablanca', 6),
(74, 'Concón', 6),
(75, 'Juan Fernández', 6),
(76, 'Puchuncaví', 6),
(77, 'Quilpué', 6),
(78, 'Quintero', 6),
(79, 'Valparaíso', 6),
(80, 'Villa Alemana', 6),
(81, 'Viña del Mar', 6),
(82, 'Colina', 7),
(83, 'Lampa', 7),
(84, 'Tiltil', 7),
(85, 'Pirque', 7),
(86, 'Puente Alto', 7),
(87, 'San José de Maipo', 7),
(88, 'Buin', 7),
(89, 'Calera de Tango', 7),
(90, 'Paine', 7),
(91, 'San Bernardo', 7),
(92, 'Alhué', 7),
(93, 'Curacaví', 7),
(94, 'María Pinto', 7),
(95, 'Melipilla', 7),
(96, 'San Pedro', 7),
(97, 'Cerrillos', 7),
(98, 'Cerro Navia', 7),
(99, 'Conchalí', 7),
(100, 'El Bosque', 7),
(101, 'Estación Central', 7),
(102, 'Huechuraba', 7),
(103, 'Independencia', 7),
(104, 'La Cisterna', 7),
(105, 'La Granja', 7),
(106, 'La Florida', 7),
(107, 'La Pintana', 7),
(108, 'La Reina', 7),
(109, 'Las Condes', 7),
(110, 'Lo Barnechea', 7),
(111, 'Lo Espejo', 7),
(112, 'Lo Prado', 7),
(113, 'Macul', 7),
(114, 'Maipú', 7),
(115, 'Ñuñoa', 7),
(116, 'Pedro Aguirre Cerda', 7),
(117, 'Peñalolén', 7),
(118, 'Providencia', 7),
(119, 'Pudahuel', 7),
(120, 'Quilicura', 7),
(121, 'Quinta Normal', 7),
(122, 'Recoleta', 7),
(123, 'Renca', 7),
(124, 'San Miguel', 7),
(125, 'San Joaquín', 7),
(126, 'San Ramón', 7),
(127, 'Santiago', 7),
(128, 'Vitacura', 7),
(129, 'El Monte', 7),
(130, 'Isla de Maipo', 7),
(131, 'Padre Hurtado', 7),
(132, 'Peñaflor', 7),
(133, 'Talagante', 7),
(134, 'Codegua', 8),
(135, 'Coínco', 8),
(136, 'Coltauco', 8),
(137, 'Doñihue', 8),
(138, 'Graneros', 8),
(139, 'Las Cabras', 8),
(140, 'Machalí', 8),
(141, 'Malloa', 8),
(142, 'Mostazal', 8),
(143, 'Olivar', 8),
(144, 'Peumo', 8),
(145, 'Pichidegua', 8),
(146, 'Quinta de Tilcoco', 8),
(147, 'Rancagua', 8),
(148, 'Rengo', 8),
(149, 'Requínoa', 8),
(150, 'San Vicente de Tagua Tagua', 8),
(151, 'La Estrella', 8),
(152, 'Litueche', 8),
(153, 'Marchihue', 8),
(154, 'Navidad', 8),
(155, 'Peredones', 8),
(156, 'Pichilemu', 8),
(157, 'Chépica', 8),
(158, 'Chimbarongo', 8),
(159, 'Lolol', 8),
(160, 'Nancagua', 8),
(161, 'Palmilla', 8),
(162, 'Peralillo', 8),
(163, 'Placilla', 8),
(164, 'Pumanque', 8),
(165, 'San Fernando', 8),
(166, 'Santa Cruz', 8),
(167, 'Cauquenes', 9),
(168, 'Chanco', 9),
(169, 'Pelluhue', 9),
(170, 'Curicó', 9),
(171, 'Hualañé', 9),
(172, 'Licantén', 9),
(173, 'Molina', 9),
(174, 'Rauco', 9),
(175, 'Romeral', 9),
(176, 'Sagrada Familia', 9),
(177, 'Teno', 9),
(178, 'Vichuquén', 9),
(179, 'Colbún', 9),
(180, 'Linares', 9),
(181, 'Longaví', 9),
(182, 'Parral', 9),
(183, 'Retiro', 9),
(184, 'San Javier', 9),
(185, 'Villa Alegre', 9),
(186, 'Yerbas Buenas', 9),
(187, 'Constitución', 9),
(188, 'Curepto', 9),
(189, 'Empedrado', 9),
(190, 'Maule', 9),
(191, 'Pelarco', 9),
(192, 'Pencahue', 9),
(193, 'Río Claro', 9),
(194, 'San Clemente', 9),
(195, 'San Rafael', 9),
(196, 'Talca', 9),
(197, 'Bulnes', 10),
(198, 'Chillán', 10),
(199, 'Chillán Viejo', 10),
(200, 'Cobquecura', 10),
(201, 'Coelemu', 10),
(202, 'Coihueco', 10),
(203, 'El Carmen', 10),
(204, 'Ninhue', 10),
(205, 'Ñiquen', 10),
(206, 'Pemuco', 10),
(207, 'Pinto', 10),
(208, 'Portezuelo', 10),
(209, 'Quirihue', 10),
(210, 'Ránquil', 10),
(211, 'Treguaco', 10),
(212, 'Quillón', 10),
(213, 'San Carlos', 10),
(214, 'San Fabián', 10),
(215, 'San Ignacio', 10),
(216, 'San Nicolás', 10),
(217, 'Yungay', 10),
(218, 'Arauco', 11),
(219, 'Cañete', 11),
(220, 'Contulmo', 11),
(221, 'Curanilahue', 11),
(222, 'Lebu', 11),
(223, 'Los Álamos', 11),
(224, 'Tirúa', 11),
(225, 'Alto Biobío', 11),
(226, 'Antuco', 11),
(227, 'Cabrero', 11),
(228, 'Laja', 11),
(229, 'Los Ángeles', 11),
(230, 'Mulchén', 11),
(231, 'Nacimiento', 11),
(232, 'Negrete', 11),
(233, 'Quilaco', 11),
(234, 'Quilleco', 11),
(235, 'San Rosendo', 11),
(236, 'Santa Bárbara', 11),
(237, 'Tucapel', 11),
(238, 'Yumbel', 11),
(239, 'Chiguayante', 11),
(240, 'Concepción', 11),
(241, 'Coronel', 11),
(242, 'Florida', 11),
(243, 'Hualpén', 11),
(244, 'Hualqui', 11),
(245, 'Lota', 11),
(246, 'Penco', 11),
(247, 'San Pedro de La Paz', 11),
(248, 'Santa Juana', 11),
(249, 'Talcahuano', 11),
(250, 'Tomé', 11),
(251, 'Carahue', 12),
(252, 'Cholchol', 12),
(253, 'Cunco', 12),
(254, 'Curarrehue', 12),
(255, 'Freire', 12),
(256, 'Galvarino', 12),
(257, 'Gorbea', 12),
(258, 'Lautaro', 12),
(259, 'Loncoche', 12),
(260, 'Melipeuco', 12),
(261, 'Nueva Imperial', 12),
(262, 'Padre Las Casas', 12),
(263, 'Perquenco', 12),
(264, 'Pitrufquén', 12),
(265, 'Pucón', 12),
(266, 'Saavedra', 12),
(267, 'Temuco', 12),
(268, 'Teodoro Schmidt', 12),
(269, 'Toltén', 12),
(270, 'Vilcún', 12),
(271, 'Villarrica', 12),
(272, 'Angol', 12),
(273, 'Collipulli', 12),
(274, 'Curacautín', 12),
(275, 'Ercilla', 12),
(276, 'Lonquimay', 12),
(277, 'Los Sauces', 12),
(278, 'Lumaco', 12),
(279, 'Purén', 12),
(280, 'Renaico', 12),
(281, 'Traiguén', 12),
(282, 'Victoria', 12),
(283, 'Corral', 13),
(284, 'Lanco', 13),
(285, 'Los Lagos', 13),
(286, 'Máfil', 13),
(287, 'Mariquina', 13),
(288, 'Paillaco', 13),
(289, 'Panguipulli', 13),
(290, 'Valdivia', 13),
(291, 'Futrono', 13),
(292, 'La Unión', 13),
(293, 'Lago Ranco', 13),
(294, 'Río Bueno', 13),
(295, 'Ancud', 14),
(296, 'Castro', 14),
(297, 'Chonchi', 14),
(298, 'Curaco de Vélez', 14),
(299, 'Dalcahue', 14),
(300, 'Puqueldón', 14),
(301, 'Queilén', 14),
(302, 'Quemchi', 14),
(303, 'Quellón', 14),
(304, 'Quinchao', 14),
(305, 'Calbuco', 14),
(306, 'Cochamó', 14),
(307, 'Fresia', 14),
(308, 'Frutillar', 14),
(309, 'Llanquihue', 14),
(310, 'Los Muermos', 14),
(311, 'Maullín', 14),
(312, 'Puerto Montt', 14),
(313, 'Puerto Varas', 14),
(314, 'Osorno', 14),
(315, 'Puero Octay', 14),
(316, 'Purranque', 14),
(317, 'Puyehue', 14),
(318, 'Río Negro', 14),
(319, 'San Juan de la Costa', 14),
(320, 'San Pablo', 14),
(321, 'Chaitén', 14),
(322, 'Futaleufú', 14),
(323, 'Hualaihué', 14),
(324, 'Palena', 14),
(325, 'Aisén', 15),
(326, 'Cisnes', 15),
(327, 'Guaitecas', 15),
(328, 'Cochrane', 15),
(329, 'O\'higgins', 15),
(330, 'Tortel', 15),
(331, 'Coihaique', 15),
(332, 'Lago Verde', 15),
(333, 'Chile Chico', 15),
(334, 'Río Ibáñez', 15),
(335, 'Antártica', 16),
(336, 'Cabo de Hornos', 16),
(337, 'Laguna Blanca', 16),
(338, 'Punta Arenas', 16),
(339, 'Río Verde', 16),
(340, 'San Gregorio', 16),
(341, 'Porvenir', 16),
(342, 'Primavera', 16),
(343, 'Timaukel', 16),
(344, 'Natales', 16),
(345, 'Torres del Paine', 16),
(346, 'Cabildo', 6);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_boleta`
--

CREATE TABLE `detalle_boleta` (
  `ID_DETALLE` int(11) NOT NULL,
  `ID_PEDIDO` int(11) NOT NULL,
  `ID_LIB` int(11) NOT NULL,
  `PRECIO_UNITARIO` int(11) NOT NULL,
  `TOTAL` int(11) NOT NULL,
  `CANTIDAD` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `detalle_boleta`
--

INSERT INTO `detalle_boleta` (`ID_DETALLE`, `ID_PEDIDO`, `ID_LIB`, `PRECIO_UNITARIO`, `TOTAL`, `CANTIDAD`) VALUES
(1, 1, 7, 17000, 17000, 1),
(102, 2, 17, 7000, 49000, 7),
(103, 3, 1, 10000, 10000, 1),
(104, 3, 18, 11000, 11000, 1),
(105, 3, 20, 10000, 20000, 2),
(106, 4, 24, 7000, 7000, 1),
(107, 4, 25, 14000, 14000, 1),
(108, 5, 15, 15000, 15000, 1),
(109, 6, 7, 17000, 17000, 1),
(110, 6, 9, 25000, 700000, 28),
(111, 7, 23, 10000, 10000, 1),
(112, 7, 24, 7000, 7000, 1),
(113, 7, 25, 14000, 14000, 1),
(114, 8, 4, 17000, 17000, 1),
(115, 9, 1, 10000, 10000, 1),
(116, 9, 3, 15000, 15000, 1),
(117, 10, 18, 11000, 11000, 1),
(118, 11, 15, 15000, 15000, 1),
(119, 11, 21, 15000, 210000, 14),
(120, 12, 2, 20000, 280000, 14),
(121, 12, 21, 15000, 105000, 7),
(122, 13, 23, 10000, 10000, 1),
(123, 13, 22, 20000, 20000, 1),
(124, 13, 24, 7000, 7000, 1),
(125, 13, 25, 14000, 14000, 1);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `detalle_venta`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `detalle_venta` (
`NOMBRE` varchar(250)
,`CANTIDAD` int(11)
,`PRECIO_UNITARIO` int(11)
,`TOTAL` int(11)
,`COD_PEDIDO` int(11)
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `libros`
--

CREATE TABLE `libros` (
  `ID` int(11) NOT NULL,
  `NOMBRE` varchar(250) COLLATE utf8_unicode_ci NOT NULL,
  `AUTOR` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `IMAGEN` varchar(250) COLLATE utf8_unicode_ci NOT NULL,
  `SINOPSIS` text COLLATE utf8_unicode_ci NOT NULL,
  `PRECIO` int(11) NOT NULL,
  `STOCK` int(3) NOT NULL,
  `ISBN` varchar(14) COLLATE utf8_unicode_ci NOT NULL,
  `ESTADO` tinyint(1) NOT NULL
) ;

--
-- Volcado de datos para la tabla `libros`
--

INSERT INTO `libros` (`ID`, `NOMBRE`, `AUTOR`, `IMAGEN`, `SINOPSIS`, `PRECIO`, `STOCK`, `ISBN`, `ESTADO`) VALUES
(1, 'Ciudad de Hueso', 'Stephanie Meyer', 'https://vignette.wikia.nocookie.net/shadowhunters/images/2/21/CDS1_portada_ES_01.jpg/revision/latest?cb=20130103192518&path-prefix=es', 'Una historia oscura de amor y demonios, que entusiasmará a las seguidoras de Stephenie Meyer y L.J.Smith. En el Pandemonium, la discoteca de moda de Nueva York, Clary sigue a un atractivo chico de pelo azul hasta que presencia su muerte a manos de tres jóvenes cubiertos de extraños tatuajes. Desde esa noche, su destino se une al de esos tres cazadores de sombras, guerreros dedicados a liberar a la tierra de demonios.', 10000, 8, '9781416914280', 1),
(2, 'La Chica Del Tren', 'Paula Hawkins', 'https://www.planetadelibros.com/usuaris/libros/fotos/250/m_libros/portada_la-chica-del-tren_paula-hawkins_201702281633.jpg', 'Rachel Watson, una mujer con problemas con el alcohol que envidia lo poco que puede ver de la vida perfecta de Scott y Megan, la pareja ante cuya casa pasa cada día de camino al trabajo, descubre que algo terrible ha ocurrido en la vivienda y decide entrometerse para intentar resolver el enigma.', 20000, 35, '9789562479882', 1),
(3, 'El Nombre Del Viento', 'Patrick Rothfuss', 'https://images-na.ssl-images-amazon.com/images/I/7125ljaY0gL.jpg', 'En una posada en tierra de nadie, un hombre se dispone a relatar, por primera vez, la auténtica historia de su vida. Una historia que únicamente él conoce y que ha quedado diluida tras los rumores, las conjeturas y los cuentos de taberna que le han convertido en un personaje legendario a quien todos daban ya por muerto: Kvothe... músico, mendigo, ladrón, estudiante, mago, héroe y asesino.', 15000, 14, '9789506441746', 1),
(4, 'El Resto Es Silencio', 'Carla Guelfenbein', 'https://images.cdn1.buscalibre.com/fit-in/360x360/16/ab/16ab851e9139bdc65933f5864d8bf1d3.jpg', 'Una historia de vida, amor y redención. Todas las familias esconden un secreto. Tommy, un niño sensible y muy particular, se ha propuesto averiguar el de la suya: la verdad sobre la muerte de su madre. ... Una historia puzzle en donde no falta ni sobra ninguna pieza.', 17000, 32, '9789563252040', 1),
(5, 'Identidad', 'Francis Fukuyama', 'https://static2planetadelibroscom.cdnstatics.com/usuaris/libros/fotos/291/original/portada___201812031014.jpg', 'En algún momento a mediados de la segunda década del siglo XXI, la política mundial cambió drásticamente. Desde entonces, ha estado guiada por demandas de carácter identitario. Las ideas de nación, religión, raza, género, etnia y clase han sustituido a una noción más amplia e inclusiva de quiénes somos: simples ciudadanos. Hemos construido muros en lugar de puentes. Y el resultado es un creciente sentimiento antiinmigratorio, además de agrias discusiones sobre víctimas y victimarios y el retorno de políticas abiertamente supremacistas y chovinistas.', 20000, 1, '9788423430284', 1),
(7, 'El Enigma De La Habitación 622', 'Joël Dicker', 'https://m.media-amazon.com/images/I/41zwNGOS5BL.jpg', 'Año 2018. El joven y exitoso escritor Joël Dicker, tras sufrir una ruptura amorosa y una fuerte adicción a la escritura, decide ir a descansar al lugar preferido de Bernard de Fallois, su antiguo editor: el Palace de Verbier, un hotel de lujo a pocos kilómetros de Ginebra. Allí conocerá a Scarlett, una joven que le acompañará en la investigación del misterio de la habitación 622 y en la escritura del fascinante thriller que estamos leyendo.', 17000, 39, '9789563841770', 1),
(9, 'El Último Deseo, The Witcher ', 'Andrzej Sapkowski', 'https://static.serlogal.com/imagenes_big/9788498/978849889065.JPG', 'Geralt de Rivia, brujo y mutante sobrehumano, se gana la vida como cazador de monstruos en una tierra de magia y maravilla: con sus dos espadas al hombro -la de acero para hombres, y la de plata para bestias- da cuenta de estriges, manticoras, grifos, vampiros, quimeras  y lobisomes, pero sólo cuando amenazan la paz. Irónico, cínico, descreído y siempre errante, sus pasos lo llevan de pueblo en pueblo ofreciendo sus servicios, hallando las más de las veces que los auténticos monstruos se esconden bajo rostros humanos.', 25000, 22, '9788498891270', 1),
(15, 'Bajo El Manto De Urania', 'José María Maza Sancho', 'https://www.planetadelibros.cl/usuaris/libros/fotos/320/m_libros/portada_bajo-el-manto-de-urania_jose-maza_202005262311.jpg', 'Urania, la musa de la astronomía, es quien ha guiado los sueños de tantas personas en la historia y bajo su manto (el cielo), la ciencia se ha cobijado en busca de los misterios del cosmos.', 15000, 42, '9789563607543', 1),
(16, 'El Poder Del Click', 'Pablo Halpern y Francisca Lobos ', 'https://www.feriachilenadellibro.cl/pub/media/catalog/product/cache/1/image/200x256/e9c3970ab036de70892d86c6d221abfe/9/7/9789569986604.jpg', 'La pandemia mundial que nos afecta obligó a las organizaciones y empresas a funcionar de manera remota. De un momento a otroda interacción con los usuarios —ya sean clientes, consumidores, empleados o alumnos— ha comenzado a ser en línea. Pero ¿cómo responder efectivamente a este desafío?, ¿cuáles son los riesgos que se deben considerar? Aquí todas las respuestas para subsistir en la nueva era digital.', 13000, 9, '9789569986604', 1),
(17, 'Un Perro Confundido', 'Cecilia Beuchat', 'https://www.libreriadelgam.cl/imagenes/9789563/978956349616.JPG', 'Amadeo, el perro salchicha de los Martínez, es el más regalón de la familia: todos lo miman, y él vive feliz y tranquilo. Hasta que un día, escucha algo que lo deja atónito...\r\n', 7000, 7, '9789563496161', 1),
(18, 'Sapo y Sepo, Inseparables', 'Arnold Lobel', 'https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcRIEoDpSqSPqFCHsMYTVGr9lH1puS5919mLYBeZBvYjtf5v691z', 'Sapo es activo y sensato; Sepo, por el contrario es pasivo y un poco atolondrado. El contraste entre sus personalidades dará origen a una relación de amigos inseparables, llena de simpatía y buen humor.  ', 11000, 45, '9786070134098', 1),
(19, 'El Bolígrafo De Gel Verde', 'Eloy Moreno', 'http://quelibroleo.com/images/libros/libro-1587024508.jpg', 'SUPERFICIES DE VIDA:\r\nCasa: 89 m²\r\nAscensor: 3 m²\r\nGaraje: 8 m²\r\nEmpresa: la sala, unos 80 m².\r\n\r\n¿Puede alguien vivir en 445 m² durante el resto de su vida?. \r\nPersonas que se desplazan por una celda sin estar presas; que se levantan cada día sabiendo que todo va a ser igual que ayer, igual que mañana; personas que a pesar \r\nde estar vivas se sienten muertas.', 35000, 0, '9788490703496', 1),
(20, 'La Chica Que Lo Tenía Todo', 'Jessica Knoll', 'https://images.cdn2.buscalibre.com/fit-in/360x360/d6/cd/d6cdb918b87e15aefa66301ebc8267fb.jpg', 'Como estudiante en la prestigiosa escuela Bradley, Ani FaNelli no pasó la mejor de las adolescencias. Ahora, con un trabajo glamoroso, ropa cara y un novio muy apuesto, está cerca de concretar esa vida con la que siempre soñó. Pero Ani tiene un secreto: algo oculto y doloroso de su pasado aún la persigue y amenaza.  ', 10000, 48, ' 9788416700233', 1),
(21, 'Escrito En EL Agua', 'Paula Hawkins', 'https://images.cdn1.buscalibre.com/fit-in/360x360/f8/ba/f8baf14c0bf2fb0403a00c21b9c01bde.jpg', 'Pocos días antes de morir, Nel Abbott estuvo llamando a su hermana, pero Jules no cogió el teléfono, ignoró sus súplicas de ayuda. Ahora Nel está muerta. Dicen que saltó al río. Y Jules se ve arrastrada al pequeño pueblo de los veranos de su infancia, un lugar del que creía haber escapado, para cuidar de la adolescente que su hermana deja atrás. Pero Jules tiene miedo. Mucho miedo. Miedo al agua, miedo de sus recuerdos enterrados largo tiempo atrás, y miedo, sobre todo, de su certeza de que Nel nunca habría saltado?No te fíes nunca de una superficie en calma, no sabes lo que puede haber debajo.', 15000, 28, '9788408191247', 1),
(22, 'El Resplandor', 'Stephen King', 'https://images.cdn3.buscalibre.com/fit-in/360x360/7c/c2/7cc2d89ff2df8d15fe52b511d8197a3f.jpg', 'REDRUM. Ésa es la palabra que Danny había visto en el espejo. Y, aunque no sabía leer, entendió que era un mensaje de horror. Danny tenía cinco años, y a esa edad pocos niños saben que los espejos invierten las imágenes y menos aún saben diferenciar entre realidad y fantasía. Pero Danny tenía pruebas de que sus fantasías relacionadas con el resplandor del espejo acabarían cumpliéndose: REDRUM MURDER, asesinato. De todos modos, necesitaban aquel trabajo en el hotel. Danny sabía que su madre pensaba en el divorcio y que su padre se obsesionaba con algo\r\nmuy malo, tan malo como la muerte y el suicidio. Sí, su padre tenía que aceptar la propuesta de cuidar de aquel hotel de lujo de más de cien habitaciones, aislado por la nieve durante seis meses. Hasta el deshielo iban a estar solos... ¿Solos?', 20000, 40, '9786073118392', 1),
(23, 'It (Eso)', 'Stephen King', 'https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcSeRv-0tB7o8Z09dV66xIg0GM7_avlppfOfF7kgvS3g3RQkLG5T', '¿Quién o qué mutila y mata a los niños de un pequeño pueblo norteamericano? ¿Por qué llega cíclicamente el horror a Derry en forma de un payaso siniestro que va sembrando la destrucción a su paso?\r\n\r\nEsto es lo que se proponen averiguar los protagonistas de esta novela. Tras veintisiete años de tranquilidad y lejanía una antigua promesa infantil les hace volver al lugar en el que vivieron su infancia y juventud como una terrible pesadilla. Regresan a Derry para enfrentarse con su pasado y enterrar definitivamente la amenaza que los amargó durante su niñez.', 10000, 30, '9789877250244', 1),
(24, 'Carrie', 'Stephen King', 'https://www.antartica.cl/antartica/gfx_libros/144/9788497595698.jpg', 'El escalofriante caso de una joven de apariencia insignificante que se transformó en un ser de poderes anormales, sembrando el terror en la ciudad. Con pulso mágico para mantener la tensión a lo largo de todo el libro, Stephen King narra la atormentada adolescencia de Carrie, y nos envuelve en una atmósfera sobrecogedora cuando la muchacha realiza una serie de descubrimientos hasta llegar al terrible momento de la venganza. Esta novela fue llevada al cine con un inmenso éxito de público y crítica. ', 7000, 8, '9788497595698', 1),
(25, 'La Caja De Botones De Gwendy', 'Stephen King', 'https://www.antartica.cl/antartica/gfx_libros/144/9788491292418.jpg', 'Existen tres vías para llegar a Castle View desde la ciudad de Castle Rock: por la carretera 117, por Pleasant Road y por las Escaleras de los Suicidios. Cada día del verano de 1974, Gwendy Peterson, de doce años de edad, toma el camino de las escaleras, que ascienden en zigzag por la ladera rocosa.\r\n\r\nPero un día, al llegar a lo alto, mientras recupera el aliento con la cara roja y las manos apoyadas sobre las rodillas, un desconocido la llama. Allí, en un banco a la sombra, se sienta un hombre con una chaqueta negra y un pequeño sombrero. Llegará un día en el que Gwendy sufra pesadillas con ese sombrero...', 14000, 45, '9788491292418', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pedido`
--

CREATE TABLE `pedido` (
  `ID` int(11) NOT NULL,
  `FECHA` varchar(10) COLLATE utf8_unicode_ci NOT NULL,
  `RUT_USUARIO` varchar(10) COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `pedido`
--

INSERT INTO `pedido` (`ID`, `FECHA`, `RUT_USUARIO`) VALUES
(1, '13-09-2020', '19081946-9'),
(2, '2020-09-13', '19081946-9'),
(3, '2020-09-13', '20521935-8'),
(4, '2020-09-13', '20521935-8'),
(5, '2020-09-13', '20521935-8'),
(6, '2020-09-13', '20521935-8'),
(7, '2020-09-13', '19848207-2'),
(8, '2020-09-13', '19848207-2'),
(9, '2020-09-13', '19848207-2'),
(10, '2020-09-13', '19848207-2'),
(11, '2020-09-13', '19848207-2'),
(12, '2020-09-13', '15757508-2'),
(13, '2020-09-13', '15757508-2');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `registro_usuarios`
--

CREATE TABLE `registro_usuarios` (
  `ID_RU` int(11) NOT NULL,
  `RUT_USUARIO` varchar(10) COLLATE utf8_unicode_ci NOT NULL,
  `CORREO` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `PASS` varchar(250) COLLATE utf8_unicode_ci NOT NULL,
  `ROL` int(1) NOT NULL,
  `ESTADO` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `registro_usuarios`
--

INSERT INTO `registro_usuarios` (`ID_RU`, `RUT_USUARIO`, `CORREO`, `PASS`, `ROL`, `ESTADO`) VALUES
(16, '19081946-9', 'diegoescurraromero@gmail.com', '$2a$04$SmcDsRIc1DAECU1cOf0Biec8KdQxTIg/trOplIB1QCHkxp764tvnK', 1, 1),
(19, '23981261-9', 'gabi21@gmail.com', '$2a$04$C2pVg1rK7w5pXO9pmlNPJeQXOm/cGht9zmFcedRZC7SA1ojTnOVUO', 2, 1),
(20, '19645151-K', 'whatever@gmail.com', '$2a$04$bZiOfzJ4nDKoJpE89of5lOW4PNUjDrWMMwXmReTSM9TqFNnSH9Mq2', 3, 1),
(21, '20521935-8', 'gustavojavier2612@gmail.com', '$2a$04$xuZT2Bun8bz91CojnZmeC.A9VGYvYeJoz1.QFjkyXym1pJlSG1lPW', 3, 1),
(22, '19848207-2', 'dany-carrasco@hotmail.com', '$2a$04$jEBTEQ1L6HNpOb/gtirnp.4pqrD/frQZjzhlQMsgmx7e6SQZWhgk.', 3, 1),
(23, '15757508-2', 'abril_2426@hotmail.com', '$2a$04$2auLvw9q59RAHeWrbLlEJupRyqdvuTuhoQdWEogS6um74m0QuLaOe', 1, 1),
(24, '24295891-8', 'jtastorga@noexisto.com', '$2a$04$fWJmZPe5WIZEU/NO0aRrluLilyO8BOogzknDyG5iOgwZqD031bIuW', 3, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sessions`
--

CREATE TABLE `sessions` (
  `session_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `expires` int(11) UNSIGNED NOT NULL,
  `data` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `sessions`
--

INSERT INTO `sessions` (`session_id`, `expires`, `data`) VALUES
('EyPHNjMF4VOJTbFmIOWIv5pRpNHwkBgQ', 1600129211, '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{}}'),
('RI04JOTp2sVnzVVZ_-fCJa9xu5bXvTR6', 1600129625, '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{}}'),
('YbYx-7BiylXsHW-yvDyg39iAwfhrH9jG', 1600129635, '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{},\"passport\":{\"user\":\"19081946-9\"},\"cart\":{}}'),
('dcGMhMRayIFOJI9SC-fB0orTWv1G0Gxf', 1600130087, '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{},\"passport\":{\"user\":\"15757508-2\"},\"cart\":{}}'),
('l-0ZUr1ybHxs_rrnlUm0oUdyig78OMnI', 1600127664, '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{}}'),
('mWZ-y3pffSiHp_q_z1PZbhFNwJr58BgS', 1600108676, '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{}}'),
('tvWqZbat6ydITK3Me6-W8Gq3Qr0Zvo7z', 1600129549, '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{}}'),
('xR3DTydGDTSAABYhnbu41hy2Y9yxWvTh', 1600135306, '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{}}');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `RUT` varchar(10) COLLATE utf8_unicode_ci NOT NULL,
  `NOMBRE` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `APELLIDO` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `DIRECCION` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `COMUNA` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`RUT`, `NOMBRE`, `APELLIDO`, `DIRECCION`, `COMUNA`) VALUES
('15757508-2', 'Marysol', 'Romero', 'Las Heras 3027', 80),
('19038650-3', 'diego', 'chupaelpico', 'aaaaaaaa', 196),
('19081946-9', 'Diego', 'Escurra', 'Los Ángeles 135', 110),
('19645151-K', 'slania', 'slaniams', 'ki paaaa 111', 103),
('19848207-2', 'Daniela', 'Carrasco', 'Los libertadores 1330', 129),
('20521935-8', 'Gustavo', 'Romero', 'Psje Crisol', 80),
('23981261-9', 'Gabriela', 'Amaral', 'Las Acasias 456', 77),
('24295891-8', 'Juan', 'Astorga', 'Alefacia 121', 2);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `usuarios_detalle`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `usuarios_detalle` (
`rut` varchar(10)
,`nombre` varchar(50)
,`apellido` varchar(50)
,`direccion` varchar(100)
,`correo` varchar(100)
,`rol` int(1)
,`estado` tinyint(1)
,`comuna` varchar(255)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `detalle_venta`
--
DROP TABLE IF EXISTS `detalle_venta`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `detalle_venta`  AS  select `l`.`NOMBRE` AS `NOMBRE`,`dt`.`CANTIDAD` AS `CANTIDAD`,`dt`.`PRECIO_UNITARIO` AS `PRECIO_UNITARIO`,`dt`.`TOTAL` AS `TOTAL`,`dt`.`ID_PEDIDO` AS `COD_PEDIDO` from (`libros` `l` join `detalle_boleta` `dt` on(`l`.`ID` = `dt`.`ID_LIB`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `usuarios_detalle`
--
DROP TABLE IF EXISTS `usuarios_detalle`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `usuarios_detalle`  AS  select `u`.`RUT` AS `rut`,`u`.`NOMBRE` AS `nombre`,`u`.`APELLIDO` AS `apellido`,`u`.`DIRECCION` AS `direccion`,`ru`.`CORREO` AS `correo`,`ru`.`ROL` AS `rol`,`ru`.`ESTADO` AS `estado`,`comunas`.`NOMBRE` AS `comuna` from ((`usuarios` `u` join `registro_usuarios` `ru` on(`u`.`RUT` = `ru`.`RUT_USUARIO`)) join `comunas` on(`u`.`COMUNA` = `comunas`.`ID`)) ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `comunas`
--
ALTER TABLE `comunas`
  ADD PRIMARY KEY (`ID`);

--
-- Indices de la tabla `detalle_boleta`
--
ALTER TABLE `detalle_boleta`
  ADD PRIMARY KEY (`ID_DETALLE`),
  ADD KEY `FK_DETALLE2` (`ID_LIB`),
  ADD KEY `FK_DETALLE` (`ID_PEDIDO`);

--
-- Indices de la tabla `libros`
--
ALTER TABLE `libros`
  ADD PRIMARY KEY (`ID`);

--
-- Indices de la tabla `pedido`
--
ALTER TABLE `pedido`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `FK_BOLETA` (`RUT_USUARIO`);

--
-- Indices de la tabla `registro_usuarios`
--
ALTER TABLE `registro_usuarios`
  ADD PRIMARY KEY (`ID_RU`),
  ADD KEY `FK_USUARIO` (`RUT_USUARIO`);

--
-- Indices de la tabla `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`session_id`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`RUT`),
  ADD KEY `COMUNA` (`COMUNA`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `comunas`
--
ALTER TABLE `comunas`
  MODIFY `ID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=347;

--
-- AUTO_INCREMENT de la tabla `detalle_boleta`
--
ALTER TABLE `detalle_boleta`
  MODIFY `ID_DETALLE` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=126;

--
-- AUTO_INCREMENT de la tabla `libros`
--
ALTER TABLE `libros`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `pedido`
--
ALTER TABLE `pedido`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=103;

--
-- AUTO_INCREMENT de la tabla `registro_usuarios`
--
ALTER TABLE `registro_usuarios`
  MODIFY `ID_RU` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `detalle_boleta`
--
ALTER TABLE `detalle_boleta`
  ADD CONSTRAINT `FK_PEDIDO` FOREIGN KEY (`ID_PEDIDO`) REFERENCES `pedido` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_PRODUCTO` FOREIGN KEY (`ID_LIB`) REFERENCES `libros` (`ID`);

--
-- Filtros para la tabla `pedido`
--
ALTER TABLE `pedido`
  ADD CONSTRAINT `FK_USUARIO1` FOREIGN KEY (`RUT_USUARIO`) REFERENCES `usuarios` (`RUT`);

--
-- Filtros para la tabla `registro_usuarios`
--
ALTER TABLE `registro_usuarios`
  ADD CONSTRAINT `FK_USUARIO` FOREIGN KEY (`RUT_USUARIO`) REFERENCES `usuarios` (`RUT`);

--
-- Filtros para la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `usuarios_ibfk_1` FOREIGN KEY (`COMUNA`) REFERENCES `comunas` (`ID`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

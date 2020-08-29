-- phpMyAdmin SQL Dump
-- version 4.9.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 29-08-2020 a las 02:03:44
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `ACTUALIZAR_USUARIO` (IN `_RUT` VARCHAR(10), IN `_NOMBRE` VARCHAR(50), IN `_APELLIDO` VARCHAR(50), IN `_CORREO` VARCHAR(100), IN `_DIRECCION` VARCHAR(100), IN `_PASS` VARCHAR(50), IN `_ROL` INT(1), IN `_RUTADM` VARCHAR(10))  BEGIN

IF (VALIDAR_ADM(_RUTADM)=0) THEN
     SIGNAL SQLSTATE '40004' 
     SET MESSAGE_TEXT = 'NO TIENE PERMISO';
ELSE

UPDATE usuarios 

SET NOMBRE    = _NOMBRE,
    APELLIDO  = _APELLIDO,
    DIRECCION = _DIRECCION
    WHERE RUT = _RUT;
    
UPDATE registro_usuarios

SET PASS = _PASS,
    CORREO = _CORREO,
    ROL  = _ROL
    WHERE RUT_USUARIO = _RUT;

END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AGREGAR_LIBROS` (IN `_AUTOR` VARCHAR(100), IN `_IMAGEN` VARCHAR(250), IN `_NOMBRE` VARCHAR(250), IN `_PRECIO` INT(7), IN `_STOCK` INT(3), IN `_SINOPSIS` TEXT, IN `_ISBN` VARCHAR(14))  BEGIN
 IF (BUSCAR_LIBRO(_ISBN)=1) THEN SIGNAL SQLSTATE '40004'SET MESSAGE_TEXT = 'LIBRO DUPLICADO'; 
ELSE INSERT INTO libros 
(NOMBRE,AUTOR,PRECIO,STOCK,SINOPSIS,IMAGEN,ISBN,ESTADO)
VALUES (_NOMBRE,_AUTOR,_PRECIO,_STOCK,_SINOPSIS,_IMAGEN,_ISBN,1); 
END IF; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AGREGAR_USUARIO` (IN `_RUT` VARCHAR(10), IN `_NOMBRE` VARCHAR(50), IN `_APELLIDO` VARCHAR(50), IN `_CORREO` VARCHAR(100), IN `_DIRECCION` VARCHAR(100), IN `_ROL` INT(1), IN `_PASS` VARCHAR(50), IN `RUT_ADM` VARCHAR(10))  BEGIN

IF(VALIDAR_ADM(RUT_ADM)=0)THEN
    SIGNAL SQLSTATE '40004'SET MESSAGE_TEXT = 'NO TIENE PERMISO';
    ELSEIF(BUSCAR_USUARIO(_RUT)=1) THEN
    SIGNAL SQLSTATE '40004'SET MESSAGE_TEXT = 'ESTE USUARIO YA EXISTE';
    ELSE
    INSERT INTO usuarios (RUT,NOMBRE,APELLIDO,DIRECCION)
    VALUES (_RUT,_NOMBRE,_APELLIDO,_DIRECCION);
    
   INSERT INTO registro_usuarios (RUT_USUARIO,CORREO,PASS,ROL)
   VALUES (_RUT,_CORREO,_PASS,_ROL);

END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DESCONTAR_STOCK` (IN `_ID` INT, IN `_STOCK` INT)  BEGIN

DECLARE ST INT DEFAULT 0;
SELECT STOCK INTO ST FROM libros WHERE ID = _ID;


UPDATE libros SET
STOCK = STOCK - _STOCK WHERE ID = _ID ;


IF (ST<=0) THEN

SIGNAL SQLSTATE '40004' SET MESSAGE_TEXT ='ERROR';

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

CREATE DEFINER=`root`@`localhost` PROCEDURE `REGISTRAR_CLIENTE` (IN `_RUT` VARCHAR(10), IN `_NOMBRE` VARCHAR(50), IN `_APELLIDO` VARCHAR(50), IN `_CORREO` VARCHAR(100), IN `_DIRECCION` VARCHAR(100), IN `_PASS` VARCHAR(50))  BEGIN

IF(BUSCAR_USUARIO(_RUT)=1) THEN

   SIGNAL SQLSTATE '40004'SET MESSAGE_TEXT = 'ESTE USUARIO YA EXISTE';
    ELSE
   INSERT INTO usuarios (RUT,NOMBRE,APELLIDO,DIRECCION)
    VALUES (_RUT,_NOMBRE,_APELLIDO,_DIRECCION);
    
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
(3, 2, 17, 7000, 14000, 2),
(4, 3, 17, 7000, 0, 0),
(5, 4, 9, 25000, 0, 0),
(6, 4, 4, 17000, 0, 0),
(7, 5, 4, 17000, 0, 0),
(8, 6, 4, 17000, 0, 0),
(9, 7, 3, 15000, 0, 0),
(10, 8, 3, 15000, 0, 0);

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
(1, 'Ciudad de Hueso', 'Stephanie Meyer', 'https://vignette.wikia.nocookie.net/shadowhunters/images/2/21/CDS1_portada_ES_01.jpg/revision/latest?cb=20130103192518&path-prefix=es', 'Una historia oscura de amor y demonios, que entusiasmará a las seguidoras de Stephenie Meyer y L.J.Smith. En el Pandemonium, la discoteca de moda de Nueva York, Clary sigue a un atractivo chico de pelo azul hasta que presencia su muerte a manos de tres jóvenes cubiertos de extraños tatuajes. Desde esa noche, su destino se une al de esos tres cazadores de sombras, guerreros dedicados a liberar a la tierra de demonios.', 10000, 18, '9781416914280', 1),
(2, 'La Chica Del Tren', 'Paula Hawkins', 'https://www.planetadelibros.com/usuaris/libros/fotos/250/m_libros/portada_la-chica-del-tren_paula-hawkins_201702281633.jpg', 'Rachel Watson, una mujer con problemas con el alcohol que envidia lo poco que puede ver de la vida perfecta de Scott y Megan, la pareja ante cuya casa pasa cada día de camino al trabajo, descubre que algo terrible ha ocurrido en la vivienda y decide entrometerse para intentar resolver el enigma.', 20000, 9, '9789562479882', 1),
(3, 'El Nombre Del Viento', 'Patrick Rothfuss', 'https://images-na.ssl-images-amazon.com/images/I/7125ljaY0gL.jpg', 'En una posada en tierra de nadie, un hombre se dispone a relatar, por primera vez, la auténtica historia de su vida. Una historia que únicamente él conoce y que ha quedado diluida tras los rumores, las conjeturas y los cuentos de taberna que le han convertido en un personaje legendario a quien todos daban ya por muerto: Kvothe... músico, mendigo, ladrón, estudiante, mago, héroe y asesino.', 15000, 1, '9789506441746', 1),
(4, 'El Resto Es Silencio', 'Carla Guelfenbein', 'https://images.cdn1.buscalibre.com/fit-in/360x360/16/ab/16ab851e9139bdc65933f5864d8bf1d3.jpg', 'Una historia de vida, amor y redención. Todas las familias esconden un secreto. Tommy, un niño sensible y muy particular, se ha propuesto averiguar el de la suya: la verdad sobre la muerte de su madre. ... Una historia puzzle en donde no falta ni sobra ninguna pieza.', 17000, 2, '9789563252040', 1),
(5, 'Identidad', 'Francis Fukuyama', 'https://static2planetadelibroscom.cdnstatics.com/usuaris/libros/fotos/291/original/portada___201812031014.jpg', 'En algún momento a mediados de la segunda década del siglo XXI, la política mundial cambió drásticamente. Desde entonces, ha estado guiada por demandas de carácter identitario. Las ideas de nación, religión, raza, género, etnia y clase han sustituido a una noción más amplia e inclusiva de quiénes somos: simples ciudadanos. Hemos construido muros en lugar de puentes. Y el resultado es un creciente sentimiento antiinmigratorio, además de agrias discusiones sobre víctimas y victimarios y el retorno de políticas abiertamente supremacistas y chovinistas.', 20000, 17, '9788423430284', 1),
(7, 'El Enigma De La Habitación 622', 'Joël Dicker', 'https://m.media-amazon.com/images/I/41zwNGOS5BL.jpg', 'Año 2018. El joven y exitoso escritor Joël Dicker, tras sufrir una ruptura amorosa y una fuerte adicción a la escritura, decide ir a descansar al lugar preferido de Bernard de Fallois, su antiguo editor: el Palace de Verbier, un hotel de lujo a pocos kilómetros de Ginebra. Allí conocerá a Scarlett, una joven que le acompañará en la investigación del misterio de la habitación 622 y en la escritura del fascinante thriller que estamos leyendo.', 17000, 48, '9789563841770', 1),
(9, 'El Último Deseo, The Witcher ', 'Andrzej Sapkowski', 'https://static.serlogal.com/imagenes_big/9788498/978849889065.JPG', 'Geralt de Rivia, brujo y mutante sobrehumano, se gana la vida como cazador de monstruos en una tierra de magia y maravilla: con sus dos espadas al hombro -la de acero para hombres, y la de plata para bestias- da cuenta de estriges, manticoras, grifos, vampiros, quimeras  y lobisomes, pero sólo cuando amenazan la paz. Irónico, cínico, descreído y siempre errante, sus pasos lo llevan de pueblo en pueblo ofreciendo sus servicios, hallando las más de las veces que los auténticos monstruos se esconden bajo rostros humanos.', 25000, 21, '9788498891270', 1),
(15, 'Bajo El Manto De Urania', 'José María Maza Sancho', 'https://www.planetadelibros.cl/usuaris/libros/fotos/320/m_libros/portada_bajo-el-manto-de-urania_jose-maza_202005262311.jpg', 'Urania, la musa de la astronomía, es quien ha guiado los sueños de tantas personas en la historia y bajo su manto (el cielo), la ciencia se ha cobijado en busca de los misterios del cosmos.', 15000, 49, '9789563607543', 1),
(16, 'El Poder Del Click', 'Pablo Halpern y Francisca Lobos ', 'https://www.feriachilenadellibro.cl/pub/media/catalog/product/cache/1/image/200x256/e9c3970ab036de70892d86c6d221abfe/9/7/9789569986604.jpg', 'La pandemia mundial que nos afecta obligó a las organizaciones y empresas a funcionar de manera remota. De un momento a otroda interacción con los usuarios —ya sean clientes, consumidores, empleados o alumnos— ha comenzado a ser en línea. Pero ¿cómo responder efectivamente a este desafío?, ¿cuáles son los riesgos que se deben considerar? Aquí todas las respuestas para subsistir en la nueva era digital.', 13000, 49, '9789569986604', 1),
(17, 'Un Perro Confundido', 'Cecilia Beuchat', 'https://www.libreriadelgam.cl/imagenes/9789563/978956349616.JPG', '\r\nAmadeo, el perro salchicha de los Martínez, es el más regalón de la familia: todos lo miman, y él vive feliz y tranquilo. Hasta que un día, escucha algo que lo deja atónito...\r\n', 7000, 21, '9789563496161', 1),
(18, 'Sapo y Sepo, Inseparables', 'Arnold Lobel', 'https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcRIEoDpSqSPqFCHsMYTVGr9lH1puS5919mLYBeZBvYjtf5v691z', 'Sapo es activo y sensato; Sepo, por el contrario es pasivo y un poco atolondrado. El contraste entre sus personalidades dará origen a una relación de amigos inseparables, llena de simpatía y buen humor.  ', 11000, 50, '9786070134098', 1),
(19, 'El Bolígrafo De Gel Verde', 'Eloy Moreno', 'http://quelibroleo.com/images/libros/libro-1587024508.jpg', 'SUPERFICIES DE VIDA:\r\nCasa: 89 m²\r\nAscensor: 3 m²\r\nGaraje: 8 m²\r\nEmpresa: la sala, unos 80 m².\r\n\r\n¿Puede alguien vivir en 445 m² durante el resto de su vida?. \r\nPersonas que se desplazan por una celda sin estar presas; que se levantan cada día sabiendo que todo va a ser igual que ayer, igual que mañana; personas que a pesar \r\nde estar vivas se sienten muertas.', 35000, 50, '9788490703496', 1);

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
(1, '2020-08-21', '19081946-9'),
(2, '2020-08-24', '19081946-9'),
(3, '2020-08-24', '19081946-9'),
(4, '2020-08-24', '19081946-9'),
(5, '2020-08-24', '19848207-2'),
(6, '2020-08-24', '19081946-9'),
(7, '2020-08-25', '19081946-9'),
(8, '2020-08-25', '19848207-2');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `registro_usuarios`
--

CREATE TABLE `registro_usuarios` (
  `ID_RU` int(11) NOT NULL,
  `RUT_USUARIO` varchar(10) COLLATE utf8_unicode_ci NOT NULL,
  `CORREO` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `PASS` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `ROL` int(1) NOT NULL,
  `ESTADO` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `registro_usuarios`
--

INSERT INTO `registro_usuarios` (`ID_RU`, `RUT_USUARIO`, `CORREO`, `PASS`, `ROL`, `ESTADO`) VALUES
(1, '19081946-9', 'diegoescurraromero@gmail.com', '77', 1, 1),
(2, '18086228-5', 'gabi@gmail.com', '44', 2, 1),
(3, '19694860-0', 'xx@xx.com', 'xx', 3, 1),
(4, '7563486-2', 'jp20@gmail.com', '44', 3, 1),
(5, '19848207-2', 'dany-carrasco@hotmail.com', 'd198482072', 3, 1);

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
('3M9m9bu6ZgGTXsXfpI85bzCQ9HLTH1zN', 1598541154, '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{}}'),
('7qyMFGUpibb-rD1JrdbE6c_9lfAfaUgB', 1598637183, '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{}}'),
('9SB7LMzgPm4Y7UCYePg41ruMIdcF34Zb', 1598414776, '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{}}'),
('Rkef5FrOtf1dolFCmvveIzC4s2CxWVTp', 1598415201, '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{},\"passport\":{\"user\":\"19848207-2\"},\"cart\":{}}'),
('Yhcm5CF5s82BEGfuMECQsuoQbAFVwDBS', 1598452308, '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{}}'),
('baaZVjcW6OnGPzlnsnrRDwBkpYGoMlTA', 1598541144, '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{}}'),
('cpuRPpUrH8HabkC0sN__LzVzgHhH3QJD', 1598417274, '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{}}'),
('lhLYdEoRFLbpinR5hjbBpdr21y5D25SO', 1598724041, '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{}}'),
('vNQczQJIDK2suA7a6a_8kRHl4B2P0AIe', 1598406499, '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{}}'),
('ykjyu9OJ91pDzJfQAbbC91BOJ0yRHZMT', 1598541112, '{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"flash\":{}}');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `RUT` varchar(10) COLLATE utf8_unicode_ci NOT NULL,
  `NOMBRE` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `APELLIDO` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `DIRECCION` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`RUT`, `NOMBRE`, `APELLIDO`, `DIRECCION`) VALUES
('18086228-5', 'Gabriela', 'Hormazabal', 'Las Manzanas 456'),
('19081946-9', 'Diego', 'Escurra', 'San Antonio 49'),
('19694860-0', 'Ale', 'Jandra', '456'),
('19848207-2', 'Daniela', 'Carrasco', 'Los libertadores 1330, el Monte'),
('7563486-2', 'Juan', 'Gomez', '4545');

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
);

-- --------------------------------------------------------

--
-- Estructura para la vista `usuarios_detalle`
--
DROP TABLE IF EXISTS `usuarios_detalle`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `usuarios_detalle`  AS  select `u`.`RUT` AS `rut`,`u`.`NOMBRE` AS `nombre`,`u`.`APELLIDO` AS `apellido`,`u`.`DIRECCION` AS `direccion`,`ru`.`CORREO` AS `correo`,`ru`.`ROL` AS `rol`,`ru`.`ESTADO` AS `estado` from (`usuarios` `u` join `registro_usuarios` `ru` on(`u`.`RUT` = `ru`.`RUT_USUARIO`)) ;

--
-- Índices para tablas volcadas
--

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
  ADD PRIMARY KEY (`RUT`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `detalle_boleta`
--
ALTER TABLE `detalle_boleta`
  MODIFY `ID_DETALLE` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `libros`
--
ALTER TABLE `libros`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `pedido`
--
ALTER TABLE `pedido`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `registro_usuarios`
--
ALTER TABLE `registro_usuarios`
  MODIFY `ID_RU` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

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
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

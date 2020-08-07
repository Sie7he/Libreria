// Importamos los módulos necesarios
const express = require('express');
const router = express.Router();
const pool = require('../database');


/*Obtenemos la ruta del index para mostrar los datos de los libros de la base de datos
Seleccionamos los datos de los libros ocupando un formato que devuelve un numero x en formato xxx,xxx
y con replace remplazamos las comas por puntos para obtener los separadores de miles y guardamos todo en una constante
libros.

Utilizando async await obtenemos un código más limpio que al ocupar una promesa o callback,
con await esperamos que nuestra consulta a la base de datos termine para seguir con lo siguiente que seria
 mostrar los resultados que obtuvimos en la vista del index*/
router.get('/', async (req,res) =>{

    const libros = await pool.query("SELECT ID, NOMBRE,AUTOR,IMAGEN, REPLACE(FORMAT(PRECIO,0), ',', '.') AS PRECIO from libros"); 
    res.render('index', {libros});
 });

 
 
module.exports = router;    
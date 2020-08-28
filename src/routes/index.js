// Importamos los módulos necesarios
const express = require('express');
const router = express.Router();
const pool = require('../database');



router.get('/', async (req,res) =>{
    
    
    const libros = await pool.query("SELECT ID, NOMBRE,AUTOR,IMAGEN, REPLACE(FORMAT(PRECIO,0), ',', '.') AS PRECIO from libros order by ID desc limit 0,12"); 
    res.render('index', {libros});
 });


 
module.exports = router;    
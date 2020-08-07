const express = require('express');
const router = express.Router();
const pool = require('../database');
const { response } = require('express');
const { isLoggedIn, isADM, isAut } = require('../lib/auth');



router.get('/agregar',isAut, (req,res) =>{
    res.render('libros/agregar');
});

router.get('/lista', async (req,res) =>{
    const librosEMP = await pool.query('Select * FROM libros');
    res.render('libros/lista', {librosEMP});
 });

 
/* Obtenemos los datos del formulario y los guardamos en constantes,
luego llamamos a un procedimiento almacenado para agregar libros pasandole los parámetros necesarios
y ocupamos los signos de interrogación como parametros para evitar SQL Injection*/
router.post('/agregar', isAut, async (req,res) => {
    const {NOMBRE,AUTOR,IMAGEN,SIPNOPSIS,PRECIO,STOCK,ISBN} = req.body;
    await pool.query('call AGREGAR_LIBROS(?,?,?,?,?,?,?)',[AUTOR,IMAGEN,NOMBRE,PRECIO,STOCK,SIPNOPSIS,ISBN]);
    req.flash('success', 'Libro Guardado Correctamente');
    res.redirect('/');
});

/* Realizamos una busqueda donde usamos una funcion para concatenar y asi podemos buscar a través del "input search" 
un libro o un autor*/
router.get('/search/:n', async (req,res) =>{
    const n = req.query.n;
    const libros = await pool.query('Select * from libros where CONCAT_WS("",NOMBRE,AUTOR) like ?','%'+[n]+'%');
    res.render('libros/search', {libros});
 });
 

router.get('/detalle/:id', async (req,res) =>{
    const {id} = req.params;
    const libro = await pool.query("SELECT ID,NOMBRE,AUTOR,IMAGEN,STOCK,SIPNOPSIS, REPLACE(FORMAT(PRECIO,0), ',', '.') AS PRECIO from libros where id = ?",[id]);
    res.render('libros/detalle_libro',{libro : libro[0]});
 });

 // Realizamos la compra a través de un procedimimento almacenado
 router.post('/detalle/:id', isLoggedIn, async (req,res) =>{
    const {PRECIO,CANTIDAD} = req.body;
    const LIBRO = req.params.id;
    const RUT = req.user.rut;
    const nom = req.user.nombre;
    await pool.query('CALL PEDIDO (?,?,?,?,?)',[null,RUT,LIBRO,PRECIO,CANTIDAD]);
    req.flash('success', 'Gracias Por Su Compra',nom);
    res.redirect('/ventas/boleta');
  
 });

 router.get('/editar/:id', async (req,res) =>{
    const {id} = req.params;
    const librosEdit = await pool.query('SELECT * FROM libros where id = ?',[id]);
    res.render('libros/editar',{l : librosEdit[0]});
 });
 
 //Editamos el libro a través de un procedimiento almacenado
router.post('/editar/:id', async (req, res) => {
    const { id } = req.params;
    const {NOMBRE,AUTOR,IMAGEN,SIPNOPSIS,PRECIO,STOCK,ISBN} = req.body;
    await pool.query('call ACTUALIZAR_LIBRO(?,?,?,?,?,?,?,?)',[id,NOMBRE,AUTOR,IMAGEN,SIPNOPSIS,PRECIO,STOCK,ISBN]);
    req.flash('success','Libro Actualizado Correctamente')
    res.redirect('/libros/lista');
});

module.exports = router;
const express = require('express');
const router = express.Router();
const pool = require('../database');
const { isLoggedIn, isADM, isAut } = require('../lib/auth');
var cart = {};



router.get('/agregar',isAut, (req,res) =>{

    res.render('libros/agregar');
    
});
router.post('/agregar', isAut, async (req,res) => {
    try {
     const {NOMBRE,AUTOR,IMAGEN,SINOPSIS,PRECIO,STOCK,ISBN} = req.body;
     await pool.query('call AGREGAR_LIBROS(?,?,?,?,?,?,?)',[AUTOR,IMAGEN,NOMBRE,PRECIO,STOCK,SINOPSIS,ISBN]);
     res.json('Libro Agregado Correctamente');

    } catch (error) {
        res.status(201);
        console.log(error.sqlMessage);
    }

 });
 

 router.get('/lista', async (req,res) =>{
    
    res.render("libros/lista");
 
 });


 router.get('/listaAjax', async (req,res) =>{
     try {

        let page = parseInt(req.query.page);
        let limit = parseInt(req.query.size);
        let startIndex = page* limit;
        let orderby = (req.query.orderby === 'true');
        const filas = await pool.query("Select count(ID) as cont from libros where estado = 1");
        const contador = filas[0].cont;
        let librosEMP= {};
        if(orderby == false){
             librosEMP = await pool.query("Select * FROM libros where estado = 1  order by NOMBRE asc limit "+startIndex+","+limit+""); 
    
        }else {
            librosEMP = await pool.query("Select * FROM libros where estado = 1  order by AUTOR asc limit "+startIndex+","+limit+""); 
    
        }
    
        const response = {
                "totalPages" : Math.ceil(contador/limit),
                "pageNumber": page,  
                "libros": librosEMP,
    
        
    };
     
        res.json(response);
    } catch (error) {
        console.warn(error);
    }
   
 });




router.get('/search/:n', async (req,res) =>{
    const n = req.query.n;
    const libros = await pool.query('Select * from libros where CONCAT_WS("",NOMBRE,AUTOR) like ?','%'+[n]+'%');
    res.render('libros/search', {libros});
 });
 


router.get('/detalle/:id', async (req,res) =>{
    const {id} = req.params;
    const libro = await pool.query("SELECT ID,NOMBRE,AUTOR,IMAGEN,STOCK,SINOPSIS, REPLACE(FORMAT(PRECIO,0), ',', '.') AS PRECIO from libros where id = ?",[id]);
    const aut = libro[0];
    const autor = await pool.query("SELECT * FROM libros WHERE AUTOR = ? and NOMBRE != ? order by ID desc limit 3",[aut.AUTOR,aut.NOMBRE]);
    res.render('libros/detalle_libro',{libro : libro[0],autor});
 });
 


 // Realizamos la compra a través de un procedimimento almacenado
 router.post('/detalle/:id', isLoggedIn, async (req,res) =>{
    cart = req.session.cart;

    if (!cart) {
        cart = req.session.cart = {}
    }
    var id = req.params.id;
    cart[id] = (cart[id] || 0);
    res.redirect('/carrito');
});


 router.get('/editar/:id', async (req,res) =>{
    const {id} = req.params;
    const librosEdit = await pool.query('SELECT * FROM libros where id = ?',[id]);
    res.render('libros/editar',{l : librosEdit[0]});
 });
 
 //Editamos el libro a través de un procedimiento almacenado
router.post('/editar/:id', async (req, res) => {
    const { id } = req.params;
    const {NOMBRE,AUTOR,IMAGEN,SINOPSIS,PRECIO,STOCK,ISBN} = req.body;
    await pool.query('call ACTUALIZAR_LIBRO(?,?,?,?,?,?,?,?)',[id,NOMBRE,AUTOR,IMAGEN,SINOPSIS,PRECIO,STOCK,ISBN]);
    req.flash('success','Libro Actualizado Correctamente')
    res.redirect('/libros/lista');
});


router.post('/eliminar/:id', async (req,res) =>{
    try {
        const {id} = req.params;
        const rut = req.user.rut;
        await pool.query("call ELIMINAR_LIBRO(?,?)", [rut,id]);
        console.log(id);
        res.json("Libro Eliminado");
    } catch (error) {
        console.log(error);
    }
   
 
});

module.exports = router;
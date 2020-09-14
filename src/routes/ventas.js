const express = require('express');
const router = express.Router();
const pool = require('../database');
const { response } = require('express');
const { isLoggedIn, isADM , isAut } = require('../lib/auth');


/* Obtenemos los pedidos a través de una consulta y los guardamos en la constante pedido
para luego verlos en la vista */
router.get('/pedido',isLoggedIn,isAut,  async (req,res) =>{
    const pedido = await pool.query('SELECT * from pedido order by ID ASC limit 0,12');
    res.render('ventas/pedido', {pedido});
 });
 
 // Vemos el detalle de cada pedido 

router.get('/detalle/:id',isLoggedIn,isAut, async (req,res)=>{
     const detalle = await pool.query("Select * from detalle_venta where COD_PEDIDO = ?",req.params.id);
     res.json(detalle);
});



router.get('/pedido/page', async (req,res) =>{
   
     const limit = 12;
     const page = parseInt(req.query.pg);
     const startIndex = (page-1)* limit;
     const endIndex = page * limit;
     const pedido = await pool.query("SELECT * from pedido order by ID asc limit "+startIndex+","+"12"); 
     const filas = await pool.query("Select count(ID) as cont from libros");
     const contador = filas[0].cont;
     const results = {};
     results.results = JSON.parse(JSON.stringify(pedido));

     if (endIndex < contador){
          results.next = {
               page: page+1,
               limit
          }
     }

     if (startIndex > 0){
          results.previous ={
               page: page-1,
               limit
          }
     }

     res.render('ventas/pedido',{pedido});
  });
module.exports = router;
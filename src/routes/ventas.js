const express = require('express');
const router = express.Router();
const pool = require('../database');
const { response } = require('express');
const { isLoggedIn, isADM , isAut } = require('../lib/auth');


/* Obtenemos los pedidos a través de una consulta y los guardamos en la constante pedido
para luego verlos en la vista */
router.get('/pedido',isLoggedIn,isAut,  async (req,res) =>{
    const pedido = await pool.query('Select * from pedido');
    res.render('ventas/pedido', {pedido});
 });
 
 // Vemos el detalle de cada pedido 

router.get('/detalle/:id',isLoggedIn,isAut, async (req,res)=>{
     const detalle = await pool.query("Select * from detalle_venta where COD_PEDIDO = ?",req.params.id);
     res.json(detalle);
});


module.exports = router;
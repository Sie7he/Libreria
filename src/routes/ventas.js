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
 router.get('/detalle_venta/:id',isLoggedIn,isAut,  async (req,res) =>{
    const {id} = req.params;
    const detalle = await pool.query('select * from ventas_detalle where ID_PEDIDO = ?',[id]);
    console.log(detalle);
    res.render('ventas/detalle_venta', {detalle});
 });

// Obtenemos el detalle de la compra a través de una vista para mostrarsela al cliente
 router.get('/boleta',isLoggedIn,  async (req,res) =>{
   const rut = req.user.rut;
   const boleta = await pool.query('SELECT * FROM `ventas_detalle` order by ID_PEDIDO DESC');
   res.render('ventas/boleta',{b : boleta[0]});
});





module.exports = router;
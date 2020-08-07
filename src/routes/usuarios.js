const express = require('express');
const router = express.Router();
const pool = require('../database');
const { response } = require('express');
const { isLoggedIn } = require('../lib/auth');
const { serializeUser } = require('passport');
const { isADM } = require('../lib/auth');


router.get('/agregarUsuario',isLoggedIn,isADM, (req,res) =>{
    res.render('usuarios/agregarUsuario');
});


/* Agregamos un usuario en la base de datos a través de un procedimiento almacenado
que por seguridad verifica que el usuario que está ingresando datos sea un administrador*/
router.post('/agregarUsuario', async (req,res) => {
    const {RUT,NOMBRE,APELLIDO,CORREO,PASS,ROL} = req.body;
    const RUTADM = req.user.rut;
    await pool.query('call AGREGAR_USUARIO(?,?,?,?,?,?,?)',[RUT,NOMBRE,APELLIDO,CORREO,ROL,PASS,RUTADM]);
    req.flash('success', 'Usuario Guardado Correctamente');
    res.redirect('/usuarios/lista_usuarios');
});

router.get('/lista_usuarios',isLoggedIn,isADM, async (req,res) =>{
    const usuarios = await pool.query('Select * FROM usuarios_detalle');
    res.render('usuarios/lista_usuarios', {usuarios});
 });

 /* A través del botón actualizar obtenemos el rut del usuario por url y hacemos una consulta
 a la base de datos que muestre los datos del usuario con el rut que queremos actualizar */
 
 router.get('/editarUsuario/:rut', async (req,res) =>{
    const {rut} = req.params;
    const us = await pool.query('SELECT * FROM usuarios_detalle where RUT = ?',[rut]);
    res.render('usuarios/editarUsuario',{usuario : us[0]});
 });
 
 // Actualizamos a un usuario en la  base de datos con un procedimiento almacenado
router.post('/editarUsuario/:rut', async (req, res) => {
    const RUTADM = req.user.rut;
    const {RUT,NOMBRE,APELLIDO,CORREO,PASS,ROL} = req.body;
    await pool.query('call ACTUALIZAR_USUARIO(?,?,?,?,?,?,?)',[RUT,NOMBRE,APELLIDO,CORREO,PASS,ROL,RUTADM]);
    req.flash('success', 'Usuario Actualizado Correctamente');
    res.redirect('/usuarios/lista_usuarios');
 
});
module.exports = router;
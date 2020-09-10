const express = require('express');
const router = express.Router();
const pool = require('../database');
const { response } = require('express');
const { isLoggedIn } = require('../lib/auth');
const { serializeUser } = require('passport');
const { isADM } = require('../lib/auth');
const helpers = require('../lib/handlebars');

router.get('/agregarUsuario',isLoggedIn,isADM, (req,res) =>{
    res.render('usuarios/agregarUsuario');
});


/* Agregamos un usuario en la base de datos a través de un procedimiento almacenado
que por seguridad verifica que el usuario que está ingresando datos sea un administrador*/
router.post('/agregarUsuario', async (req,res) => {
    const RUTADM = req.user.rut;
    console.log(RUTADM);
    const {RUT,NOMBRE,APELLIDO,CORREO,DIRECCION,PASS,ROL,COMUNA} = req.body;
    const password = await helpers.encryptPassword(PASS);
    await pool.query('call AGREGAR_USUARIO(?,?,?,?,?,?,?,?,?)',[RUT,NOMBRE,APELLIDO,CORREO,DIRECCION,ROL,password,RUTADM,COMUNA]);
    req.flash('success', 'Usuario Guardado Correctamente');
    res.redirect('/usuarios/lista_usuarios');
});

router.get('/lista_usuarios',isLoggedIn,isADM, async (req,res) =>{
    const usuarios = await pool.query('Select * FROM usuarios_detalle where estado = 1');
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
    const {RUT,NOMBRE,APELLIDO,CORREO,DIRECCION,ROL,COMUNA} = req.body;
    await pool.query('call ACTUALIZAR_USUARIO(?,?,?,?,?,?,?,?)',[RUT,NOMBRE,APELLIDO,CORREO,DIRECCION,ROL,RUTADM,COMUNA]);
    req.flash('success', 'Usuario Actualizado Correctamente');
    res.redirect('/usuarios/lista_usuarios');
 
});

router.get('/eliminarUsuario/:rut', async (req,res) =>{
    const RUTADM = req.user.rut;
    const {rut} = req.params;
    try {
      await pool.query('call ELIMINAR_USUARIO(?,?)',[RUTADM,rut]);
      req.flash('success, Usuario Eliminado Correctamente');
      res.redirect('/usuarios/lista_usuarios')
    } catch (error) {
      req.flash('message',error.sqlMessage);  
    }
});
module.exports = router;
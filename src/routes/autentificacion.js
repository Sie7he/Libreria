const express = require('express');
const router = express.Router();
const passport = require('passport');
const pool = require('../database');
const {isLoggedIn, isNotLoggedIn,isADM} = require('../lib/auth');



// Utilizamos el módulo passport para poder ingresar a través del login
router.get('/signin',isNotLoggedIn, (req,res) =>{
    res.render('auth/signin');
});

router.post('/signin', (req,res,next) =>{
    
    passport.authenticate('local.signin', {
        successRedirect: '/',
        failureRedirect: '/signin',
        failureFlash: true
      })(req, res, next);
    });

 
    // El cliente se registra ocupando un procedimiento almacenado que siempre otorga el rol de cliente 
    router.get('/signup', (req,res) =>{
        res.render('auth/signup');
    });
    
    
    router.post('/signup', async (req,res) => {
        const {RUT,NOMBRE,APELLIDO,CORREO,PASS} = req.body;
        await pool.query('call REGISTRAR_CLIENTE(?,?,?,?,?)',[RUT,NOMBRE,APELLIDO,CORREO,PASS]);
        req.flash('success', 'Registrado Correctamente');
        res.redirect('/signin');
    });


    // Ocupamos la funcion logOut para cerrar sesión
router.get('/logout', (req,res) =>{
    req.logOut();
    res.redirect('/signin');
});

module.exports = router;
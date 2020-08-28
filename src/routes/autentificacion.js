const express = require('express');
const router = express.Router();
const passport = require('passport');
const pool = require('../database');
const {isLoggedIn, isNotLoggedIn,isADM} = require('../lib/auth');
const { session } = require('passport');
const helpers = require('../lib/handlebars');


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
        var {RUT,NOMBRE,APELLIDO,DIRECCION,CORREO,PASS} = req.body;
        console.log(req.body);

        try {
            await pool.query('call REGISTRAR_CLIENTE(?,?,?,?,?,?)',[RUT,NOMBRE,APELLIDO,CORREO,DIRECCION,PASS]);
            req.flash('success', 'Registrado Correctamente');
            res.redirect('/signin');
        } catch (error) {
            req.flash('message', error.sqlMessage);
            res.redirect('/signup');


        }
      
    });


    // Ocupamos la funcion logOut para cerrar sesión
router.get('/logout', (req,res) =>{
    req.session.destroy();
    req.logOut();
    res.redirect('/signin');
});

module.exports = router;
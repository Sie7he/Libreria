const passport = require('passport');
const pool = require('../database');
const LocalStrategy = require('passport-local').Strategy;
const helpers = require('./handlebars');

/*
passport.use('local.signin', new LocalStrategy({
  usernameField: 'username',
  passwordField: 'password',
  passReqToCallback: true
}, async (req, username, password, done) => {
  const rows = await pool.query('SELECT * FROM registro_usuarios WHERE CORREO = ? and PASS = ?', [username,password]);
  if (rows.length > 0) {
    const user = rows[0];
    done(null, user);
    } else {
      done(null, false, req.flash('message', 'Usuario o Contraseña Incorrecta'));
    }
}));

*/
// A través de el módulo passport realizamos un signin seguro
 passport.use('local.signin', new LocalStrategy({

  usernameField: 'username',
  passwordField: 'password',
  passReqToCallback: true
}, 

async (req, username, password, done) => {

  const rows = await pool.query('SELECT * FROM registro_usuarios WHERE CORREO = ?', [username]);
  if (rows.length > 0) {
    const user = rows[0];

    const validPassword = await helpers.checkUser(password,user.PASS);
    if (validPassword) {
      done(null, user);
    } 
  else {
    return done(null, false, req.flash('message', 'Usuario o Contraseña Incorrecta'));
  } }
}));








// Serializamos al usuario

passport.serializeUser((user, done) => {
    done(null, user.RUT_USUARIO);
  });

// Deserializamos al usuario y obtenemos sus datos a través de la vista detalle
passport.deserializeUser(async (rut, done) => {
    const rows = await pool.query('SELECT * from usuarios_detalle WHERE RUT = ?', [rut]);
    done(null, rows[0]);
  });


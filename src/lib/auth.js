module.exports = {
    
    /* Si el usuario no está conectado al momento de comprar será redireccionado
    al login */
    isLoggedIn(req,res,next){
        if (req.isAuthenticated()){
            return next();
        }
        return res.redirect('/signin');
    },
    
    /* Si está conectado no podra ingresar al login y será redireccionado al index */
    isNotLoggedIn(req,res,next){
        if( !req.isAuthenticated()){
            return next();
        }
        return res.redirect('/');

    },
    
    /*Se otorga el permiso solo para administrador */
    isADM(req,res,next){
        if (req.user.rol ===1){
            return next();
        }
        return res.redirect('/signin');
    },
    
    /* Se otorga el permiso para empleados y administrador */
    isAut(req,res,next){
        if (req.user.rol < 3){
            return next();
        }
        return res.redirect('/signin');
    },
}
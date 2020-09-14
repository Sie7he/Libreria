const express = require('express');
const router = express.Router();
const pool = require('../database');
const nodemailer = require("nodemailer");
const { isLoggedIn, isADM, isAut } = require('../lib/auth');
var cart = {};




router.get('/carrito', isLoggedIn, async (req,res) =>{
     cart= req.session.cart;
    if (!cart) {
        cart = req.session.cart = {};
    };      
    const ids = Object.keys(cart)
    if (ids.length > 0) {
     const carrito = await pool.query("SELECT ID,NOMBRE,IMAGEN,STOCK, REPLACE(FORMAT(PRECIO,0), ',' , '.') AS PRECIO FROM libros WHERE ID IN  (?) ",[ids]);
     res.render('carrito',{carrito});
    } else{
        req.flash('message','No hay elementos en el carrito');
        res.redirect('/');    
    }

 });
  
router.get('/eliminarLibro/:id', async(req,res) =>{
    cart = req.session.cart;
    const {id} = req.params;;
    delete cart[id];
    res.redirect('/carrito');

});


router.get('/limpiarCarrito', async (req,res) =>{
    cart = req.session.cart = {};
    res.redirect('/');
})

 router.post('/carrito', async (req,res) =>{
    let contador = 0;
    cart = req.session.cart;
    const ids = Object.keys(cart);
    const carrito = await pool.query("SELECT ID,NOMBRE,PRECIO FROM libros WHERE ID IN  (?) ",[ids]);
    const idPedido =  await pool.query('select MAX(ID)+1 as ID from pedido');
    const rut = req.user.rut;
    const id = idPedido[0].ID;
    await pool.query('call PEDIDO(?,?)',[id,rut]);
    const cantidad = req.body.CANTIDADC;
     

        try {
    
            carrito.forEach(async element => {   
                 contador +=1;         
                 await pool.query("CALL DESCONTAR_STOCK(?,?)", [element.ID,parseInt(cantidad[contador-1])]);               
                 
                });
               contador=0;
               
            carrito.forEach(async element => {
                contador +=1;
                await pool.query("Insert into detalle_boleta (ID_PEDIDO,ID_LIB,PRECIO_UNITARIO,CANTIDAD,TOTAL)VALUES ('"+id+"','"+element.ID+"','"+element.PRECIO+"','"+req.body.CANTIDADC[contador-1]+"','" + (element.PRECIO * req.body.CANTIDADC[contador-1]) +"')");
           
               });
            
            contador=0;
            const transporter = nodemailer.createTransport({
                host: 'smtp-mail.outlook.com',
                secureConnection: false, 
                port: 587,
                tls: {
                    ciphers:'SSLv3'
                 },
                auth: {
                    user: 'elpalaciodelaliteratura@hotmail.com',
                    pass: 'elpalacio77'
                }
            });
            let style = ( 'html,body {'+
                'margin: 0 auto !important;'+
                'padding: 0 !important;'+
                'height: 100% !important;'+
                'width: 100% !important;'+
                'background: #fff;'+
                '* {-ms-text-size-adjust: 100%;'+
                '-webkit-text-size-adjust: 100%; }'+
                'div[style*="margin: 16px 0"] {'+
                   'margin: 0 !important; }'+
                   'table,td { mso-table-lspace: 0pt !important;'+
                    'mso-table-rspace: 0pt !important;}'+
                    'table { border-spacing: 0 !important;'+
                    'border-collapse: collapse !important;'+
                    'table-layout: fixed !important;'+
                    'margin: 0 auto !important; }'+
                    'img { -ms-interpolation-mode:bicubic;  }'+
                'a {  text-decoration: none; } })'+
                  
                '*[x-apple-data-detectors],'+  
                '.unstyle-auto-detected-links *,'+
                '.aBn { border-bottom: 0 !important;'+
                   'cursor: default !important;'+
                    'color: inherit !important;'+
                    'text-decoration: none !important;'+
                    'font-size: inherit !important;'+
                    'font-family: inherit !important;'+
                    'font-weight: inherit !important;'+
                    'line-height: inherit !important;}'+
                   '.a6S { display: none !important;'+
                    'opacity: 0.01 !important;}'+
                    '.im { color: inherit !important;}'+
                    'img.g-img + div { display: none !important; }'+
                   '@media only screen and (min-device-width: 320px) and (max-device-width: 374px) {'+
                       'u ~ div .email-container {'+
                        'min-width: 320px !important; } }'+
        
                    '@media only screen and (min-device-width: 375px) and (max-device-width: 413px) {'+
                        'u ~ div .email-container {'+
                        'min-width: 375px !important;}}'+
                        
                  
                    '@media only screen and (min-device-width: 414px) {'+
                     'u ~ div .email-container {'+
                     'min-width: 414px !important; } }</style><style>'+
                     '.primary{background: #17bebb; }'+
                    '.bg_white{ background: #ffffff;}'+  
                    '.bg_light{background: #f7fafa;}'+
                    '.bg_black{ background: #000000; }'+
                    '.bg_dark{background: rgba(0,0,0,.8); }'+
                    '.email-section{padding: 2.5em;}'+
                   
                    '.btn{ padding: 10px 15px;'+
                    'display: inline-block;}'+
                    
                    '.btn.btn-primary{'+
                        'border-radius: 5px;'+
                        'background: #17bebb;'+
                        'color: #ffffff; }'+
                   
                    'h1,h2,h3,h4,h5,h6{'+
                        'font-family: "Work Sans", sans-serif;'+
                        'color: #000000;'+
                       'margin-top: 0; font-weight: 400;}'+
                       'body{ font-family: "Work Sans", sans-serif;'+
                        'font-weight: 400;'+
                        'font-size: 15px;'+
                        'line-height: 1.8;'+
                        'color: rgba(0,0,0,.4); }'+
                        'a{ color: #17bebb; }'+
                        '@media screen and (max-width: 500px) { }')    
                       
                   let mensaje = ('<!DOCTYPE html>'+
                   '<html lang="en" xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office"><head>'+
                    '<meta charset="utf-8"> <meta name="viewport" content="width=device-width"><meta http-equiv="X-UA-Compatible" content="IE=edge"> <meta name="x-apple-disable-message-reformatting">'+   
                       '<title>El Palacio De La Literatura</title>'+
                       '<link href="https://fonts.googleapis.com/css?family=Work+Sans:200,300,400,500,600,700" rel="stylesheet"><style>'+
                       style+
                       '</style></head>'+
                       '<body width="100%" style="margin: 0; padding: 0 !important; mso-line-height-rule: exactly; background-color: #f1f1f1;">'+
                       '<center style="width: 100%; background-color: #f1f1f1;">'+
                       '<div style="display: none; font-size: 1px;max-height: 0px; max-width: 0px; opacity: 0; overflow: hidden; mso-hide: all; font-family: sans-serif;"></div>'+
                       '<div style="max-width: 600px; margin: 0 auto;" class="email-container">'+
                       ' <table  role="presentation" cellspacing="0" cellpadding="0" width="100%" style="margin: auto;"><tr>'+
                       '          <td valign="top" class="bg_white" style="padding: 1em 2.5em 0 2.5em;">'+
                       '          	<table role="presentation" cellpadding="0" cellspacing="0" width="100%"> <tr>'+
                      '<td class="logo" style="text-align: left;">'+
                      '			            <h1>El Palacio De La Literatura</h1></td></tr></table></td></tr><tr>'+
                      
                      '<tr><td valign="middle" class="hero bg_white" style="padding: 2em 0 2em 0;">'+
                        '<table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100%">'+
                            
                        '<tr><td style="padding: 0 2.5em; text-align: left;">'+
                                    
                        '<div class="text"> <h2>Gracias por comprar en nuestra tienda!</h2>'+
                          '</div></td><tr>'+   
                          '<td style="padding: 0 2.5em; text-align: left;color: #000;">'+
                          '<strong> Código boleta: '+id+'</strong>'+
                          '</td></tr>'+ 
                          '<tr><td style="padding: 0 2.5em; text-align: left;color: #000;">'+
                          '<strong>'+req.user.rut+'</strong>'+
                          '</td></tr>'+                          
                          '<tr><td style="padding: 0 2.5em; text-align: left;color: #000;">'+        
                          '<strong>'+req.user.nombre +" "+ req.user.apellido+'</strong> </td></tr>'+
                          '<tr><td style="padding: 0 2.5em; text-align: left;color: #000;">'+
                          '<strong>'+req.user.comuna+'</strong>'+
                          '</td></tr>'+ 
                          '<tr><td style="padding: 0 2.5em; text-align: left;color: #000;">'+
                          '<strong>'+req.user.direccion+'</strong>'+
                          '</td></tr></tr></table></td></tr>'+
        
                      '<table class="bg_white" role="presentation" cellpadding="0" cellspacing="0" width="100%">'+
                      '<tr style="border-bottom: 1px solid rgba(0,0,0,.05);">'+
                      '<th width="10%" style="text-align:center; padding: 0 2.5em; color: #000;">Código</th>'+
                      '<th width="40%" style="text-align:center; padding: 0 2.5em; color: #000;">Libro</th>'+
                      '<th width="20%" style="text-align:center; padding: 0 2.5em; color: #000;">Precio</th>'+
                      '<th width="10%" style="text-align:center; padding: 0 2.5em; color: #000;">Cantidad</th>'+
                      '<th width="20%" style="text-align:center; padding: 0 2.5em; color: #000;">Total</th></tr>')
                      var total = 0;
                carrito.forEach(async element => {
                    contador +=1;
                    mensaje += (
                        '<tr style="border-bottom: 1px solid rgba(0,0,0,.05);">' +
                        '<td valign="middle" width="10%" style="text-align:center; padding: 0 2.5em;">' + element.ID+ '</td>' +
                        '<td valign="middle" width="40%" style="text-align:center; padding: 0 2.5em;">' + element.NOMBRE+ '</td>' +
                        '<td valign="middle" width="20%" style="text-align:center; padding: 0 2.5em;">' + element.PRECIO+ '</td>' +
                        '<td valign="middle" width="10%" style="text-align:center; padding: 0 2.5em;">' + req.body.CANTIDADC[contador-1] +'</td>' +
                        '<td valign="middle" width="20%" style="text-align:center; padding: 0 2.5em;">' + (element.PRECIO * req.body.CANTIDADC[contador-1]) +'</td></tr>');
                        total = total+ (element.PRECIO * req.body.CANTIDADC[contador-1]);
                       
                   });
                   if (total<1000000){
                    total = (total/1000) +'.000'
                } 
                   mensaje += ('<tr style="border-bottom: 1px solid rgba(0,0,0,.05);">'+          
                       '<td valign="middle" style="text-align:center;"><strong><span>Total</span></strong></td>'+
                       '<td></td><td></td><td></td>'+
                       '<td valign="middle" style="text-align:center;"><strong><span>$'+total+'</span></strong></td>'+
                       '</tr><tr><td colspan="2" valign="middle" style="text-align:center; padding: 1em 2.5em;">'+
                       '<a href="#" class="btn btn-primary">Visita nuestra página!</a>'+
                       '</td></tr></table></div></center></body></html>' 
        
                   )
        
                let info = await transporter.sendMail({
                from: 'elpalaciodelaliteratura@hotmail.com', 
                to: req.user.correo, 
                subject: "Gracias Por Su Compra! ✔",
                html: mensaje
              });
        
          
            cart = req.session.cart ={};
            req.flash('success',req.user.nombre+', su boleta ha sido enviada a su correo')
            res.redirect('/'); 
        
        } catch (error) {
            console.log(error);
            req.flash('message','Producto sin stock');
        }
    
        
 });

 module.exports = router;
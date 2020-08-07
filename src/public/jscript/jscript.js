
/* Con buscar libros y buscar usuario filtramos la tabla para que aparezca
   el usuario o libro que estamos buscando al principio de la tabla*/
  
    $('#buscar_usuario').keyup(function(){ 
        let buscar = $(this).val();       
        $('#tablaUsuario tr:gt(0)').filter(function() { 
            $(this).toggle($(this).text().indexOf(buscar) > -1);         
        });
        
        
    });

    $('#buscar_libro').keyup(function(){ 
      let buscar = $(this).val();       
      $('#tablaLibros tr:gt(0)').filter(function() { 
          $(this).toggle($(this).text().indexOf(buscar) > -1);         
      });
      
      
  });

  //Cada vez que se cambie el valor del input cantidad se calculara el total automáticamente

    $('#CANTIDAD').bind('keyup mouseup',function() {
      let a = $('#PRECIO').val();
      let b = $(this).val();
      if (b>0){
      $('#spanPrecio').text('$'+a * b+".000");
    } else{

      // Si la cantidad es menor a cero se mostrará un total de $0
      $('#spanPrecio').text('$0');

    }

  });
    
  
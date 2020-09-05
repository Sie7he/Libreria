
/* Con buscar libros y buscar usuario filtramos la tabla para que aparezca
   el usuario o libro que estamos buscando al principio de la tabla*/
  
window.onload = actualizarTabla();

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
 


  var filas=document.querySelectorAll("#miTabla tbody tr");
  var total=0;

    $('.CANTIDAD').bind('keyup mouseup',function() {
      $('#miTabla tbody tr').each(function() {
       var cantidad = $(this).find('input[type="number"]').val();
       var precio = $(this).find('td').eq(3).text().replace('.',''); 
       var subtotal = cantidad*precio; 
       if (subtotal>0){
       $(this).find('td').eq(4).text((subtotal/1000)+'.000');
      }else{
        $(this).find('td').eq(4).text(0);

      }
       actualizarTabla();

  });
});


function actualizarTabla(){
var sum=0;
$('.subtotal').each(function() {  
 sum += parseFloat($(this).text().replace('.',''));  
}); 
if(sum<=0){
  $('#resultado_total').text('0');

}
else if(sum>1 && sum<1000000){
$('#resultado_total').text(('$ '+(sum/1000)+'.000'));
}
else if(sum>=1000000){
  sum = sum-1000000;
  if(sum<100000){
    $('#resultado_total').text(('$ 1.0'+(sum/1000)+'.000'));

  }else
  $('#resultado_total').text(('$ 1.'+(sum/1000)+'.000'));

}
};


$('.btn-danger').click(function(){
if(confirm("¿Desea Eliminar Al Usuario?")){
  document.submit();
}else{
   return false;
  }

});



const getTiempoTotal = horaCero =>{

  let ahora = new Date(),
  tiempoTotal = (new Date(horaCero)- ahora + 1000)/1000,
  segundos = ('0' + Math.floor(tiempoTotal % 60)).slice(-2),
  minutos = ('0' + Math.floor(tiempoTotal/ 60 % 60)).slice(-2),
  horas = ('0' + Math.floor(tiempoTotal/ 3600 % 24)).slice(-2),
  dias = Math.floor(tiempoTotal/(3600*24) );
  
  return {
      tiempoTotal,
      segundos,
      minutos,
      horas,
      dias
  };
  };
  
  
  
  /*const cuenta = (cero,dias,horas,minutos,segundos) =>{
      const d = document.getElementById(dias);
      const h = document.getElementById(horas);
      const m = document.getElementById(minutos);
      const s = document.getElementById(segundos);

      const actualizador = setInterval( () => {
          let t = getTiempoTotal(cero);        
         d.innerHTML = `${t.dias}`;
         h.innerHTML = `${t.horas}`;
         m.innerHTML = `${t.minutos}`;
         s.innerHTML = `${t.segundos}`;
          if (t.tiempoTotal <= 1){
              clearInterval(actualizador);
          }
          
      },1000);
      
  };
  
  cuenta('Sep 22 2020 01:39:00 GMT-0400','dias','horas','minutos','segundos'); 

*/

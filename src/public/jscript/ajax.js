$("#region").change(function(){
    const id = $("#region").val();
    $.ajax({
        url : "/regiones/"+id,
        type : "GET",
        success : function(data){

            var len = data.length;
            if(len<=0){
                $("#comunas").empty();
                $("#comunas").append("<option value='0'>Seleccione Su Comuna...</option>");
            }else{
                $("#comunas").empty();
                for(var i =0; i<len;i++){
                var value1 = data[i]['NOMBRE'];
                var value2 = data[i]['ID'];
                    $("#comunas").append("<option value='"+value2+"' >"+value1+"</option>");
    
                }
            }
          
        }
    });
}); 


function detalle(id){
    $.ajax({
        url : "/ventas/detalle/"+id,
        type : "GET",
        success : function(data){
        $('.tbventas').empty();
             
        $.each(data, function(i, item) {
                $('#ventas').append(
                $('<tr>'),
                $('<td>').text(item.NOMBRE),
                $('<td>').text(item.CANTIDAD),
                $('<td>').text(item.PRECIO_UNITARIO),
                $('<td class="totalD">').text(item.TOTAL)
                
            );

        }
        );
        tablaDetalle();

        }})
};
function tablaDetalle(){
    let sum =0;
    $('.totalD').each(function() {  
      sum += parseFloat($(this).text());  
    }); 
     $('#ventas_total').text(sum);
     console.log(sum);
}





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



    function libros(page,size,orderby){

            let pageNumber = (typeof page !== 'undefined') ?  page : 0;
            let sizeNumber = (typeof size !== 'undefined') ?  size : 10;
            var order      = (typeof orderby !== 'undefined') ?  order : false;
            
     

            $('#btnCargar').fadeOut();
            $.ajax({
                url : "listaAjax",
                type : "GET",
                data : { 
                    page: pageNumber, 
                    size: sizeNumber,
                    orderby : order
                },
        
                success : function(response){
                
                    $('#tablaLibros tbody').empty();
                $.each(response.libros, (i, item) =>{
                        $('#tablaLibros').append(
                        $('<tr>'),
                        $('<td>').text(item.NOMBRE),
                        $('<td>').text(item.AUTOR),
                        $('<td>').text(item.STOCK),
                        $('<td>').text(item.PRECIO),
                        $('<td>').text(item.ISBN),
                        $('<td><a href="/libros/editar/'+item.ID+'" class="btn btn-info"> Editar </a>'),
                        $('<td><a onclick="eliminarLibro('+item.ID+')"  class="btn btn-danger"> Eliminar </a>')
        
                        
                    )});
                    
                    if ($('ul.pagination li').length - 2 != response.totalPages){
                      
                      $('ul.pagination').empty();
                      buildPagination(response.totalPages);
                  }
                },
                error : function(e) {
                  alert("ERROR: ", e);
                  console.log("ERROR: ", e);
                }
        
                    
            });
        };
        
        
        
                        function buildPagination(totalPages){
                            // Build paging navigation
                            let pageIndex = '<li class="page-item"><a class="page-link">Anterior</a></li>';
                            $("ul.pagination").append(pageIndex);
                            
                            // create pagination
                            for(let i=1; i <= totalPages; i++){
        
                                
                                // adding .active class on the first pageIndex for the loading time
                                if(i==1){
                                    pageIndex = "<li class='page-item active'><a class='page-link'>"
                                          + i + "</a></li>"            		  
                                } else {
                                    pageIndex = "<li class='page-item'><a class='page-link'>"
                                              + i + "</a></li>"
                                  }
                                $("ul.pagination").append(pageIndex);
                            }
                            
                            pageIndex = '<li class="page-item"><a class="page-link">Siguiente</a></li>';
                            $("ul.pagination").append(pageIndex);
                        }
        
        
        
        
        
                        $(document).on("click", "ul.pagination li a", function() {
                            let val = $(this).text();

                            // click on the NEXT tag
                              if(val.toUpperCase()==="SIGUIENTE"){
                    
                                
                                  let activeValue = parseInt($("ul.pagination li.active").text());
                                  let totalPages = $("ul.pagination li").length - 2; // -2 beacause 1 for Previous and 1 for Next 
                                  if(activeValue < totalPages){
                                      let currentActive = $("li.active");
                                      libros(activeValue, 10); // get next page value
                                      // remove .active class for the old li tag
                                      $("li.active").removeClass("active");
                                      // add .active to next-pagination li
                                      currentActive.next().addClass("active");
                                  }
                              } else if(val.toUpperCase()==="ANTERIOR"){
                                  let activeValue = parseInt($("ul.pagination li.active").text());
                                  if(activeValue > 1){
                                      // get the previous page
                                      libros(activeValue-2, 10);
                                      let currentActive = $("li.active");
                                      currentActive.removeClass("active");
                                      // add .active to previous-pagination li
                                      currentActive.prev().addClass("active");
                                  }
                              } else {
                                  libros(parseInt(val) - 1, 10);
                                  // add focus to the li tag
                                  $("li.active").removeClass("active");
                                  $(this).parent().addClass("active");
                              } 
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
                    $('<td style="text-align:center">').text(item.CANTIDAD),
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




    $(function (){
      const Toast = Swal.mixin({
        toast: true,
        position: 'top-end',
        showConfirmButton: false,
        timer: 3000,
        timerProgressBar: true,
        didOpen: (toast) => {
          toast.addEventListener('mouseenter', Swal.stopTimer)
          toast.addEventListener('mouseleave', Swal.resumeTimer)
        }
      })
    $('#frmAgregarU').on('submit', (e) => {
        let inputs = $(':input');
        e.preventDefault();
        let NOMBRE = $('#NOMBRE');
        let AUTOR = $('#AUTOR');
        let IMAGEN = $('#IMAGEN');
        let SINOPSIS = $('#SINOPSIS');
        let PRECIO = $('#PRECIO');
        let STOCK = $('#STOCK');
        let ISBN = $('#ISBN');
        $.ajax({
          url: "agregar",
          method: 'POST',
          data: {
            NOMBRE: NOMBRE.val(),
            AUTOR: AUTOR.val(),
            IMAGEN: IMAGEN.val(),
            SINOPSIS: SINOPSIS.val(),
            PRECIO: PRECIO.val(),
            STOCK: STOCK.val(),
            ISBN: ISBN.val()
          
          },
        
          success: function() {
            Toast.fire({
                icon: 'success',
                title: 'Libro Agregado Correctamente'
              });
          inputs.val("");
          },
          error: function (err) {
            console.log(err);
          }
        });
      });

    });


    function eliminarLibro(id){

      Swal.fire({
        title: 'Estas seguro?',
        text: "No podrás revertir esto!",
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Si, Borrar',
        cancelButtonText: 'Cancelar'
      }).then((result) => {
        if (result.isConfirmed) {
          
          $.ajax({

            url: "eliminar/"+id,
            type: "POST",
            data: {
              id: id
            },
            success:  ()=>{
              Swal.fire(
                'Eliminado!',
                'El libro ha sido eliminado.',
                'success'
              );
            }
          });
          libros();
        }
      })
      

    };

 

/*La funcion validar declara un rango de letras entre la a y z
y hace una prueba que si el texto ingresado no es ninguna letra devuelve un falso*/
function validar(texto){
    let patron = /^[a-zA-z]*$/;
    let prueba = patron.test(texto.value);
   return prueba;
  };
 
  function checkRut(rut) {
    // Despejar Puntos
    var valor = rut.value.replace('.','');
    // Despejar Guión
    valor = valor.replace('-','');
    
    // Aislar Cuerpo y Dígito Verificador
    cuerpo = valor.slice(0,-1);
    dv = valor.slice(-1).toUpperCase();
    
    // Formatear RUN
    rut.value = cuerpo + '-'+ dv
    
    // Calcular Dígito Verificador
    suma = 0;
    multiplo = 2;
    
    // Para cada dígito del Cuerpo
    for(i=1;i<=cuerpo.length;i++) {
    
        // Obtener su Producto con el Múltiplo Correspondiente
        index = multiplo * valor.charAt(cuerpo.length - i);
        
        // Sumar al Contador General
        suma = suma + index;
        
        // Consolidar Múltiplo dentro del rango [2,7]
        if(multiplo < 7) {
           multiplo = multiplo + 1; 
          } 
        else 
        {
           multiplo = 2; 
          }
  
    }
    
    // Calcular Dígito Verificador en base al Módulo 11
    dvEsperado = 11 - (suma % 11);
    
    // Casos Especiales (0 y K)
    dv = (dv == 'K')?10:dv;
    dv = (dv == 0)?11:dv;
    
    // Validar que el Cuerpo coincide con su Dígito Verificador
    if(dvEsperado != dv) {
       rut.setCustomValidity("RUT Inválido")
    ; 
    return false;    
  }
    
    // Si todo sale bien, eliminar errores (decretar que es válido)
    rut.setCustomValidity('');
}
  
  
  function validarFormulario(){
  //Se declaran las variable correspondientes
    var nombre = document.getElementById('NOMBRE');
    var apellido = document.getElementById('APELLIDO');
    
    /*Con la funcion validar se pasa por parametro cada variable y si no cumple las condiciones 
    de la funcion anterior el div_error cambiara por una frase que diga solo letras y desaparecerá en 4 segundos*/
    
    if (validar(nombre)===false){
     document.getElementById("nombre_error").innerHTML = "Debe insertar solo letras";
        setInterval(function(){document.getElementById("nombre_error").innerHTML = "";},4000);
      return false;
    } else if(validar(apellido)===false){
        document.getElementById("apellido_error").innerHTML = "Debe insertar solo letras";
        setInterval(function(){document.getElementById("apellido_error").innerHTML = "";},4000);
      return false;
    } 
  };
  
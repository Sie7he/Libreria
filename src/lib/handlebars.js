const helpers = {};


/*Este es un "helper" que ocuparemos en algunas vistas para ocultar o deshabilitar botones
ya que el If de handlebars no sirve en este caso */

helpers.equal = function(lvalue, rvalue, options) {
    if (arguments.length < 3)
    if (arguments.length < 3)
        throw new Error("Handlerbars Helper 'compare' needs 2 parameters");

    var operator = options.hash.operator || "==";

    var operators = {
        '==':       function(l,r) {return l==r;},
        '<':        function(l,r) { return l < r; },
        '>':        function(l,r) { return l > r; }

   
    }

    if (!operators[operator])
        throw new Error("Handlerbars Helper 'compare' doesn't know the operator "+operator);

    var result = operators[operator](lvalue,rvalue);

    if( result ) {
        return options.fn(this);
    } else {
        return options.inverse(this);
    }
    };

module.exports = helpers;
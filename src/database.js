const mysql = require('mysql'); 
const {promisify} = require('util');

const {database} = require('./keys');

const pool = mysql.createPool(database);

pool.getConnection((err,connection) =>{
    if (err){
        if (err.code === 'PROTOCOL_CONNECTION_LOST'){
             console.error('SE PERDIO LA CONEXION CON LA BASE DE DATOS');
        }
        if (err.code === 'ER_CON_COUNT_ERROR'){
            console.error('DATABASE HAS TO MANY CONNECTIONS');

        }
        if (err.code === 'ENCONNREFUSED'){
            console.error('LA CONEXION FUE RECHAZADA');
        }
    }
    if (connection) connection.release();
    console.log('DB conectada');
    return;
});

pool.query = promisify(pool.query);
module.exports = pool;
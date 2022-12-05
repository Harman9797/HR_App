var mysql      = require('mysql');
var connection = mysql.createConnection({
  host     : '127.0.0.1',
  user     : 'hbstudent',
  password : 'hbstudent',
  database : 'humanresources'
});

module.exports = function getConnection(){
    if (!connection) {
        connection.connect(function(err) {
            if (err) {
                  console.error('error connecting: ' + err.stack);
                  return;
            }               
            console.log('connected as id ' + connection.threadId);
        });
    }
    return connection;
}
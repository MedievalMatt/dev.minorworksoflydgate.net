var mysql = require('mysql');

var con = mysql.createConnection({
  host: "witnesses.minorworksoflydgate.net",
  user: "mdavislib",
  password: "dr3am3r1"
});

con.connect(function(err) {
  if (err) throw err;
  console.log("Connected!");
});

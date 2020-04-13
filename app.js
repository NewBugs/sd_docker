const express = require('express');
const app = express();
const router = express.Router();

// db
const db = require('./db');

// routes
const index = require('./routes/index');
const inspection = require('./routes/inspection');

// Model schema
const model = require('./models/model');



// File reader
const fs = require('fs');

const path = __dirname + '/views/';

app.set('view engine', 'ejs');
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path));
app.use(express.static(path+'three.js/'));
app.use('/', index);
app.use('/inspection', inspection);

// Check if new data exists
if (fs.existsSync('newData.json')) {
  // PARSE JSON FILE
  let modelData = fs.readFileSync('newData.json');
  let models = JSON.parse(modelData);
  model.insertMany(models) // using Mongoose
  // console.log(models);

  // date 
  var datetime = new Date();
  var d = datetime.toISOString().slice(0,10);
  
  // Rename file to mark data as merged
  fs.rename('newData.json', 'mergedData/oldData-'+d +'.json', function(err) {
    if ( err ) console.log('ERROR: ' + err);
  });
} 
// IDEA For Backup Data
// else if (fs.existsSync('exportData.json')) {

//    // date 
//    var datetime = new Date();
//   var d = datetime.toISOString().slice(0,10);

//   model.find({}, function (err, data) {
//     fs.writeFileSync('exportData.json', JSON.stringify(data));

//     fs.rename('exportData.json', 'backupData-'+d, function(err) {
//       if ( err ) console.log('ERROR: ' + err);
//     });
//   })
// }

// expose port
const port = process.env.PORT || 8080;

app.listen(port, function () {
  console.log('Server running... on ${port}!')
});

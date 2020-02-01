const express = require('express');
const app = express();
const router = express.Router();
const db = require('./db');
const routes = require('./routes/index');
const model = require('./models/model');



// File reader
const fs = require('fs');

const path = __dirname + '/views/';

app.set('view engine', 'ejs');
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path));
app.use(express.static(path+'three.js/'));
app.use('/', routes);

// PARSE JSON FILE
// let modelData = fs.readFileSync('modelTest.json');
// let models = JSON.parse(modelData);
// model.insertMany(models) // using Mongoose
// console.log(models);

const port = process.env.PORT || 8080;

app.listen(port, function () {
  console.log('Server running... on ${port}!')
});

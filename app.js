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

// PARSE JSON FILE
// let modelData = fs.readFileSync('modelTest.json');
// let models = JSON.parse(modelData);
// model.insertMany(models) // using Mongoose
// console.log(models);

// expose port
const port = process.env.PORT || 8080;

app.listen(port, function () {
  console.log('Server running... on ${port}!')
});

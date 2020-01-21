const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const fs = require('fs');

const app = express();

const urlencodedParser = bodyParser.urlencoded({ extended: false });

app.set('view engine', 'ejs');

app.use(express.static('public'));

// Connect to MongoDB
mongoose
  .connect(
    'mongodb://mongo:27017/docker-node-mongo',
    { useNewUrlParser: true }
  )
  .then(() => console.log('MongoDB Connected'))
  .catch(err => console.log(err));

const Model = require('./models/model');

// PARSE JSON FILE
// let modelData = fs.readFileSync('modelTest.json');
// let models = JSON.parse(modelData);
// model.insertMany(models) // using Mongoose
// console.log(models);

app.get('/', (req, res) => {
  Model.find()
    .then(models => res.render('index', { models }))
    .catch(err => res.status(404).json({ msg: 'No models found' }));
});

// app.post('/item/add', (req, res) => {
//   const newItem = new Item({
//     name: req.body.name
//   });
//
//   newModel.save().then(item => res.redirect('/'));
// });

const port = 3000;

app.listen(port, () => console.log('Server running...'));

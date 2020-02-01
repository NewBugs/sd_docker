const express = require('express');
const router = express.Router();
const model = require('../models/model');



// router.use (function (req,res,next) {
//   console.log('/' + req.method);
//   next();
// });

router.get('/',function(req,res){
  model.find()
    .then(models => res.render('index', { models }))
    .catch(err => res.status(404).json({ msg: 'No models found' })
  );
  // console.log(model.findById(0, 'cable_number', function (err, models) {}));
  // res.render('index');
  // res.sendFile(path.resolve('views/index.ejs'));

  // Model.find()
  //   .then(function(doc) {
  //     res.render('index', {models: doc})
  //   });
  // Model.find({}, function(err, models) {
  //     res.render('index', { models: models });
  // });

});

// router.post('/item/add', (req, res) => {
//   const newItem = new Item({
//     name: req.body.name
//   });
//
//   newModel.save().then(item => res.redirect('/'));
// });

module.exports = router;

const express = require('express');
const router = express.Router();
const model = require('../models/model');


// Main home GET request
router.get('/',function(req,res){

  // Find all distinct inspection dates
  model.distinct('inspection_date')
    .then(models => res.render('index', { models }))
    .catch(err => res.status(404).json({ msg: 'No models found' })
  );

});



module.exports = router;

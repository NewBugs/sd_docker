const express = require('express');
const router = express.Router();
const model = require('../models/model');
var date1;
var section_id;


// Main GET request
router.get('/',function(req,res){

  date = new Date(req.query.id);

  // Might need comparison if date field is too accurate
  // var date2 = new Date();
  // console.log(date1);

  var sid = req.query.sid;
  var inspection_date = date.toString();

  // Intialize viewer to view section
    // Find inspection date to get all model data
    model.find({ inspection_date: date})
      .then(models => res.render('inspection', { models, sid, inspection_date }))
      .catch(err => res.status(404).json({ msg: date1 })
    );
  // }


});

// Post request to update flag on section
router.post('/flag', function(req, res){
  // const newItem = new Item({
  //   name: req.body.name
  // });
  //
  // newModel.save().then(item => res.redirect('/'));

  section_id = req.query.sid;
  inspection_date = req.query.id;


  model.findOne({cable_section_id: section_id}, function(err, doc) {
    if (err) return res.send(500, {error: err});
    doc.flagged = true;
    doc.save(function (err){
      if (err) return res.send(500, {error: err});
    });
    return res.redirect("../inspection?id="+inspection_date+"&sid="+section_id);
  });

  // res.redirect('/inspection?='+date1);

});

// Post request to unflag a section
router.post('/unflag', function(req, res){

  section_id = req.query.sid;
  inspection_date = req.query.id;


  // MIGHT NEED TO CHANGE TO UPDATE()
  // Find section_id and update it to false
  model.findOne({cable_section_id: section_id, inspection_date: inspection_date}, function(err, doc) {
    if (err) return res.send(500, {error: err});

    doc.flagged = false;
    doc.save(function (err){
      if (err) return res.send(500, {error: err});
    });

    return res.redirect("../inspection?id="+inspection_date+"&sid="+section_id);
  });

});

module.exports = router;

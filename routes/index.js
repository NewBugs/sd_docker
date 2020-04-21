const express = require('express');
const router = express.Router();
const model = require('../models/model');

const distinct = (value, index, self) =>{
    return self.indexOf(value) === index;
}

// Main home GET request
router.get('/',function(req,res){

//   // Find all distinct inspection dates
//   model.distinct('inspection_date', function(error, models) {
//     // ids is an array of all ObjectIds
//     if(error) {
//       console.log(error);
//     } 
//     else {
//       // console.log(models);
//       var counts = [];
//       var temp;

//       var processing = function(insp_date) {

//         model.countDocuments({inspection_date: insp_date.toString(), flagged: 'true'}, function(err, c) {
//           // console.log('Count is ' + c);
//           counts[counts.length] = c;
//         });
//       }
//       for( var i = 0; i < models.length; i++) {
//         var insp_date = models[i];
//         processing(insp_date);
//       }

      
//       console.log('Count is ' + counts[0]);
//       res.render('index', {models, counts: counts});
//     }
// });
var counts = [];
// var cableCounts;
var i = 0;
var j = 0;

model.find({ section_number: '0'}, function(error, docs) {
  if(error) {
    console.log(error);
  } else{
    // Map results of first query to get all unique sections 
    var originalResults = docs.map(function(doc) { return doc.inspection_date.toISOString(); });

    // Find all distinct inspection dates 
    var results = originalResults.filter(distinct); 

    // Count the amount of cables for each inspection date
    (cableCounts = []).length = results.length;
    cableCounts.fill(0);
    for (var a = 0; a < originalResults.length; a++) {
        if (originalResults[a] === results[j]) {
            cableCounts[j] += 1;
        } else {
            j++;
            cableCounts[j] += 1;
        }
    }
    results.reduce(function(promise, models) {
     
          // Chain promises together
          return promise.then(function(r) {
            // Count the amount of flags on the cable section
            return model.countDocuments({inspection_date: models, flagged: 'true'}, function(err, c) {
                  // console.log('Count is ' + c);
                  counts[i] = c;
                  i++;
                });
          });
        }, Promise.resolve([])).then(function(r) {
          // Log out all values resolved by promises
          res.render('index', {results, counts: counts, cableCounts: cableCounts});
        });
  }
})


});



module.exports = router;

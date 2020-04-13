const express = require('express');
const router = express.Router();
const model = require('../models/model');


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
var models = [];
var i = 0;

// var processing = function(insp_date) {

//   model.countDocuments({inspection_date: insp_date.toString(), flagged: 'true'}, function(err, c) {
//     // console.log('Count is ' + c);
//     counts[i] = c;
//     i++;
//   });
// }

model.distinct('inspection_date', function(error, results) {
  if(error) {
    console.log(error);
  } else{
    results.reduce(function(promise, models) {
     
          // Chain promises together
          return promise.then(function(r) {
            return model.countDocuments({inspection_date: models.toString(), flagged: 'true'}, function(err, c) {
                  // console.log('Count is ' + c);
                  counts[i] = c;
                  i++;
                });
          });
        }, Promise.resolve([])).then(function(r) {
          // Log out all values resolved by promises
          console.log(results);
          res.render('index', {results, counts: counts});
        });
  }
})


  // Iterate over actionList

  // actionList.reduce(function(promise, action) {
  //   // Chain promises together
  //   return promise.then(function(results) {
  //     return collectionActions.find({
  //       eventid: action.eventid
  //     }).then(function(e, actionsFound) {
  //         // returns another promise that will resolve up to outer promises
  //         return collectionActions.insert(action, function(err, result) {
  //           // Finally resolve a value for outer promises
  //           return results.push('insert action : ' + action.sourceName);
  //         });
        
  //     });
  //   });
  // }, Promise.resolve([])).then(function(results) {
  //   // Log out all values resolved by promises
  //   console.log(results);
  // });

});



module.exports = router;

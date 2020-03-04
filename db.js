const mongoose = require('mongoose');

const MONGO_USERNAME = process.env.MONGO_USERNAME;
const MONGO_PASSWORD = process.env.MONGO_PASSWORD;
const MONGO_PORT = process.env.MONGO_PORT;
const MONGO_DB = process.env.MONGO_DB;


const options = {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  // reconnectTries: Number.MAX_VALUE,
  // reconnectInterval: 500,
  connectTimeoutMS: 10000
};

// MongoDB server
const url = `mongodb://${MONGO_USERNAME}:${MONGO_PASSWORD}@db:${MONGO_PORT}/${MONGO_DB}?authSource=admin`;

// Connect to mongoDB
mongoose.connect(url,options).then( function() {
  console.log('MongoDB is connected');
})
  .catch( function(err) {
  console.log(err);
});

// mongoose.connect(url, {useNewUrlParser: true});

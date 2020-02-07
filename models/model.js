const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const modelSchema = new Schema({
  cable_section_id: { type: Number, required: true },
  cable_number: { type: Number, required: true },
  section_number: { type: Number, required: true },
  inspection_date: { type: Date, default: Date.now },
  original_image1_path: { type: String, required: true },
  original_image2_path: { type: String, required: true },
  original_image3_path: { type: String, required: true },
  original_image4_path: { type: String, required: true },
  model_path: { type: String, required: true },
  mesh_path: { type: String, required: true },
  flagged: { type: Boolean, required: true },
});

module.exports = mongoose.model('model', modelSchema);

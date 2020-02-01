const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const modelSchema = new Schema({
  cable_section_id: { type: Number, required: true },
  cable_number: { type: Number, required: true },
  section_number: { type: Number, required: true },
  inspection_date: { type: Date, default: Date.now },
  camera_angle: { type: Number, required: true },
  original_image_path: { type: String, required: true },
  model_path: { type: String, required: true },
  mesh_path: { type: String, required: true },
  flagged: { type: Boolean, required: true },
});

module.exports = mongoose.model('model', modelSchema);

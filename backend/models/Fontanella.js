import mongoose from 'mongoose';

const FontanellaSchema = new mongoose.Schema({
  name: String,
  lat: Number,
  lon: Number
});

export default mongoose.models.Fontanella || mongoose.model('Fontanella', FontanellaSchema);

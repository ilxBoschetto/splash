import mongoose from 'mongoose';

const FontanellaSchema = new mongoose.Schema({
  name: { type: String, required: true },
  lat: { type: Number, required: true },
  lon: { type: Number, required: true },
  stato: {
    type: String,
    enum: ['potabile', 'non potabile', 'in manutenzione'],
    default: 'potabile',
  },
  immagini: [String], // URL di immagini salvate
}, { timestamps: true });

export default mongoose.models.Fontanella || mongoose.model('Fontanella', FontanellaSchema);

// /models/SavedFontanella.js
import mongoose from 'mongoose';

const SavedFontanellaSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
  },
  fontanellaId: {
    type: String,
    required: true,
  },
}, { timestamps: true });

export default mongoose.models.SavedFontanella || mongoose.model('SavedFontanella', SavedFontanellaSchema);

import mongoose, { Schema, Document, Model } from 'mongoose';

export interface ISavedFontanella extends Document {
  userId: mongoose.Types.ObjectId;
  fontanellaId: mongoose.Types.ObjectId;
  createdAt: Date;
  updatedAt: Date;
}

const SavedFontanellaSchema: Schema<ISavedFontanella> = new Schema(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    fontanellaId: {
      type: Schema.Types.ObjectId,
      ref: 'Fontanella',
      required: true,
    },
  },
  { timestamps: true }
);

const SavedFontanella: Model<ISavedFontanella> =
  mongoose.models.SavedFontanella || mongoose.model<ISavedFontanella>('SavedFontanella', SavedFontanellaSchema);

export default SavedFontanella;

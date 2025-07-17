import mongoose, { Schema, Document, Model } from 'mongoose';

export interface IFontanella extends Document {
  name: string;
  lat: number;
  lon: number;
  location: {
    type: 'Point';
    coordinates: [number, number];
  };
  stato: 'potabile' | 'non potabile' | 'in manutenzione';
  imageUrl?: String;
  createdBy: mongoose.Types.ObjectId;
  createdAt: Date;
  updatedAt: Date;
}

const FontanellaSchema: Schema<IFontanella> = new Schema(
  {
    name: { type: String, required: true },
    lat: { type: Number, required: true },
    lon: { type: Number, required: true },

    location: {
      type: {
        type: String,
        enum: ['Point'],
        required: true,
        default: 'Point',
      },
      coordinates: {
        type: [Number],
        required: true,
      },
    },

    stato: {
      type: String,
      enum: ['potabile', 'non potabile', 'in manutenzione'],
      default: 'potabile',
    },
    imageUrl: { type: String },
    createdBy: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  },
  { timestamps: true }
);

FontanellaSchema.index({ location: '2dsphere' });

const Fontanella: Model<IFontanella> =
  mongoose.models.Fontanella || mongoose.model<IFontanella>('Fontanella', FontanellaSchema);

export default Fontanella;

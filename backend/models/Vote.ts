import mongoose, { Schema, Document, Model } from 'mongoose';

export interface IVote extends Document {
  userId: mongoose.Types.ObjectId;
  fontanellaId: mongoose.Types.ObjectId;
  value: String;
  createdAt: Date;
  updatedAt: Date;
}

const VoteSchema: Schema<IVote> = new Schema(
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
    value: {
        type: String,
        required: true,
    }
  },
  { timestamps: true }
);

const Vote: Model<IVote> =
  mongoose.models.Vote || mongoose.model<IVote>('Vote', VoteSchema);

export default Vote;

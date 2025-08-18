import mongoose, { Schema, Document, Model } from 'mongoose';

export interface IUser extends Document {
  name: string;
  email: string;
  passwordHash: string;
  isConfirmed: boolean;
  isAdmin: boolean;
  confirmationCode: string;
  createdAt: Date;
  resetPasswordToken: string;
  resetPasswordExpires: Date;
}

const UserSchema: Schema<IUser> = new Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },

    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },

    isAdmin: {
      type: Boolean
    },

    passwordHash: {
      type: String,
      required: true,
    },

    isConfirmed: {
      type: Boolean,
      default: false,
    },

    confirmationCode:{
      type: String,
      required: false,
    },
    
    resetPasswordToken: {
      type: String,
      default: null
    },
    resetPasswordExpires: {
      type: Date,
      default: null
    },

    createdAt: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: false,
  }
);

const User: Model<IUser> = mongoose.models.User || mongoose.model<IUser>('User', UserSchema);

export default User;

import mongoose, { Schema, Document, Model } from "mongoose";

export interface IUser extends Document {
  name: string;
  email: string;
  passwordHash?: string;
  googleId?: string;
  isConfirmed: boolean;
  isAdmin: boolean;
  confirmationCode?: string;
  createdAt: Date;
  lastRequest: Date | null;
  resetPasswordToken?: string;
  resetPasswordExpires?: Date | null;
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

    googleId: {
      type: String,
      required: false,
      unique: true,
    },

    isAdmin: {
      type: Boolean,
      default: false,
    },

    passwordHash: {
      type: String,
      required: false,
      default: null,
    },

    isConfirmed: {
      type: Boolean,
      default: false,
    },

    confirmationCode: {
      type: String,
      required: false,
    },

    resetPasswordToken: {
      type: String,
      default: null,
    },
    resetPasswordExpires: {
      type: Date,
      default: null,
    },

    createdAt: {
      type: Date,
      default: Date.now,
    },
    lastRequest: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: false,
  }
);

const User: Model<IUser> =
  mongoose.models.User || mongoose.model<IUser>("User", UserSchema);

export default User;

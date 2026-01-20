import mongoose, { Schema, Document, Model } from "mongoose";

export interface IDeviceNotification extends Document {
  userId?: string;
  deviceToken: string;
  createdAt: Date;
  updatedAt: Date;
}

const DeviceNotificationSchema: Schema<IDeviceNotification> = new Schema(
  {
    deviceToken: { type: String, required: true, unique: true },
    userId: { type: String },
  },
  { timestamps: true }
);

export const DeviceNotification: Model<IDeviceNotification> =
  mongoose.models.DeviceNotification || mongoose.model<IDeviceNotification>("DeviceNotification", DeviceNotificationSchema);
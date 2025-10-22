import { ReportStatus } from "@/enum/report_status_enum";
import { ReportType } from "@/enum/report_type_enum";
import mongoose, { Schema, Document, Model } from "mongoose";

export interface IReport extends Document {
  fontanellaId: mongoose.Types.ObjectId;
  createdBy: mongoose.Types.ObjectId;
  type: ReportType;
  value?: string;
  status: ReportStatus;
  description?: string;
  imageUrl?: string;
  originalValue?: string;
  createdAt: Date;
  updatedAt: Date;
}

const ReportSchema: Schema<IReport> = new Schema(
  {
    fontanellaId: {
      type: Schema.Types.ObjectId,
      ref: "Fontanella",
      required: true,
    },
    createdBy: { type: Schema.Types.ObjectId, ref: "User", required: true },
    type: { type: Number, required: true },
    value: { type: String },
    status: { type: Number, default: 0 },
    description: { type: String },
    imageUrl: { type: String },
    originalValue: { type: mongoose.Schema.Types.Mixed, default: null },
  },
  { timestamps: true }
);

export const Report: Model<IReport> =
  mongoose.models.Report || mongoose.model<IReport>("Report", ReportSchema);

import { IUser } from "@/lib/auth";
import { IFontanella } from "@/models/Fontanella";
import { IReport, Report } from "@/models/Report";
import mongoose from "mongoose";

export class ReportDto {
  id: string;
  fontanellaId: string;
  fontanella?: IFontanella;
  createdById: string;
  createdBy?: IUser;
  type: number;
  typeLabel?: string;
  status: number;
  statusLabel?: string;
  value?: string;
  imageUrl?: string;
  description?: string;
  createdAt: Date;
  updatedAt: Date;

  constructor(data: {
    report: IReport;
    user?: IUser;
    fontanella?: IFontanella;
  }) {
    const { report, user, fontanella } = data;
    this.id = (report._id as mongoose.Types.ObjectId).toHexString();
    this.fontanella = fontanella;
    this.createdBy = user;
    this.type = report.type;
    this.status = report.status;
    this.value = report.value;
    this.imageUrl = report.imageUrl;
    this.description = report.description;
    this.createdAt = report.createdAt;
    this.updatedAt = report.updatedAt;
  }
}

export const mapToDto = (
  report: IReport,
  user?: IUser,
  fontanella?: IFontanella
) => new ReportDto({ report, user, fontanella });

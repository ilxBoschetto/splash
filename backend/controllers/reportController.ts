import { mapToDto, ReportDto } from "@/dtos/reportDto";
import { DecodedToken } from "@/lib/auth";
import Fontanella, { IFontanella } from "@/models/Fontanella";
import { IReport, Report } from "@/models/Report";
import User, { IUser } from "@/models/User";

export const createReport = async (
  fontanellaId: IFontanella,
  user: IUser,
  type: number,
  value?: string,
  imageUrl?: string,
  description?: string
): Promise<void> => {
  if (!fontanellaId || !user) {
    throw new Error("Fontanella o utente non validi");
  }
  if (description && typeof description !== "string") {
    throw new Error("Descrizione del report non valida");
  }

  const createData: any = {};
  createData.fontanellaId = fontanellaId;
  createData.createdBy = user.id;
  createData.type = type;
  createData.status = 0;
  if (value) createData.value = value;
  if (imageUrl) createData.imageUrl = imageUrl;
  if (description) createData.description = description;
  await Report.create(createData);
};

export const getReports = async (currentUser: IUser): Promise<ReportDto[]> => {
  let reports: IReport[];

  if (currentUser.isAdmin) {
    // Admin: prende tutti i report
    reports = await Report.find().sort({ createdAt: -1 }).exec();
  } else {
    // Utente normale: prende solo i propri
    reports = await Report.find({ createdBy: currentUser._id })
      .sort({ createdAt: -1 })
      .exec();
  }

  const dtos: ReportDto[] = [];
  for (const report of reports) {
    const fontanella = await Fontanella.findById(report.fontanellaId).exec();
    const user = await User.findById(report.createdBy).exec();

    if (!fontanella || !user) continue;

    dtos.push(mapToDto(report, user, fontanella));
  }

  return dtos;
};

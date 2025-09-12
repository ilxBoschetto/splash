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

export const handleWrongInformation = async (report: IReport) => {
  if (!report.value)
    throw new Error("Il report non contiene un valore proposto");
  const fontanella = await Fontanella.findById(report.fontanellaId).exec();
  if (!fontanella) throw new Error("Fontanella non trovata");

  fontanella.name = report.value;
  await fontanella.save();

  report.status = 1;
  await report.save();
};

export const handleWrongImage = async (report: IReport) => {
  if (!report.imageUrl)
    throw new Error("Il report non contiene un'immagine proposta");
  const fontanella = await Fontanella.findById(report.fontanellaId).exec();
  if (!fontanella) throw new Error("Fontanella non trovata");

  fontanella.imageUrl = report.imageUrl;
  await fontanella.save();

  report.status = 1;
  await report.save();
};

export const handleNonExistent = async (report: IReport) => {
  const fontanella = await Fontanella.findById(report.fontanellaId).exec();
  if (!fontanella) throw new Error("Fontanella non trovata");

  await fontanella.deleteOne();

  report.status = 1;
  await report.save();
};

export const handleWrongPotability = async (report: IReport) => {
  if (!report.value)
    throw new Error("Il report non contiene il valore di potabilità");
  const fontanella = await Fontanella.findById(report.fontanellaId).exec();
  if (!fontanella) throw new Error("Fontanella non trovata");

  fontanella.status = parseInt(report.value);
  await fontanella.save();

  report.status = 1;
  await report.save();
};

export const processReport = async (reportId: string) => {
  const report = await Report.findById(reportId).exec();
  if (!report) throw new Error("Report non trovato");
  if (report.status !== 0) throw new Error("Report già processato");

  switch (report.type) {
    case ReportType.wrongInformation:
      return handleWrongInformation(report);
    case ReportType.wrongImage:
      return handleWrongImage(report);
    case ReportType.wrongPotability:
      return handleWrongPotability(report);
    case ReportType.nonExistentFontanella:
      return handleNonExistent(report);
    default:
      throw new Error("Tipo di report non supportato");
  }
};

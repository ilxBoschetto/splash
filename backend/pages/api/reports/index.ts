// pages/api/reports/index.ts
import type { NextApiRequest, NextApiResponse } from "next";
import dbConnect from "@lib/mongodb";
import withCors from "@lib/withCors";
import { getReports } from "@controllers/reportController";
import { getUserFromRequest } from "@lib/auth"; // funzione che estrae l'utente loggato dalla request

async function handler(req: NextApiRequest, res: NextApiResponse) {
  await dbConnect();

  //#region GET /api/reports
  if (req.method !== "GET") {
    res.setHeader("Allow", ["GET"]);
    return res.status(405).end("Method Not Allowed");
  }
  //#endregion

  try {
    const currentUser = await getUserFromRequest(req);
    if (!currentUser) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    const reports = await getReports(currentUser);

    return res.status(200).json({ reports });
  } catch (err) {
    console.error("GET /reports error:", err);
    return res.status(500).json({ error: "Failed to fetch reports" });
  }
}

export default withCors(handler);

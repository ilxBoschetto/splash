// pages/api/reports/index.ts
import type { NextApiRequest, NextApiResponse } from "next";
import dbConnect from "@lib/mongodb";
import withCors from "@lib/withCors";
import { getReports, createReport } from "@controllers/reportController";
import { getUserFromRequest, verifyToken } from "@lib/auth";

async function handler(req: NextApiRequest, res: NextApiResponse) {
  await dbConnect();

  try {
    const currentUser = await getUserFromRequest(req);
    if (!currentUser) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    switch (req.method) {
      //#region GET /api/reports
      case "GET": {
        let user = verifyToken(req);
        if (!user || !user.userId) {
          return res
            .status(401)
            .json({ error: "Unauthorized: Invalid or missing token" });
        }
        const reports = await getReports(currentUser);
        return res.status(200).json({ reports });
      }
      //#endregion

      //#region POST /api/reports
      case "POST": {
        const { fontanellaId, type, value, imageUrl, description } = req.body;

        if (!fontanellaId || type === undefined) {
          return res.status(400).json({ error: "Missing required fields" });
        }

        await createReport(
          fontanellaId,
          currentUser,
          type,
          value,
          imageUrl,
          description
        );

        return res.status(200).json({ message: "Report created successfully" });
      }
      //#endregion

      default: {
        res.setHeader("Allow", ["GET", "POST"]);
        return res.status(405).end("Method Not Allowed");
      }
    }
  } catch (err) {
    console.error(`/${req.method} /reports error:`, err);
    return res.status(500).json({
      error: `Failed to ${req.method === "GET" ? "fetch" : "create"} reports`,
    });
  }
}

export default withCors(handler);

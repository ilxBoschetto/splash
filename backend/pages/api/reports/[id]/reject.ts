// pages/api/reports/[id]/reject.ts
import type { NextApiRequest, NextApiResponse } from "next";
import dbConnect from "@lib/mongodb";
import withCors from "@lib/withCors";
import { rejectReport } from "@controllers/reportController";
import { getUserFromRequest } from "@lib/auth";

async function handler(req: NextApiRequest, res: NextApiResponse) {
  await dbConnect();

  const {
    query: { id },
  } = req;

  try {
    const currentUser = await getUserFromRequest(req);
    if (!currentUser) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    switch (req.method) {
      //#region POST /api/reports/[id]/reject
      case "POST": {
        if (currentUser.isAdmin === false) {
          return res.status(403).json({ error: "Forbidden" });
        }

        await rejectReport(id as string);

        return res
          .status(200)
          .json({ message: "Report rejected successfully" });
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

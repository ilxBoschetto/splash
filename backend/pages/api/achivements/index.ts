// pages/api/achivements/index.ts
import type { NextApiRequest, NextApiResponse } from "next";
import dbConnect from "@lib/mongodb";
import withCors from "@lib/withCors";
import { AchivementCount, AchivementList } from "@controllers/achivementController";
import { getUserFromRequest, verifyToken } from "@lib/auth";

const handler = async (req: NextApiRequest, res: NextApiResponse) => {
    await dbConnect();
    try {
        const currentUser = await getUserFromRequest(req);
        if (!currentUser) {
            return res.status(401).json({ error: "Unauthorized" });
        }
        switch (req.method) {
            //#region GET /api/achivements
            case "GET": {
                const user = verifyToken(req);
                if (!user || !user.userId) {
                    return res.status(401).json({ error: "Unauthorized: Invalid or missing token" });
                }
                const achivements = await AchivementList();
                return res.status(200).json({ achivements });
            }
            //#endregion
            default:
                res.setHeader("Allow", ["GET"]);
                return res.status(405).end(`Method ${req.method} Not Allowed`);
        }
    } catch (error) {
        console.error("Error in /api/achivements:", error);
        return res.status(500).json({ error: "Internal Server Error" });
    }
};

export default withCors(handler);
import type { NextApiRequest, NextApiResponse } from "next";
import dbConnect from "@lib/mongodb";
import withCors from "@lib/withCors";
import withLastRequest from "@/lib/withLastRequest";
import { createDeviceTokenNotification } from "@/controllers/notificationController";
import { getUserFromRequest } from "@/lib/auth";
import { log } from "@/helpers/logger";

const handler = async (req: NextApiRequest, res: NextApiResponse) => {
  await dbConnect();

  const { method } = req;

  try {
    switch (method) {
      //#region POST /api/users/device-token
      case "POST": {
        const authHeader = req.headers.authorization;
        let userId = null;
        if (!authHeader || !authHeader.startsWith("Bearer ")) {
          const user = await getUserFromRequest(req);
          userId = user?.id;
        }
        const { deviceToken } = req.body;
        if (!deviceToken) {
          return res.status(400).json({ error: "Missing deviceToken in request body" });
        }
        return createDeviceTokenNotification(userId, deviceToken);
      }
      //#endregion

      //#region Metodo non supportato
      default:
        res.setHeader("Allow", ["POST"]);
        return res.status(405).end(`Method ${method} Not Allowed`);
      //#endregion
    }
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: "Internal server error" });
  }
};
//#endregion

export default withCors(withLastRequest(handler));

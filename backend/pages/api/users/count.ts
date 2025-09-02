import type { NextApiRequest, NextApiResponse } from "next";
import dbConnect from "@lib/mongodb";
import withCors from "@lib/withCors";
import UserController from "@/controllers/userController";

//#region Handler principale per /api/users/count
const handler = async (req: NextApiRequest, res: NextApiResponse) => {
  // Connessione al DB
  await dbConnect();

  // Estrazione dati da request
  const { method } = req;

  try {
    switch (method) {
      //#region GET /api/users/count
      case "GET": {
        const count = await UserController.countUsers(req, res);
        res.status(200).json({ count });
      }
      //#endregion
    }
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: "Internal server error" });
  }
};
//#endregion

export default withCors(handler);

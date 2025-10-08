import type { NextApiRequest, NextApiResponse } from "next";
import dbConnect from "@lib/mongodb";
import withCors from "@lib/withCors";
import UserController from "@/controllers/userController";
import withLastRequest from "@/lib/withLastRequest";

//#region Handler principale per /api/fontanelle/[id]
const handler = async (req: NextApiRequest, res: NextApiResponse) => {
  // Connessione al DB
  await dbConnect();

  // Estrazione dati da request
  const { method } = req;

  try {
    switch (method) {
      //#region GET /api/users
      case "GET": {
        return UserController.getAllUsers(req, res);
      }
      //#endregion

      //#region Metodo non supportato
      default:
        res.setHeader("Allow", ["GET", "PUT", "DELETE"]);
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

import type { NextApiRequest, NextApiResponse } from "next";
import dbConnect from "@lib/mongodb";
import withCors from "@lib/withCors";
import UserController from "@/controllers/userController";
import withLastRequest from "@/lib/withLastRequest";

//#region Handler principale per /api/users/delete-account
const handler = async (req: NextApiRequest, res: NextApiResponse) => {
  // Connessione al DB
  await dbConnect();

  // Estrazione dati da request
  const { method } = req;

  try {
    switch (method) {
      //#region DELETE /api/users/delete-account
      case "DELETE": {
        return UserController.deleteMyAccount(req, res);
      }
      //#endregion
    }
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: "Internal server error" });
  }
};
//#endregion
export default withCors(withLastRequest(handler));

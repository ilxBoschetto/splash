// lib/withLastRequest.ts
import jwt from "jsonwebtoken";
import User from "@models/User";
import dbConnect from "@lib/mongodb";
import { getUserFromRequest } from "./auth";

export default function withLastRequest(handler: Function) {
  return async (req: any, res: any) => {
    await dbConnect();

    const authHeader = req.headers.authorization || "";
    const token = authHeader.replace("Bearer ", "");

    if (token) {
      try {
        const user = await getUserFromRequest(req);
        const userId = user.id;

        if (userId) {
          await User.findByIdAndUpdate(userId, { lastRequest: new Date() });
        }
      } catch (err) {
        // Non blocchiamo la chiamata se il token è invalido
        console.warn("withLastRequest: token invalido o scaduto");
      }
    }

    // Prosegui con l'handler originale
    return handler(req, res);
  };
}

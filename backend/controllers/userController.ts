// controllers/UserController.ts
import { NextApiRequest, NextApiResponse } from "next";
import User from "../models/User";
import { getUserFromRequest } from "@/lib/auth";

class UserController {
  /**
   * Restituisce tutti gli utenti (solo admin)
   */
  static async getAllUsers(req: NextApiRequest, res: NextApiResponse) {
    try {
      // Recupera utente loggato dal token
      const admin = await getUserFromRequest(req);

      if (!admin || !admin.isAdmin) {
        return res.status(401).json({ error: "Unauthorized: access denied" });
      }

      // Recupera tutti gli utenti dal DB
      const users = await User.find().select("_id name email isAdmin");

      return res.status(200).json(users);
    } catch (err) {
      console.error("Errore getAllUsers:", err);
      return res.status(500).json({ error: "Internal server error" });
    }
  }
  /**
   * DELETE /api/users/[id]
   * Elimina un utente (solo admin)
   */
  static async deleteUser(req: NextApiRequest, res: NextApiResponse) {
    try {
      const admin = await getUserFromRequest(req);

      if (!admin || !admin.isAdmin) {
        return res.status(401).json({ error: "Unauthorized: access denied" });
      }

      const { id } = req.query;

      if (!id || typeof id !== "string") {
        return res.status(400).json({ error: "Invalid user id" });
      }

      const user = await User.findById(id);

      if (!user) {
        return res.status(404).json({ error: "User not found" });
      }

      await User.findByIdAndDelete(id);

      return res.status(200).json({ message: "User deleted successfully" });
    } catch (err) {
      console.error("Errore deleteUser:", err);
      return res.status(500).json({ error: "Internal server error" });
    }
  }
}

export default UserController;

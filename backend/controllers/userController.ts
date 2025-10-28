// controllers/UserController.ts
import { NextApiRequest, NextApiResponse } from "next";
import User, { IUser } from "../models/User";
import { getUserFromRequest } from "@/lib/auth";
import { mapToDto, TopUserDto } from "@/dtos/topUserDto";
import dbConnect from "@/lib/mongodb";
import mongoose from "mongoose";
import Fontanella from "@/models/Fontanella";

class UserController {
  /**
   * Restituisce tutti gli utenti (solo admin)
   */
  static async getAllUsers(req: NextApiRequest, res: NextApiResponse) {
    try {
      const sortOrder =
        typeof req.query.sort === "string" &&
        req.query.sort.toLowerCase() === "asc"
          ? 1
          : -1;
      // Recupera utente loggato dal token
      const admin = await getUserFromRequest(req);

      if (!admin || !admin.isAdmin) {
        return res.status(401).json({ error: "Unauthorized: access denied" });
      }

      // Recupera tutti gli utenti dal DB
      const users = await User.find()
        .select("_id name email isAdmin")
        .sort({ createdAt: sortOrder });

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

      if (user._id == admin._id) {
        return res
          .status(409)
          .json({ error: "Conflict: Cannot delete yourself" });
      }

      await User.findByIdAndDelete(id);

      return res.status(200).json({ message: "User deleted successfully" });
    } catch (err) {
      console.error("Errore deleteUser:", err);
      return res.status(500).json({ error: "Internal server error" });
    }
  }

  static async countUsers(req: NextApiRequest, res: NextApiResponse) {
    const admin = await getUserFromRequest(req);

    if (!admin || !admin.isAdmin) {
      return res.status(401).json({ error: "Unauthorized: access denied" });
    }

    return User.countDocuments();
  }

  static async getTopUsers(): Promise<TopUserDto[]> {
    await dbConnect();

    const topUsers = await Fontanella.aggregate([
      { $match: { deleted: { $ne: true } } },
      { $group: { _id: "$createdBy", count: { $sum: 1 } } },
      { $sort: { count: -1 } },
      {
        $lookup: {
          from: User.collection.name,
          localField: "_id",
          foreignField: "_id",
          as: "userInfo",
        },
      },
      { $unwind: "$userInfo" },
      { $match: { userInfo: { $exists: true } } },
      { $limit: 3 },
    ]);

    return topUsers.map((row: any) =>
      mapToDto(row._id, row.count, row.userInfo as IUser)
    );
  }
}

export default UserController;

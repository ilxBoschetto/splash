import type { NextApiRequest, NextApiResponse } from "next";
import dbConnect from "@lib/mongodb";
import withCors from "@lib/withCors";
import UserController from "@/controllers/userController";
import { TopUserDto } from "@/dtos/topUserDto";
import withLastRequest from "@/lib/withLastRequest";

const handler = async (req: NextApiRequest, res: NextApiResponse) => {
  await dbConnect();
  const { method } = req;

  try {
    switch (method) {
      case "GET": {
        const topUsers: TopUserDto[] = await UserController.getTopUsers();
        return res.status(200).json(topUsers);
      }
      default:
        return res.status(405).json({ error: "Method not allowed" });
    }
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: "Internal server error" });
  }
};

export default withCors(withLastRequest(handler));

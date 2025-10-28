// /pages/api/users/[id]/saved_fontanella_count.ts
import type { NextApiRequest, NextApiResponse } from "next";
import dbConnect from "@lib/mongodb";
import Fontanella from "@models/Fontanella";
import withCors from "@lib/withCors";

async function handler(req: NextApiRequest, res: NextApiResponse) {
  await dbConnect();

  const { id } = req.query;

  if (req.method !== "GET") {
    return res.status(405).end("Method Not Allowed");
  }

  try {
    const count = await Fontanella.countDocuments(
      { deleted: { $ne: true } },
      { createdBy: id as string }
    );
    res.status(200).json({ count });
  } catch (err: any) {
    res
      .status(500)
      .json({ error: "Failed to count user's created fontanelle" });
  }
}
export default withCors(handler);

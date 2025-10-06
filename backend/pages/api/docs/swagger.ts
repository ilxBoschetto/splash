import type { NextApiRequest, NextApiResponse } from "next";
import { swaggerSpec } from "@/lib/swaggerConfig";
import withCors from "@/lib/withCors";

async function handler(req: NextApiRequest, res: NextApiResponse) {
  res.setHeader("Content-Type", "application/json");
  res.status(200).json(swaggerSpec);
}

export default withCors(handler);

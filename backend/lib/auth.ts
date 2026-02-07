import User, { IUser } from "@/models/User";
import jwt from "jsonwebtoken";
import type { NextApiRequest } from "next";

const JWT_SECRET = process.env.JWT_SECRET || "super-secret-key";

export interface DecodedToken {
  userId: string;
  email?: string;
}

export function verifyToken(req: NextApiRequest): DecodedToken {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    console.log("Missing or invalid Authorization header");
    return false as any;
  }

  const token = authHeader.split(" ")[1];
  const decoded = jwt.verify(token, JWT_SECRET);

  return decoded as DecodedToken;
}

export async function getUserFromRequest(
  req: NextApiRequest
): Promise<IUser | null> {
  let user = verifyToken(req);
  const userModel = await User.findById(user.userId).select("-password");
  if (!userModel) return null;

  return userModel;
}

export async function generateJwtToken(userId: string, email?: string): Promise<string> {
  const payload = {
    userId,
    email,
  };
  return jwt.sign(payload, JWT_SECRET, { expiresIn: "10y" });
}

export type { IUser };

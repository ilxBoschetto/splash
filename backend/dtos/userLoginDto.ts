import mongoose from "mongoose";
import { IUser } from "@/lib/auth";

export class UserLoginDto {
  id: string;
  name: string;
  email: string;
  isAdmin?: boolean;
  googleId?: string;
  createdAt?: Date;

  constructor(data: {
    userId: mongoose.Types.ObjectId | string;
    user?: IUser;
  }) {
    const { userId, user } = data;
    this.id = typeof userId === "string" ? userId : userId.toHexString();
    this.name = user?.name ?? "-";
    this.email = user?.email ?? "-";
    this.googleId = user?.googleId;
    this.createdAt = user?.createdAt;
    if (user?.isAdmin !== undefined) {
      this.isAdmin = user.isAdmin;
    }
  }
}

/**
 * Funzione helper per creare rapidamente un DTO coerente.
 */
export const mapToUserDto = (
  userId: mongoose.Types.ObjectId | string,
  user?: IUser
): UserLoginDto => new UserLoginDto({ userId, user });

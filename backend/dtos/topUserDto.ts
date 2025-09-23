import { IUser } from "@/lib/auth";
import mongoose from "mongoose";

export class TopUserDto {
  userId: string;
  user?: IUser;
  count: number;

  constructor(data: { userId: mongoose.Types.ObjectId | string; user?: IUser; count: number }) {
    const { userId, user, count } = data;
    this.userId = typeof userId === "string" ? userId : userId.toHexString();
    this.user = user;
    this.count = count;
  }
}

export const mapToDto = (userId: mongoose.Types.ObjectId | string, count: number, user?: IUser) =>
  new TopUserDto({ userId, count, user });

import mongoose from "mongoose";
import { IUser } from "@/lib/auth";

export class TopUserDto {
  _id: string;
  name: string;
  email: string;
  count: number;

  constructor(data: {
    userId: mongoose.Types.ObjectId | string;
    user?: IUser;
    count: number;
  }) {
    const { userId, user, count } = data;
    this._id = typeof userId === "string" ? userId : userId.toHexString();
    this.name = user?.name ?? "-";
    this.email = user?.email ?? "-";
    this.count = count;
  }
}

export const mapToDto = (
  userId: mongoose.Types.ObjectId | string,
  count: number,
  user?: IUser
): TopUserDto => new TopUserDto({ userId, count, user });

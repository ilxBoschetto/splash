import { achievements } from "@/enum/achivements";


export const AchivementCount = async (): Promise<number> => {
  return achievements.length;
};

export const AchivementList = async (): Promise<any[]> => {
  return achievements;
};
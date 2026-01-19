// achievements.ts
export type Rank = {
  name: string;       // Rank name: Bronze, Silver, Gold
  threshold: number;  // Threshold to reach this rank
  points: number;     // Reward points
};

export type Achievement = {
  id: string;               // Unique ID
  name: string;             // Display name
  description: string;      // Description
  icon?: string;            // Optional icon URL
  ranks: Rank[];            // Array of ranks
  criteriaType: string;     // Action type: "comments_count", "likes_count", etc.
};

// Achievement list
export const achievements: Achievement[] = [
  {
    id: "fountain_creator",
    name: "Fountain Creator",
    description: "Add new fountains to the database",
    icon: "/icons/fountain_creator.png",
    criteriaType: "fountains_created",
    ranks: [
      { name: "Bronze", threshold: 1, points: 10 },
      { name: "Silver", threshold: 10, points: 20 },
      { name: "Gold", threshold: 50, points: 50 }
    ]
  },
  {
    id: "feedback_provider",
    name: "Reviewer",
    description: "Give likes or dislikes to fountains",
    icon: "/icons/feedback_provider.png",
    criteriaType: "feedback_given",
    ranks: [
      { name: "Bronze", threshold: 5, points: 5 },
      { name: "Silver", threshold: 25, points: 15 },
      { name: "Gold", threshold: 100, points: 50 }
    ]
  },
  {
    id: "error_reporter",
    name: "Reporter",
    description: "Report incorrect fountain information",
    icon: "/icons/error_reporter.png",
    criteriaType: "errors_reported",
    ranks: [
      { name: "Bronze", threshold: 1, points: 5 },
      { name: "Silver", threshold: 10, points: 15 },
      { name: "Gold", threshold: 25, points: 50 }
    ]
  },
  {
    id: "fountain_fan",
    name: "Fountain Fan",
    description: "Save fountains as favorites",
    icon: "/icons/fountain_fan.png",
    criteriaType: "fountains_favorited",
    ranks: [
      { name: "Bronze", threshold: 1, points: 5 },
      { name: "Silver", threshold: 10, points: 15 },
      { name: "Gold", threshold: 50, points: 50 }
    ]
  }
];

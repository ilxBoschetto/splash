export enum NotificationType {
  HOT_DAY_REMINDER = "HOT_DAY_REMINDER",
  ECO_REMINDER = "ECO_REMINDER",
  HYDRATION_NUDGE = "HYDRATION_NUDGE",
  WEEKEND_OUTDOOR = "WEEKEND_OUTDOOR",
  CITY_DISCOVERY = "CITY_DISCOVERY",
}

export type AppNotification = {
  type: NotificationType;
  title: string;
  body: string;
  minDaysBetweenSends: number;
};

export const NOTIFICATIONS_CATALOG: Record<NotificationType, AppNotification> = {
  [NotificationType.HOT_DAY_REMINDER]: {
    type: NotificationType.HOT_DAY_REMINDER,
    title: "Giornata calda ☀️",
    body: "Ricordati di idratarti. Apri l'app e trova una fontanella vicino a te 💧",
    minDaysBetweenSends: 14,
  },

  [NotificationType.ECO_REMINDER]: {
    type: NotificationType.ECO_REMINDER,
    title: "Fai bene all'ambiente 🌱",
    body: "Usare le fontanelle riduce la plastica. Continua così.",
    minDaysBetweenSends: 30,
  },

  [NotificationType.HYDRATION_NUDGE]: {
    type: NotificationType.HYDRATION_NUDGE,
    title: "Hai bevuto oggi?",
    body: "Un piccolo promemoria per prenderti cura di te 💧",
    minDaysBetweenSends: 14,
  },

  [NotificationType.WEEKEND_OUTDOOR]: {
    type: NotificationType.WEEKEND_OUTDOOR,
    title: "Weekend all'aperto?",
    body: "Se esci oggi, ricordati che puoi trovare acqua gratuita vicino a te.",
    minDaysBetweenSends: 21,
  },

  [NotificationType.CITY_DISCOVERY]: {
    type: NotificationType.CITY_DISCOVERY,
    title: "Conosci davvero la tua città?",
    body: "Le fontanelle raccontano il territorio. Apri la mappa e scoprile.",
    minDaysBetweenSends: 45,
  },
};

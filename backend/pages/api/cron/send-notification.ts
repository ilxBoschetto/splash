import {
  getDeviceNotifications,
  sendNotificationsToDeviceTokens,
} from "@/controllers/notificationController";
import {
  NOTIFICATIONS_CATALOG,
  NotificationType,
} from "@/enum/notifications.catalog";
import { log } from "@/helpers/logger";
import withCors from "@/lib/withCors";
import type { NextApiRequest, NextApiResponse } from "next";

const handler = async (req: NextApiRequest, res: NextApiResponse) => {
  log.info("Cron send-notification started");
  if (req.headers.authorization !== `Bearer ${process.env.CRON_SECRET}`) {
    return res.status(401).json({ error: "Unauthorized" });
  }

  log.info("Cron authorized");
  try {
    const notification =
      NOTIFICATIONS_CATALOG[NotificationType.HOT_DAY_REMINDER];

    const deviceTokens = await getDeviceNotifications();
    await sendNotificationsToDeviceTokens(
      deviceTokens.map((dt) => dt.deviceToken),
      notification.title,
      notification.body,
    );

    return res.status(200).json({ success: true });
  } catch (error) {
    console.error("Cron error", error);
    return res.status(500).json({ error: "Internal error" });
  }
};
export default withCors(handler);

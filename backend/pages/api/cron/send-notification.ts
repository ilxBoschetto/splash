import {
  getDeviceNotifications,
  sendNotificationsToDeviceTokens,
  updateLastNotificationSentAt,
} from "@/controllers/notificationController";
import {
  NOTIFICATIONS_CATALOG,
  NotificationType,
} from "@/enum/notifications.catalog";
import { log } from "@/helpers/logger";
import dbConnect from "@/lib/mongodb";
import withCors from "@/lib/withCors";
import type { NextApiRequest, NextApiResponse } from "next";

const handler = async (req: NextApiRequest, res: NextApiResponse) => {
  log.info("Cron send-notification started");
  if (req.headers.authorization !== `Bearer ${process.env.CRON_SECRET}`) {
    return res.status(401).json({ error: "Unauthorized" });
  }

  log.info("Cron authorized");
  try {
    dbConnect();
    const notificationTypes = Object.values(NotificationType);
    const randomType =
      notificationTypes[Math.floor(Math.random() * notificationTypes.length)];
    const notification = NOTIFICATIONS_CATALOG[randomType];

    log.info(`Sending random notification: ${notification.type}`);

    const deviceNotifications = await getDeviceNotifications(
      notification.minDaysBetweenSends,
    );
    const deviceTokens = deviceNotifications.map((dt) => dt.deviceToken);

    if (deviceTokens.length > 0) {
      await sendNotificationsToDeviceTokens(
        deviceTokens,
        notification.title,
        notification.body,
      );
      await updateLastNotificationSentAt(deviceTokens);
      log.info(`Sent notification to ${deviceTokens.length} devices`);
    } else {
      log.info("No devices eligible for notification today");
    }

    return res.status(200).json({ success: true, sentTo: deviceTokens.length });
  } catch (error) {
    console.error("Cron error", error);
    return res.status(500).json({ error: "Internal error" });
  }
};
export default withCors(handler);

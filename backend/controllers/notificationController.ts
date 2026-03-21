import {
  DeviceNotification,
  IDeviceNotification,
} from "@/models/DeviceNotification";
import { log } from "@/helpers/logger";
import { firebaseAdmin } from "@/lib/firebaseAdmin";

export const createDeviceTokenNotification = async (
  userId: string | null | undefined,
  deviceToken: string,
): Promise<IDeviceNotification> => {
  log.info(`Creazione notifica per device token di utente ${userId}`);
  if (!deviceToken) {
    throw new Error("deviceToken mancante");
  }
  const existingNotification = await DeviceNotification.findOne({
    deviceToken: deviceToken,
  });
  if (existingNotification) {
    log.info(`Notifica già esistente per device token ${deviceToken}`);
    existingNotification.userId = userId;
    await existingNotification.save();
    return existingNotification;
  }
  const notification = new DeviceNotification({
    userId: userId,
    deviceToken: deviceToken,
  });
  return await notification.save();
};

export const deleteDeviceTokenNotification = async (
  deviceToken: string,
): Promise<void> => {
  log.info(`Eliminazione notifica per device token ${deviceToken}`);
  await DeviceNotification.deleteOne({
    deviceToken: deviceToken,
  });
};

export const sendNotificationsToDeviceTokens = async (
  deviceTokens: string[],
  title: string,
  body: string,
): Promise<void> => {
  deviceTokens.forEach((deviceToken) => {
    sendNotificationsToDeviceToken(deviceToken, title, body);
  });
};

export const sendNotificationsToDeviceToken = async (
  deviceToken: string,
  title: string,
  body: string,
): Promise<void> => {
  log.info(`Invio notifica a device token ${deviceToken}`);
  try {
    await firebaseAdmin.messaging().send({
      token: deviceToken,
      notification: {
        title: title,
        body: body,
      },
    });
  } catch (error) {
    log.error(`Errore invio notifica a device token ${deviceToken}, with error: ${error}`);
  }

};

export const updateLastNotificationSentAt = async (
  deviceTokens: string[],
): Promise<void> => {
  log.info(`Aggiornamento lastNotificationSentAt per ${deviceTokens.length} device tokens`);
  await DeviceNotification.updateMany(
    { deviceToken: { $in: deviceTokens } },
    { $set: { lastNotificationSentAt: new Date() } },
  );
};

export const getDeviceNotifications = async (
  minDaysThreshold?: number,
): Promise<IDeviceNotification[]> => {
  if (minDaysThreshold !== undefined) {
    const thresholdDate = new Date();
    thresholdDate.setDate(thresholdDate.getDate() - minDaysThreshold);
    return await DeviceNotification.find({
      $or: [
        { lastNotificationSentAt: { $lte: thresholdDate } },
        { lastNotificationSentAt: { $exists: false } },
        { lastNotificationSentAt: null },
      ],
    });
  }
  return await DeviceNotification.find({});
};

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
  await firebaseAdmin.messaging().send({
    token: deviceToken,
    notification: {
      title: title,
      body: body,
    },
  });
};

export const getDeviceNotifications = async (): Promise<
  IDeviceNotification[]
> => {
  return await DeviceNotification.find({});
};

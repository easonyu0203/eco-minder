import * as admin from "firebase-admin";

export interface NotificationParams {
  targetToken: string;
  title: string;
  body: string;
}

export async function sendNotification({
  targetToken,
  title,
  body,
}: NotificationParams) {
  const message = {
    token: targetToken,
    notification: {
      title,
      body,
    },
  };

  try {
    const response = await admin.messaging().send(message);
    console.log("Notification sent successfully:", response);
  } catch (error) {
    console.log("Error sending notification:", error);
  }
}

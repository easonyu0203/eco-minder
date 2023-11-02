import * as admin from "firebase-admin";
import { EcoMinder, MyUser } from "./types";
import { FieldValue } from "firebase-admin/firestore";

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

export async function createEcoMinderNUserIfNotExist(eco_minder_id: string) {
  const db = await admin.firestore();
  const eco_minder_exit = (
    await db.collection("eco_minders").doc(eco_minder_id).get()
  ).exists;
  if (eco_minder_exit) {
    return;
  }

  const ecoMinder: EcoMinder = {
    create_at: FieldValue.serverTimestamp(),
    eco_minder_id: eco_minder_id,
    mode: "mild",
    name: "My Eco Minder",
    uid: "ABLICHj43wZpwIpOgnDDg7dz5Bz1",
  };
  await db.collection("eco_minders").doc(eco_minder_id).set(ecoMinder);
  const myUser: MyUser = {
    eco_minder_id: eco_minder_id,
    email: "test_user_email",
    name: "eason",
    token:
      "f8hBI9qqmkshmXnh3rTcDe:APA91bEZfXU8OLiUeR053mZoXYZBG97Cj3rQfZZNr1Ku4yCXuu2QeR-fr090TT9FzT2qZsiPIqPClahiwxzFFjM_PnXqHp0whK16DT7H-DDqdGpauzKMcGR2w8B3FIa-qry2IFkRqkEL",
    notification_mode: "medium",
    uid: "ABLICHj43wZpwIpOgnDDg7dz5Bz1",
  };
  await db.collection("users").doc("ABLICHj43wZpwIpOgnDDg7dz5Bz1").set(myUser);
}

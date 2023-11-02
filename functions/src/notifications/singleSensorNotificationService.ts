import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { DataPoint, EcoMinder, MyUser } from "../types";
import { sendNotification } from "../utils";
import { Timestamp } from "@google-cloud/firestore";

const AIR_POLLUTE_THRESHOLD = 300;
const LIGHT_THRESHOLD = 350;
const NOTIFICATION_INTERVAL = 5 * 60 * 1000;
const db = admin.firestore();

async function getUserAndEcoMinder(
  dataPoint: DataPoint<string>
): Promise<{ ecoMinder: EcoMinder; user: MyUser } | null> {
  const ecoMinderDoc = await db
    .collection("eco_minders")
    .doc(dataPoint.eco_minder_id)
    .get();
  if (!ecoMinderDoc.exists) return null;

  const ecoMinder = ecoMinderDoc.data()! as EcoMinder;
  const userDoc = await db.collection("users").doc(ecoMinder.uid).get();
  const user = userDoc.data() as MyUser | undefined;

  if (!userDoc.exists || !user?.token || user?.notification_mode == "none")
    return null;

  return { ecoMinder, user };
}

async function shouldSendNotification(
  user: MyUser,
  type: string
): Promise<boolean> {
  const lastNotificationSent = await db
    .collection("notification_states")
    .doc(user.uid)
    .get();

  if (
    !lastNotificationSent.exists ||
    lastNotificationSent.data()?.type !== type
  )
    return true;

  const now = Date.now();
  const lastSent = lastNotificationSent.data()!.timestamp.toDate().getTime();

  return now - lastSent >= NOTIFICATION_INTERVAL;
}

async function updateNotificationState(uid: string, type: string) {
  await db.collection("notification_states").doc(uid).set({
    timestamp: Timestamp.now(),
    type: type,
  });
}

export const airPolluteNotificationService = functions
  .region("australia-southeast1")
  .firestore.document("iaq_sensor/{sensorId}")
  .onCreate(async (snapshot, context) => {
    const dataValue = Number(snapshot.data().data);
    if (dataValue < AIR_POLLUTE_THRESHOLD) return;

    const { ecoMinder, user } =
      (await getUserAndEcoMinder(snapshot.data() as DataPoint<string>)) || {};
    if (!ecoMinder || !user) return;

    if (await shouldSendNotification(user, "air_pollute")) {
      await sendAirPolluteNotification({ token: user.token! });
      await updateNotificationState(user.uid, "air_pollute");
    }
  });

export const lightNotificationService = functions
  .region("australia-southeast1")
  .firestore.document("light_sensor/{sensorId}")
  .onCreate(async (snapshot, context) => {
    const dataValue = Number(snapshot.data().data);
    if (dataValue < LIGHT_THRESHOLD) return;

    const { ecoMinder, user } =
      (await getUserAndEcoMinder(snapshot.data() as DataPoint<string>)) || {};
    if (!ecoMinder || !user) return;

    if (await shouldSendNotification(user, "light")) {
      await sendLightNotification({ token: user.token! });
      await updateNotificationState(user.uid, "light");
    }
  });

async function sendAirPolluteNotification({ token }: { token: string }) {
  console.log("sending air pollute notification...");
  await sendNotification({
    targetToken: token,
    title: "🌬️ Fresh Air Needed!",
    body: "Hey there! 😊 The air's a bit stuffy. How about opening a window for some fresh air? 🌳🍃",
  });
}

async function sendLightNotification({ token }: { token: string }) {
  console.log("sending light notification...");
  await sendNotification({
    targetToken: token,
    title: "💡 Too Bright!",
    body: "How about adjust lights or rearrange EcoMinder? 💡🌟",
  });
}
